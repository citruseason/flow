# ECC Handoff Guide

This document defines how brainstorming results connect to ECC's workflow.

## Handoff Protocol

When brainstorming produces an approved spec, the transition to ECC follows this pattern:

### 1. Spec Location Convention

Design specs are saved to `docs/specs/YYYY-MM-DD-<topic>-design.md`. This is a shared convention — ECC's planner agent can read these files when invoked with `/plan`.

### 2. Handoff Message

After the user approves the spec, present the handoff:

> "Design complete and committed to `<path>`.
>
> To continue with implementation, you can:
> - `/plan` — create a step-by-step implementation plan (ECC)
> - `/plan` then `/tdd` — plan and implement with test-driven development (ECC)
>
> The spec file contains everything the planner needs to get started."

### 3. What Flow Passes to ECC

| Artifact | Location | Used By |
|----------|----------|---------|
| Design spec | `docs/specs/*.md` | ECC `/plan` (planner agent) |
| Git commit | spec committed to branch | ECC git workflow |
| Visual mockups | `.flow/brainstorm/` (if used) | Reference only |

### 4. What Flow Does NOT Do

- Create implementation plans (ECC `/plan`)
- Write or scaffold code (ECC `/tdd`)
- Review implementation code (ECC `/code-review`)
- Fix build errors (ECC `/build-fix`)
- Run E2E tests (ECC `/e2e`)

Flow's scope ends when the spec is approved. Everything after is ECC's domain.
