---
name: implement
description: "Execute an implementation plan using SDD (subagent-driven development) with TDD enforcement. Reads a plan, dispatches subagents per step, and runs two-stage review gates. Use after /plan to automate implementation."
---

# Implement

Execute an implementation plan by combining SDD execution pattern with TDD development methodology.

## Input

```
/implement docs/plans/2026-03-22-auth-plan.md
/implement docs/plans/2026-03-22-frontend-arch-phase1-plan.md
/implement --continue
/implement -c
```

- **Plan path:** Read the plan and execute from the beginning.
- **`--continue` / `-c`:** Resume from where the last session left off using `.progress.md`.

## Execution Strategy Handling

Read the plan's `## Execution Strategy` section to determine the mode:

- **`type: direct`** → Direct Mode (single plan, no worktree)
- **`type: worktree`** → Worktree Mode (multi-plan, isolated workspace)

If the plan has no Execution Strategy section, default to `direct`.

---

## Direct Mode

For single plans with small scope. No worktree, no phase branches.

### Setup
```bash
git checkout -b feature/<topic>
```

### Execution

Follow the SDD + TDD process (see "Core Execution" below).

### Completion Actions

```
구현 완료.
  1) PR 생성 (feature/<topic> → main)
  2) 브랜치 유지
  3) 폐기
```

**PR 생성:**
```bash
gh pr create --base main --head feature/<topic> \
  --title "<topic>" --body "<summary>"
```

Update `.progress.md` status to `pr_created` with PR number.

---

## Worktree Mode

For multi-plan specs. One worktree per spec, phase branches inside.

### Branch Hierarchy

```
main
  └── feature/<topic>                       ← spec branch (worktree checkout)
        ├── feature/<topic>/phase1          → PR → merge into spec branch
        ├── feature/<topic>/phase2          → PR → merge into spec branch
        └── feature/<topic>/phaseN          → PR → merge into spec branch

  All phases done:
  feature/<topic> → PR → merge into main
```

### First Phase Setup

1. Create spec branch: `git checkout -b feature/<topic>`
2. Create worktree following `skills/using-worktree/SKILL.md` procedures:
   - Verify `.worktrees/` is gitignored
   - `git worktree add .worktrees/<topic> feature/<topic>`
   - Run project setup (auto-detect package manager)
   - Verify baseline tests
3. Create phase branch inside worktree:
   ```bash
   cd .worktrees/<topic>
   git checkout -b feature/<topic>/phase1
   ```
4. Execute SDD + TDD process (see "Core Execution" below)

### Phase Completion Actions

**Mid-phase (next phase exists):**
```
Phase N 완료.
  1) PR 생성 (feature/<topic>/phaseN → feature/<topic>)
  2) PR 생성 + 다음 phase 시작
  3) worktree 유지
  4) 폐기
```

**Last phase:**
```
마지막 Phase 완료.
  1) PR 생성 (feature/<topic>/phaseN → feature/<topic>)
  2) worktree 유지
  3) 폐기

모든 phase PR merge 후:
  → 최종 PR (feature/<topic> → main) 생성 안내
  → worktree 정리 안내
```

**PR 생성:**
```bash
gh pr create \
  --base feature/<topic> \
  --head feature/<topic>/phaseN \
  --title "Phase N: <phase name>" \
  --body "<summary from .progress.md>"
```

**Worktree 정리 (모든 phase + 최종 PR merge 후):**
```bash
git worktree remove .worktrees/<topic>
```

---

## Phase Transition

When starting a new phase after the previous one:

1. Check if previous phase PR is merged into spec branch
2. **If merged:**
   ```bash
   cd .worktrees/<topic>
   git checkout feature/<topic>
   git pull origin feature/<topic>
   git checkout -b feature/<topic>/phase(N+1)
   ```
3. **If not merged:** Warn the user with options:
   - a) Start from previous phase branch (pre-merge development). Branch `feature/<topic>/phase(N+1)` from `feature/<topic>/phaseN`. Record `base: feature/<topic>/phaseN` in `.progress.md`. Can rebase onto spec branch after merge.
   - b) Wait (call `/implement` again after merge)

---

## .progress.md Management

### Location

`docs/plans/.progress.md` (git tracked, committed to the working branch)

### Lifecycle

- **Created:** On first `/implement` execution
- **Updated:** After each Step completion (current_step), after Phase completion (status + PR number)
- **Committed:** Every update triggers `git add docs/plans/.progress.md && git commit -m "chore: update .progress.md" && git push`

### Format — Multi-plan (worktree mode)

```markdown
# Execution Progress

## Context
- spec: docs/specs/<date>-<topic>-design.md
- strategy: worktree
- branch_prefix: feature/<topic>
- created: <date>
- last_updated: <date>

## Phases

### Phase 1: <phase name>
- plan: docs/plans/<date>-<topic>-phase1-plan.md
- branch: feature/<topic>/phase1
- status: merged
- pr: #12
- steps: 8/8

### Phase 2: <phase name>
- plan: docs/plans/<date>-<topic>-phase2-plan.md
- branch: feature/<topic>/phase2
- status: in_progress
- steps: 4/8
- current_step: "Step 2.5: <step description>"

### Phase 3: <phase name>
- plan: docs/plans/<date>-<topic>-phase3-plan.md
- status: pending
```

### Format — Single plan (direct mode)

```markdown
# Execution Progress

## Context
- spec: docs/specs/<date>-<topic>-design.md
- strategy: direct
- branch_prefix: feature/<topic>
- created: <date>
- last_updated: <date>

## Progress
- plan: docs/plans/<date>-<topic>-plan.md
- branch: feature/<topic>
- status: in_progress
- steps: 3/5
- current_step: "Step 1.4: <step description>"
```

---

## Continue Mode (`--continue` / `-c`)

Resume execution from a previous session (same or different machine).

1. Read `docs/plans/.progress.md`
2. Find the `in_progress` phase (or single plan progress)
3. Read the corresponding plan file
4. Ask user: "Phase N, Step M부터 이어서 진행할까요?"
5. Restore environment:
   - **Worktree mode:**
     - If `.worktrees/<topic>` exists locally → use it as-is
     - If not → `git fetch origin && git worktree add .worktrees/<topic> feature/<topic>` then `cd .worktrees/<topic> && git checkout feature/<topic>/phaseN`
   - **Direct mode:**
     - `git fetch origin && git checkout feature/<topic>`
6. Run project setup (dependency install etc.)
7. Skip completed Steps, resume from the next pending Step

---

## Core Execution (SDD + TDD)

This is the shared execution logic used by both direct and worktree modes.

Follow the SDD skill pattern (`skills/sdd/SKILL.md`):

**For each Step:**

1. **Read prompt templates** from `skills/sdd/references/`
2. **Build worker prompt** using `worker-prompt.md` template:
   - Paste the Step's full text as the task description
   - Include relevant context: spec excerpts, existing file contents, interfaces from prior steps
   - Instruct the worker to follow TDD (`skills/tdd/SKILL.md`): write tests first, verify they fail, implement, verify they pass
3. **Dispatch worker** as `general-purpose` subagent
4. **Handle worker status** per SDD rules (DONE/CONCERNS/NEEDS_CONTEXT/BLOCKED)
5. **Dispatch compliance reviewer** using `compliance-reviewer-prompt.md`
6. **Dispatch quality reviewer** using `quality-reviewer-prompt.md` — only after compliance passes
7. **Update .progress.md** (current_step, steps count)
8. **Mark step complete** via TaskUpdate

**At Phase boundaries:**

Run the Phase's verification command, then update `.progress.md`.

### Final Review

After all Phases complete, dispatch one final quality reviewer covering the entire implementation diff.

### Report

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
- Proceed to next phase without proper phase transition
- Skip .progress.md updates between Steps
- Work directly on main in worktree mode

**Always:**
- Read the plan once, extract everything upfront
- Follow SDD review gates for every step
- Run Phase verification at Phase boundaries
- Track progress with TaskCreate/TaskUpdate and .progress.md
- Commit and push .progress.md after every update
