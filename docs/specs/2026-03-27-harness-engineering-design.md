# Harness Engineering Integration Design

## Overview

OpenAI의 [Harness Engineering](https://openai.com/index/harness-engineering/) 글에서 제시한 에이전트 우선 개발 패턴을 Flow 플러그인에 통합한다. 에이전트가 안정적으로 작업할 수 있는 환경(harness)을 설계하고, 지식 베이스 관리, 아키텍처 강제, 품질 스코어링, 문서 최신 상태 유지를 자동화한다.

기존 워크플로(spec → plan → implement → code-review)를 전면 재설계하여 meeting → design-doc → implement → lint 구조로 전환한다.

## Motivation

- 에이전트가 코드베이스에서 직접 추론할 수 있는 구조화된 지식 베이스 필요
- 아키텍처/컨벤션 규칙을 기계적으로 강제하여 에이전트 출력 품질 보장
- 문서와 코드의 괴리를 자동 감지하고 해소
- 토픽 단위 칸반으로 작업 상태를 추적하여 세션 간 연속성 확보

---

## Workflow

### 새 워크플로

```
/harness-init → /meeting → /design-doc → /implement → /lint
```

| 단계 | 스킬 | 산출물 | 핵심 |
|------|------|--------|------|
| 0 | `/harness-init` | harness/ + lint-* 스킬 | 코드베이스 분석, 지식 베이스 스캐폴딩, 린트 스킬 생성 |
| 1 | `/meeting` | Meeting Log → CPS → PRD | 대화를 통한 요구사항 정의. 반복 실행/업데이트 가능. 가장 중요한 단계 |
| 2 | `/design-doc` | Spec, Blueprint, Architecture, Code-Develop-Plan | PRD 기반 설계 문서 생성. PRD 변경 시 연동 업데이트 |
| 3 | `/implement` | 실제 코드 | 완성된 문서들을 기반으로 자율 개발 실행 |
| 4 | `/lint` | 검증 리포트 | 요구사항 충족 검증 + lint-* 스킬 통과 여부 |

### 유기적 연동 원칙

각 단계는 독립적이 아니라 서로 참조하고 영향을 주는 관계이다:

- **상향 전파** — `/implement` 중 설계 문제 발견 시 design-doc으로 회귀, 요구사항 문제면 `/meeting`까지 거슬러 올라감
- **하향 전파** — `/meeting`에서 PRD 변경 시 영향받는 design-doc → code-dev-plan → 진행 중인 implement 스텝까지 영향도 분석
- **횡단 참조** — 모든 문서는 같은 토픽 내 다른 문서를 참조, lint-* 스킬 규칙도 architecture.md를 참조
- **kanban 연동** — 변경 발생 시 각 스킬이 kanban.json을 읽고, 영향받는 하위 스텝을 backlog로 되돌린 뒤 저장한다. 별도 watcher 프로세스 없이, 스킬 실행 시점에 에이전트가 판단하여 적용한다

### 자율 실행 원칙 (implement ~ lint)

- `/implement` 시작 후 `/lint` 완료까지 사용자 개입 없이 자율 진행
- 에스컬레이션이 필요한 경우에만 사용자에게 보고 (설계와 심각한 불일치, 해결 불가능한 블로커)
- 세션 중단 시 토픽 `kanban.json`에서 `in_progress` 스텝을 찾아 이어서 진행
- lint까지 전부 PASS하면 최종 결과만 사용자에게 리포트

---

## Harness 지식 베이스 구조

```
harness/
├── index.md                          ← 하네스 지식 베이스 목차
├── kanban.json                       ← 전체 토픽 상태 (조감도)
├── topics/
│   └── <topic>/
│       ├── kanban.json               ← 토픽 세부 진행 상태
│       ├── meetings/
│       │   ├── YYYY-MM-DD-initial.md
│       │   └── YYYY-MM-DD-followup.md
│       ├── cps.md
│       ├── prd.md
│       ├── spec.md
│       ├── blueprint.md
│       ├── architecture.md
│       └── code-dev-plan.md
├── quality-score.md                  ← 도메인별 품질 점수
├── observability.md                  ← 로깅/메트릭/에러 형식 가이드
├── golden-rules.md                   ← 핵심 불변 규칙
├── tech-debt.md                      ← 기술 부채 추적
└── references/                       ← 외부 참조 문서
```

### 칸반 관리

**루트 `kanban.json`** — 전체 토픽 조감도:
```json
{
  "topics": {
    "user-auth": { "phase": "implement", "last_updated": "2026-03-28" },
    "payment": { "phase": "meeting", "last_updated": "2026-03-27" }
  }
}
```

**토픽 `kanban.json`** — 세부 스텝 추적:
```json
{
  "topic": "user-auth",
  "phase": "implement",
  "last_updated": "2026-03-28",
  "meetings": [
    { "date": "2026-03-25", "file": "meetings/2026-03-25-initial.md" },
    { "date": "2026-03-26", "file": "meetings/2026-03-26-followup.md" }
  ],
  "steps": {
    "done": [
      { "id": "meeting", "name": "미팅" },
      { "id": "cps", "name": "CPS 작성" },
      { "id": "prd", "name": "PRD 작성" },
      { "id": "spec", "name": "Spec 작성" },
      { "id": "blueprint", "name": "Blueprint 작성" },
      { "id": "architecture", "name": "Architecture 작성" },
      { "id": "code-dev-plan", "name": "Code Dev Plan 작성" },
      { "id": "impl-phase-1", "name": "인증 모듈 구현" }
    ],
    "in_progress": [
      { "id": "impl-phase-2", "name": "세션 관리 구현" }
    ],
    "backlog": [
      { "id": "impl-phase-3", "name": "권한 체계 구현" },
      { "id": "lint", "name": "린트 검증" }
    ]
  }
}
```

---

## Skill: `/harness-init`

### 실행 흐름

```
/harness-init
    ↓
[harness-initializer] 코드베이스 분석
  ├── 프로젝트 구조 (디렉터리, 진입점, 설정 파일)
  ├── 기술 스택 감지 (언어, 프레임워크, 라이브러리)
  ├── 아키텍처 패턴 추출 (레이어링, 의존성 방향)
  └── 코드 컨벤션 감지 (네이밍, 포맷, 에러 처리)
    ↓
분석 결과 사용자에게 제시 & 확인
    ↓
harness/ 스캐폴딩
    ↓
사용자 프로젝트의 .claude/skills/ 에 lint-* 스킬 생성 (Flow 플러그인 내부가 아닌 호스트 프로젝트에 생성)
  ├── lint-architecture/      ← 항상 생성
  ├── lint-code-convention/   ← 항상 생성
  └── lint-{framework}/       ← 감지된 스택에 따라 선택적
    ↓
각 lint 스킬의 references/에 분석된 규칙 파일 생성
    ↓
사용자에게 생성 결과 리뷰 요청 → 승인 시 git commit
```

### 재실행 시

- 현재 코드베이스와 기존 harness/ 비교
- 변경된 부분만 업데이트 제안
- 사용자 커스터마이즈 내용 보존
- lint-* 스킬의 references/ 축적분 유지

---

## Skill: `/meeting`

가장 중요한 단계. 대화를 통해 요구사항을 정의하고 CPS/PRD를 생성한다.

### 신규 실행: `/meeting "topic-name"`

```
토픽 디렉터리 생성 (harness/topics/<topic>/)
    ↓
[meeting-facilitator] 대화를 통해 요구사항 탐색
  ├── 프로젝트 컨텍스트 파악
  ├── 한 번에 하나씩 질문
  ├── 목적, 제약, 성공 기준 이해
  └── 2-3가지 접근 방식 제안
    ↓
Meeting Log 저장 (meetings/YYYY-MM-DD-<session>.md)
    ↓
CPS 문서 자동 생성 (cps.md)
  ├── Context: 배경과 현재 상태
  ├── Problem: 해결할 문제 정의
  └── Solution: 합의된 해결 방향
    ↓
PRD 자동 생성 (prd.md)
  ├── 기능 요구사항
  ├── 비기능 요구사항
  ├── 사용자 시나리오
  └── 수용 기준
    ↓
[meeting-reviewer] CPS/PRD 검증 (최대 3회)
  검증 기준:
  - CPS: Context가 현재 프로젝트 상태를 정확히 반영하는지, Problem이 명확하고 측정 가능한지, Solution이 Problem을 직접 해결하는지
  - PRD: 모든 CPS Solution 항목이 기능 요구사항으로 전환되었는지, 수용 기준이 검증 가능한지, 기능/비기능 요구사항 간 모순이 없는지, 미확인 사항이 명시적으로 표기되었는지
    ↓
사용자 리뷰 (CPS → PRD 순서로 확인)
    ↓
kanban.json 업데이트
    ↓
다음 단계 안내: /design-doc <topic>
```

### 후속 실행: `/meeting <topic>` (이미 토픽 존재)

```
기존 Meeting Log, CPS, PRD 읽기
  + 이전 미확인 사항 검토 (유효성 판단 후 유효한 것만 재확인)
    ↓
추가 대화 진행
    ↓
새 Meeting Log 추가 (meetings/YYYY-MM-DD-<session>.md)
    ↓
CPS, PRD 업데이트 (변경 사항 하이라이트)
    ↓
사용자 리뷰 → kanban.json 업데이트
```

### Meeting Log 형식

```markdown
# Meeting Log - 2026-03-27

## 참석: user, claude
## 주제: user-auth 초기 논의

### 논의 사항
- Q: 인증 방식은?
  A: OAuth2 + JWT 기반

- Q: 세션 관리 요구사항?
  A: 최대 동시 세션 3개, 30일 만료

### 결정 사항
- OAuth2 + JWT 채택
- Redis 기반 세션 스토어

### 미확인 사항 (unresolved)
- Rate limiting 임계값 — 언급만 되고 구체화되지 않음

### 해소된 미확인 사항
- ~~소셜 로그인 범위~~ → 2026-03-28 미팅에서 소셜 로그인 제외로 결정
```

### 미확인 사항 처리 로직

- 미팅 중 질문에 대해 확답을 못 받고 대화가 다른 방향으로 흐르면 `미확인 사항`에 기록
- 미팅 종료 전 미확인 사항 목록을 사용자에게 제시하고 확인 여부 묻기
- 후속 `/meeting` 실행 시 이전 미확인 사항 검토:
  - 이후 결정 사항으로 인해 **무효화된 항목** → 자동 제거하고 사유 기록
  - 여전히 **유효한 항목** → 사용자에게 다시 확인
- CPS/PRD 생성 시 미확인 사항이 남아있으면 해당 부분을 명시적으로 표기

---

## Skill: `/design-doc`

### 실행 흐름: `/design-doc <topic>`

```
토픽의 PRD 읽기 (harness/topics/<topic>/prd.md)
  + 미확인 사항 남아있으면 경고 후 진행 여부 확인
    ↓
[design-doc-writer] 4개 문서를 순차 생성, 각각 사용자 승인 후 다음으로
    ↓
① spec.md — 기능 상세 명세, 인터페이스 정의, 데이터 모델
② blueprint.md — 시스템 구성도, 컴포넌트 간 관계, 데이터 흐름
③ architecture.md — 기술 스택 결정, 레이어 구조, 의존성 방향
④ code-dev-plan.md — 개발 위치/순서/방향/접근법 (코드 아님), 테스트 전략
    ↓
[design-doc-reviewer] 문서 간 일관성, PRD 누락 검증 (최대 3회)
    ↓
사용자 리뷰 → kanban.json 업데이트
    ↓
다음 단계 안내: /implement <topic>
```

### PRD 변경 시 연동

```
/meeting <topic> (PRD 업데이트됨)
    ↓
PRD diff 분석 → 영향받는 design-doc 문서 식별 → 해당 문서만 업데이트 제안 → 사용자 승인 후 반영
```

### code-dev-plan.md 예시

```markdown
# Code Development Plan - user-auth

## Phase 1: 인증 기반
- 방향: Express middleware로 JWT 검증 레이어 구축
- 위치: src/middleware/auth/
- 접근법: 기존 라우터 구조에 미들웨어 체인으로 삽입
- 테스트: 토큰 만료, 무효 토큰, 권한 부족 시나리오

## Phase 2: 세션 관리
- 방향: Redis adapter 패턴으로 세션 스토어 추상화
- 위치: src/services/session/
- 접근법: Repository 패턴, 스토어 교체 가능하게
- 테스트: 동시 세션 제한, 만료 처리
```

---

## Skill: `/implement`

기존 `/implement`의 `.progress.md` 기반 추적은 토픽 `kanban.json`으로 완전 대체된다. 기존 `docs/plans/` 경로 참조 대신 `harness/topics/<topic>/` 내 문서를 참조한다. SDD + TDD 패턴과 2단계 리뷰 게이트(compliance → quality)는 기존대로 유지한다.

### 실행 흐름: `/implement <topic>`

```
토픽의 kanban.json 읽기
    ↓
code-dev-plan.md에서 phase 목록 로드
    ↓
backlog에 phase별 스텝 자동 등록 (첫 실행 시)
    ↓
in_progress 스텝부터 이어서 작업 (중단 복구)
    ↓
각 phase 실행:
  ├── code-dev-plan의 방향/접근법 참조
  ├── spec, blueprint, architecture 문서 참조
  ├── SDD + TDD로 개발 (기존 SDD worker/reviewer 에이전트 패턴 활용)
  └── phase 완료 시:
      ├── kanban 업데이트 (done으로 이동)
      ├── 변경이 lint-* 규칙에 영향? → 해당 lint 스킬 references/ 자동 업데이트
      └── 설계와 불일치 발견 시 → 사용자에게 알리고 회귀 제안
    ↓
전체 phase 완료 → 자동으로 /lint 실행
```

---

## Skill: `/lint`

### 실행 흐름: `/lint <topic>`

```
토픽의 PRD, spec 읽기
    ↓
① lint-requirements 로직 실행 (Flow 플러그인 내장 로직, 별도 스킬이 아님)
  ├── PRD 수용 기준 대비 구현 확인
  ├── spec 인터페이스/데이터 모델 준수 여부
  └── 미충족 항목 리포트
    ↓
② lint-* 스킬 호출 (프로젝트 .claude/skills/lint-*)
  ├── 자동 탐색
  ├── 각 린트 스킬 순차 실행
  └── 스킬별 검증 결과 통합
    ↓
통합 리포트 (요구사항 + 린트 결과)
    ↓
결과: PASS / WARNING / FAIL
    ↓
PASS → 사용자에게 최종 리포트
WARNING → 리포트에 경고 항목 포함하여 사용자에게 전달, 자율 실행은 계속 진행
FAIL → SDD worker 에이전트가 실패 항목에 대해 코드만 수정 (harness 문서/lint 규칙은 수정하지 않음), 수정 후 /lint 재실행, 최대 2회 재시도 후에도 FAIL이면 사용자에게 에스컬레이션
    ↓
kanban.json 업데이트
```

### 린트 스킬 구조

```
.claude/
└── skills/
    ├── lint-architecture/
    │   ├── SKILL.md
    │   └── references/           ← 관점별로 분리, 계속 축적
    │       ├── layer-dependencies.md
    │       ├── module-boundaries.md
    │       └── naming-conventions.md
    ├── lint-code-convention/
    │   ├── SKILL.md
    │   └── references/
    │       ├── formatting.md
    │       ├── error-handling.md
    │       └── typing.md
    ├── lint-react-optimization/  ← 감지된 스택에 따라 선택적
    │   ├── SKILL.md
    │   └── references/
    │       ├── rendering.md
    │       ├── state-management.md
    │       └── hooks.md
    └── ...
```

lint-* 스킬은 사용자 프로젝트의 `.claude/skills/` 에 생성된다 (Flow 플러그인의 `skills/` 디렉터리가 아님). 이를 통해 프로젝트별로 독립적인 린트 규칙을 관리한다.

- 각 린트 스킬이 자기 규칙을 references/에서 자체 관리
- 규칙 파일은 관점별로 분리되어 계속 축적
- `/implement` 완료 시 변경된 코드가 규칙에 영향을 주면 해당 references/ 자동 업데이트

### lint-* 스킬 출력 계약

모든 lint-* 스킬은 실행 결과를 다음 구조의 마크다운으로 출력해야 한다. `/lint` 스킬이 이 형식을 파싱하여 통합 리포트를 생성한다.

```markdown
## Lint Result: {skill-name}

### Status: PASS | WARNING | FAIL

### Findings
- [FAIL] {파일경로}:{라인} — {설명}
- [WARNING] {파일경로}:{라인} — {설명}
- [PASS] {검증 항목} — {통과 사유}

### Summary
- Total checks: {N}
- Pass: {N} / Warning: {N} / Fail: {N}
```

`/harness-init`이 lint-* 스킬을 생성할 때 이 출력 계약을 SKILL.md에 포함시킨다.

---

## Skill: `/doc-garden`

### doc-gardener 에이전트

**실행 시점:**
- `/lint` 실행 시 함께 호출 (`/implement` 완료 → `/lint` 자동 실행 → doc-gardener 포함이므로, `/implement` 후 별도 트리거는 불필요)
- 독립 스킬 `/doc-garden`으로 수동 실행 가능

**검증 항목:**
- harness/ 문서와 현재 코드 구조의 불일치
- lint-* 스킬 references/ 규칙과 실제 코드 패턴의 괴리
- quality-score.md 현재 상태 반영 여부 (staleness만 플래그, 점수 재산출은 `/lint`에서만 수행)
- tech-debt.md 해소된 항목 잔존 여부

**결과:**
- 불일치 발견 시 harness/ 내 문서와 lint-* 스킬의 references/ 규칙만 수정 (코드베이스 자체는 수정하지 않음)
- 변경 사항을 사용자에게 알림

---

## Quality Score

### quality-score.md

```markdown
# Quality Score

## 도메인별 점수
| 도메인 | 점수 | 마지막 평가 | 비고 |
|--------|------|------------|------|
| auth | 78/100 | 2026-03-28 | 세션 관리 테스트 보강 필요 |
| payment | 52/100 | 2026-03-25 | 에러 핸들링 미흡 |

## 평가 기준
| 항목 | 배점 |
|------|------|
| 요구사항 충족 | 30 |
| 아키텍처 준수 | 20 |
| 코드 컨벤션 | 15 |
| 테스트 커버리지 | 20 |
| 기술 부채 | 15 |

## 전체 기술 부채 요약
- 긴급: 2건
- 개선 필요: 5건
```

- 평가 기준/배점은 `/harness-init` 시 프로젝트 특성에 맞게 초기 설정, 사용자 커스터마이즈 가능
- `/lint` 실행 시 lint-reviewer 에이전트가 각 항목별로 점수를 산출한다. 점수 산출은 에이전트의 판단 기반이며, 각 항목별 근거(통과/실패한 구체적 사항)를 리포트에 함께 기록한다

---

## Agents

| 에이전트 | 모델 | 역할 |
|----------|------|------|
| harness-initializer | Opus | 코드베이스 분석, harness/ 스캐폴딩, lint-* 스킬 생성 |
| meeting-facilitator | Opus | 미팅 진행, Meeting Log/CPS/PRD 생성 |
| meeting-reviewer | Sonnet | CPS/PRD 검증 |
| design-doc-writer | Opus | PRD 기반 4개 설계 문서 작성 |
| design-doc-reviewer | Sonnet | 설계 문서 간 일관성, PRD 누락 검증 |
| doc-gardener | Sonnet | 문서/규칙과 코드베이스 비교 검증 |
| lint-reviewer | Sonnet | 요구사항 충족 검증 (lint-requirements 기본 스킬) |

기존 `/implement`의 SDD 에이전트 패턴(worker subagent, compliance-reviewer, quality-reviewer)은 유지한다. `/implement` 스킬이 이 에이전트들을 기존과 동일하게 디스패치하며, 변경되는 것은 참조 문서 경로(harness/topics/)와 진행 상태 추적(kanban.json)뿐이다.

---

## Skills Summary

### Flow 플러그인 기본 스킬

| 스킬 | 신규/변경 | 역할 |
|------|----------|------|
| `/harness-init` | 신규 | 코드베이스 분석, harness/ 스캐폴딩, lint-* 스킬 생성 |
| `/meeting` | 신규 (기존 /spec 대체) | 대화 기반 요구사항 정의, CPS/PRD 생성 |
| `/design-doc` | 신규 (기존 /plan 대체) | PRD 기반 설계 문서 4종 생성 |
| `/implement` | 변경 | harness 토픽 칸반 연동, lint-* 자동 업데이트 |
| `/lint` | 신규 (기존 /code-review 대체) | 요구사항 검증 + lint-* 스킬 호출 |
| (lint-requirements) | /lint 내장 로직 | 요구사항 충족 검증 (별도 스킬이 아닌 /lint 내부 로직) |
| `/doc-garden` | 신규 | 문서/규칙 최신 상태 검증 |

### 프로젝트에 생성되는 스킬

| 스킬 | 생성 시점 | 역할 |
|------|----------|------|
| `/lint-architecture` | /harness-init | 아키텍처 구조 검증 |
| `/lint-code-convention` | /harness-init | 코드 컨벤션 검사 |
| `/lint-{framework}` | /harness-init (선택적) | 프레임워크별 최적화 검증 |

---

## Existing Skill Disposition

대체되는 스킬은 파일 시스템에서 삭제한다. 기존 에이전트(spec-facilitator, spec-reviewer, plan-writer, plan-reviewer, code-reviewer, amend-orchestrator)도 새 에이전트로 대체되므로 삭제한다.

| 기존 스킬 | 처리 | 상세 |
|----------|------|------|
| `/spec` | 삭제 | `/meeting`으로 대체 |
| `/plan` | 삭제 | `/design-doc`으로 대체 |
| `/implement` | 유지 + 수정 | harness 연동 추가, .progress.md → kanban.json |
| `/code-review` | 삭제 | `/lint`로 대체 |
| `/amend` | 삭제 | `/meeting` 재실행으로 대체 |
| `/sdd` | 유지 | /implement 내부에서 활용 |
| `/tdd` | 유지 | /implement 내부에서 활용 |
| `/using-worktree` | 유지 | 변경 없음 |

---

## Success Criteria

- `/harness-init`으로 기존 프로젝트에 harness/ 스캐폴딩과 lint-* 스킬이 정상 생성됨
- `/meeting`으로 대화 → Meeting Log → CPS → PRD가 순차 생성되고, 반복 실행 시 기존 내용이 보존/업데이트됨
- 미확인 사항이 후속 미팅에서 유효성 판단과 함께 재확인됨
- `/design-doc`으로 PRD 기반 4개 설계 문서가 생성되고, PRD 변경 시 영향받는 문서만 업데이트됨
- `/implement` ~ `/lint`가 사용자 개입 없이 자율 실행되고, 세션 중단 후에도 kanban으로 이어서 진행됨
- lint-* 스킬의 references/가 코드베이스 변화에 따라 계속 축적됨
- quality-score.md가 점수제로 자동 산출됨
- 생성되는 lint-* 스킬과 harness/ 문서는 영어로 작성됨 (사용자 프로젝트의 언어 설정과 무관하게 에이전트 가독성 우선)
