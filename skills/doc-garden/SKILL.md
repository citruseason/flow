---
name: doc-garden
description: "Validate and update harness/ documentation freshness. Can be run independently or is automatically invoked during /lint."
---

## Overview

Documentation freshness validation skill. Dispatches the `doc-gardener` agent to check that harness/ documents and lint-* skill rules accurately reflect the current codebase. The agent does the heavy lifting -- this skill handles dispatch and result presentation.

## When to Use

- Standalone: `/doc-garden` to manually check documentation freshness
- Automatically: invoked as part of `/lint` during the verification pipeline

## Process Flow

### 1. Dispatch doc-gardener Agent

Dispatch the `doc-gardener` agent. The agent validates:

- `harness/PRODUCT.md` -- product definition, architecture, conventions, observability vs current code patterns
- `harness/SECURITY.md` -- security rules and constraints vs current codebase
- `harness/quality-score.md` -- staleness flags only (no score recomputation)
- `harness/tech-debt.md` -- resolved items still listed
- `.claude/skills/lint-*/references/*.md` -- rule file references vs existing files/patterns

The agent updates stale documents (harness/ and lint references only, never source code) and flags ambiguous cases for human review.

### 2. Present Results

Display the agent's report to the user:

- **Updated items**: what was stale and how it was fixed (before/after)
- **Flagged for review**: ambiguous cases that need human judgment
- **Up to date**: documents that required no changes

### 3. Summary

Provide a brief summary:
- Total documents checked
- Number updated
- Number flagged for review
- Number already up to date

## Important Constraints

- The doc-gardener agent NEVER modifies source code -- only harness/ docs and lint-* references
- Quality scores are never recomputed -- only staleness is flagged
- Lint rules that may be aspirational are flagged for review, not deleted
