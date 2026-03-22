# CLAUDE.md

## Project Overview

**Flow** is a Claude Code plugin that provides a structured brainstorming and design workflow. It is designed as a **companion to ECC (Everything Claude Code)** — covering the ideation and spec design phase that precedes ECC's `/plan` -> `/tdd` -> `/code-review` pipeline.

Core brainstorming methodology is adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent.

## Architecture

```
flow (this plugin)              ECC (companion plugin)
========================        ========================
/brainstorm                     /plan
  -> design-facilitator agent     -> planner agent
  -> spec-reviewer agent          -> code-reviewer agent
  -> visual companion             -> tdd-guide agent
  -> spec doc output        --->  (input to /plan)
```

### Components

- **agents/** - `spec-reviewer.md` (spec validation), `design-facilitator.md` (brainstorming guide)
- **skills/brainstorming/** - Core brainstorming skill with visual companion and server scripts
- **commands/** - `/brainstorm` slash command
- **hooks/** - Session start hint, post-brainstorm ECC handoff

### ECC Integration Points

- After brainstorming completes, Flow suggests invoking ECC's `/plan` command
- Spec documents are saved to `docs/specs/` which ECC's planner agent can read
- Flow does NOT duplicate any ECC functionality (no TDD, no code review, no build-fix)

## Running the Visual Companion Server

```bash
# Start (requires Node.js, zero dependencies)
skills/brainstorming/scripts/start-server.sh --project-dir /path/to/project

# Stop
skills/brainstorming/scripts/stop-server.sh $SCREEN_DIR
```

## Key Design Decisions

- Flow is intentionally small — it covers ONE phase (ideation/design) well
- All implementation-phase workflows are delegated to ECC
- No overlapping agents, commands, or hooks with ECC
