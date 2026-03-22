# Command-to-Skill Migration Design Spec

## Overview

Migrate Flow plugin from command-based to skill-based architecture. Skills become the main logic holders, agents become dispatch targets. All 5 commands are deleted and replaced by 5 skills.

## Motivation

Commands serve as thin entry points that invoke agents. Moving to skill-based architecture aligns with the Claude Code plugin model where skills define workflows and agents handle specialized tasks. This gives skills full control over the process while agents provide focused expertise when dispatched.

## Invocation Changes

| Before | After |
|--------|-------|
| `/brainstorm` (command) | `/spec` (skill) |
| `/plan <spec-path>` (command) | `/plan <spec-path>` (skill) |
| `/tdd` (command) | `/tdd` (skill) |
| `/amend` (command) | `/amend` (skill) |
| `/code-review` (command) | `/code-review` (skill) |

All invocations are explicit (user types the slash command). No auto-triggering.

## Directory Structure

### Before

```
commands/
├── brainstorm.md
├── plan.md
├── tdd.md
├── amend.md
└── code-review.md

skills/
├── brainstorming/
│   ├── SKILL.md
│   ├── visual-companion.md
│   └── scripts/
└── planning/
    └── SKILL.md
```

### After

```
skills/
├── spec/                  (renamed from brainstorming/)
│   ├── SKILL.md           (refreshed)
│   ├── visual-companion.md
│   └── scripts/
├── plan/                  (renamed from planning/)
│   └── SKILL.md           (refreshed)
├── tdd/                   (new)
│   └── SKILL.md
├── amend/                 (new)
│   └── SKILL.md
└── code-review/           (new)
    └── SKILL.md

commands/                  (deleted entirely)
```

## Skill Definitions

### `/spec` (renamed from brainstorming)

Based on Superpowers brainstorming skill structure, customized for Flow:

- **Name in frontmatter:** `spec`
- **9-step checklist:** explore context, offer visual companion, ask questions, propose approaches, present design, write spec, spec-reviewer dispatch, user review, transition to `/plan`
- **Spec save path:** `docs/specs/YYYY-MM-DD-<topic>-design.md`
- **Reviewer:** dispatch `spec-reviewer` agent
- **Visual Companion:** supported (visual-companion.md + scripts/)
- **Terminal state:** user approves spec, then transition to `/plan`
- **Dispatches:** `design-facilitator` agent as needed for facilitation, `spec-reviewer` for validation
- **Amend mode:** when invoked with `existing_spec_path`, skip full exploration, apply targeted modifications

### `/plan`

- **Name in frontmatter:** `plan`
- **Input:** spec document path (required)
- **Process:** read spec, analyze codebase, break into phases, write plan, dispatch plan-reviewer, wait for user confirmation
- **Plan save path:** `docs/plans/YYYY-MM-DD-<topic>-plan.md`
- **Reviewer:** dispatch `plan-reviewer` agent
- **Terminal state:** user approves plan
- **Dispatches:** `planner` agent as needed, `plan-reviewer` for validation
- **Amend mode:** when invoked with `existing_plan_path`, update only affected phases/steps

### `/tdd`

- **Name in frontmatter:** `tdd`
- **Process:** RED (write failing test) -> GREEN (minimal implementation) -> REFACTOR (improve)
- **Coverage requirement:** 80%+ (100% for critical code)
- **Content:** full TDD workflow including mocking patterns, test file organization, coverage thresholds, common mistakes (previously in tdd-workflow skill, now inlined in tdd-guide agent)
- **Dispatches:** `tdd-guide` agent for enforcement

### `/amend`

- **Name in frontmatter:** `amend`
- **Input:** free-text change request
- **Process:** document discovery, scope assessment, routing
- **Path 1 (minor):** delegate to `/tdd` directly
- **Path 2 (spec-level):** `/spec` (amend mode) -> user confirms -> `/plan` (amend mode) -> user confirms -> `/tdd`
- **Default rule:** ambiguous changes default to Path 2
- **Dispatches:** `amender` agent for orchestration, other agents via their respective skills

### `/code-review`

- **Name in frontmatter:** `code-review`
- **Process:** get changed files, check security/quality/practices, generate report
- **Severity levels:** CRITICAL, HIGH, MEDIUM, LOW
- **Blocking:** CRITICAL or HIGH issues block commit
- **Dispatches:** `code-reviewer` agent for review execution

## Agent Role Changes

Agents are preserved but their role shifts from "main logic owner" to "dispatch target":

| Agent | New Role |
|-------|----------|
| design-facilitator | Dispatched by `/spec` skill for facilitation assistance |
| spec-reviewer | Dispatched by `/spec` skill for spec validation |
| planner | Dispatched by `/plan` skill for planning assistance |
| plan-reviewer | Dispatched by `/plan` skill for plan validation |
| tdd-guide | Dispatched by `/tdd` skill for TDD enforcement |
| code-reviewer | Dispatched by `/code-review` skill for review execution |
| amender | Dispatched by `/amend` skill for orchestration |

Agent prompts should be updated to reflect they are dispatch targets, not entry points. Workflow logic that duplicates what's now in the skill should be removed from agent prompts to avoid inconsistency.

## File Changes

| Action | File | Description |
|--------|------|-------------|
| Rename | `skills/brainstorming/` -> `skills/spec/` | Directory rename including all contents |
| Rewrite | `skills/spec/SKILL.md` | Refresh based on Superpowers structure, Flow customized |
| Rename | `skills/planning/` -> `skills/plan/` | Directory rename |
| Rewrite | `skills/plan/SKILL.md` | Refresh with full planning workflow |
| Create | `skills/tdd/SKILL.md` | New TDD skill with full workflow |
| Create | `skills/amend/SKILL.md` | New amend skill with orchestration logic |
| Create | `skills/code-review/SKILL.md` | New code review skill |
| Delete | `commands/` | Entire directory (5 files) |
| Update | `agents/design-facilitator.md` | Trim to dispatch-target role |
| Update | `agents/planner.md` | Trim to dispatch-target role |
| Update | `agents/tdd-guide.md` | Trim to dispatch-target role |
| Update | `agents/code-reviewer.md` | Trim to dispatch-target role |
| Update | `agents/amender.md` | Trim to dispatch-target role |
| Update | `.claude-plugin/plugin.json` | Remove commands entry |
| Update | `CLAUDE.md` | Reflect new architecture |
| Update | `README.md` | Reflect new architecture |

## Final Workflow

```
/spec          -> spec document (docs/specs/)
/plan          -> plan document (docs/plans/)
/tdd           -> TDD implementation (RED -> GREEN -> REFACTOR)
/amend         -> revision orchestrator (spec -> plan -> TDD)
/code-review   -> security and quality review
```

Each step is invoked manually via explicit slash command. No automatic chaining or auto-triggering.
