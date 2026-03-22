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
- **Visual Companion:** supported (visual-companion.md + scripts/). Path reference must be updated to `skills/spec/visual-companion.md`.
- **Terminal state:** user approves spec, then transition to `/plan`
- **Amend mode:** when invoked with `existing_spec_path`, skip full exploration, apply targeted modifications, dispatch spec-reviewer

### `/plan`

- **Name in frontmatter:** `plan`
- **Input:** spec document path (required)
- **Process:** read spec, analyze codebase, break into phases, write plan, dispatch plan-reviewer, wait for user confirmation
- **Plan save path:** `docs/plans/YYYY-MM-DD-<topic>-plan.md`
- **Reviewer:** dispatch `plan-reviewer` agent
- **Terminal state:** user approves plan
- **Amend mode:** when invoked with `existing_plan_path`, update only affected phases/steps, dispatch plan-reviewer

### `/tdd`

- **Name in frontmatter:** `tdd`
- **Process:** RED (write failing test) -> GREEN (minimal implementation) -> REFACTOR (improve)
- **Coverage requirement:** 80%+ (100% for critical code)
- **Content:** full TDD workflow. The skill owns ALL TDD reference content: mocking patterns, test file organization, coverage thresholds, common testing mistakes. This content moves FROM `agents/tdd-guide.md` INTO `skills/tdd/SKILL.md`.
- **Dispatches:** `tdd-guide` agent for cycle enforcement (agent retains only the enforcement role, not reference content)

### `/amend`

- **Name in frontmatter:** `amend`
- **Input:** free-text change request
- **Process:** document discovery, scope assessment, routing
- **Delegation mechanism:** The `/amend` skill contains the full orchestration logic (document discovery, routing, confirmation gates). It dispatches agents directly -- NOT other skills. Skills are user entry points, not composable.
  - Path 1 (minor): dispatch `tdd-guide` agent
  - Path 2 (spec-level): dispatch `design-facilitator` agent (with existing_spec_path) -> user confirms -> dispatch `planner` agent (with existing_plan_path) -> user confirms -> dispatch `tdd-guide` agent
- **Default rule:** ambiguous changes default to Path 2

### `/code-review`

- **Name in frontmatter:** `code-review`
- **Process:** get changed files via git diff, dispatch code-reviewer agent, present report
- **The skill owns:** process flow (git diff, report presentation, commit blocking)
- **The agent owns:** review checklist content (security, code quality, practices) and severity assessment
- **Blocking:** CRITICAL or HIGH issues block commit (defined in skill, enforced by skill)

## Agent Role Changes

Agents are preserved but their role shifts from "main logic owner" to "dispatch target":

| Agent | New Role | What to Trim | What to Keep |
|-------|----------|-------------|-------------|
| design-facilitator | Dispatched by `/spec` skill | Remove Steps 1-6 workflow (now in skill), remove "Your Role" orchestration | Keep output format, "What You DO NOT Do", amend mode section |
| spec-reviewer | Dispatched by `/spec` skill | Update "brainstorming" references to "spec" | Keep all review logic (already a focused dispatch target) |
| planner | Dispatched by `/plan` skill | Remove top-level planning process steps (now in skill) | Keep worked example, sizing/phasing guidance, red flags, amend mode section |
| plan-reviewer | Dispatched by `/plan` skill | No changes needed | Keep all review logic (already a focused dispatch target) |
| tdd-guide | Dispatched by `/tdd` skill | Remove mocking patterns, test file org, coverage thresholds, common mistakes (move to skill) | Keep TDD cycle enforcement role, edge cases checklist, quality checklist, test types table |
| code-reviewer | Dispatched by `/code-review` skill | Remove git-diff-gathering steps (now in skill) | Keep full review checklist, severity definitions, output format |
| amender | Dispatched by `/amend` skill | Remove ALL workflow logic (document discovery, routing, confirmation gates -- all move to skill) | Keep only frontmatter + minimal description of role as "revision assistant" |

## Path Reference Updates

The following hard-coded paths must be updated when renaming directories:

| File | Old Path | New Path |
|------|----------|----------|
| `skills/spec/SKILL.md` | `skills/brainstorming/visual-companion.md` | `skills/spec/visual-companion.md` |
| `CLAUDE.md` | `skills/brainstorming/scripts/start-server.sh` | `skills/spec/scripts/start-server.sh` |
| `CLAUDE.md` | `skills/brainstorming/scripts/stop-server.sh` | `skills/spec/scripts/stop-server.sh` |
| `agents/spec-reviewer.md` | "brainstorming process" / "brainstorming spec review loop" | "spec process" / "spec review loop" |
| `agents/amender.md` | `/brainstorm` | `/spec` |
| `skills/plan/SKILL.md` | `/brainstorm` | `/spec` |

## File Changes

| Action | File | Description |
|--------|------|-------------|
| Rename | `skills/brainstorming/` -> `skills/spec/` | Directory rename including all contents |
| Rewrite | `skills/spec/SKILL.md` | Refresh based on Superpowers structure, Flow customized, update visual-companion path |
| Rename | `skills/planning/` -> `skills/plan/` | Directory rename |
| Rewrite | `skills/plan/SKILL.md` | Refresh with full planning workflow |
| Create | `skills/tdd/SKILL.md` | New TDD skill with full workflow + reference content from tdd-guide |
| Create | `skills/amend/SKILL.md` | New amend skill with full orchestration logic from amender agent |
| Create | `skills/code-review/SKILL.md` | New code review skill with process flow |
| Delete | `commands/` | Entire directory (5 files: brainstorm.md, plan.md, tdd.md, amend.md, code-review.md) |
| Update | `agents/design-facilitator.md` | Trim: remove Steps 1-6 workflow. Keep: output format, constraints, amend mode |
| Update | `agents/spec-reviewer.md` | Update "brainstorming" references to "spec" |
| Update | `agents/planner.md` | Trim: remove top-level process. Keep: worked example, guidance, amend mode |
| Update | `agents/tdd-guide.md` | Trim: move reference content to skill. Keep: enforcement role, checklists |
| Update | `agents/code-reviewer.md` | Trim: remove git-diff steps. Keep: review checklist, severity, output format |
| Update | `agents/amender.md` | Trim: remove ALL workflow logic. Keep: minimal role description |
| Update | `.claude-plugin/plugin.json` | Remove `"./commands/"` from commands array |
| Update | `CLAUDE.md` | Update architecture (skills not commands), script paths, workflow diagram |
| Update | `README.md` | Match CLAUDE.md changes, update directory tree, workflow, quick start |

## Final Workflow

```
/spec          -> spec document (docs/specs/)
/plan          -> plan document (docs/plans/)
/tdd           -> TDD implementation (RED -> GREEN -> REFACTOR)
/amend         -> revision orchestrator (spec -> plan -> TDD)
/code-review   -> security and quality review
```

Each step is invoked manually via explicit slash command. No automatic chaining or auto-triggering.
