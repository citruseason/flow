# Flow

**Complete development workflow plugin for Claude Code.**

브레인스토밍부터 구현 계획, TDD, 코드 리뷰까지 — 사용자가 직접 각 단계를 호출하는 수동 워크플로우 플러그인입니다.

```
/brainstorm           → spec 문서 생성
/plan <spec-path>     → 구현 계획서 생성
/tdd                  → TDD 구현 (RED → GREEN → REFACTOR)
/code-review          → 코드 리뷰
/tdd-workflow         → 수정사항 TDD로 반영
```

---

## Why Flow?

- 아이디어를 설계 문서로 구체화하는 구조화된 대화 프로세스
- spec 문서를 기반으로 Phase별 구현 계획서 생성
- TDD (테스트 우선 개발) 강제
- 보안 + 코드 품질 리뷰
- 각 단계를 사용자가 직접 호출 — 자동 체이닝 없음

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
# 1. 브레인스토밍 → spec 문서
/brainstorm "사용자 인증 기능 추가"

# 2. spec 기반 구현 계획
/plan docs/specs/2026-03-22-auth-design.md

# 3. TDD 구현
/tdd

# 4. 코드 리뷰
/code-review

# 5. 수정사항 있으면 TDD로 반영
/tdd-workflow
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
|
|-- commands/
|   |-- brainstorm.md             # /brainstorm
|   |-- plan.md                   # /plan
|   |-- tdd.md                    # /tdd
|   |-- tdd-workflow.md           # /tdd-workflow
|   |-- code-review.md            # /code-review
|
|-- skills/
|   |-- brainstorming/            # 브레인스토밍 스킬
|   |   |-- SKILL.md
|   |   |-- visual-companion.md
|   |   |-- scripts/              # Zero-dep WebSocket 서버
|   |
|   |-- planning/                 # 구현 계획 스킬
|   |   |-- SKILL.md
|   |
|   |-- tdd-workflow/             # TDD 워크플로우 스킬
|       |-- SKILL.md
|
|-- hooks/
|   |-- hooks.json                # 세션 시작 알림
|
|-- CLAUDE.md
|-- README.md
```

---

## How It Works

### 1. /brainstorm — 아이디어 → 설계 문서

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

### 5. /tdd-workflow — TDD 패턴 레퍼런스

- Unit/Integration/E2E 테스트 패턴
- 외부 서비스 목킹 (Supabase, Redis, OpenAI)
- 커버리지 검증 및 임계값
- 테스팅 안티패턴

---

## Visual Companion

UI 목업, 와이어프레임, 아키텍처 다이어그램 등을 브라우저에서 실시간으로 보여주는 도구입니다.

- Zero-dependency Node.js WebSocket 서버
- HTML 파일 작성 → 서버가 자동 감지 → 브라우저에 표시
- 사용자 클릭/선택이 `.events` 파일로 기록
- 질문별로 브라우저/터미널 판단 (시각적 질문만 브라우저 사용)

```bash
# 수동 시작 (보통 스킬이 자동 관리)
skills/brainstorming/scripts/start-server.sh --project-dir /path/to/project

# 종료
skills/brainstorming/scripts/stop-server.sh $SCREEN_DIR
```

---

## Configuration

### Spec Location

기본 스펙 저장 경로는 `docs/specs/`입니다. 프로젝트별로 변경하려면 브레인스토밍 중 위치를 지정하면 됩니다.

### Plan Location

기본 계획서 저장 경로는 `docs/plans/`입니다.

### Visual Companion Storage

Visual Companion의 목업 파일은 `.flow/brainstorm/` 디렉토리에 저장됩니다. `.gitignore`에 추가하는 것을 권장합니다:

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

### /brainstorm 또는 /plan 명령어가 인식되지 않는 경우

```bash
/plugin list flow@flow-marketplace
```

---

## Credits

- Brainstorming methodology adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent
- TDD and code review patterns adapted from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa

## License

MIT
