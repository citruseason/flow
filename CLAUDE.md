# CLAUDE.md

## Project Overview

**Flow** is a Claude Code plugin that provides a complete development workflow — from brainstorming through planning, TDD implementation, and code review. Each step is invoked manually via skill slash commands, giving full control over the development process.

Core brainstorming methodology is adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent. TDD and code review patterns are adapted from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa.

## Workflow

```
/spec              → spec document (docs/specs/)
/plan <spec-path>  → plan document (docs/plans/)
/tdd               → TDD implementation (RED → GREEN → REFACTOR)
/amend             → revision orchestrator (spec → plan → TDD)
/code-review       → quality & security review
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

### Skills (5)

- **skills/spec/** - Design spec creation with visual companion
- **skills/plan/** - Spec-to-plan conversion with phased implementation
- **skills/tdd/** - TDD workflow with mocking patterns and coverage
- **skills/amend/** - Revision orchestrator (spec → plan → TDD)
- **skills/code-review/** - Security and quality review

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
