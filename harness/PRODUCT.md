# 제품 정의

## 개요

- **이름:** Flow
- **버전:** 0.0.12
- **설명:** Claude Code용 완전한 개발 워크플로우 플러그인 -- 하네스 설정부터 미팅 기반 요구사항 정의, 설계 문서 작성, 자율 구현, 린트 검증까지 전 과정을 지원한다.
- **유형:** Claude Code 플러그인 (프롬프트 기반 CLI 워크플로우 도구)
- **라이선스:** MIT

## 기술 스택

- **언어:** Markdown (주요 -- 에이전트/스킬 프롬프트), JavaScript-CJS (서버, 헬퍼), Bash (셸 스크립트), JSON (설정, 칸반)
- **프레임워크:** 없음 (의존성 없는 Node.js WebSocket 서버)
- **주요 라이브러리:** Node.js 내장 모듈만 사용 (`crypto`, `http`, `fs`, `path`)
- **빌드 도구:** 없음 (컴파일 및 번들링 불필요)
- **테스트 프레임워크:** 현재 없음 (권장: `node:test` 내장 테스트 러너)

## 아키텍처

- **패턴:** 계층형 플러그인 -- 오케스트레이션(skills/) -> 실행(agents/) -> 인프라(scripts/)
- **모듈 구성:** 역할별 구분 (agents/, skills/, hooks/, harness/)
- **API 스타일:** 슬래시 명령 호출과 구조화된 문서 I/O

### 3계층 모델

```
skills/       오케스트레이션 계층 -- 에이전트 디스패치, 확인 게이트 관리, 칸반 업데이트, git 처리
agents/       실행 계층 -- 분석, 생성, 검토 수행
scripts/      인프라 계층 -- WebSocket 서버, 프로세스 관리
```

### 에이전트-스킬 분리

- 에이전트는 작업을 실행한다 (분석, 작성, 검토). 스킬은 오케스트레이션한다 (에이전트 디스패치, 확인 게이트 관리, 칸반 업데이트, git 커밋 처리).
- 에이전트는 오케스트레이션 작업을 절대 수행하지 않으며, 스킬은 실행 로직을 절대 포함하지 않는다.

### 의존성 방향

- 스킬은 슬래시 명령으로 다른 스킬을 참조할 수 있다.
- 에이전트는 다른 에이전트를 참조해서는 안 된다.
- 스크립트는 에이전트나 스킬을 참조해서는 안 된다.
- 의존성 흐름: skills -> agents -> references, 역방향 불가.

### 자기 완결적 스킬

- 모든 스킬 디렉토리에는 유효한 YAML 프론트매터(`name`, `description`)가 포함된 SKILL.md가 있어야 한다.
- `references/` 디렉토리는 보조 문서용으로 선택 사항이다.
- 스킬은 자체 디렉토리 또는 `harness/` 외부의 파일에 의존해서는 안 된다.

### 모델 할당

- **작성 에이전트는 Opus 사용:** harness-initializer, meeting-facilitator, design-doc-writer -- 콘텐츠를 생성하는 모든 에이전트는 `model: opus`를 사용해야 한다.
- **검토 에이전트는 Sonnet 사용:** meeting-reviewer, design-doc-reviewer, doc-gardener, lint-reviewer -- 검증 또는 검토하는 모든 에이전트는 `model: sonnet`을 사용해야 한다.

### 에이전트 (7개)

| 에이전트 | 모델 | 역할 |
|----------|------|------|
| harness-initializer | Opus | 코드베이스 분석, harness/ 스캐폴딩, lint-* 스킬 생성 |
| meeting-facilitator | Opus | 미팅 대화, 미팅 로그/CPS/PRD 생성 |
| meeting-reviewer | Sonnet | CPS/PRD 검증 |
| design-doc-writer | Opus | PRD 기반 설계 문서 작성 (5개 문서) |
| design-doc-reviewer | Sonnet | 문서 간 일관성 검증, PRD 커버리지 검증 |
| doc-gardener | Sonnet | 문서/규칙 최신성 검증 |
| lint-reviewer | Sonnet | lint-* 스킬 종합, 품질 점수 산출 |

### 스킬 (14개)

| 스킬 | 경로 | 목적 |
|------|------|------|
| harness-init | skills/harness-init/ | 코드베이스 분석 및 하네스 지식 베이스 스캐폴딩 |
| meeting | skills/meeting/ | 비주얼 컴패니언을 활용한 미팅 기반 요구사항 정의 |
| design-doc | skills/design-doc/ | PRD에서 설계 문서로 변환 (Spec, Blueprint, Architecture, Code-Dev-Plan, Test-Cases) |
| implement | skills/implement/ | SDD + TDD를 활용한 자율 실행 및 칸반 추적 |
| lint | skills/lint/ | 요구사항 검증 + 프로젝트 lint-* 스킬 실행 |
| lint-manage | skills/lint-manage/ | 린트 스킬 진화 (코드 변경 기반 규칙 생성/업데이트) |
| lint-integrate | skills/lint-integrate/ | 외부 스킬을 린트 워크플로우에 통합 |
| lint-validate | skills/lint-validate/ | 린트 스킬 상태 검증 (구조, 최신성, 감지) |
| core-update | skills/core-update/ | 병합 후 CORE 문서를 실현된 결정으로 업데이트 |
| doc-garden | skills/doc-garden/ | 하네스 문서 최신성 검증 |
| sdd | skills/sdd/ | 서브에이전트 기반 개발 패턴 (디스패치 + 리뷰 게이트) |
| tdd | skills/tdd/ | TDD 방법론 (RED -> GREEN -> REFACTOR) |
| using-worktree | skills/using-worktree/ | 격리된 개발을 위한 워크트리 설정 + 작업 컨텍스트 |
| update-plugin | skills/update-plugin/ | 수동 플러그인 업데이트 |

## 파이프라인

### 순차 워크플로우

```
/harness-init -> /meeting -> /design-doc -> /implement -> /lint
```

- 단계를 건너뛸 수 없다. 각 단계의 출력은 다음 단계의 입력이 된다.
- **자율 실행 경계:** `/implement` 시작부터 `/lint` 완료까지 사용자 개입 없이 진행된다. 심각한 불일치나 해결 불가능한 차단 문제가 있을 때만 에스컬레이션한다.
- **사용자 승인 게이트:** 미팅과 설계 문서 단계에서 사용자 승인이 필요하다. CPS, PRD, 최종 설계 문서 세트를 승인해야 다음 단계로 진행할 수 있다. 이 게이트를 우회해서는 안 된다.

### 문서 흐름

```
harness/
├── PRODUCT.md, SECURITY.md, kanban.json, quality-score.md, tech-debt.md
└── topics/<topic>/
    ├── meetings/, cps.md, prd.md
    ├── spec.md, blueprint.md, architecture.md, code-dev-plan.md, test-cases.md
    ├── history/                        <- 버전 추적 (최대 2개)
    └── kanban.json                     <- 토픽 진행 추적
```

### 문서 이력

- **최대 2개 버전의 FIFO 순환:** 문서를 `history/`에 보관할 때 일관된 FIFO 순환을 사용한다: v1 = 가장 최근 이전 버전, v2 = 더 오래된 버전. 문서당 최대 2개의 보관 버전을 유지한다.

## 규칙

### 네이밍

- **파일:** 모든 파일에 kebab-case 사용 (`meeting-facilitator.md`, `start-server.sh`, `server.cjs`)
- **디렉토리:** kebab-case (`harness-init/`, `lint-architecture/`, `design-doc/`)
- **에이전트/스킬 이름:** YAML 프론트매터에서 kebab-case (`name: meeting-facilitator`)
- **JavaScript 함수:** camelCase (`computeAcceptKey`, `encodeFrame`, `handleRequest`)
- **JavaScript 상수 (모듈 수준):** UPPER_SNAKE_CASE (`OPCODES`, `WS_MAGIC`, `IDLE_TIMEOUT_MS`, `MIME_TYPES`)
- **셸 변수:** UPPER_SNAKE_CASE (`SCREEN_DIR`, `PID_FILE`, `SERVER_PID`)

### 포맷팅

- **들여쓰기:** 2칸 공백 (JavaScript, JSON, YAML, 셸)
- **세미콜론:** JavaScript에서 필수
- **따옴표:** JavaScript에서 작은따옴표, JSON에서 큰따옴표
- **후행 쉼표:** JavaScript 객체/배열에서 사용
- **줄 길이:** 엄격한 제한 없음, 가독성 우선

### 임포트 / 익스포트

- **JavaScript:** CommonJS (`require` / `module.exports`). ES 모듈 사용 금지.
- **임포트 순서:** Node.js 내장 모듈 먼저, 이후 로컬 모듈.

### 에러 처리

- **JavaScript:** 연결 수준에서 try/catch, 에러는 `console.error()`로 기록하며 전파하지 않음
- **셸:** JSON 에러 출력 (`echo '{"error": "..."}'`) 후 `exit 1`
- **에이전트/스킬:** 린트 결과 계약에 따른 구조화된 출력 (PASS/WARNING/FAIL 및 소견)
- **에스컬레이션:** N번 재시도 후 구체적인 컨텍스트와 함께 사용자에게 에스컬레이션

### 타이핑

- 해당 없음 (TypeScript 미사용, 타입 어노테이션 없음)

### 주석

- **JavaScript:** 섹션 헤더와 명확하지 않은 로직에 인라인 `//` 주석
- **셸:** 사용법 문서, 인자 설명에 `#` 주석
- **Markdown 프롬프트:** `##` 섹션으로 구조화, 코드 블록으로 예시, 표로 데이터 표현

### Git

- **커밋 형식:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`)
- **브랜치 네이밍:** 토픽 브랜치에 `feature/<topic>`
- **버전 동기화:** `plugin.json`과 `marketplace.json` 버전은 항상 일치해야 한다. 두 파일을 반드시 함께 업데이트한다.
- **패치 전용 버전 관리:** 1.0.0까지는 패치 버전만 올린다 (0.0.1 -> 0.0.2 -> ...).

### 출력 언어

- 모든 생성 문서는 프로젝트 CLAUDE.md 하네스 섹션에 지정된 언어를 따른다. 언어는 `/harness-init` 실행 시 설정된다. 언어가 지정되지 않은 경우 영어를 기본값으로 사용한다.

## 관찰 가능성

### 로깅 형식

모든 런타임 로깅은 구조화된 JSON을 사용한다. WebSocket 서버(`skills/meeting/scripts/server.cjs`)는 stdout에 한 줄당 하나의 JSON 객체를 출력한다:

```json
{"type": "server-started", "port": 52341, "host": "127.0.0.1", "url": "http://localhost:52341", "screen_dir": "/path/to/session"}
{"type": "screen-added", "file": "/path/to/file.html"}
{"type": "screen-updated", "file": "/path/to/file.html"}
{"source": "user-event", "type": "click", "choice": "a", "text": "Option A", "timestamp": 1706000101}
{"type": "server-stopped", "reason": "idle timeout"}
```

셸 스크립트는 에러에 대해 JSON을 출력한다:

```json
{"error": "Server failed to start within 5 seconds"}
{"error": "Unknown argument: --bad-flag"}
{"status": "stopped"}
{"status": "not_running"}
```

### 로그 수준

- **ERROR:** 주의가 필요한 예기치 않은 장애 (예: WebSocket 디코드 실패, fs.watch 에러)
- **WARN:** 복구 가능한 문제 또는 성능 저하 (현재 미사용 -- 향후 추가 권장)
- **INFO:** 중요한 상태 변경 및 비즈니스 이벤트 (server-started, screen-added, server-stopped)
- **DEBUG:** 개발용 진단 정보 (현재 미사용 -- 향후 추가 권장)

### 로깅 규칙

- 서버는 구조화된 이벤트에 `console.log(JSON.stringify({...}))`를, 파싱 실패에 `console.error(...)`를 사용한다
- 셸 스크립트는 에러 출력에 `echo '{"error": "..."}'`를, 상태에 `echo '{"status": "..."}'`를 사용한다
- 로그 수준을 명시적으로 설정하지 않는다 -- 모든 출력은 stdout 또는 stderr로 전달된다
- 세션 생명주기 이벤트(started, stopped)에는 항상 `type` 필드를 포함한다
- 사용자 상호작용 이벤트에는 항상 `source: "user-event"` 필드를 포함한다

### 에러 전파

```
에이전트 출력 에러       -> 스킬이 구조화된 소견을 읽고 처리
서버 런타임 에러         -> stdout/stderr에 JSON 출력, 서버는 계속 실행
셸 스크립트 에러         -> JSON 에러 출력 + 0이 아닌 종료 코드
검토 실패               -> 작성자-검토자 루프 (최대 3회) -> 사용자 에스컬레이션
구현 실패               -> SDD 재시도 (최대 2회) -> 사용자 에스컬레이션
```

### 메트릭

메트릭 계측 없음. 이 프로젝트는 영구 런타임이 없는 프롬프트 기반 CLI 플러그인이다. 관찰 가능성은 다음을 통해 달성한다:

- WebSocket 서버의 구조화된 JSON 로깅
- 린트 스킬 출력 계약 (Status/Findings/Summary)
- `harness/quality-score.md`의 품질 점수 산출
- `harness/kanban.json` 및 토픽 수준 칸반 파일의 상태 추적
