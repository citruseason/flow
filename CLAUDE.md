# CLAUDE.md

## Project Overview

**Flow** is a Claude Code plugin that provides a complete development workflow — from harness setup through meeting-driven requirements, design documentation, autonomous implementation, and lint verification. Each step is invoked via skill slash commands. Implementation through lint runs autonomously without user intervention.

Core meeting/design methodology integrates patterns from [Harness Engineering](https://openai.com/index/harness-engineering/) (OpenAI). TDD patterns are adapted from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa.

## Workflow

```
/harness-init          → harness/ knowledge base + lint-* skills
/meeting "topic"       → Meeting Log → CPS → PRD (harness/topics/<topic>/)
/design-doc <topic>    → Spec, Blueprint, Architecture, Code-Dev-Plan
/implement <topic>     → autonomous execution (SDD + TDD → /lint)
/lint <topic>          → requirements verification + lint-* skills
```

Standalone skills:
```
/lint-integrate        → add/update external skills as lint-* wrappers
/core-update <topic>   → update CORE docs with realized decisions post-merge
/doc-garden            → harness/ documentation freshness check
/tdd                   → manual TDD guide (RED → GREEN → REFACTOR)
/sdd                   → subagent-driven execution (independent of /implement)
/using-worktree        → isolated worktree workspace
/update-plugin         → manual plugin update
```

## Architecture

### Agents (7)

| Agent | Model | Role |
|-------|-------|------|
| harness-initializer | Opus | Codebase analysis, harness/ scaffolding, lint-* skill generation |
| meeting-facilitator | Opus | Meeting dialogue, Meeting Log/CPS/PRD generation |
| meeting-reviewer | Sonnet | CPS/PRD validation |
| design-doc-writer | Opus | PRD-based design document creation (5 docs) |
| design-doc-reviewer | Sonnet | Cross-document consistency, PRD coverage validation |
| doc-gardener | Sonnet | Documentation/rule freshness verification |
| lint-reviewer | Sonnet | lint-* skill aggregation, quality score computation |

### Skills (14)

- **skills/harness-init/** - Codebase analysis and harness knowledge base scaffolding
- **skills/meeting/** - Meeting-driven requirements with visual companion
- **skills/design-doc/** - PRD to design documents (Spec, Blueprint, Architecture, Code-Dev-Plan)
- **skills/implement/** - Autonomous execution using SDD + TDD with kanban tracking
- **skills/lint/** - Requirements verification + project lint-* skill invocation
- **skills/lint-manage/** - Lint skill evolution (create/update rules based on code changes)
- **skills/lint-integrate/** - External skill integration into lint workflow (add/update/list/remove)
- **skills/lint-validate/** - Lint skill health validation (structure, freshness, detection)
- **skills/core-update/** - Post-merge CORE document update with realized decisions
- **skills/doc-garden/** - Harness documentation freshness validation
- **skills/sdd/** - Subagent-driven development pattern (dispatch + review gates)
- **skills/tdd/** - TDD methodology (RED → GREEN → REFACTOR)
- **skills/using-worktree/** - Worktree setup + working context for isolated development
- **skills/update-plugin/** - Manual plugin update

### Document Flow

```
harness/
├── index.md, kanban.json, quality-score.md, ...
└── topics/<topic>/
    ├── meetings/, cps.md, prd.md
    ├── spec.md, blueprint.md, architecture.md, code-dev-plan.md
    ├── history/                        ← version tracking (max 2)
    └── kanban.json                     ← topic progress tracking
```

## Running the Visual Companion Server

```bash
# Start (requires Node.js, zero dependencies)
skills/meeting/scripts/start-server.sh --project-dir /path/to/project

# Stop
skills/meeting/scripts/stop-server.sh $SCREEN_DIR
```

## Parallel Development with Worktrees

```
/meeting "feature" → /using-worktree → /design-doc → /implement → /lint
```

## Versioning

버전 변경 시 반드시 두 파일을 함께 수정:

- `.claude-plugin/plugin.json` → `"version"` 필드
- `.claude-plugin/marketplace.json` → `plugins[0].version` 필드

1.0.0 이전까지 패치 버전만 올린다 (0.0.1 → 0.0.2 → ...).

<!-- harness:start -->
## Harness

**Flow** -- Claude Code용 완전한 개발 워크플로우 플러그인

### Language
한국어

### 기술 스택
Markdown (프롬프트) / JavaScript-CJS (서버) / Bash (스크립트) / JSON (설정)

### 아키텍처
계층형 플러그인 -- Skills (오케스트레이션) -> Agents (실행) -> Infrastructure (스크립트)

### CORE 문서
| 문서 | 목적 |
|------|------|
| [PRODUCT.md](harness/PRODUCT.md) | 제품 정의, 기술 스택, 규칙 |
| [SECURITY.md](harness/SECURITY.md) | 보안 원칙, 입력 검증, 프로세스 격리 |
| [ARCHITECTURE.md](harness/ARCHITECTURE.md) | 아키텍처 패턴, 모듈 구성, 의존성 방향 |
| [PIPELINE.md](harness/PIPELINE.md) | 워크플로우 순서, 자율 실행 경계, 사용자 게이트 |
| [OBSERVABILITY.md](harness/OBSERVABILITY.md) | 로깅 형식, 로그 레벨, 에러 전파, 메트릭 |

### 운영 문서
| 문서 | 목적 |
|------|------|
| [quality-score.md](harness/quality-score.md) | 품질 평가 기준 및 도메인 점수 |
| [tech-debt.md](harness/tech-debt.md) | 기술 부채 목록 |
| [kanban.json](harness/kanban.json) | 토픽 추적 |

### 규칙
`harness/rules/` 디렉토리에서 도메인+스택별 규칙 파일 관리

### 참조 문서
`harness/references/`에서 의존성 참조 문서를 확인할 수 있다.

### 린트 스킬
- **lint-architecture** -- 에이전트-스킬 분리, 의존성 방향, 모델 할당
- **lint-code-convention** -- 파일 네이밍, 프론트매터 형식, JS/셸 스타일, 출력 언어
- **lint-plugin-structure** -- 매니페스트 일관성, 도구 선언, 출력 계약, 스키마
- **lint-workflow-integrity** -- 파이프라인 완전성, 작성자-검토자 페어링, 이력 순환
<!-- harness:end -->
