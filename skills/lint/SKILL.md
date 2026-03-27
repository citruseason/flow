---
name: lint
description: "Verify implementation against requirements and run project lint skills. Replaces /code-review. Use after /implement completes."
---

## Overview

Unified verification skill that checks implementation against requirements (PRD/spec) and runs all project lint-* skills. Produces a combined report with a PASS/WARNING/FAIL verdict. This skill owns the process flow -- dispatching agents, compiling results, and enforcing retry logic on failures.

## When to Use

- Automatically invoked after `/implement` completes (autonomous execution)
- Manually as `/lint <topic>` for standalone verification
- After manual code changes to verify compliance

## Process Flow

### 1. Load Topic Context

Read the topic's requirements and specification documents:

```
harness/topics/<topic>/prd.md      -- PRD with acceptance criteria
harness/topics/<topic>/spec.md     -- Spec with interfaces and data models
```

If the topic path is provided as an argument, use it directly. If invoked from `/implement`, inherit the topic context.

### 2. Execute lint-requirements (Inline Logic)

This is built into the /lint skill, NOT a separate agent or skill. Perform these checks directly:

#### 2a. PRD Acceptance Criteria Verification

- Read all acceptance criteria from `prd.md`
- For each criterion, search the codebase to verify it is implemented
- Classify each criterion:
  - **[PASS]** -- Implementation found and matches the requirement
  - **[WARNING]** -- Partial implementation or ambiguous match
  - **[FAIL]** -- No implementation found or clear mismatch

#### 2b. Spec Interface and Data Model Compliance

- Read interface definitions from `spec.md`
- Verify each interface exists in the codebase with matching signatures
- Read data model definitions from `spec.md`
- Verify each model exists with correct fields, types, and constraints
- Classify each check as PASS/WARNING/FAIL

#### 2c. Produce lint-requirements Output

Format the results using the standard lint output contract:

```markdown
## Lint Result: lint-requirements

### Status: PASS | WARNING | FAIL

### Findings
- [FAIL] {criterion/interface} — {description of mismatch}
- [WARNING] {criterion/interface} — {description of partial match}
- [PASS] {criterion/interface} — {verification details}

### Summary
- Total checks: {N}
- Pass: {N} / Warning: {N} / Fail: {N}
```

### 3. Dispatch lint-reviewer Agent

Dispatch the `lint-reviewer` agent. This agent will:
- Discover all `.claude/skills/lint-*/SKILL.md` in the project
- Execute each lint-* skill against the codebase
- Aggregate results into a unified report
- Compute and update quality scores in `harness/quality-score.md`

Pass the lint-requirements results from step 2 to the agent so it can incorporate them into quality score computation (requirements compliance criterion).

### 4. Dispatch doc-gardener Agent

Dispatch the `doc-gardener` agent. This agent will:
- Validate harness/ documents against the current codebase
- Check lint-* skill references/ for stale rules
- Update stale documentation (harness/ and lint references only, never source code)
- Report what was updated and what needs human review

### 5. Compile Unified Report

Combine all results into a single report:

```markdown
# Lint Report: {topic}

## Requirements Verification
{lint-requirements output from step 2}

## Lint Skills
{lint-reviewer agent output from step 3}

## Documentation Freshness
{doc-gardener agent output from step 4}

## Overall Verdict: {PASS | WARNING | FAIL}

### Verdict Rationale
{explanation of why this verdict was chosen}

### Quality Score: {N}/100
{score breakdown from lint-reviewer}
```

### 6. Determine Verdict

Apply these rules to determine the overall verdict:

| Condition | Verdict |
|-----------|---------|
| All checks PASS across requirements, lint skills, and doc-garden | **PASS** |
| Any WARNING but no FAIL across all checks | **WARNING** |
| Any FAIL in requirements OR any lint-* skill | **FAIL** |

Doc-garden findings do NOT affect the verdict (they are informational).

### 7. Act on Verdict

#### PASS
- Present the full report to the user
- Update kanban.json: move lint step to `done`

#### WARNING
- Include warnings in the report
- Present to user with highlighted warning items
- Do NOT block -- continue execution if in autonomous mode
- Update kanban.json: move lint step to `done` with warning note

#### FAIL
- Dispatch an SDD worker agent to fix the failing items
- **The worker fixes CODE only** -- never harness documents or lint-* rules
- After the fix, re-run /lint (recursive invocation)
- Maximum 2 retry attempts
- If still FAIL after 2 retries, escalate to the user with:
  - Full report of all attempts
  - Specific items that could not be resolved
  - Suggested manual actions
- Update kanban.json accordingly

### 8. Update Kanban

Update the topic's `kanban.json`:
- On PASS: move lint step to `done`
- On WARNING: move lint step to `done`, add warning note
- On FAIL (after retries exhausted): keep lint step in `in_progress`, add failure note

## Execution Modes

### Autonomous Mode (called from /implement)

- Run the entire flow without user interaction
- Only escalate on unresolvable FAIL (after 2 retries)
- On PASS or WARNING, report results at the end

### Standalone Mode (`/lint <topic>`)

- Run the same flow but present results interactively
- Show the report to the user after completion
- On FAIL, ask the user whether to attempt auto-fix or review manually

## Important Constraints

- lint-requirements logic runs INLINE in this skill -- it is NOT a separate agent
- lint-* skill discovery and execution is delegated to the lint-reviewer agent
- Doc freshness validation is delegated to the doc-gardener agent
- SDD worker agents fix CODE only, never harness docs or lint rules
- Maximum 2 retry attempts on FAIL before user escalation
- Doc-garden results are informational and do not affect the PASS/WARNING/FAIL verdict
