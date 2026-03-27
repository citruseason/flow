# Flow

**Complete development workflow plugin for Claude Code.**

하네스 기반 지식 관리, 미팅 기반 요구사항 정의, 설계 문서화, 자율 구현, 린트 검증까지 — 각 단계를 스킬 슬래시 커맨드로 호출하는 개발 워크플로우 플러그인입니다.

```
/harness-init          → 프로젝트 분석 + CORE 지식 문서 생성 + CLAUDE.md 엔트리포인트
/meeting "topic"       → Meeting Log → CPS → PRD 생성
/design-doc <topic>    → Spec, Blueprint, Architecture, Code-Dev-Plan, Test-Cases
/implement <topic>     → 자율 구현 (SDD + TDD → /lint 자동 실행)
/lint <topic>          → 요구사항 검증 + lint-* 스킬 실행
```

독립 사용 가능한 스킬:
```
/lint-integrate        → 외부 스킬을 lint-* 래퍼로 추가/관리
/core-update <topic>   → 머지 후 CORE 문서에 실현된 결정 반영
/doc-garden            → 하네스 문서 최신 상태 검증
/tdd                   → 수동 TDD 가이드 (RED → GREEN → REFACTOR)
/sdd                   → 서브에이전트 기반 실행 패턴
/using-worktree        → worktree 셋업 + 작업 컨텍스트 전환
/update-plugin         → 수동 플러그인 업데이트
```

---

## Why Flow?

- **CORE 지식 레이어** — 프로젝트를 도메인별로 이해하는 구조화된 문서 (PRODUCT, SECURITY, FRONTEND, BACKEND 등)
- **CLAUDE.md 에이전트 엔트리포인트** — 100줄 이내의 프로젝트 맵으로 점진적 컨텍스트 로딩
- **미팅 기반 요구사항** — 대화를 통해 CPS(Context-Problem-Solution) → PRD 생성
- **5단계 설계 문서** — Spec, Blueprint, Architecture, Code-Dev-Plan, Test-Cases
- **자율 구현** — implement부터 lint까지 사용자 개입 없이 자동 진행
- **프로젝트별 린트 스킬** — CORE 문서에서 파생된 규칙, 자동 생성 및 축적
- **머지 타임 지식 축적** — 토픽 머지 시 CORE 문서에 실현된 설계 결정 반영
- **레퍼런스 자동 수집** — 의존성의 llms.txt 또는 공식 문서 기반 레퍼런스 관리

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

# 4. 머지 후 CORE 문서 업데이트
/core-update user-auth
```

---

## What's Inside

```
flow/
|-- .claude-plugin/
|   |-- plugin.json               # 플러그인 매니페스트
|   |-- marketplace.json          # 마켓플레이스 등록 정보
|
|-- agents/                        # 7개 에이전트
|   |-- harness-initializer.md    # 코드베이스 분석 + CORE 문서 생성 (Opus)
|   |-- meeting-facilitator.md    # 미팅 진행 + CPS/PRD 생성 (Opus)
|   |-- meeting-reviewer.md       # CPS/PRD 검증 (Sonnet)
|   |-- design-doc-writer.md      # 설계 문서 5종 작성 (Opus)
|   |-- design-doc-reviewer.md    # 설계 문서 검증 (Sonnet)
|   |-- doc-gardener.md           # 문서 최신 상태 검증 (Sonnet)
|   |-- lint-reviewer.md          # 린트 통합 + 품질 점수 (Sonnet)
|
|-- skills/                        # 14개 스킬
|   |-- harness-init/             # /harness-init — CORE 문서 + CLAUDE.md + 레퍼런스
|   |-- meeting/                  # /meeting — 미팅 진행 + Visual Companion
|   |-- design-doc/               # /design-doc — 5개 설계 문서
|   |-- implement/                # /implement — SDD + TDD 자율 구현
|   |-- lint/                     # /lint — 요구사항 + 린트 검증
|   |-- lint-manage/              # /lint-manage — 린트 스킬 생성/업데이트
|   |-- lint-integrate/           # /lint-integrate — 외부 스킬 린트 래퍼
|   |-- lint-validate/            # /lint-validate — 린트 스킬 건강 검증
|   |-- core-update/              # /core-update — 머지 후 CORE 문서 업데이트
|   |-- doc-garden/               # /doc-garden — 문서 최신 상태 검증
|   |-- sdd/                      # /sdd — 서브에이전트 기반 실행
|   |-- tdd/                      # /tdd — 테스트 주도 개발
|   |-- using-worktree/           # /using-worktree — 격리 워크트리
|   |-- update-plugin/            # /update-plugin — 플러그인 업데이트
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
- **CORE 도메인 문서 생성** — PRODUCT.md(항상), SECURITY.md(항상) + 프로젝트 특성에 따라 FRONTEND.md, BACKEND.md, DATA.md 등
- **CLAUDE.md 하네스 섹션** — `<!-- harness:start/end -->` 마커로 100줄 이내 프로젝트 맵 삽입
- **의존성 레퍼런스 수집** — llms.txt 우선, 없으면 공식 문서 기반 생성
- 프로젝트 `.claude/skills/`에 lint-* 스킬 자동 생성 (CORE 문서 upstream 참조 포함)
- 레거시 harness(index.md, golden-rules.md 등) 자동 마이그레이션 지원
- 재실행 시 변경사항만 diff 기반 업데이트

### 1. /meeting — 대화 → Meeting Log → CPS → PRD

- 한 번에 하나의 질문, 객관식 우선
- 2-3개 접근법 비교, 단계별 승인
- 미확인 사항 자동 추적 (후속 미팅에서 유효성 재검토)
- Visual Companion (브라우저 기반 목업/다이어그램)
- meeting-reviewer가 CPS/PRD 검증 (최대 3회)
- 반복 실행 시 기존 문서 보존 + history/ 관리

### 2. /design-doc — PRD → 5개 설계 문서

- Spec: 기능 목록, 인터페이스, 데이터 모델, 제약조건
- Blueprint: 컴포넌트 목록, 계층 구조, 연결 관계
- Architecture: 기술 스택, 패턴, 제약 (간결한 결정 문서)
- Code-Dev-Plan: Phase별 What/Where/How/Verify (코드 아님)
- Test-Cases: TDD용 테스트 시나리오 정의
- design-doc-reviewer가 교차 문서 일관성 검증
- PRD 변경 시 영향받는 문서만 자동 업데이트

### 3. /implement — 자율 구현

- code-dev-plan의 Phase별 SDD 워커 디스패치
- 각 워커가 TDD로 구현 (테스트 먼저 → 최소 구현 → 리팩터)
- 2단계 리뷰 게이트 (스펙 준수 → 코드 품질)
- 칸반으로 진행 추적, 세션 중단 후 `--continue`로 이어서 가능
- 완료 시 `/lint` 자동 실행

### 4. /lint — 검증

- 요구사항 충족 검증 (PRD 수용 기준, Spec 인터페이스)
- 프로젝트 lint-* 스킬 자동 탐색 및 실행
- 문서 최신 상태 검증 (doc-gardener)
- 품질 점수 산출 (100점 만점)
- FAIL 시 자동 수정 → 재실행 (최대 2회)
- lint-manage로 린트 스킬 자동 진화

### 5. /core-update — 머지 후 CORE 업데이트

- 토픽 브랜치 머지 후 실현된 설계 결정만 CORE 문서에 반영
- 계획/미머지 내용은 절대 포함하지 않음
- CLAUDE.md 하네스 섹션도 필요 시 자동 갱신

---

## Harness Knowledge Base

`/harness-init`이 프로젝트 루트에 생성하는 구조:

```
harness/
├── PRODUCT.md            # 프로젝트 정의, 스택, 아키텍처, 컨벤션 (항상 생성)
├── SECURITY.md           # 보안 원칙, 입력 검증, 비밀 관리 (항상 생성)
├── FRONTEND.md           # 프론트엔드 패턴 (조건부)
├── BACKEND.md            # 백엔드 패턴 (조건부)
├── DATA.md               # 데이터/DB 패턴 (조건부)
├── DESIGN.md             # UI/UX 디자인 패턴 (조건부)
├── INFRA.md              # 인프라/배포 패턴 (조건부)
├── BATCH.md              # 배치 처리 패턴 (조건부)
├── kanban.json           # 전체 토픽 상태 조감도
├── quality-score.md      # 도메인별 품질 점수
├── tech-debt.md          # 기술 부채 추적
├── references/           # 의존성 레퍼런스 (llms.txt 기반)
└── topics/
    └── <topic>/
        ├── kanban.json    # 토픽 진행 상태
        ├── meetings/      # 미팅 로그
        ├── cps.md         # Context-Problem-Solution
        ├── prd.md         # Product Requirements Document
        ├── spec.md        # 기능 상세 명세
        ├── blueprint.md   # 시스템 구성도
        ├── architecture.md # 아키텍처 결정
        ├── code-dev-plan.md # 개발 계획
        ├── test-cases.md  # 테스트 케이스
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
