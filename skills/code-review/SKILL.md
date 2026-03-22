---
name: code-review
description: "Comprehensive security and quality review of code changes. Dispatches code-reviewer agent and presents findings with severity-based blocking. Invoke after writing or modifying code."
---

## Overview

Security and quality review process for code changes. This skill owns the process flow — gathering diffs, dispatching the review agent, and enforcing blocking rules based on severity. The detailed review checklist and assessment logic live in the `code-reviewer` agent.

## When to Use

- After writing or modifying code
- Before commits and merges
- After TDD implementation (Red-Green-Refactor complete)

## Process Flow

### 1. Gather Changed Files

Get the scope of changes to review:

```bash
# Check staged and unstaged changes
git diff --staged
git diff

# If no diff output, check recent commits
git log --oneline -5
```

### 2. Dispatch Review Agent

Send the changed files to the `code-reviewer` agent. The agent performs the full review — security audit, code quality checks, framework-specific patterns, performance analysis, and best practices.

### 3. Present Review Report

Display the agent's findings organized by severity with the summary table and verdict.

## Blocking Rules

| Verdict | Condition | Action |
|---------|-----------|--------|
| **Block** | CRITICAL issues found | Must fix before merge |
| **Warning** | HIGH issues only (no CRITICAL) | Can merge with caution |
| **Approve** | No CRITICAL or HIGH issues | Safe to merge |

## What the Agent Handles

The `code-reviewer` agent owns all review content and assessment logic:

- **Review checklist** — Security, code quality, React/Next.js, Node.js/Backend, performance, best practices
- **Severity assessment** — Classifying findings as CRITICAL, HIGH, MEDIUM, or LOW
- **Confidence-based filtering** — Only reporting issues with >80% confidence; consolidating similar findings
- **Output format** — Structured findings with file locations, descriptions, and suggested fixes

## Save Review Results

After presenting the review report, save the results to `.flow/review-result.md`:

```bash
mkdir -p .flow
```

Write the review verdict and findings summary to `.flow/review-result.md`. This file is used by `/pr-create` to populate the PR template.

Format:
```markdown
# Code Review Result
**Date:** YYYY-MM-DD
**Verdict:** Approve / Warning / Block

## Findings
<copy of the review findings table>

## Summary
<1-2 sentence summary>
```

## PR Creation Prompt

After saving the review results:

1. Ask the user:
   > "Would you like to create a PR? (Y/n)"

2. **If yes:** Invoke `/pr-create`. The pr-create skill will gather all artifacts and create the PR.

3. **If no:** End the review process. The user can run `/pr-create` later or continue with `/amend` for modifications.
