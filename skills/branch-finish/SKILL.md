---
name: branch-finish
description: "Complete a development branch — verify tests, present 4 options (merge/PR/keep/discard), handle PR creation with Flow template, release ports, and clean up worktree. Called after /code-review or directly."
---

# Branch Finish

Guide completion of development work with structured options and automatic cleanup.

**Core principle:** Verify tests → Present options → Execute choice → Release ports → Clean up worktree.

## Process

### Step 1: Verify Tests

Before presenting options, verify tests pass:

```bash
# Auto-detect test runner
npm test || pytest || go test ./... || cargo test
```

**If tests fail:** Use AskUserQuestion to report failures. Do not proceed to Step 2.

> "Tests failing (N failures). Must fix before completing. Fix now or abort?"

**If tests pass:** Continue to Step 2.

**If no test runner found:** Skip and continue.

### Step 2: Determine Base Branch

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```

If unable to detect, use AskUserQuestion:

> "Could not detect base branch. Is it `main` or `master`?"

### Step 3: Gather Flow Artifacts

Collect information for PR template (used if Option 2 is chosen):

1. **Spec/Plan:** Scan `docs/specs/` and `docs/plans/` for matching documents by topic
2. **Code review:** Read `.flow/review-result.md` if it exists
3. **Change summary:** `git diff <base-branch>...HEAD --stat`
4. **Test results:** From Step 1

### Step 4: Present Options

Use AskUserQuestion to present exactly 4 options:

> "Implementation complete. What would you like to do?"
>
> 1. Merge back to `<base-branch>` locally
> 2. Push and create a Pull Request
> 3. Keep the branch as-is (handle later)
> 4. Discard this work

### Step 5: Execute Choice

#### Option 1: Merge Locally

```bash
git checkout <base-branch>
git pull
git merge <feature-branch>
```

Verify tests on merged result:

```bash
npm test || pytest || go test ./... || cargo test
```

**If tests fail on merge:** Report and ask whether to revert.

**If tests pass:**

```bash
git branch -d <feature-branch>
```

Then: Cleanup (Step 6).

#### Option 2: Push and Create PR

**Build PR content from gathered artifacts:**

**Title:** Generate from branch name or spec title.

**Body:**

```markdown
## Summary
- **Spec:** <spec-path or "N/A">
- **Plan:** <plan-path or "N/A">

## Changes
<3-5 bullet point summary from git diff>

## Test Results
<test summary: X passed, Y failed, Z% coverage>

## Code Review
<review verdict and key findings summary>
```

Use AskUserQuestion to let user review/edit:

> "Here's the PR. Edit title or body, or confirm to create?"
>
> **Title:** `<title>`
> **Body:** (show body)
>
> Options: Create / Edit / Cancel

```bash
git push -u origin <feature-branch>

gh pr create --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Report PR URL.

**Do NOT cleanup worktree** — keep it for review feedback. User can run `/branch-finish` again after PR is merged.

#### Option 3: Keep As-Is

Report: "Keeping branch `<name>`. Worktree preserved at `<path>`."

**Do NOT cleanup.**

#### Option 4: Discard

Use AskUserQuestion for typed confirmation:

> "This will permanently delete:"
> - Branch `<name>`
> - All commits since `<base-branch>`
> - Worktree at `<path>`
>
> "Type 'discard' to confirm."

Wait for exact match. If not `discard`, abort.

```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup (Step 6).

### Step 6: Cleanup

**Only for Options 1 and 4.** Option 2 keeps worktree. Option 3 keeps everything.

#### Release Ports

If worktree has port allocation (check `.flow/worktrees.json`):

1. Check for running processes on allocated ports:

```bash
lsof -i :<port> -t 2>/dev/null
```

2. If processes found, use AskUserQuestion:

> "Active processes on ports: PORT PID COMMAND. Terminate? (Y/n)"

3. Remove `.env.flow` from worktree directory
4. Remove port entries from `.flow/worktrees.json`

#### Remove Worktree

```bash
git worktree remove .worktrees/<name>
```

If uncommitted changes exist, inform user and offer force removal.

#### Update State

Remove entry from `.flow/worktrees.json`.

### Step 7: Report

```
Branch finished:
  Option:  <chosen option>
  Branch:  <branch> (merged/PR created/kept/discarded)
  PR:      <URL> (if Option 2)
  Ports:   released (if cleanup)
  Worktree: removed/kept
```

## Quick Reference

| Option | Merge | Push | PR | Keep Worktree | Cleanup Ports | Cleanup Branch |
|--------|-------|------|----|---------------|---------------|----------------|
| 1. Merge | yes | - | - | - | yes | yes |
| 2. PR | - | yes | yes | yes | - | - |
| 3. Keep | - | - | - | yes | - | - |
| 4. Discard | - | - | - | - | yes | yes (force) |

## Prerequisites

- `gh` CLI installed and authenticated (for Option 2)

```bash
gh auth status
```

## Chaining

Called by `/code-review` when user agrees to finish the branch. Can also be called directly via `/branch-finish`.

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without typed "discard" confirmation
- Force-push without explicit request
- Cleanup worktree after PR creation (keep for review feedback)

**Always:**
- Verify tests before offering options
- Present exactly 4 options via AskUserQuestion
- Get typed confirmation for Option 4
- Release ports during cleanup
- Use AskUserQuestion for all user interaction
