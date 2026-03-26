---
name: plan
description: "Use this skill to create a detailed implementation plan from an approved spec document. Requires a spec file path as input. Breaks down the spec into phased, actionable implementation steps with file paths, dependencies, risks, and testing strategy. Saves plan to docs/plans/."
---

# Implementation Planning

## Overview

Turn an approved spec document into a detailed, actionable implementation plan.

## When to Activate

- After a spec document has been approved via `/spec`
- When a user has a design document and needs a concrete implementation plan
- Before starting any multi-step implementation work

## Input

A spec document path is required. The plan-writer reads the spec and the existing codebase to produce a plan.

```
/plan docs/specs/2026-03-22-auth-design.md
```

## Planning Process

### 1. Requirements Analysis
- Read the spec document at the provided path
- Understand the feature request completely
- Identify success criteria
- List assumptions and constraints

### 2. Architecture Review
- Analyze existing codebase structure
- Identify affected components
- Review similar implementations
- Consider reusable patterns

### 3. Step Breakdown
Create detailed steps with:
- Clear, specific actions
- File paths and locations
- Dependencies between steps
- Estimated complexity
- Potential risks

### 4. Implementation Order
- Prioritize by dependencies
- Group related changes
- Minimize context switching
- Enable incremental testing

## Execution Strategy Determination

When writing a plan, determine the execution strategy based on the spec's scope and include it in the plan document.

| Condition | Strategy | Reason |
|-----------|----------|--------|
| Single plan | `direct` | Branch only, no phase branches |
| Multiple plans (2+) | `worktree` | Isolation needed, per-phase branches + PRs |
| Spec explicitly mentions parallel work | `worktree` | Isolation required |

**Rules:**
- Direct mode always means a single plan. If multiple plans are generated, it automatically becomes worktree mode.
- Multi-plan file naming: `<date>-<topic>-phase<N>-plan.md`
- The user can override the strategy (direct ↔ worktree).

Add this section at the end of every plan:

```markdown
## Execution Strategy
- type: direct | worktree
- branch_prefix: feature/<topic>
```

## Deduplication Rule

The plan builds ON TOP OF the spec — it does not repeat it.

- **Do NOT copy** Overview, Requirements, Architecture, or code snippets verbatim from the spec
- **Reference** the spec via `## Spec Reference` at the top of the plan
- **Only include** implementation-specific content: phased steps, file-level actions, dependency ordering, risk mitigations, testing strategy
- Code snippets in the plan should add implementation detail beyond the spec's interface definitions (e.g., concrete config values, internal logic, wiring code). If the spec already provides a complete code block, reference it rather than duplicating it.
- `## Success Criteria` should only list plan-specific verification steps (e.g., "grep returns 0 results"), not restate the spec's success criteria

## Plan Format & References

For the plan format template and a worked example, read `skills/plan/references/plan-format.md`.

For best practices, sizing/phasing guidelines, and red flags, read `skills/plan/references/best-practices.md`.

## After Writing the Plan

1. Save to `docs/plans/YYYY-MM-DD-<topic>-plan.md`
2. Commit the plan document to git
3. Dispatch plan-reviewer agent to validate the plan (max 3 iterations)
4. Ask the user to review the plan before proceeding

## Amend Mode

When invoked with an `existing_plan_path` parameter (via `/amend`), operate in amend mode:

- Read the existing plan document
- Understand the change request and updated spec
- Update only the affected phases/steps
- Present the changes to the user for approval
- Dispatch plan-reviewer after updates

### Amend Mode Workflow

1. Read the existing plan at `existing_plan_path`
2. Read the updated spec document (path provided by amend skill)
3. Identify which phases/steps are affected by the change
4. Update only the affected sections of the plan
5. Present the updated plan to the user, highlighting what changed
6. Write the updated plan to the same path
7. Dispatch plan-reviewer for validation (max 3 iterations)
