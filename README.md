# Flow

**Complete development workflow plugin for Claude Code.**

스펙 작성부터 구현 계획, TDD, 코드 리뷰까지 — 사용자가 직접 각 단계를 스킬 슬래시 커맨드로 호출하는 수동 워크플로우 플러그인입니다.

```
/spec              → spec 문서 생성
/plan <spec-path>  → 구현 계획서 생성
/tdd               → TDD 구현 (RED → GREEN → REFACTOR)
/amend             → 수정 (스펙 → 플랜 → TDD 오케스트레이션)
/code-review       → 코드 리뷰
/worktree-create   → worktree 생성 + 포트 할당
/worktree-remove   → worktree 정리 + 포트 해제
/worktree-status   → worktree 현황 조회
/port-assign       → 포트 블록 할당
/port-release      → 포트 블록 해제
/port-status       → 포트 현황 조회
/pr-create         → PR 생성 (템플릿 기반)
```

---

## Why Flow?

- 아이디어를 설계 문서로 구체화하는 구조화된 대화 프로세스
- spec 문서를 기반으로 Phase별 구현 계획서 생성
- TDD (테스트 우선 개발) 강제
- 보안 + 코드 품질 리뷰
- 각 단계를 스킬 슬래시 커맨드로 직접 호출 — 자동 체이닝 없음

---

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/code) CLI 설치
- Node.js >= 18 (Visual Companion 서버용)

### 설치

```bash
# Flow 마켓플레이스 추가 및 설치
/plugin marketplace add citruseason/flow
/plugin install flow@flow-marketplace
```

### 사용 시작

```bash
# 1. 스펙 작성 → spec 문서
/spec "사용자 인증 기능 추가"

# 2. spec 기반 구현 계획
/plan docs/specs/2026-03-22-auth-design.md

# 3. TDD 구현
/tdd

# 4. 코드 리뷰
/code-review

# 5. 수정사항 있으면
/amend "에러 메시지를 토스트로 변경해줘"
```

---

## What's Inside

```
flow/
|-- .claude-plugin/
|   |-- plugin.json               # 플러그인 매니페스트
|   |-- marketplace.json          # 마켓플레이스 등록 정보
|
|-- agents/
|   |-- design-facilitator.md     # 브레인스토밍 진행 (Opus)
|   |-- spec-reviewer.md          # 스펙 검증 (Sonnet)
|   |-- planner.md                # 구현 계획 수립 (Opus)
|   |-- plan-reviewer.md          # 계획 검증 (Sonnet)
|   |-- tdd-guide.md              # TDD 가이드 (Sonnet)
|   |-- code-reviewer.md          # 코드 리뷰 (Sonnet)
|   |-- amender.md                # 수정 오케스트레이터 (Opus)
|
|-- skills/
|   |-- spec/                   # /spec (스펙 작성)
|   |   |-- SKILL.md
|   |   |-- visual-companion.md
|   |   |-- scripts/
|   |
|   |-- plan/                   # /plan (구현 계획)
|   |   |-- SKILL.md
|   |
|   |-- tdd/                    # /tdd (TDD 구현)
|   |   |-- SKILL.md
|   |
|   |-- amend/                  # /amend (수정)
|   |   |-- SKILL.md
|   |
|   |-- code-review/            # /code-review (코드 리뷰)
|   |   |-- SKILL.md
|   |
|   |-- worktree-create/       # /worktree-create
|   |   |-- SKILL.md
|   |
|   |-- worktree-remove/       # /worktree-remove
|   |   |-- SKILL.md
|   |
|   |-- worktree-status/       # /worktree-status
|   |   |-- SKILL.md
|   |
|   |-- port-assign/           # /port-assign
|   |   |-- SKILL.md
|   |
|   |-- port-release/          # /port-release
|   |   |-- SKILL.md
|   |
|   |-- port-status/           # /port-status
|   |   |-- SKILL.md
|   |
|   |-- pr-create/             # /pr-create
|       |-- SKILL.md
|   |
|-- hooks/
|   |-- hooks.json                # 세션 시작 알림
|
|-- CLAUDE.md
|-- README.md
```

---

## How It Works

### 1. /spec — 아이디어 → 설계 문서

- 프로젝트 컨텍스트 탐색
- 한 번에 하나의 질문, 객관식 우선
- 2-3개 접근법 비교, 단계별 승인
- Visual Companion (브라우저 기반 목업/다이어그램)
- spec-reviewer 에이전트가 검증 (최대 3회)
- 결과: `docs/specs/YYYY-MM-DD-<topic>-design.md`

### 2. /plan — 설계 문서 → 구현 계획

- spec 문서 경로를 인자로 받음
- 기존 코드베이스 분석
- Phase별 구현 단계 분해 (파일 경로, 의존성, 리스크)
- plan-reviewer 에이전트가 검증 (최대 3회)
- 결과: `docs/plans/YYYY-MM-DD-<topic>-plan.md`

### 3. /tdd — TDD 구현

- RED: 실패하는 테스트 작성
- GREEN: 테스트 통과하는 최소 코드 작성
- REFACTOR: 코드 개선 (테스트 유지)
- 80%+ 커버리지 달성

### 4. /code-review — 코드 리뷰

- CRITICAL: 보안 취약점 (SQL injection, XSS, 하드코딩 키 등)
- HIGH: 코드 품질 (큰 함수, 깊은 중첩, 에러 처리 누락)
- MEDIUM: 성능 (비효율 알고리즘, 불필요한 리렌더)
- LOW: 베스트 프랙티스 (명명, 매직 넘버)

### 5. /amend — 수정 오케스트레이터

- 자연어로 수정 요청 (파일 경로 불필요)
- 변경 규모 자동 판단 (경미 vs 스펙 변경)
- 경미한 변경: 바로 TDD 구현
- 스펙 변경: design-facilitator → planner → tdd-guide 순차 위임
- 각 단계에서 사용자 확인 필수

---

## Parallel Development

여러 spec을 동시에 개발할 때 git worktree와 포트 자동 관리를 사용합니다.

### Setup

프로젝트 루트에 `.flow/config.json`을 생성하여 포트를 정의합니다:

```json
{
  "ports": {
    "FRONTEND_PORT": 3000,
    "API_PORT": 8080,
    "DB_PORT": 5432
  }
}
```

### Workflow

각 터미널에서 독립적으로 하나의 기능을 개발합니다:

```
Terminal 1:                         Terminal 2:
/spec "인증 기능"                    /spec "결제 기능"
  -> worktree 생성 + 포트 할당        -> worktree 생성 + 포트 할당
  -> 새 세션에서 /plan → /tdd         -> 새 세션에서 /plan → /tdd
  -> /code-review → /pr-create       -> /code-review → /pr-create
  -> /worktree-remove                -> /worktree-remove
```

### Port Block Allocation

- 범위: 10000~20000, 블록 단위 100
- worktree-1: `FRONTEND_PORT=10000, API_PORT=10001, DB_PORT=10002`
- worktree-2: `FRONTEND_PORT=10100, API_PORT=10101, DB_PORT=10102`
- 각 포트는 할당 전에 충돌 여부를 자동 검증

### Commands

| 명령어 | 설명 |
|--------|------|
| `/worktree-create` | worktree 생성 + 포트 할당 |
| `/worktree-remove` | worktree 정리 + 포트 해제 |
| `/worktree-status` | 전체 worktree 현황 조회 |
| `/port-assign` | 포트 블록 할당 |
| `/port-release` | 포트 블록 해제 |
| `/port-status` | 포트 할당 현황 조회 |
| `/pr-create` | PR 생성 (템플릿 기반) |

---

## Visual Companion

UI 목업, 와이어프레임, 아키텍처 다이어그램 등을 브라우저에서 실시간으로 보여주는 도구입니다.

- Zero-dependency Node.js WebSocket 서버
- HTML 파일 작성 → 서버가 자동 감지 → 브라우저에 표시
- 사용자 클릭/선택이 `.events` 파일로 기록
- 질문별로 브라우저/터미널 판단 (시각적 질문만 브라우저 사용)

```bash
# 수동 시작 (보통 스킬이 자동 관리)
skills/spec/scripts/start-server.sh --project-dir /path/to/project

# 종료
skills/spec/scripts/stop-server.sh $SCREEN_DIR
```

---

## Configuration

### Spec Location

기본 스펙 저장 경로는 `docs/specs/`입니다. 프로젝트별로 변경하려면 브레인스토밍 중 위치를 지정하면 됩니다.

### Plan Location

기본 계획서 저장 경로는 `docs/plans/`입니다.

### Visual Companion Storage

Visual Companion의 목업 파일은 `.flow/spec/` 디렉토리에 저장됩니다. `.gitignore`에 추가하는 것을 권장합니다:

```
.flow/
```

---

## Troubleshooting

### 플러그인이 로드되지 않는 경우

```bash
/plugin list
```

### Visual Companion 서버가 시작되지 않는 경우

```bash
node --version  # >= 18 필요
```

### /spec 또는 /plan 명령어가 인식되지 않는 경우

```bash
/plugin list flow@flow-marketplace
```

---

## Credits

- Spec design methodology adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent
- TDD and code review patterns adapted from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa

## License

MIT
