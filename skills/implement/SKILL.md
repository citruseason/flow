---
name: implement
description: "Execute an implementation plan using SDD (subagent-driven development) with TDD enforcement. Reads a plan, dispatches subagents per step, and runs two-stage review gates. Use after /plan to automate implementation."
---

# Implement

Execute an implementation plan by combining SDD execution pattern with TDD development methodology.

## Input

A plan document path is required.

```
/implement docs/plans/2026-03-22-auth-plan.md
```

## Process

### 1. Read and Extract

Read the plan file once. Extract:
- All Phases and Steps with **full text** (don't summarize)
- Phase verification commands ("이 Phase 완료 후 검증: ...")
- Spec reference path (for compliance review context)

Read the referenced spec file for compliance review context.

### 2. Create Task Tracking

Create a TaskCreate entry for each Step. Use the step name as the subject.

### 3. Execute Using SDD

Follow the SDD skill pattern (`skills/sdd/SKILL.md`):

**For each Step:**

1. **Read prompt templates** from `skills/sdd/references/`
2. **Build worker prompt** using `worker-prompt.md` template:
   - Paste the Step's full text as the task description
   - Include relevant context: spec excerpts, existing file contents, interfaces from prior steps
   - Instruct the worker to follow TDD (`skills/tdd/SKILL.md`): write tests first, verify they fail, implement, verify they pass
3. **Dispatch worker** as `general-purpose` subagent
4. **Handle worker status** per SDD rules (DONE/CONCERNS/NEEDS_CONTEXT/BLOCKED)
5. **Dispatch compliance reviewer** using `compliance-reviewer-prompt.md` — verify implementation matches the Step's requirements
6. **Dispatch quality reviewer** using `quality-reviewer-prompt.md` — only after compliance passes
7. **Mark step complete** via TaskUpdate

**At Phase boundaries:**

After the last Step of a Phase, run the Phase's verification command:

```bash
# Example: "이 Phase 완료 후 검증: pnpm build"
pnpm build
```

If verification fails, assess and fix before proceeding to the next Phase.

### 4. Final Review

After all Phases complete, dispatch one final quality reviewer covering the entire implementation diff:

```bash
git diff <base>...HEAD
```

### 5. Report

```
Implementation complete:
  Plan:    <plan-path>
  Phases:  N/N completed
  Steps:   M/M completed
  Tests:   passing
```

Suggest `/code-review` for a full standalone review if desired.

## Context Curation

The controller's most important job is curating context for each worker. Workers should receive:

- **Full step text** from the plan (never summarized)
- **Relevant spec sections** (not the entire spec)
- **File contents** the worker will modify or depend on
- **Interfaces** from prior steps (if the current step depends on them)
- **Nothing else** — excess context degrades worker performance

## Error Handling

- **Worker BLOCKED on a step:** Try providing more context, upgrading model, or breaking the step into smaller pieces. If none work, pause and ask the human.
- **Phase verification fails:** Review the failing output, identify which step caused it, and dispatch a fix worker for that specific issue.
- **Compliance review fails repeatedly (3+ loops):** The step spec may be ambiguous. Pause and ask the human to clarify.

## Red Flags

**Never:**
- Skip the spec or plan reading step
- Summarize step text (always provide full text to workers)
- Skip Phase verification commands
- Run steps from different Phases in parallel
- Continue to next Phase with failing verification

**Always:**
- Read the plan once, extract everything upfront
- Follow SDD review gates for every step
- Run Phase verification at Phase boundaries
- Track progress with TaskCreate/TaskUpdate
