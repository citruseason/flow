---
description: Amend existing specs, plans, and implementation. Assesses change scope and delegates to appropriate agents. For minor changes, goes straight to TDD. For spec-level changes, updates spec -> plan -> TDD with confirmation gates.
---

# Amend Command

This command invokes the **amender** agent to orchestrate revisions.

## What This Command Does

1. **Discover Documents** - Locate relevant spec/plan documents
2. **Assess Scope** - Determine if spec/plan updates are needed
3. **Update Spec** (if needed) - Delegate to design-facilitator, user confirms
4. **Update Plan** (if needed) - Delegate to planner, user confirms
5. **Implement Changes** - Delegate to tdd-guide for TDD implementation

## Usage

```
/amend 로그인 실패 시 에러 메시지를 토스트로 변경해줘
/amend Change error messages to use toast notifications
/amend 버튼 색상을 파란색으로 변경
```

Free-text change request. No file path needed.

## When to Use

Use `/amend` when:
- A feature needs modification after initial implementation
- You discover issues during development that require spec/plan changes
- Code review identified changes that affect the design
- Requirements changed after planning

## How It Works

The amender agent:
1. Finds relevant spec and plan documents automatically
2. Asks you to confirm which documents to amend
3. Routes to the right path based on change scope:
   - **Minor changes** (cosmetic, typo): straight to TDD
   - **Spec-level changes** (behavioral, architectural): spec -> plan -> TDD
4. Requires your confirmation after each document update
