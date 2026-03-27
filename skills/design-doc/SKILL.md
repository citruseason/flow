---
name: design-doc
description: "Create design documents (Spec, Blueprint, Architecture, Code-Dev-Plan, Test-Cases) from an approved PRD. Use after /meeting completes."
---

# Design Document Creation

## Overview

Turn an approved PRD into five interconnected design documents: spec.md, blueprint.md, architecture.md, and code-dev-plan.md. These documents bridge the gap between product requirements and implementation.

## When to Activate

- After `/meeting` completes and a PRD is approved
- When a topic has a `prd.md` and needs design documents before implementation
- When PRD changes require design document updates

## Input

A topic name is required. The skill reads the PRD from the topic directory.

```
/design-doc <topic>
```

## Checklist

Execute these steps in order. **No per-document user approval** — generate all documents, review, then present the complete set for approval at the end.

### 1. Read Topic PRD

Read `harness/topics/<topic>/prd.md`. If the file does not exist, inform the user and suggest running `/meeting` first.

### 2. Check for Unresolved Items

Scan the PRD for unresolved items — `[TODO]`, `[TBD]`, `[OPEN]`, or sections explicitly marked as unresolved. If any exist, display them and ask whether to proceed or return to `/meeting`.

### 3. Archive Existing Design Documents

If any design documents already exist in `harness/topics/<topic>/`, archive them to `history/` using FIFO rotation (max 2 versions).

### 4. Generate Documents (subagent)

Dispatch the `design-doc-writer` as a subagent using the Agent tool:

- **Prompt**: Include the full PRD content directly in the prompt — do not make the subagent read it
- **Task**: Generate all 5 documents (spec.md, blueprint.md, architecture.md, code-dev-plan.md, test-cases.md) and write them to `harness/topics/<topic>/`
- **Model**: opus

The subagent generates all documents in one pass without stopping for approval.

### 5. Review (subagent)

Dispatch the `design-doc-reviewer` as a subagent using the Agent tool:

- **Prompt**: Include the topic path; the reviewer reads all documents from disk
- **Task**: Validate cross-document consistency and PRD coverage
- **Model**: sonnet

Review loop (max 3 iterations):
1. If issues found → dispatch writer subagent to fix specific issues
2. Re-dispatch reviewer subagent
3. If issues persist after 3 iterations → escalate to user

### 6. User Final Review

Present the complete set of documents to the user for sign-off. This is the **only** approval gate.

### 7. Update Kanban

Update `harness/topics/<topic>/kanban.json` to reflect the completed design-doc step.

### 8. Suggest Next Step

```
Design documents complete. Next step: /implement <topic>
```

## PRD Change Propagation

When a PRD has been updated (detected by the existence of `harness/topics/<topic>/history/prd.v1.md`):

### Detection

1. Diff `harness/topics/<topic>/prd.md` against `harness/topics/<topic>/history/prd.v1.md`
2. Summarize what changed in the PRD

### Selective Update

1. The design-doc-writer identifies which of the 4 documents are affected by the PRD changes using this matrix:

   | PRD Change | Affected Documents |
   |------------|-------------------|
   | New/modified requirements | spec.md, possibly code-dev-plan.md |
   | New external dependency | blueprint.md, architecture.md |
   | Scope change | All 4 documents |
   | Non-functional requirement change | architecture.md, code-dev-plan.md |
   | API contract change | spec.md, blueprint.md |

2. Archive only the affected documents to `history/` (FIFO rotation)
3. Regenerate only the affected documents
4. Run design-doc-reviewer on the full set (all documents must still be consistent)
5. Present the complete updated set to the user for approval

## Organic Workflow Principle

Design documents exist in a bidirectional relationship with both upstream (PRD/meeting) and downstream (implementation) artifacts.

### Upward Propagation

If during design document creation the writer discovers:

- Contradictions or ambiguities in the PRD that cannot be resolved by reasonable interpretation
- Missing requirements that are critical for a coherent design
- Technical infeasibility of a PRD requirement

Then: **suggest returning to `/meeting`** to resolve the issue before continuing. Do not guess at requirements — surface the gap.

### Downward Propagation

If the PRD changes after design documents were created:

- Cascade changes to affected design documents (via PRD Change Propagation above)
- If implementation has already started, check `harness/topics/<topic>/kanban.json` for `implement` steps

### Kanban Regression

If design documents change after `/implement` has started (i.e., implement steps exist in kanban.json):

1. Identify which implement steps are affected by the design document changes
2. Move affected implement steps back to `backlog` in kanban.json
3. Warn the user that implementation progress has been rolled back for affected steps
4. The next `/implement` run will re-execute those steps with the updated design

This ensures implementation always reflects the current design documents.

## Document Flow

```
harness/topics/<topic>/
├── prd.md                          ← input (from /meeting)
├── spec.md                         ← output
├── blueprint.md                    ← output
├── architecture.md                 ← output
├── code-dev-plan.md                ← output
├── test-cases.md                   ← output (used by /implement for TDD)
├── kanban.json                     ← status tracking
└── history/
    ├── prd.v1.md, prd.v2.md        ← PRD history (from /meeting)
    ├── spec.v1.md, spec.v2.md      ← spec history
    ├── blueprint.v1.md, blueprint.v2.md
    ├── architecture.v1.md, architecture.v2.md
    ├── code-dev-plan.v1.md, code-dev-plan.v2.md
    └── test-cases.v1.md, test-cases.v2.md
```
