# CLAUDE.md

## Project Overview

**Flow** is a Claude Code plugin that provides a complete development workflow — from spec design through planning, TDD implementation, and code review. Each step is invoked manually via skill slash commands, giving full control over the development process.

Core spec design methodology is adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent. TDD and code review patterns are adapted from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa.

## Workflow

```
/spec              → spec document (docs/specs/)
/plan <spec-path>  → plan document (docs/plans/)
/implement <plan>  → automated execution (SDD + TDD)
/code-review       → quality & security review
/amend             → revision orchestrator (spec → plan)
```

Standalone skills:
```
/tdd               → manual TDD guide (RED → GREEN → REFACTOR)
/sdd               → subagent-driven execution (independent of /implement)
/using-worktree    → isolated worktree workspace
```

## Architecture

### Agents (6)

| Agent | Model | Role |
|-------|-------|------|
| spec-facilitator | Opus | Spec design session facilitator |
| spec-reviewer | Sonnet | Spec document validation |
| plan-writer | Opus | Implementation plan creation |
| plan-reviewer | Sonnet | Plan document validation |
| code-reviewer | Sonnet | Security & quality review |
| amend-orchestrator | Opus | Revision orchestrator |

### Skills (8)

- **skills/spec/** - Design spec creation with visual companion
- **skills/plan/** - Spec-to-plan conversion with phased implementation
- **skills/implement/** - Plan execution using SDD + TDD
- **skills/sdd/** - Subagent-driven development pattern (dispatch + review gates)
- **skills/tdd/** - TDD methodology (RED → GREEN → REFACTOR)
- **skills/code-review/** - Security and quality review
- **skills/amend/** - Revision orchestrator (spec → plan)
- **skills/using-worktree/** - Worktree setup + working context for isolated development

### Document Flow

```
docs/specs/YYYY-MM-DD-<topic>-design.md    ← /spec output
docs/plans/YYYY-MM-DD-<topic>-plan.md      ← /plan output
```

## Running the Visual Companion Server

```bash
# Start (requires Node.js, zero dependencies)
skills/spec/scripts/start-server.sh --project-dir /path/to/project

# Stop
skills/spec/scripts/stop-server.sh $SCREEN_DIR
```

## Parallel Development with Worktrees

```
/spec "feature" → /using-worktree → /plan → /implement → /code-review
```

## Versioning

버전 변경 시 반드시 두 파일을 함께 수정:

- `.claude-plugin/plugin.json` → `"version"` 필드
- `.claude-plugin/marketplace.json` → `plugins[0].version` 필드

1.0.0 이전까지 패치 버전만 올린다 (0.0.1 → 0.0.2 → ...).
