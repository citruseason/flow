---
name: amend
description: "Revision orchestrator for modifying existing specs, plans, and implementation. Assesses change scope and delegates to appropriate agents. Invoke explicitly when modifications are needed."
---

# Amend -- Revision Orchestrator

Revision orchestrator for the Flow workflow. When the user requests a change to an existing feature, assess scope, locate relevant documents, and delegate to specialized agents.

## Input

A free-text change request from the user. No file path is needed -- the skill discovers relevant documents automatically.

```
/amend <change request>
```

## Document Discovery

Locate relevant documents using this algorithm:

1. List all files in `docs/specs/` and `docs/plans/`, sorted by date (most recent first)
2. Read the most recent spec and plan
3. If multiple specs/plans exist, read their titles/overviews and match against the change request by topic relevance
4. Present the matched documents to the user for confirmation before proceeding

**Edge cases:**
- **No spec exists:** Inform the user and suggest running `/spec` first
- **No plan exists:** Inform the user and suggest running `/plan` first
- **Multiple matching specs/plans:** Present candidates and ask the user to confirm which one to amend
- **Spec exists but no corresponding plan:** After updating the spec, delegate to plan-writer in create mode (normal `/plan` behavior)

## Routing Logic

Evaluate the change request and select one of two paths.

**Default rule:** When classification is ambiguous, default to Path 2 (safer).

### Path 1: Minor Change

Criteria (ALL must be true):
- Cosmetic changes (image swap, button repositioning, color change) or typo fixes
- No behavioral or architectural impact
- Existing spec/plan still accurately describes the system after the change

Flow:
1. Dispatch `tdd` agent with the specific change to implement

### Path 2: Spec-level Change

Criteria (ANY triggers Path 2):
- Behavioral changes (error handling, validation logic, timeout values)
- New or removed functionality
- Architectural modifications
- Public API changes (renaming endpoints, changing signatures)
- Existing spec/plan no longer accurately describes the desired system

Flow:
1. Dispatch `spec-facilitator` agent with `existing_spec_path` and change description
2. **User confirmation gate** -- show updated spec diff, ask "스펙 변경사항이 맞나요?"
   - Approve: proceed to step 3
   - Request changes: re-run spec-facilitator with additional instructions
   - Abort: stop the entire amend flow
3. Dispatch `plan-writer` agent with `existing_plan_path` and change description
4. **User confirmation gate** -- show updated plan diff, ask "플랜 변경사항이 맞나요?"
   - Approve: proceed to step 5
   - Request changes: re-run plan-writer with additional instructions
   - Abort: stop the entire amend flow
5. Dispatch `tdd` agent with the specific changes to implement

## User Confirmation Gates

Two confirmation gates exist in Path 2 to ensure changes are correct before proceeding:

1. **After spec update:** "스펙 변경사항이 맞나요?"
2. **After plan update:** "플랜 변경사항이 맞나요?"

At each gate the user may:
- **Approve** -- proceed to the next step
- **Request changes** -- re-run the previous agent with additional instructions
- **Abort** -- stop the entire amend flow

Do NOT skip confirmation gates. Each gate must receive explicit user approval before continuing.

## Workflow Summary

```
User: /amend <change request>
  |
  v
[Document Discovery] -> confirm docs with user
  |
  v
[Assess Scope]
  |
  +--> Path 1 (minor) --> tdd --> done
  |
  +--> Path 2 (spec-level) --> spec-facilitator --> user confirms
                                --> plan-writer --> user confirms
                                --> tdd --> done
```

## Agent Dispatch

This skill dispatches agents directly (NOT other skills):

- **Path 1:** dispatch `tdd` agent
- **Path 2:** dispatch `spec-facilitator` agent (with `existing_spec_path`) -> `plan-writer` agent (with `existing_plan_path`)

## What This Skill Does NOT Do

- Write spec or plan content itself (delegates to spec-facilitator and plan-writer)
- Implement code itself (delegates to tdd)
- Skip user confirmation gates
