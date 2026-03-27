# Harness Knowledge Base

## Project
- **Name:** Flow
- **Stack:** Markdown (prompts) / JavaScript-CJS (server) / Bash (scripts) / JSON (config)
- **Architecture:** Layered plugin -- Orchestration (skills/) -> Execution (agents/) -> Infrastructure (scripts/)

## Knowledge Map

| Topic | File | Purpose |
|-------|------|---------|
| Quality Scoring | harness/quality-score.md | Weighted quality criteria and scoring rubric |
| Observability | harness/observability.md | Logging, metrics, and error format guidelines |
| Golden Rules | harness/golden-rules.md | Core invariants that must never be violated |
| Tech Debt | harness/tech-debt.md | Known tech debt inventory and priorities |
| Kanban | harness/kanban.json | Topic tracking for ongoing work |
| References | harness/references/ | External reference documents |

## Lint Skills

| Skill | Path | Purpose |
|-------|------|---------|
| Architecture Lint | .claude/skills/lint-architecture/ | Agent-skill separation, dependency direction, model assignment |
| Code Convention Lint | .claude/skills/lint-code-convention/ | File naming, frontmatter format, JS/shell style, output language |
| Plugin Structure Lint | .claude/skills/lint-plugin-structure/ | Manifest consistency, tool declarations, output contracts, schemas |
| Workflow Integrity Lint | .claude/skills/lint-workflow-integrity/ | Pipeline completeness, writer-reviewer pairing, history rotation |

## How This Works

- **harness/**: Project knowledge base -- analyzed facts about this codebase
- **lint-* skills**: Executable checks that Claude Code runs via slash commands
- **Rules accumulate**: Lint rules are append-only. New rules are added over time as patterns emerge. Existing rules are never deleted, only updated.
