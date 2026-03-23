---
name: using-worktree
description: "Set up and work in an isolated git worktree. Handles creation, project setup, port allocation, and establishes the worktree as the working context for all subsequent skills. Other skills (/plan, /tdd, /code-review, /branch-finish) should recognize when they are inside a worktree and operate accordingly."
---

# Using Worktree

Set up an isolated git worktree and establish it as the working context for the session.

**Core principle:** Create isolated workspace → Verify baseline → All subsequent work happens inside the worktree.

## When This Applies

- `/spec` 완료 후 사용자가 worktree 작업에 동의
- 사용자가 직접 `/using-worktree` 호출
- 작업 중 격리가 필요하다고 판단될 때 (mid-workflow transition)

## Input

- `name` (optional): Worktree name. If omitted, extract from spec filename or use AskUserQuestion.
- `branch` (optional): Branch name. Defaults to `feature/<name>`.
- `spec` (optional): Spec file path. Auto-passed when chained from `/spec`.

---

## Part 1: Worktree Setup

### 1. Determine Name and Branch

**If `name` is provided:** use it directly.

**If `spec` is provided but not `name`:** extract name from the spec filename:
- Pattern: `YYYY-MM-DD-<name>-design.md`
- Example: `2026-03-22-user-auth-design.md` → `user-auth`

**If neither is provided:** use AskUserQuestion:
> "What name would you like for this worktree?"

**Branch:** if not provided, default to `feature/<name>`.

### 2. Safety Verification

Verify `.worktrees/` is gitignored:

```bash
git check-ignore -q .worktrees 2>/dev/null
```

If NOT ignored, fix immediately:

```bash
echo ".worktrees/" >> .gitignore
git add .gitignore && git commit -m "chore: add .worktrees/ to gitignore"
```

Also ensure `.flow/worktrees.json` and `.flow/review-result.md` are ignored.

### 3. Validate

- Check the branch doesn't already exist: `git branch --list <branch>`
- Check `.worktrees/<name>` directory doesn't already exist
- If either exists, use AskUserQuestion to ask for a different name

### 4. Create Worktree

```bash
git worktree add .worktrees/<name> -b <branch>
cd .worktrees/<name>
```

### 5. Run Project Setup

Auto-detect and run:

```bash
if [ -f package.json ]; then npm install; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi
if [ -f go.mod ]; then go mod download; fi
if [ -f Cargo.toml ]; then cargo build; fi
```

### 6. Initialize .flow State

In the **project root** (not the worktree):

```bash
mkdir -p <project-root>/.flow
```

Create/update `.flow/worktrees.json`:

```json
{
  "<name>": {
    "branch": "<branch>",
    "path": "<absolute-path-to-.worktrees/name>"
  }
}
```

### 7. Port Assignment (conditional)

If `.flow/config.json` exists → invoke `/port-assign` with `worktree=<name>`.

If not → skip and inform user.

### 8. Verify Clean Baseline

```bash
npm test || pytest || go test ./... || cargo test
```

**If tests fail:** Use AskUserQuestion — proceed or investigate?

**If tests pass:** Continue.

**If no test runner:** Skip.

### 9. Report Ready

```
Worktree ready at <full-path>
  Branch: <branch>
  Ports:  FRONTEND_PORT=10000, API_PORT=10001, DB_PORT=10002  (or "none")
  Tests:  passing (N tests) / skipped

All subsequent work happens in this worktree.
```

---

## Part 2: Working Inside a Worktree

After setup, the session is inside the worktree. The following guidelines apply to ALL skills that run in this context.

### How to Detect You're in a Worktree

```bash
# Check if current directory is under .worktrees/
pwd | grep -q "/.worktrees/" && echo "in worktree"

# Or check git worktree status
git rev-parse --git-common-dir 2>/dev/null
# If output differs from .git, you're in a worktree
```

### Guidelines for Skills Running in a Worktree

**File operations:** All file reads, writes, and edits use the worktree's file tree. The worktree IS the project — treat it as such.

**Git operations:** Commits go to the worktree's branch. `git status`, `git diff`, `git log` all reflect the worktree branch.

**Document paths:** `docs/specs/`, `docs/plans/` resolve relative to the worktree root, not the original project root.

**Port-aware commands:** If `.env.flow` exists in the worktree root, source it or reference it when starting dev servers:
```bash
# Load port assignments
source .env.flow 2>/dev/null
```

**Test commands:** Run tests from the worktree root. They test the worktree's code, not main.

### What Each Skill Should Know

| Skill | Worktree Behavior |
|-------|-------------------|
| `/plan` | Creates plan in worktree's `docs/plans/`. Analyzes worktree's codebase. |
| `/tdd` | Writes code and tests in the worktree. Runs tests in the worktree. |
| `/code-review` | Reviews worktree's diff against base branch. Saves `review-result.md` in worktree's `.flow/`. |
| `/amend` | Modifies spec/plan in the worktree. |
| `/branch-finish` | Operates on the worktree's branch — merge/PR/keep/discard. |

### Returning to Main

When the work is done, `/branch-finish` handles the transition back:
- **Merge/Discard:** Worktree is removed, session returns to project root.
- **PR:** Worktree is kept for review feedback.
- **Keep:** Worktree is preserved.

Do NOT manually `cd` back to the project root during active worktree work.

---

## Part 3: Mid-Workflow Transition

This skill can be invoked at any point, not only after `/spec`.

### Assess Current State

- **No uncommitted changes on main:** Proceed with normal setup.
- **Uncommitted changes on main:** Stash → create worktree → apply stash inside worktree. Inform user what was stashed.
- **Commits on main that belong on a feature branch:** Create worktree → cherry-pick/rebase those commits. Use AskUserQuestion to confirm which commits to move.

### Seamless Transition

The goal is: regardless of when the user decides to use a worktree, the transition should feel seamless. No work should be lost, and the user should be able to continue exactly where they left off — just inside an isolated workspace.

---

## Integration

**Called by:**
- `/spec` (after spec approval, user agrees to worktree)
- User directly (`/using-worktree`)

**Consumed by:**
- `/plan`, `/tdd`, `/code-review`, `/amend` — these skills operate in the worktree context
- `/branch-finish` — handles the exit from worktree

**Pairs with:**
- `/branch-finish` — entry/exit lifecycle of worktree-based development

## Red Flags

**Never:**
- Create worktree without verifying it's gitignored
- Skip baseline test verification
- Manually cd back to project root during active worktree work
- Proceed with failing baseline tests without asking

**Always:**
- Follow safety verification before creation
- Auto-detect and run project setup
- Verify clean test baseline
- Use AskUserQuestion for all user decisions
