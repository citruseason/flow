---
name: implement
description: "Execute implementation by reading harness topic documents and dispatching SDD workers with TDD enforcement. Runs autonomously from implement through lint without user intervention."
---

# Implement

Execute a topic's code-dev-plan by combining SDD execution pattern with TDD development methodology. Runs autonomously through lint completion.

## Input

```
/implement <topic>
/implement --continue
/implement -c
```

- **Topic name:** Read the topic's `code-dev-plan.md` from `harness/topics/<topic>/` and execute.
- **`--continue` / `-c`:** Resume from where the last session left off using the topic's `kanban.json`.

## Setup

```bash
git checkout -b feature/<topic>
```

Read all topic documents upfront:
- `harness/topics/<topic>/code-dev-plan.md` — Phase list and execution direction
- `harness/topics/<topic>/spec.md` — Interface definitions, data models
- `harness/topics/<topic>/blueprint.md` — Component relationships, data flow
- `harness/topics/<topic>/architecture.md` — Layer structure, dependency rules
- `harness/topics/<topic>/test-cases.md` — Pre-defined test scenarios for TDD

## Autonomous Execution Principle

From `/implement` start through `/lint` completion, execute without user intervention:
- Only escalate on: design vs implementation severe mismatch, unresolvable blockers
- On session interruption, resume via `kanban.json` `in_progress` steps
- After all phases complete, automatically invoke `/lint <topic>`
- Report final results to user only after lint PASS

---

## History-Based Change Detection

Before executing, check if `harness/topics/<topic>/history/` contains previous versions of design documents:

- **History exists:** Diff current `code-dev-plan.md` against `history/code-dev-plan.v{latest}.md` to identify changed phases/areas. Only re-work affected phases. Move unchanged completed phases directly to `done` in kanban.
- **No history (first run):** Execute all phases from `code-dev-plan.md` sequentially.

---

## Kanban Management

Progress is tracked in `harness/topics/<topic>/kanban.json` (replaces `.progress.md`).

### First Run Setup

On first `/implement` execution for a topic, populate kanban steps from `code-dev-plan.md` phases:

```json
{
  "steps": {
    "done": [...previous steps...],
    "in_progress": [
      { "id": "impl-phase-1", "name": "<phase 1 name>" }
    ],
    "backlog": [
      { "id": "impl-phase-2", "name": "<phase 2 name>" },
      { "id": "impl-phase-N", "name": "<phase N name>" },
      { "id": "lint", "name": "Lint verification" }
    ]
  }
}
```

### Updates

- Move current step to `in_progress` when starting
- Move to `done` when phase completes
- Update `phase` to `"implement"` and `last_updated` to current date
- Also update root `harness/kanban.json` with topic phase
- Commit kanban changes: `git add harness/ && git commit -m "chore: update kanban"`

---

## Continue Mode (`--continue` / `-c`)

Resume execution from a previous session (same or different machine).

1. Scan `harness/kanban.json` to find topic with `phase: "implement"`
2. Read the topic's `kanban.json`, find `in_progress` steps
3. Read the topic's design documents
4. Resume from the in-progress step (no user confirmation needed in autonomous mode)
5. If on a different machine: `git fetch origin && git checkout feature/<topic>`

---

## Core Execution (SDD + TDD)

Follow the SDD skill pattern (`skills/sdd/SKILL.md`):

**For each Phase/Step:**

1. **Read prompt templates** from `skills/sdd/references/`
2. **Build worker prompt** using `worker-prompt.md` template:
   - Paste the Phase's full text from `code-dev-plan.md` (direction, location, approach, test strategy)
   - Include relevant context from topic documents: spec interfaces, blueprint data flows, architecture constraints
   - Include the relevant test cases from `test-cases.md` for this phase — the worker uses these as the TDD spec
   - Instruct the worker to follow TDD (`skills/tdd/SKILL.md`): write the pre-defined test cases FIRST, verify they fail, implement until they pass, then add any additional edge case tests discovered during implementation
3. **Dispatch worker** as `general-purpose` subagent
4. **Handle worker status** per SDD rules (DONE/CONCERNS/NEEDS_CONTEXT/BLOCKED)
5. **Dispatch compliance reviewer** using `compliance-reviewer-prompt.md`
6. **Dispatch quality reviewer** using `quality-reviewer-prompt.md` — only after compliance passes
7. **Update kanban** (move step to done, next to in_progress)
8. **Mark step complete** via TaskUpdate

**At Phase boundaries:**

Run the Phase's verification criteria from `code-dev-plan.md`, then update kanban.

**Phase completion side-effects:**
- Check if code changes affect lint-* skill rules → auto-update relevant `references/` files
- If design inconsistency discovered → escalate to user, suggest returning to `/meeting` or `/design-doc`

### Lint Pipeline Auto-Trigger

After all implementation phases complete:
1. Move `lint` step to `in_progress` in kanban
2. Invoke `/lint <topic>` (autonomous, no user interaction)
   - `/lint` internally runs: verify → lint-manage (evolve skills) → lint-validate (health check) → re-verify
3. On lint PASS → report final results to user
4. On lint FAIL → SDD worker fixes, re-lint (max 2 retries), then escalate

### Final Report

```
Implementation + Lint complete:
  Topic:   <topic>
  Phases:  N/N completed
  Steps:   M/M completed
  Tests:   passing
  Lint:    PASS
  Score:   XX/100
```

## Context Curation

The controller's most important job is curating context for each worker. Workers should receive:

- **Full phase text** from code-dev-plan (never summarized)
- **Relevant test cases** from test-cases.md for this phase (the TDD starting point)
- **Relevant spec/blueprint/architecture sections** (not entire documents)
- **File contents** the worker will modify or depend on
- **Interfaces** from prior phases (if current phase depends on them)
- **Nothing else** — excess context degrades worker performance

## Error Handling

- **Worker BLOCKED on a step:** Try providing more context, upgrading model, or breaking the step into smaller pieces. If none work, escalate to user.
- **Phase verification fails:** Review the failing output, identify which step caused it, dispatch a fix worker for that specific issue.
- **Compliance review fails repeatedly (3+ loops):** The step may be ambiguous. Escalate to user.
- **Design mismatch discovered:** Escalate to user with suggestion to revisit `/design-doc` or `/meeting`.

## Red Flags

**Never:**
- Skip reading topic documents
- Summarize phase text (always provide full text to workers)
- Skip Phase verification
- Run steps from different Phases in parallel
- Continue to next Phase with failing verification
- Skip kanban updates between steps
- Ask user for input during autonomous execution (unless escalation)

**Always:**
- Read all topic documents once, extract everything upfront
- Follow SDD review gates for every step
- Run Phase verification at boundaries
- Track progress with TaskCreate/TaskUpdate and kanban.json
- Auto-trigger /lint after all phases complete
- Commit kanban updates after every step
