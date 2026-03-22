---
name: pr-create
description: "Create a GitHub pull request with a structured template. Auto-populates from spec, plan, git diff, test results, and code-review output. Called after /code-review or directly."
---

# PR Create

Create a GitHub pull request with a structured template populated from Flow artifacts.

## Prerequisites

- `gh` CLI must be installed and authenticated
- Current branch must have a remote tracking branch (or will be pushed)

Check prerequisites:

```bash
gh auth status
```

If not authenticated:

> "GitHub CLI is not authenticated. Run `gh auth login` first."

## Process

### 1. Detect Spec and Plan

Scan `docs/specs/` and `docs/plans/` for matching documents:

- If inside a worktree, check `.flow/worktrees.json` for the worktree name, then match spec/plan files by topic
- If multiple matches, list them and ask the user to confirm
- If no matches, leave the fields as "(no spec found)" / "(no plan found)"

### 2. Generate Change Summary

```bash
# Get the base branch (usually main or master)
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'

# Generate diff summary against base
git diff <base-branch>...HEAD --stat
git diff <base-branch>...HEAD
```

Summarize the changes in 3-5 bullet points covering what was added, modified, or removed.

### 3. Collect Test Results

Detect the project's test runner and execute:

1. Check for test configuration in order:
   - `package.json` → `npm test`
   - `Makefile` with `test` target → `make test`
   - `pyproject.toml` or `setup.py` → `pytest` or `python -m pytest`
   - `go.mod` → `go test ./...`
   - `Cargo.toml` → `cargo test`

2. Run the detected test command:

```bash
<detected-test-command> 2>&1 || true
```

3. Extract: total tests, passed, failed, coverage percentage if available.

If no test runner is detected, note: "(no test runner detected — run tests manually and paste results)"

### 4. Read Code Review Results

Check for `.flow/review-result.md`:

- If exists, read and summarize the verdict (Approve/Warning/Block) and key findings
- If not exists, note: "(code-review not run — run /code-review first for a complete PR)"

### 5. Build PR Content

**Title:** Generate from branch name or spec title. Present to user for editing.

**Body template:**

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

### 6. User Review

Present the complete PR title and body to the user:

> "Here's the PR content. Edit the title or body, or confirm to create:"
>
> **Title:** `<generated title>`
>
> **Body:**
> ```
> <generated body>
> ```
>
> "Create this PR? (Y/edit/n)"

If "edit": ask which part to change, apply changes, re-present.

### 7. Push and Create PR

```bash
# Push current branch if not already pushed
git push -u origin <branch>

# Create PR
gh pr create --title "<title>" --body "<body>"
```

### 8. Output

```
PR created: <PR URL>
  Title: <title>
  Base:  <base-branch>
  Head:  <branch>
```

## Chaining

This skill is called by `/code-review` when the user agrees to PR creation. It can also be called directly via `/pr-create`.
