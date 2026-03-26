# Implementation Plan: Worktree Lifecycle

## Overview

3 phases: plan 스킬에 Execution Strategy 결정 로직 추가, implement 스킬에 worktree/direct 모드 + .progress.md + 완료 액션 추가, plan-writer 에이전트 참조 추가.

## Spec Reference

`docs/specs/2026-03-26-worktree-lifecycle-design.md`

---

## Phase 1: /plan 스킬 — Execution Strategy 결정 (2 files)

이 Phase 완료 후 검증: `grep -c "Execution Strategy" skills/plan/SKILL.md skills/plan/references/plan-format.md` — 각 파일에서 1 이상

### Step 1.1: plan format 템플릿에 Execution Strategy 섹션 추가

**File: `skills/plan/references/plan-format.md`** (수정)

- Action: Plan Format Template의 `## Success Criteria` 뒤에 `## Execution Strategy` 섹션 추가. Worked Example에도 해당 섹션 추가.
- Why: /implement가 plan에서 실행 전략을 읽어야 하므로 템플릿에 포함되어야 함
- Dependencies: None
- Risk: Low

Execution Strategy 섹션 형식:
```markdown
## Execution Strategy
- type: direct | worktree
- branch_prefix: feature/<topic>
```

### Step 1.2: /plan SKILL.md에 전략 결정 가이드 추가

**File: `skills/plan/SKILL.md`** (수정)

- Action: Planning Process 섹션 뒤에 "Execution Strategy Determination" 섹션 추가. 판단 기준 테이블 포함: 단일 plan → direct, 다중 plan → worktree.
- Why: plan-writer 에이전트가 spec 규모를 분석하여 전략을 결정해야 함
- Dependencies: Step 1.1
- Risk: Low

포함 내용:
- 판단 기준 테이블 (spec의 Section 1 참조)
- 다중 plan 파일 네이밍 규칙: `<date>-<topic>-phase<N>-plan.md`
- 사용자 오버라이드 가능 안내

---

## Phase 2: /implement 스킬 — Worktree 라이프사이클 (1 file)

이 Phase 완료 후 검증: `grep -c "Direct Mode\|Worktree Mode\|Continue Mode\|Phase Transition\|\.progress\.md" skills/implement/SKILL.md` — 5 이상

### Step 2.1: Input 섹션 수정 + Execution Strategy Handling 추가

**File: `skills/implement/SKILL.md`** (수정)

- Action: 기존 Input 섹션에 `--continue`/`-c` 플래그 설명 추가. 기존 Process 섹션 앞에 "Execution Strategy Handling" 섹션 추가 (plan에서 type 읽기 → direct/worktree 분기).
- Why: /implement의 진입점을 확장하여 두 가지 모드와 continue를 지원
- Dependencies: Phase 1
- Risk: Low

기존 Process/Context Curation/Error Handling/Red Flags 섹션은 유지한다. 이 step은 Input과 분기 로직만 추가.

### Step 2.2: Direct Mode 섹션 추가

**File: `skills/implement/SKILL.md`** (수정)

- Action: "Direct Mode" 섹션 추가. `feature/<topic>` 브랜치 생성 → 기존 SDD+TDD 프로세스 실행 → 완료 액션 (PR 생성/브랜치 유지/폐기).
- Why: 소규모 단일 plan의 실행 경로 정의
- Dependencies: Step 2.1
- Risk: Low

### Step 2.3: Worktree Mode 섹션 추가

**File: `skills/implement/SKILL.md`** (수정)

- Action: "Worktree Mode" 섹션 추가. 브랜치 계층 (main → spec 브랜치 → phase 브랜치), worktree 생성 (`/using-worktree` SKILL.md 참조), phase별 브랜치 전환, 완료 액션 (PR 생성/PR+다음phase/유지/폐기), 마지막 phase 시 최종 PR 안내 + worktree 정리.
- Why: 대규모 다중 plan의 실행 경로 정의
- Dependencies: Step 2.1
- Risk: Medium — 가장 복잡한 섹션

worktree 생성 절차는 `/using-worktree`의 SKILL.md를 참조한다고 명시. .worktrees/ gitignore 검증, 프로젝트 셋업 자동 감지, 베이스라인 테스트 실행을 포함.

### Step 2.4: Phase Transition 섹션 추가

**File: `skills/implement/SKILL.md`** (수정)

- Action: "Phase Transition" 섹션 추가. 이전 phase merge 여부 확인, merged → spec 브랜치에서 pull → 새 phase 브랜치, not merged → 경고 + 선택지 (이전 브랜치 기반/대기).
- Why: 다중 plan의 phase 간 전환 로직 정의
- Dependencies: Step 2.3
- Risk: Low

### Step 2.5: .progress.md Management 섹션 추가

**File: `skills/implement/SKILL.md`** (수정)

- Action: ".progress.md Management" 섹션 추가. 위치, 생성 시점, 업데이트 시점, 자동 커밋+푸시, 파일 구조 (spec Section 4 참조). 커밋 메시지: `chore: update .progress.md`.
- Why: 세션 연속성을 위한 진행 상태 파일 관리
- Dependencies: Step 2.1
- Risk: Low

### Step 2.6: Continue Mode 섹션 추가

**File: `skills/implement/SKILL.md`** (수정)

- Action: "Continue Mode (`--continue` / `-c`)" 섹션 추가. .progress.md 읽기 → in_progress phase 찾기 → worktree/direct에 따라 환경 복원 → 프로젝트 셋업 → 재개. 동일 머신에서 worktree가 이미 존재하는 경우: 기존 worktree를 그대로 사용 (재생성하지 않음).
- Why: 다른 머신(또는 같은 머신의 새 세션)에서 작업 이어받기
- Dependencies: Step 2.5
- Risk: Low

### Step 2.7: Red Flags 섹션 업데이트

**File: `skills/implement/SKILL.md`** (수정)

- Action: 기존 Red Flags 섹션에 추가: Phase 전환 없이 다음 phase plan 실행 금지, .progress.md 업데이트 없이 Step 진행 금지, worktree 모드에서 main에서 직접 작업 금지.
- Why: 새로 추가된 기능의 안전 규칙
- Dependencies: Steps 2.2-2.6
- Risk: Low

---

## Phase 3: 에이전트 + 스킬 참조 업데이트 (1 file)

이 Phase 완료 후 검증: `grep "Execution Strategy" agents/plan-writer.md` — 1건 이상

### Step 3.1: plan-writer 에이전트에 전략 결정 참조 추가

**File: `agents/plan-writer.md`** (수정)

- Action: "Plan Format & References" 섹션의 참조 목록에 "Execution Strategy determination guide in `skills/plan/SKILL.md`" 추가.
- Why: plan-writer가 plan 작성 시 전략 결정을 포함하도록 유도
- Dependencies: Step 1.2
- Risk: Low

Note: `/using-worktree/SKILL.md`는 변경하지 않는다. `/implement`가 참조만 하면 되며, `/using-worktree` 자체는 독립 스킬로서 현재 내용 그대로 유지한다.

---

## Testing Strategy

이 plan의 변경은 모두 마크다운 스킬/에이전트 파일 수정이다. 코드 변경이 아니므로 단위 테스트나 통합 테스트는 해당하지 않는다.

검증 방법:
- Phase별 grep 기반 검증 (각 Phase 상단에 명시)
- 수정 후 파일 내 내부 참조 일관성 확인 (깨진 참조 없음)
- 최종적으로 사람이 스킬 파일을 읽고 플로우가 논리적으로 맞는지 확인

---

## Risks & Mitigations

- **Risk**: /implement SKILL.md가 너무 커질 수 있음 (현재 111줄 + 대량 추가)
  - Mitigation: Step별로 분리하여 증분 추가. 최종 크기 확인 후 500줄 초과 시 `skills/implement/references/`로 분리.
- **Risk**: .progress.md 자동 커밋이 git history를 오염시킬 수 있음
  - Mitigation: 커밋 메시지를 `chore: update .progress.md`로 통일하여 `git log --grep` 필터링 가능
- **Risk**: --continue 시 .progress.md와 실제 코드 상태 불일치
  - Mitigation: Continue Mode에 상태 검증 단계 포함 (Step 2.6)
- **Risk**: 동일 머신에서 --continue 시 worktree가 이미 존재
  - Mitigation: Continue Mode에서 기존 worktree 감지 → 재사용 (Step 2.6에 명시)

## Success Criteria

- [ ] `grep "Execution Strategy" skills/plan/references/plan-format.md` — match found
- [ ] `grep "Execution Strategy Determination" skills/plan/SKILL.md` — match found
- [ ] `grep -c "Direct Mode\|Worktree Mode\|Continue Mode\|Phase Transition\|progress\.md" skills/implement/SKILL.md` — 5 이상
- [ ] `grep "Execution Strategy" agents/plan-writer.md` — match found

## Execution Strategy
- type: direct
- branch_prefix: feature/worktree-lifecycle
