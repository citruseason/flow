---
name: design-doc
description: "Create design documents (Spec, Blueprint, Architecture, Code-Dev-Plan) from an approved PRD. Use after /meeting completes."
---

# Design Document Creation

## Overview

Turn an approved PRD into four interconnected design documents: spec.md, blueprint.md, architecture.md, and code-dev-plan.md. These documents bridge the gap between product requirements and implementation.

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

Execute these tasks in order:

### 1. Read Topic PRD

Read `harness/topics/<topic>/prd.md`. If the file does not exist, inform the user and suggest running `/meeting` first.

### 2. Check for Unresolved Items

Scan the PRD for unresolved items — open questions, `[TODO]`, `[TBD]`, `[OPEN]`, or sections explicitly marked as unresolved. If any exist:

- Display the unresolved items to the user
- Warn that proceeding with unresolved items may produce incomplete design documents
- Ask whether to proceed or return to `/meeting` to resolve them

### 3. Archive Existing Design Documents

If any of `spec.md`, `blueprint.md`, `architecture.md`, `code-dev-plan.md` already exist in `harness/topics/<topic>/`, archive them to `history/` before overwriting:

1. If `history/<doc>.v2.md` exists, delete it
2. If `history/<doc>.v1.md` exists, rename it to `history/<doc>.v2.md`
3. Copy current `<doc>.md` to `history/<doc>.v1.md`

This maintains a maximum of 2 historical versions (v2 = oldest, v1 = most recent prior).

### 4. Dispatch design-doc-writer Agent

Dispatch the `design-doc-writer` agent to generate the 4 documents sequentially:

1. `spec.md` — User approves before proceeding
2. `blueprint.md` — User approves before proceeding
3. `architecture.md` — User approves before proceeding
4. `code-dev-plan.md` — User approves before proceeding

Each document is written to `harness/topics/<topic>/` after approval.

### 5. Dispatch design-doc-reviewer Agent

Dispatch the `design-doc-reviewer` agent to validate cross-document consistency and PRD coverage:

- Maximum 3 review iterations
- If issues are found, relay them to design-doc-writer for correction
- After corrections, re-run the reviewer
- If issues persist after 3 iterations, escalate to the user

### 6. User Final Review

Present the complete set of approved and reviewed documents to the user for final sign-off.

### 7. Update Kanban

Update `harness/topics/<topic>/kanban.json` to reflect the completed design-doc step.

### 8. Suggest Next Step

After all documents are approved:

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
4. Present changes to the user, highlighting what changed and why
5. User approves each updated document
6. Run design-doc-reviewer on the full set (all 4 documents must still be consistent)

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
├── kanban.json                     ← status tracking
└── history/
    ├── prd.v1.md, prd.v2.md        ← PRD history (from /meeting)
    ├── spec.v1.md, spec.v2.md      ← spec history
    ├── blueprint.v1.md, blueprint.v2.md
    ├── architecture.v1.md, architecture.v2.md
    └── code-dev-plan.v1.md, code-dev-plan.v2.md
```
