---
description: Create a detailed implementation plan from an approved spec document. Requires spec file path. Restate requirements, assess risks, break down into phases. WAIT for user CONFIRM before proceeding.
---

# Plan Command

This command invokes the **planner** agent to create a comprehensive implementation plan from a spec document.

## What This Command Does

1. **Read Spec** - Load the spec document at the provided path
2. **Restate Requirements** - Clarify what needs to be built
3. **Identify Risks** - Surface potential issues and blockers
4. **Create Step Plan** - Break down implementation into phases
5. **Save Plan** - Write to `docs/plans/YYYY-MM-DD-<topic>-plan.md`
6. **Review Plan** - Dispatch plan-reviewer agent for validation
7. **Wait for Confirmation** - MUST receive user approval before proceeding

## Usage

```
/plan docs/specs/2026-03-22-trip-sharing-design.md
```

A spec file path is required.

## When to Use

Use `/plan` when:
- A spec document has been approved via `/brainstorm`
- Starting a new feature with a design document
- Making significant architectural changes
- Working on complex refactoring
- Multiple files/components will be affected

## How It Works

The planner agent will:

1. **Read the spec document** at the provided path
2. **Analyze the existing codebase** to understand current structure
3. **Break down into phases** with specific, actionable steps
4. **Identify dependencies** between components
5. **Assess risks** and potential blockers
6. **Write the plan** to `docs/plans/`
7. **Dispatch plan-reviewer** for validation
8. **Present the plan** and WAIT for your explicit confirmation

## Important Notes

**CRITICAL**: The planner agent will **NOT** write any code. It produces a plan document only. Use `/tdd` to start implementation after the plan is approved.

If you want changes, respond with:
- "modify: [your changes]"
- "different approach: [alternative]"
- "skip phase 2 and do phase 3 first"
