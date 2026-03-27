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
| design-doc-writer | Opus | PRD-based design document creation (4 docs) |
| design-doc-reviewer | Sonnet | Cross-document consistency, PRD coverage validation |
| doc-gardener | Sonnet | Documentation/rule freshness verification |
| lint-reviewer | Sonnet | lint-* skill aggregation, quality score computation |

### Skills (9)

- **skills/harness-init/** - Codebase analysis and harness knowledge base scaffolding
- **skills/meeting/** - Meeting-driven requirements with visual companion
- **skills/design-doc/** - PRD to design documents (Spec, Blueprint, Architecture, Code-Dev-Plan)
- **skills/implement/** - Autonomous execution using SDD + TDD with kanban tracking
- **skills/lint/** - Requirements verification + project lint-* skill invocation
- **skills/doc-garden/** - Harness documentation freshness validation
- **skills/sdd/** - Subagent-driven development pattern (dispatch + review gates)
- **skills/tdd/** - TDD methodology (RED → GREEN → REFACTOR)
- **skills/using-worktree/** - Worktree setup + working context for isolated development

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
