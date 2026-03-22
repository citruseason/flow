---
description: Use when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests.
---

# TDD Workflow Command

This command activates the **tdd-workflow** skill for comprehensive test-driven development.

## What This Command Does

1. **Write User Journeys** - Define what needs to be built as user stories
2. **Generate Test Cases** - Create comprehensive test suite from journeys
3. **Run Tests (RED)** - Verify tests fail before implementation
4. **Implement Code (GREEN)** - Write minimal code to pass tests
5. **Run Tests Again** - Verify tests pass
6. **Refactor** - Improve code while keeping tests green
7. **Verify Coverage** - Ensure 80%+ test coverage

## When to Use

Use `/tdd-workflow` when:
- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new components
- Implementing changes from a code review

## How It Works

The tdd-workflow skill provides:
- Complete RED-GREEN-REFACTOR cycle guidance
- Unit, integration, and E2E test patterns
- Mocking patterns for external services (Supabase, Redis, OpenAI)
- Coverage verification and thresholds
- Common testing mistakes to avoid
- Test file organization conventions

## Difference from /tdd

- `/tdd` invokes the **tdd-guide agent** for interactive guidance through a single TDD session
- `/tdd-workflow` activates the **tdd-workflow skill** which provides the full reference of patterns, examples, and best practices

Use `/tdd` for guided implementation. Use `/tdd-workflow` when you want the comprehensive TDD reference available during development.
