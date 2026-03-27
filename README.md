# Flow

**Complete development workflow plugin for Claude Code.**

하네스 기반 지식 관리, 미팅 기반 요구사항 정의, 설계 문서화, 자율 구현, 린트 검증까지 — 각 단계를 스킬 슬래시 커맨드로 호출하는 개발 워크플로우 플러그인입니다.

```
/harness-init          → 프로젝트 분석 + 하네스 지식 베이스 생성
/meeting "topic"       → Meeting Log → CPS → PRD 생성
/design-doc <topic>    → Spec, Blueprint, Architecture, Code-Dev-Plan
/implement <topic>     → 자율 구현 (SDD + TDD → /lint 자동 실행)
/lint <topic>          → 요구사항 검증 + lint-* 스킬 실행
```

독립 사용 가능한 스킬:
```
/doc-garden            → 하네스 문서 최신 상태 검증
/tdd                   → 수동 TDD 가이드 (RED → GREEN → REFACTOR)
/sdd                   → 서브에이전트 기반 실행 패턴
/using-worktree        → worktree 셋업 + 작업 컨텍스트 전환
```

---

## Why Flow?

- **하네스 지식 베이스** — 에이전트가 프로젝트를 이해하고 추론할 수 있는 구조화된 문서
- **미팅 기반 요구사항** — 대화를 통해 CPS(Context-Problem-Solution) → PRD 생성
- **4단계 설계 문서** — Spec, Blueprint, Architecture, Code-Dev-Plan으로 체계적 설계
- **자율 구현** — implement부터 lint까지 사용자 개입 없이 자동 진행
- **프로젝트별 린트 스킬** — 아키텍처, 컨벤션, 프레임워크별 규칙이 자동 생성되고 축적
- **칸반 기반 진행 추적** — 토픽별 상태 관리로 세션 간 연속성 확보

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
# 0. 프로젝트 하네스 세팅 (최초 1회)
/harness-init

# 1. 미팅으로 요구사항 정의
/meeting "사용자 인증 기능 추가"

# 2. 설계 문서 생성
/design-doc user-auth

# 3. 자율 구현 (implement → lint 자동 실행)
/implement user-auth

# 4. 수정사항 있으면 미팅 재실행
/meeting user-auth
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
|   |-- harness-initializer.md    # 코드베이스 분석 + 하네스 생성 (Opus)
|   |-- meeting-facilitator.md    # 미팅 진행 + CPS/PRD 생성 (Opus)
|   |-- meeting-reviewer.md       # CPS/PRD 검증 (Sonnet)
|   |-- design-doc-writer.md      # 설계 문서 4종 작성 (Opus)
|   |-- design-doc-reviewer.md    # 설계 문서 검증 (Sonnet)
|   |-- doc-gardener.md           # 문서 최신 상태 검증 (Sonnet)
|   |-- lint-reviewer.md          # 린트 통합 + 품질 점수 (Sonnet)
|
|-- skills/
|   |-- harness-init/             # /harness-init
|   |   |-- SKILL.md
|   |
|   |-- meeting/                  # /meeting
|   |   |-- SKILL.md
|   |   |-- visual-companion.md
|   |   |-- scripts/
|   |
|   |-- design-doc/               # /design-doc
|   |   |-- SKILL.md
|   |
|   |-- implement/                # /implement
|   |   |-- SKILL.md
|   |
|   |-- lint/                     # /lint
|   |   |-- SKILL.md
|   |
|   |-- doc-garden/               # /doc-garden
|   |   |-- SKILL.md
|   |
|   |-- sdd/                      # /sdd
|   |   |-- SKILL.md
|   |   |-- references/
|   |
|   |-- tdd/                      # /tdd
|   |   |-- SKILL.md
|   |   |-- references/
|   |
|   |-- using-worktree/           # /using-worktree
|   |   |-- SKILL.md
|   |
|   |-- update-plugin/            # /update-plugin
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

### 0. /harness-init — 프로젝트 하네스 세팅

- 코드베이스 구조, 기술 스택, 아키텍처 패턴, 코드 컨벤션 자동 분석
- `harness/` 지식 베이스 생성 (index, 품질 점수, 관측 가이드, 골든 룰, 기술 부채)
- 프로젝트 `.claude/skills/`에 lint-* 스킬 자동 생성 (architecture, code-convention, framework별)
- 재실행 시 변경사항만 diff 기반 업데이트

### 1. /meeting — 대화 → Meeting Log → CPS → PRD

- 한 번에 하나의 질문, 객관식 우선
- 2-3개 접근법 비교, 단계별 승인
- 미확인 사항 자동 추적 (후속 미팅에서 유효성 재검토)
- Visual Companion (브라우저 기반 목업/다이어그램)
- meeting-reviewer가 CPS/PRD 검증 (최대 3회)
- 반복 실행 시 기존 문서 보존 + history/ 관리

### 2. /design-doc — PRD → 4개 설계 문서

- Spec: 기능 상세 명세, 인터페이스, 데이터 모델
- Blueprint: 시스템 구성도, 컴포넌트 관계, 데이터 흐름
- Architecture: 기술 스택, 레이어 구조, 의존성 방향
- Code-Dev-Plan: 개발 방향/위치/접근법 (코드 아님)
- PRD 변경 시 영향받는 문서만 자동 업데이트

### 3. /implement — 자율 구현

- code-dev-plan의 Phase별 SDD 워커 디스패치
- 각 워커가 TDD로 구현 (테스트 먼저 → 최소 구현 → 리팩터)
- 2단계 리뷰 게이트 (스펙 준수 → 코드 품질)
- 칸반으로 진행 추적, 세션 중단 후 이어서 가능
- 완료 시 `/lint` 자동 실행

### 4. /lint — 검증

- 요구사항 충족 검증 (PRD 수용 기준, Spec 인터페이스)
- 프로젝트 lint-* 스킬 자동 탐색 및 실행
- 문서 최신 상태 검증 (doc-gardener)
- 품질 점수 산출 (100점 만점)
- FAIL 시 자동 수정 → 재실행 (최대 2회)

---

## Harness Knowledge Base

`/harness-init`이 프로젝트 루트에 생성하는 구조:

```
harness/
├── index.md              # 지식 베이스 목차
├── kanban.json            # 전체 토픽 상태 조감도
├── quality-score.md       # 도메인별 품질 점수
├── observability.md       # 로깅/메트릭/에러 형식 가이드
├── golden-rules.md        # 핵심 불변 규칙
├── tech-debt.md           # 기술 부채 추적
├── references/            # 외부 참조 문서
└── topics/
    └── <topic>/
        ├── kanban.json    # 토픽 진행 상태 (backlog/in_progress/done)
        ├── meetings/      # 미팅 로그
        ├── cps.md         # Context-Problem-Solution
        ├── prd.md         # Product Requirements Document
        ├── spec.md        # 기능 상세 명세
        ├── blueprint.md   # 시스템 구성도
        ├── architecture.md # 아키텍처 결정
        ├── code-dev-plan.md # 개발 계획
        └── history/       # 문서 버전 이력 (최대 2개)
```

---

## Parallel Development

여러 토픽을 동시에 개발할 때 git worktree를 사용합니다.

```
Terminal 1:                         Terminal 2:
/meeting "인증 기능"                 /meeting "결제 기능"
  -> /using-worktree                 -> /using-worktree
  -> /design-doc → /implement       -> /design-doc → /implement
```

---

## Visual Companion

UI 목업, 와이어프레임, 아키텍처 다이어그램 등을 브라우저에서 실시간으로 보여주는 도구입니다.

- Zero-dependency Node.js WebSocket 서버
- HTML 파일 작성 → 서버가 자동 감지 → 브라우저에 표시
- 사용자 클릭/선택이 `.events` 파일로 기록
- 질문별로 브라우저/터미널 판단 (시각적 질문만 브라우저 사용)

```bash
# 수동 시작 (보통 스킬이 자동 관리)
skills/meeting/scripts/start-server.sh --project-dir /path/to/project

# 종료
skills/meeting/scripts/stop-server.sh $SCREEN_DIR
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

---

## Credits

- Harness engineering patterns from [Harness Engineering](https://openai.com/index/harness-engineering/) by OpenAI
- SDD (Subagent-Driven Development) pattern adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent
- TDD and code review patterns adapted from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa

## License

MIT
