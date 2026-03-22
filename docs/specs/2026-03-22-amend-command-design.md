# /amend Command Design Spec

## Overview

Replace `/tdd-workflow` with `/amend` — a dedicated command for modifying specs, plans, and implementation during development. A new `amender` agent acts as an orchestrator, delegating to existing agents based on the scope of the change.

## Motivation

The current workflow lacks an explicit "revision" step. When users discover issues during or after TDD implementation, there's no structured way to propagate changes back through specs and plans. `/tdd-workflow` served as a generic TDD reference but didn't address this gap.

## Input

Free-text natural language via manual invocation:

```
/amend 로그인 실패 시 에러 메시지를 토스트로 변경해줘
/amend Change error messages to use toast notifications on login failure
```

No file path required. The amender agent automatically locates relevant spec/plan documents.

## Routing Logic

The amender agent evaluates the change request and selects one of two paths:

### Path 1: Minor Change (no spec/plan update needed)

```
amender -> tdd-guide -> TDD implementation
```

Criteria:
- Cosmetic changes (image swap, button repositioning, color change)
- Typo fixes
- No behavioral or architectural impact
- Existing spec/plan still accurately describes the system

### Path 2: Spec-level Change (spec/plan update required)

```
amender -> design-facilitator (update spec, user confirms)
         -> planner (update plan, user confirms)
         -> tdd-guide (TDD implementation of changes)
```

Criteria:
- Behavioral changes (error handling, validation logic)
- New or removed functionality
- Architectural modifications
- Existing spec/plan no longer accurately describes the desired system

## Agent: amender

- **Model:** Opus
- **Role:** Orchestrator for revision workflow
- **Responsibilities:**
  1. Receive free-text change request from user
  2. Locate relevant spec and plan documents (search `docs/specs/` and `docs/plans/`)
  3. Assess change scope (minor vs. spec-level)
  4. Delegate to appropriate agents in sequence
  5. Ensure user confirmation gates between steps

## File Changes

| Action | File | Description |
|--------|------|-------------|
| Create | `commands/amend.md` | Command definition |
| Create | `agents/amender.md` | Orchestrator agent prompt |
| Delete | `commands/tdd-workflow.md` | Replaced by /amend |
| Delete | `skills/tdd-workflow/SKILL.md` | No longer needed |
| Update | `CLAUDE.md` | Workflow and command list |
| Update | `README.md` | Documentation |

## Final Workflow

```
/brainstorm  -> spec document (docs/specs/)
/plan        -> plan document (docs/plans/)
/tdd         -> TDD implementation
/amend       -> revision orchestrator (delegates to existing agents)
/code-review -> security and quality review
```

Each step is invoked manually. No automatic chaining.

## Delegation Detail

The amender agent does NOT duplicate logic from other agents. It:
- Passes spec modification requests to `design-facilitator` with the existing spec path and change description
- Passes plan modification requests to `planner` with the existing plan path and change description
- Passes implementation requests to `tdd-guide` with the specific changes to implement

Each delegated agent operates within its normal workflow, scoped to the change rather than a full creation.
