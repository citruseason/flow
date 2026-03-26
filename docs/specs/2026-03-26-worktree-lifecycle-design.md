# Worktree Lifecycle Design

## Overview

spec 기반 개발에서 worktree의 전체 라이프사이클(생성 → 작업 → phase 전환 → 완료 → 정리)을 설계한다. /plan 단계에서 실행 전략(direct/worktree)을 결정하고, /implement가 이를 기반으로 브랜치 관리, worktree 관리, 세션 연속성을 자동 처리한다.

## Goals

- /plan이 spec 규모에 따라 실행 전략(direct/worktree)을 결정
- spec 1 : worktree 1 매핑 — worktree 안에서 phase별 브랜치 전환
- 브랜치 계층: main → spec 브랜치 → phase 브랜치
- 세션 연속성 — .progress.md를 git에 커밋하여 다른 머신에서 이어받기
- 완료 액션 — PR 생성, 다음 phase 전환, 정리를 /implement가 제안

## Non-Goals

- 포트 관리 (제거됨)
- 병렬 worktree 관리 (spec당 1 worktree)
- 자동 merge (사람이 GitHub에서 merge)

---

## 1. /plan의 실행 전략 결정

/plan이 spec을 읽고 plan을 생성할 때, 규모를 분석하여 실행 전략을 plan 문서 하단에 포함한다.

### 판단 기준

| 조건 | 전략 | 이유 |
|------|------|------|
| 단일 plan | `direct` | 브랜치만으로 충분, phase 브랜치 없음 |
| 다중 plan (2개 이상) | `worktree` | 격리 필요, phase별 브랜치 + PR |
| spec에서 명시적으로 병렬 작업 언급 | `worktree` | 격리 필수 |

**Direct 모드는 항상 단일 plan이다.** 다중 plan이 생성되면 자동으로 worktree 모드가 된다. Direct 모드에서는 phase 브랜치가 존재하지 않는다.

사용자가 오버라이드 가능 (direct ↔ worktree 변경).

### Plan 문서 Execution Strategy 섹션

```markdown
## Execution Strategy
- type: direct | worktree
- branch_prefix: feature/<topic>
```

다중 plan일 경우 plan 파일 네이밍: `<date>-<topic>-phase<N>-plan.md`

---

## 2. 브랜치 계층 구조

### Worktree 모드 (대규모/다중 plan)

```
main
  └── feature/<topic>                       ← spec 브랜치 (worktree에 체크아웃)
        ├── feature/<topic>/phase1          → PR → merge into spec 브랜치
        ├── feature/<topic>/phase2          → PR → merge into spec 브랜치
        ├── ...
        └── feature/<topic>/phaseN          → PR → merge into spec 브랜치

  모든 phase 완료 후:
  feature/<topic> → PR → merge into main
```

- **spec 브랜치**: main에서 분기. worktree가 이 브랜치를 체크아웃.
- **phase 브랜치**: spec 브랜치에서 분기. phase별 작업 단위.
- **phase PR**: phase 브랜치 → spec 브랜치로 merge.
- **최종 PR**: spec 브랜치 → main. 전체 기능이 한 PR로 보임.

### Direct 모드 (소규모/단일 plan)

```
main
  └── feature/<topic>                       ← 직접 작업
        → PR → merge into main
```

phase 브랜치 없이 spec 브랜치에서 직접 작업. 완료 후 main으로 PR.

---

## 3. /implement 실행 흐름

### 3.1 신규 실행

```
/implement docs/plans/<topic>-plan.md
  또는
/implement docs/plans/<topic>-phase1-plan.md
```

1. Plan 읽기 → Execution Strategy 확인
2. .progress.md 확인 → 없으면 신규 생성
3. 전략에 따라 분기:

**Direct 모드:**
```
1. feature/<topic> 브랜치 생성
2. SDD + TDD로 구현
3. 완료 액션 제시
4. .progress.md 업데이트 + 커밋
```

**Worktree 모드:**
```
1. feature/<topic> spec 브랜치 생성
2. .worktrees/<topic> worktree 생성 (spec 브랜치 체크아웃)
3. feature/<topic>/phase1 브랜치 생성
4. SDD + TDD로 구현
5. 완료 액션 제시
6. .progress.md 업데이트 + 커밋
```

### 3.2 이어받기 (다른 머신)

```
/implement --continue
/implement -c
```

`--continue` (또는 `-c`)는 plan 경로 대신 전달되는 인자이다. `/implement`가 인자를 파싱하여 plan 경로인지 `--continue`/`-c` 플래그인지 구분한다.

1. `docs/plans/.progress.md` 읽기
2. `in_progress`인 phase 찾기
3. 해당 plan 파일 읽기
4. 사용자에게 재개 확인: "Phase N, Step M부터 이어서 진행할까요?"
5. worktree 모드면:
   ```bash
   # remote에서 최신 상태 가져오기
   git fetch origin
   # spec 브랜치 기반 worktree 생성
   git worktree add .worktrees/<topic> feature/<topic>
   # worktree 안에서 phase 브랜치로 전환
   cd .worktrees/<topic>
   git checkout feature/<topic>/phaseN
   ```
   direct 모드면:
   ```bash
   git fetch origin
   git checkout feature/<topic>
   ```
6. 프로젝트 셋업 실행 (의존성 설치 등)
7. 완료된 Step은 건너뛰고 다음 Step부터 시작

**전제:** /implement는 실행 중 phase 브랜치를 remote에 푸시한다. .progress.md 커밋 시 함께 푸시되므로, 다른 머신에서 브랜치와 진행상황 모두 접근 가능하다.

### 3.3 Phase 전환

Phase N 완료 후 Phase N+1 시작:

```
1. Phase N의 phase 브랜치에서 PR 생성 (→ spec 브랜치)
2. .progress.md 업데이트 (phase N: pr_created)
3. 사용자가 PR merge 후:
   /implement docs/plans/<topic>-phase(N+1)-plan.md
4. spec 브랜치로 checkout + pull
5. feature/<topic>/phase(N+1) 브랜치 생성
6. 구현 시작
```

Phase N이 아직 merge 안 됐을 때 Phase N+1 시작 시:
- 경고: "Phase N PR이 아직 merge되지 않았습니다."
- 선택지:
  a) Phase N 브랜치 기반으로 Phase N+1 브랜치 생성 (merge 전 선행 개발). 이 경우 `feature/<topic>/phaseN`에서 `feature/<topic>/phase(N+1)`을 분기한다. Phase N이 나중에 merge되면 Phase N+1을 spec 브랜치에 rebase할 수 있다. .progress.md에 `base: feature/<topic>/phaseN` 으로 기록한다.
  b) 대기 (merge 후 다시 호출)

---

## 4. .progress.md — 세션 연속성

### 위치

`docs/plans/.progress.md` (git tracked)

### 생성 시점

`/implement` 첫 실행 시 자동 생성.

### 업데이트 시점

- Step 완료마다 current_step 업데이트
- Phase 완료 시 phase status 업데이트 + PR 번호 기록
- 매 업데이트마다 자동 커밋 + 푸시

### 파일 구조

```markdown
# Execution Progress

## Context
- spec: docs/specs/2026-03-26-<topic>-design.md
- strategy: worktree | direct
- branch_prefix: feature/<topic>
- created: 2026-03-26
- last_updated: 2026-03-28

## Phases

### Phase 1: <phase name>
- plan: docs/plans/2026-03-26-<topic>-phase1-plan.md
- branch: feature/<topic>/phase1
- status: merged
- pr: #12
- steps: 8/8

### Phase 2: <phase name>
- plan: docs/plans/2026-03-26-<topic>-phase2-plan.md
- branch: feature/<topic>/phase2
- status: in_progress
- steps: 4/8
- current_step: "Step 2.5: <step description>"

### Phase 3: <phase name>
- plan: docs/plans/2026-03-26-<topic>-phase3-plan.md
- status: pending
```

### 단일 plan (direct 모드)

```markdown
# Execution Progress

## Context
- spec: docs/specs/2026-03-26-auth-design.md
- strategy: direct
- branch_prefix: feature/auth
- created: 2026-03-26
- last_updated: 2026-03-26

## Progress
- plan: docs/plans/2026-03-26-auth-plan.md
- branch: feature/auth
- status: in_progress
- steps: 3/5
- current_step: "Step 1.4: Add JWT middleware"
```

---

## 5. 완료 액션

Phase의 모든 Step 완료 시 `/implement`가 선택지 제시.

### Direct 모드

```
구현 완료.
  1) PR 생성 (feature/<topic> → main)
  2) 브랜치 유지
  3) 폐기
```

### Worktree 모드 — 중간 phase

```
Phase N 완료.
  1) PR 생성 (feature/<topic>/phaseN → feature/<topic>)
  2) PR 생성 + 다음 phase 시작
  3) worktree 유지
  4) 폐기
```

### Worktree 모드 — 마지막 phase

```
마지막 Phase 완료.
  1) PR 생성 (feature/<topic>/phaseN → feature/<topic>)
  2) worktree 유지
  3) 폐기

모든 phase PR merge 후:
  → 최종 PR (feature/<topic> → main) 생성 안내
  → worktree 정리 안내
```

### PR 생성

```bash
gh pr create \
  --base feature/<topic> \
  --head feature/<topic>/phaseN \
  --title "Phase N: <phase name>" \
  --body "<summary from .progress.md>"
```

### Worktree 정리

모든 phase 완료 + 최종 PR merge 후:

```bash
git worktree remove .worktrees/<topic>
```

.progress.md의 status를 `completed`로 업데이트.

---

## 6. /using-worktree 스킬의 역할 변경

현재 `/using-worktree`는 독립 스킬로 유지하되, 일반 워크플로에서는 `/implement`가 내부적으로 worktree를 관리한다.

### /using-worktree 유지하는 경우

- `/implement` 없이 수동 작업할 때
- spec/plan 없이 격리 작업이 필요할 때
- `/implement`가 아닌 다른 스킬에서 worktree가 필요할 때

### /implement가 내부적으로 처리하는 것

- worktree 생성/제거
- 브랜치 생성/전환
- .progress.md 관리
- 완료 액션

`/implement`는 worktree 생성 시 `/using-worktree`의 SKILL.md를 참조하여 동일한 절차를 따른다: .worktrees/ gitignore 검증, worktree 생성, 프로젝트 셋업 자동 감지, 베이스라인 테스트 실행. 코드 중복이 아닌 참조 관계이다.

---

## 7. 스킬 영향 범위

| 스킬 | 변경 |
|------|------|
| /plan | Execution Strategy 섹션 추가 (type, branch_prefix) |
| /implement | worktree/direct 분기, phase 전환, .progress.md 관리, 완료 액션 |
| /using-worktree | 독립 스킬로 유지, /implement가 내부 로직 재사용 |
| /sdd | 변경 없음 (하위 실행 패턴) |
| /tdd | 변경 없음 (하위 개발 방법론) |
| /code-review | 변경 없음 |

## Success Criteria

- [ ] /plan이 spec 규모에 따라 direct/worktree 전략을 결정하고 plan에 포함
- [ ] /implement가 direct 모드에서 브랜치 생성 → 구현 → PR 생성까지 처리
- [ ] /implement가 worktree 모드에서 spec 브랜치 + phase 브랜치 계층 관리
- [ ] phase 전환 시 이전 phase merge 여부 확인 + 브랜치 전환
- [ ] .progress.md가 매 Step/Phase 완료 시 업데이트되고 커밋됨
- [ ] 다른 머신에서 /implement --continue (-c)로 진행상황 이어받기 가능
- [ ] worktree 정리가 모든 phase 완료 후 안내됨
