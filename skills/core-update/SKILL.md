---
name: core-update
description: "Update CORE domain documents with realized decisions from a merged topic. Run after merging a topic branch."
---

<!-- Hook Setup (optional, automatic triggering):

To trigger /core-update automatically after merges, add a PostToolUse hook
to your project's .claude/settings.json:

{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if echo \"$TOOL_INPUT\" | grep -q \"git merge\\|git pull\"; then echo \"CORE_UPDATE_NEEDED\"; fi'",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}

When the hook detects a merge, Claude Code will see "CORE_UPDATE_NEEDED" in
the output and can suggest running /core-update <topic>. This is advisory
only -- the skill itself must still be invoked explicitly or by the agent.

Do NOT modify settings.json automatically. Hook setup is user-specific. -->

# Core Update

Update CORE domain documents with realized decisions from a merged topic. Dispatches the harness-initializer agent in CORE Update Mode (Phase 7) to extract implemented patterns from the topic's design docs and propagate them to the appropriate CORE documents.

## When to Use

- After merging a topic branch to main
- After `/implement` + `/lint` complete and the topic is ready for merge
- Manually when CORE documents need to reflect recently landed changes

## Input

```
/core-update <topic>
```

- **Topic name:** The name of the merged topic whose design decisions should be propagated to CORE documents.

## Process Flow

### 1. Validate Topic Readiness

Read the topic's kanban to confirm the topic has completed implementation and lint:

```
harness/topics/<topic>/kanban.json
```

Check that the `lint` step is in the `done` list. If not, warn the user:

> "Topic `<topic>` has not completed the implement/lint pipeline. CORE documents should only be updated with realized facts from merged code. Continue anyway? (y/n)"

If the user declines, stop.

### 2. Verify Topic Documents Exist

Confirm the topic's design documents are present:

```
harness/topics/<topic>/spec.md
harness/topics/<topic>/blueprint.md
harness/topics/<topic>/architecture.md
harness/topics/<topic>/code-dev-plan.md
```

If any are missing, warn the user and proceed with whatever is available.

### 3. Read Current CORE State

Read the existing CORE documents at `harness/` to establish the baseline:

- `harness/PRODUCT.md` (always)
- `harness/SECURITY.md` (always)
- Any conditional CORE docs that exist (FRONTEND.md, BACKEND.md, DESIGN.md, DATA.md, INFRA.md, BATCH.md)

### 4. Dispatch harness-initializer Agent (CORE Update Mode)

Dispatch the `harness-initializer` agent with explicit instructions to run **Phase 7: CORE Update Mode**. Provide:

- The topic name
- The topic's design documents (spec, blueprint, architecture, code-dev-plan)
- The current CORE documents as baseline

The agent will:
- Read the topic's design documents
- Identify decisions that were actually implemented (realized facts only)
- Determine which CORE documents are affected
- Update affected CORE docs, appending new patterns with `<!-- from: <topic> -->` source markers
- Update CLAUDE.md harness section if CORE documents were added or significantly changed

### 5. Present Changes for Confirmation

After the agent completes, present a summary of changes to the user:

```
CORE Update Summary: <topic>

Updated Documents:
  - harness/PRODUCT.md — added: <brief description>
  - harness/BACKEND.md — added: <brief description>

Unchanged Documents:
  - harness/SECURITY.md
  - harness/FRONTEND.md

CLAUDE.md: <updated | no changes needed>
```

Wait for user confirmation before committing.

### 6. Commit Changes

Stage and commit the updated files:

```bash
git add harness/*.md CLAUDE.md
git commit -m "chore: update CORE docs from topic <topic>"
```

### 7. Update Kanban

Update the root `harness/kanban.json` to reflect that the topic's CORE update is complete. Set a `core_updated: true` flag on the topic entry or update the phase to `"done"`.

## Agent Dispatch

This skill dispatches a single agent:

- **harness-initializer** -- invoked in CORE Update Mode (Phase 7 of its prompt). The agent handles all analysis, diffing, and document updates.

The skill's role is orchestration: validating readiness, dispatching the agent, presenting changes, managing the confirmation gate, and handling the git commit.

## Important Constraints

- **Realized facts only** -- CORE documents must contain only patterns from merged, implemented code. Never add planned or aspirational items.
- **Append, never delete** -- New patterns are added to CORE documents. Existing content is preserved.
- **Source tracing** -- All additions include `<!-- from: <topic> -->` markers for provenance.
- **User confirmation gate** -- Changes are presented to the user before committing. Unlike the autonomous `/implement` -> `/lint` pipeline, CORE updates affect shared project knowledge and require explicit approval.
- **No new CORE documents** -- This skill updates existing CORE documents only. If a topic introduces a new domain that warrants a new CORE document (e.g., adding a database to a project that had no DATA.md), the user should run `/harness-init` instead.

## What This Skill Does NOT Do

- Write implementation code
- Modify source files
- Create new CORE documents (use `/harness-init` for that)
- Update CORE docs with unimplemented plans
- Skip user confirmation
