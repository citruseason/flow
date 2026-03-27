# Execution Boundaries

## Description

The Flow workflow has two distinct execution modes: interactive (user-gated) and autonomous. The boundary between these modes must be clearly defined and correctly implemented.

## Rules

### EB-1: Interactive steps require user gates

The meeting and design-doc steps are interactive. They must include explicit user confirmation gates.

**skills/meeting/SKILL.md must include:**
- User reviews CPS (step 8)
- User reviews PRD (step 9)
- User approval before proceeding to next step

**skills/design-doc/SKILL.md must include:**
- User approves each design document before proceeding
- User final review (step 6)

**Detection:**
```bash
grep -i "user review\|user approval\|user confirms\|confirmation gate\|user approves" skills/meeting/SKILL.md skills/design-doc/SKILL.md
```

### EB-2: Autonomous segment runs without user intervention

From `/implement` start through `/lint` completion, execution proceeds without user intervention.

**skills/implement/SKILL.md must state:**
- "execute without user intervention" or equivalent
- "Only escalate on: design vs implementation severe mismatch, unresolvable blockers"
- Auto-trigger `/lint` after all phases complete

**skills/lint/SKILL.md must state:**
- Autonomous mode runs "without user interaction"
- Only escalate on unresolvable FAIL (after retries)

### EB-3: Escalation conditions are explicit

Both interactive and autonomous modes must define clear escalation conditions:

**Meeting/design-doc escalation:**
- After 3 review iterations, escalate to human

**Implement escalation:**
- Worker BLOCKED after context adjustments -> escalate
- Compliance review fails 3+ times -> escalate
- Design mismatch discovered -> escalate

**Lint escalation:**
- FAIL after 2 retries -> escalate to user

### EB-4: harness-init has user confirmation gates

Despite being the first step, harness-init is interactive:
- Analysis results presented for user review (step 3)
- User confirmation gate before generation (step 4)
- Generated results presented for approval (step 7)
- User approval gate before git commit (step 8)

### EB-5: No user gates in lint-manage or lint-validate

These supporting skills run autonomously within the lint pipeline:
- `skills/lint-manage/SKILL.md` -- "Fully autonomous -- no user confirmation needed"
- `skills/lint-validate/SKILL.md` -- "Fully autonomous -- no user confirmation needed"

### EB-6: Standalone mode exceptions

When `/lint` is invoked standalone (not from `/implement`), it switches to interactive mode:
- Show full report to user
- On FAIL, ask user whether to auto-fix or review manually

This dual-mode behavior must be documented in `skills/lint/SKILL.md` under "Execution Modes".
