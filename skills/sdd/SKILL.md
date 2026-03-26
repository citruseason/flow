---
name: sdd
description: "Subagent-driven development — execute tasks by dispatching fresh subagents with two-stage review gates. Use when executing a list of independent tasks in the current session."
---

# Subagent-Driven Development

Execute tasks by dispatching a fresh subagent per task, with two-stage review after each: compliance review first, then quality review.

**Why subagents:** Fresh context per task prevents pollution. The controller curates exactly what context each worker needs — they never inherit session history. This preserves the controller's context for coordination.

**Core principle:** Fresh subagent per task + two-stage review (compliance then quality) = high quality, fast iteration.

## When to Use

- Have a list of independent tasks to execute
- Tasks are well-specified enough for a subagent to implement
- Want automated execution with review checkpoints

## The Process

```
Controller (this skill)
  │
  ├── Extract all tasks → create TaskCreate entries
  │
  └── Per task:
       │
       ①  Dispatch worker (general-purpose subagent)
       │   - Read references/worker-prompt.md for template
       │   - Fill in: task text, context, working directory
       │   - Worker implements, tests, commits, self-reviews
       │   - Reports status: DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED
       │
       ②  Dispatch compliance reviewer (general-purpose subagent)
       │   - Read references/compliance-reviewer-prompt.md for template
       │   - Verify implementation matches task requirements
       │   - ❌ → Worker fixes → re-review (loop until ✅)
       │
       ③  Dispatch quality reviewer (general-purpose subagent)
       │   - Read references/quality-reviewer-prompt.md for template
       │   - Only after ② passes
       │   - Verify code quality, tests, maintainability
       │   - ❌ → Worker fixes → re-review (loop until ✅)
       │
       ✅ → Mark task complete → next task
```

## Handling Worker Status

**DONE:** Proceed to compliance review.

**DONE_WITH_CONCERNS:** Read the concerns. If about correctness or scope, address before review. If observational ("this file is getting large"), note and proceed.

**NEEDS_CONTEXT:** Worker needs information that wasn't provided. Supply the missing context and re-dispatch.

**BLOCKED:** Worker cannot complete the task. Assess:
1. Context problem → provide more context, re-dispatch
2. Task too hard → re-dispatch with a more capable model
3. Task too large → break into smaller pieces
4. Plan itself is wrong → escalate to human

Never force the same subagent to retry without changes. If it said it's stuck, something needs to change.

## Review Order

**Compliance first, quality second.** This order is fixed.

Compliance review answers: "Did they build what was requested?" If the answer is no, there's no point reviewing code quality. Fix the spec compliance gap first, then assess quality.

## Controller Responsibilities

- **Read task text once, provide it in full** — don't make workers read plan files
- **Curate context** — provide only what the worker needs (relevant files, interfaces, dependencies)
- **Track progress** — use TaskCreate/TaskUpdate for each task
- **Handle status** — respond to NEEDS_CONTEXT and BLOCKED appropriately
- **Enforce review gates** — never skip either review stage
- **Sequential execution** — one worker at a time to avoid conflicts

## Prompt Templates

Before dispatching each subagent, read the relevant template:

- `skills/sdd/references/worker-prompt.md` — Worker dispatch template
- `skills/sdd/references/compliance-reviewer-prompt.md` — Compliance review template
- `skills/sdd/references/quality-reviewer-prompt.md` — Quality review template

## Red Flags

**Never:**
- Skip reviews (compliance OR quality)
- Start quality review before compliance passes
- Dispatch multiple workers in parallel (conflicts)
- Make workers read plan files (provide full text)
- Ignore worker questions (answer before proceeding)
- Accept "close enough" on compliance (issues found = not done)
- Move to next task while either review has open issues
- Force retry without changes when worker is blocked

**Always:**
- Fresh subagent per task
- Provide full task text + curated context in prompt
- Compliance review before quality review
- Review loop until approved (fix → re-review)
- Answer worker questions clearly and completely
