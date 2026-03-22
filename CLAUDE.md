# CLAUDE.md

## Project Overview

**Flow** is a Claude Code plugin that provides a complete development workflow — from brainstorming through planning, TDD implementation, and code review. Each step is invoked manually by the user, giving full control over the development process.

Core brainstorming methodology is adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent. TDD and code review patterns are adapted from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa.

## Workflow

```
/brainstorm           → spec document (docs/specs/)
/plan <spec-path>     → plan document (docs/plans/)
/tdd                  → TDD implementation (RED → GREEN → REFACTOR)
/amend                → revision orchestrator (spec → plan → TDD)
/code-review          → quality & security review
```

Each step is invoked manually. No automatic chaining.

## Architecture

### Agents (7)

| Agent | Model | Role |
|-------|-------|------|
| design-facilitator | Opus | Brainstorming session facilitator |
| spec-reviewer | Sonnet | Spec document validation |
| planner | Opus | Implementation plan creation |
| plan-reviewer | Sonnet | Plan document validation |
| tdd-guide | Sonnet | TDD cycle enforcement |
| code-reviewer | Sonnet | Security & quality review |
| amender | Opus | Revision orchestrator |

### Skills (2)

- **skills/brainstorming/** - Core brainstorming skill with visual companion and server scripts
- **skills/planning/** - Spec-to-plan conversion with phased implementation steps

### Commands (5)

- `/brainstorm` - Start brainstorming session
- `/plan <spec-path>` - Create implementation plan from spec
- `/tdd` - Interactive TDD session
- `/amend` - Revision orchestrator (amend spec/plan/implementation)
- `/code-review` - Code quality review

### Document Flow

```
docs/specs/YYYY-MM-DD-<topic>-design.md    ← /brainstorm output
docs/plans/YYYY-MM-DD-<topic>-plan.md      ← /plan output
```

## Running the Visual Companion Server

```bash
# Start (requires Node.js, zero dependencies)
skills/brainstorming/scripts/start-server.sh --project-dir /path/to/project

# Stop
skills/brainstorming/scripts/stop-server.sh $SCREEN_DIR
```
