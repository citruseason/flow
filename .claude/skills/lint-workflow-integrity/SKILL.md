---
name: lint-workflow-integrity
description: "Check workflow integrity -- pipeline completeness, writer-reviewer pairing, history rotation, cross-reference integrity, and autonomous execution boundaries."
---

# lint-workflow-integrity

Verify that the Flow plugin's end-to-end workflow is complete and internally consistent. This skill checks that every pipeline step has supporting infrastructure, that review gates are properly paired, and that document versioning follows a single convention.

## Before Running

Read all files in this skill's `references/` directory to load the detailed rules:
- `references/pipeline-completeness.md`
- `references/writer-reviewer-pairing.md`
- `references/history-rotation.md`
- `references/cross-reference-integrity.md`
- `references/execution-boundaries.md`

## Scope

Check these files and patterns:
- `skills/*/SKILL.md` -- all skill definitions (pipeline step coverage)
- `agents/*.md` -- all agent definitions (writer-reviewer pairing)
- `skills/*/SKILL.md` and `agents/*.md` -- history rotation references
- All `.md` files -- cross-references to skills and agents
- `skills/meeting/SKILL.md`, `skills/implement/SKILL.md`, `skills/lint/SKILL.md` -- execution boundary definitions

## Rules

### Rule 1: Pipeline Completeness
- **What:** Every step in the pipeline (harness-init, meeting, design-doc, implement, lint) must have both a skill directory with SKILL.md and at least one agent that it dispatches.
- **Upstream:** harness/PRODUCT.md#architecture
- **Why:** A pipeline step without a skill cannot be invoked. A skill without an agent has no executor.
- **Detection:** For each pipeline step, verify: (1) `skills/<step>/SKILL.md` exists, (2) the SKILL.md references at least one agent from `agents/`, (3) the referenced agent exists.
- **Fix:** Create missing skill or agent files.

### Rule 2: Writer-Reviewer Pairing
- **What:** Every writer agent must have a corresponding reviewer agent. Review iterations are capped at 3 with human escalation.
- **Upstream:** harness/PRODUCT.md#architecture
- **Why:** Unreviewed output degrades quality. Uncapped review loops waste resources.
- **Detection:** Map writer-reviewer pairs: meeting-facilitator/meeting-reviewer, design-doc-writer/design-doc-reviewer. Verify each writer has a reviewer. Check that skills mention "max 3 iterations" or equivalent cap.
- **Fix:** Add missing reviewer agent or cap references.

### Rule 3: History Rotation Consistency
- **What:** All documents using the FIFO history rotation must use the same convention: v1 = most recent prior version, v2 = older version. Maximum 2 archived versions.
- **Upstream:** harness/PRODUCT.md#conventions
- **Why:** Inconsistent conventions cause agents to read the wrong version when doing change detection.
- **Detection:** Grep all SKILL.md and agent files for "v1" and "v2" references. Verify they all describe v1 as "most recent prior" and v2 as "older".
- **Fix:** Update inconsistent references to match the majority convention (v1 = most recent prior).

### Rule 4: Cross-Reference Integrity
- **What:** When a skill or agent references another skill by slash command (e.g., `/design-doc`, `/lint`), the referenced skill must exist in `skills/`.
- **Upstream:** harness/PRODUCT.md#architecture
- **Why:** Broken cross-references create dead ends in the workflow.
- **Detection:** Extract all `/skill-name` references from skill and agent files. Verify each referenced skill directory exists with a valid SKILL.md.
- **Fix:** Update stale references or create missing skills.

### Rule 5: Autonomous Execution Boundaries
- **What:** The implement-to-lint segment runs autonomously (no user gates). The meeting and design-doc steps have mandatory user gates. These boundaries must not be mixed up.
- **Upstream:** harness/PRODUCT.md#architecture
- **Why:** Autonomous segments that pause for user input break the workflow. User-gated segments that skip confirmation risk incorrect outputs going unreviewed.
- **Detection:** Check implement/SKILL.md for autonomous execution language ("without user intervention", "only escalate on"). Check meeting/SKILL.md and design-doc/SKILL.md for user gate language ("user approval", "user reviews", "confirmation gate").
- **Fix:** Add missing boundary markers to affected skills.

## Output Contract

When reporting results, use this exact format:

```
## Lint Result: lint-workflow-integrity

### Status: PASS | WARNING | FAIL

### Findings

- [FAIL] {filepath}:{line} -- {description}
- [WARNING] {filepath}:{line} -- {description}
- [PASS] {check item} -- {pass reason}

### Summary

- Total checks: {N}
- Pass: {N} / Warning: {N} / Fail: {N}
```

## Rule Accumulation

Rules in `references/` are append-only. When updating:
- Add new rules at the end of the relevant file
- Update existing rules in place (clarify, add examples)
- Never delete rules -- mark deprecated rules with `[DEPRECATED: reason]`
