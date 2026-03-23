# CLAUDE.md

## Project Overview

**Flow** is a Claude Code plugin that provides a complete development workflow — from spec design through planning, TDD implementation, and code review. Each step is invoked manually via skill slash commands, giving full control over the development process.

Core spec design methodology is adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent. TDD and code review patterns are adapted from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa.

## Workflow

```
/spec              → spec document (docs/specs/)
/plan <spec-path>  → plan document (docs/plans/)
/tdd               → TDD implementation (RED → GREEN → REFACTOR)
/amend             → revision orchestrator (spec → plan → TDD)
/code-review       → quality & security review
/branch-finish     → merge, PR, keep, or discard
```

Some skills offer optional chaining prompts (e.g., /spec → /using-worktree, /code-review → /branch-finish) with user confirmation via AskUserQuestion.

## Architecture

### Agents (7)

| Agent | Model | Role |
|-------|-------|------|
| design-facilitator | Opus | Spec design session facilitator |
| spec-reviewer | Sonnet | Spec document validation |
| planner | Opus | Implementation plan creation |
| plan-reviewer | Sonnet | Plan document validation |
| tdd-guide | Sonnet | TDD cycle enforcement |
| code-reviewer | Sonnet | Security & quality review |
| amender | Opus | Revision orchestrator |

### Skills (9)

- **skills/spec/** - Design spec creation with visual companion
- **skills/plan/** - Spec-to-plan conversion with phased implementation
- **skills/tdd/** - TDD workflow with mocking patterns and coverage
- **skills/amend/** - Revision orchestrator (spec → plan → TDD)
- **skills/code-review/** - Security and quality review + branch finish prompt
- **skills/using-worktree/** - Worktree setup + working context for isolated development
- **skills/branch-finish/** - Branch completion (merge/PR/keep/discard) with port release and worktree cleanup
- **skills/port-assign/** - Port block allocation (10000-20000)
- **skills/port-release/** - Port block deallocation
- **skills/port-status/** - Port allocation status with live detection

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
/spec "feature" → worktree prompt → /using-worktree → /plan → /tdd → /code-review → /branch-finish
```

Port configuration: `.flow/config.json`
Worktree state: `.flow/worktrees.json` (auto-managed)

## Versioning

버전 변경 시 반드시 두 파일을 함께 수정:

- `.claude-plugin/plugin.json` → `"version"` 필드
- `.claude-plugin/marketplace.json` → `plugins[0].version` 필드

1.0.0 이전까지 패치 버전만 올린다 (0.0.1 → 0.0.2 → ...).
