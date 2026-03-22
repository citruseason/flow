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

The amender agent evaluates the change request and selects one of two paths.

**Default rule:** When the classification is ambiguous, default to Path 2 (safer — updating docs costs little, missing a needed update costs rework).

### Path 1: Minor Change (no spec/plan update needed)

```
amender -> tdd-guide -> TDD implementation
```

Criteria (ALL must be true):
- Cosmetic changes (image swap, button repositioning, color change) or typo fixes
- No behavioral or architectural impact
- Existing spec/plan still accurately describes the system after the change

### Path 2: Spec-level Change (spec/plan update required)

```
amender -> design-facilitator (update spec, user confirms)
         -> planner (update plan, user confirms)
         -> tdd-guide (TDD implementation of changes)
```

Criteria (ANY triggers Path 2):
- Behavioral changes (error handling, validation logic, timeout values)
- New or removed functionality
- Architectural modifications
- Public API changes (renaming endpoints, changing signatures)
- Existing spec/plan no longer accurately describes the desired system

## Document Discovery

The amender agent locates relevant documents using this algorithm:

1. List all files in `docs/specs/` and `docs/plans/`, sorted by date (most recent first)
2. Read the most recent spec and plan
3. If there are multiple specs/plans, read their titles/overviews and match against the change request by topic relevance
4. Present the matched documents to the user for confirmation before proceeding

**Edge cases:**

- **No spec exists:** Path 2 cannot update a nonexistent spec. The amender informs the user and suggests running `/brainstorm` first, then `/amend` after the spec exists.
- **No plan exists:** Same — suggest `/plan` first.
- **Multiple matching specs/plans:** Present the candidates and ask the user to confirm which one to amend.
- **Spec exists but no corresponding plan:** The amender runs design-facilitator to update the spec, then delegates to planner in create mode (normal `/plan` behavior) rather than update mode.

## Agent: amender

- **Model:** Opus
- **Role:** Orchestrator for revision workflow
- **Responsibilities:**
  1. Receive free-text change request from user
  2. Locate relevant spec and plan documents (see Document Discovery)
  3. Assess change scope (minor vs. spec-level; default to Path 2 when ambiguous)
  4. Delegate to appropriate agents in sequence
  5. Ensure user confirmation gates between steps

## User Confirmation Gates

Each delegation step in Path 2 requires user confirmation before proceeding to the next:

1. **After spec update:** The amender shows the updated spec diff and asks "스펙 변경사항이 맞나요?" The user can:
   - **Approve** — proceed to plan update
   - **Request changes** — re-run design-facilitator with additional instructions
   - **Abort** — stop the entire amend flow

2. **After plan update:** The amender shows the updated plan diff and asks "플랜 변경사항이 맞나요?" Same approve/change/abort options.

3. **After TDD implementation:** Normal TDD flow — tests must pass before completion.

## Required Agent Modifications

Existing agents need an "amend mode" to support editing existing documents rather than creating new ones:

### design-facilitator
- Accept an optional `existing_spec_path` parameter
- When provided: read the existing spec, apply the change request as a targeted modification (skip full brainstorming exploration), present the diff to the user
- When not provided: normal brainstorming flow
- Still dispatch `spec-reviewer` after updates

### planner
- Accept an optional `existing_plan_path` parameter
- When provided: read the existing plan, update only the affected phases/steps, present the diff to the user
- When not provided: normal plan creation flow
- Add `Write` and `Edit` to the planner's tool list (currently only has `Read`, `Grep`, `Glob`)
- Still dispatch `plan-reviewer` after updates

### tdd-guide
- No structural changes needed — it already receives specific implementation instructions
- The amender will scope the request to "implement only these changes" rather than a full feature

## Reviewer Agents

When specs or plans are updated via `/amend`:
- `spec-reviewer` runs after spec updates (same as in `/brainstorm`)
- `plan-reviewer` runs after plan updates (same as in `/plan`)

This ensures amended documents maintain the same quality bar as newly created ones.

## tdd-workflow Skill Migration

`tdd-guide.md` currently references `skill: tdd-workflow` for mocking patterns and framework-specific examples. Before deleting the skill:

1. Move the reusable TDD reference content (mocking patterns, coverage thresholds, test organization) into the `tdd-guide` agent prompt directly — this keeps all TDD guidance self-contained in one agent
2. Update `tdd-guide.md` line 80: replace `see skill: tdd-workflow` with the inlined content
3. Then delete `commands/tdd-workflow.md` and `skills/tdd-workflow/SKILL.md`

## File Changes

| Action | File | Description |
|--------|------|-------------|
| Create | `commands/amend.md` | Command definition |
| Create | `agents/amender.md` | Orchestrator agent prompt |
| Update | `agents/design-facilitator.md` | Add amend mode (existing_spec_path) |
| Update | `agents/planner.md` | Add amend mode (existing_plan_path), add Write/Edit tools |
| Update | `agents/tdd-guide.md` | Remove tdd-workflow skill reference, inline or relocate content |
| Delete | `commands/tdd-workflow.md` | Replaced by /amend |
| Delete | `skills/tdd-workflow/SKILL.md` | Content migrated to tdd-guide |
| Update | `CLAUDE.md` | Add amender to Agents table (7 agents), replace /tdd-workflow with /amend in Commands, remove tdd-workflow from Skills, update workflow diagram |
| Update | `README.md` | Match CLAUDE.md changes |

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

Each delegated agent operates within its normal workflow (including reviewer dispatch), scoped to the change rather than a full creation.
