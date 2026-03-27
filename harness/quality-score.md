# Quality Score

## Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Prompt Quality | 25 | Are agent/skill prompts clear, complete, and unambiguous? Do they avoid contradictions? |
| Agent-Skill Structure | 20 | Does each agent/skill follow the established frontmatter format, separation of concerns, and file layout? |
| Workflow Integrity | 20 | Is the pipeline (harness-init -> meeting -> design-doc -> implement -> lint) complete with no broken links? |
| Documentation Consistency | 20 | Are all documents (CLAUDE.md, README, agent/skill files) consistent with each other and with actual behavior? |
| Tech Debt | 15 | Does the change reduce or avoid introducing tech debt? Are known issues tracked? |

## Scoring Guide

- **90-100**: Excellent -- meets all criteria, no significant issues
- **70-89**: Good -- minor issues, acceptable for merge
- **50-69**: Needs Work -- significant issues that should be addressed
- **0-49**: Poor -- major issues, should not merge

## Domain Score

| Criterion | Score | Max | Rationale |
|-----------|-------|-----|-----------|
| Prompt Quality | 22 | 25 | All agent and skill prompts are clear, well-structured, and unambiguous. Writer/reviewer roles are cleanly separated. Minor issue: meeting-facilitator agent contains Korean section headers (미확인 사항, 해소된 미확인 사항, Context 배경, etc.) that should be English-only per OL-2. |
| Agent-Skill Structure | 17 | 20 | All 7 agents have valid frontmatter with correct name, description, tools, and model fields matching their role. All 14 skill directories have matching name fields. Meeting-facilitator and design-doc-writer agents manage kanban state directly — a mild AS-1 grey area where orchestration bleeds into execution, but consistent with the project's pragmatic design. |
| Workflow Integrity | 18 | 20 | Full pipeline (harness-init → meeting → design-doc → implement → lint) is intact with all skill-to-agent mappings verified. Writer-reviewer pairing, max-3-iteration caps, max-2-retry caps, and execution boundary markers all PASS. The /code-review mention in lint/SKILL.md description is a legacy label, not a broken reference. Implement skill uses `v{latest}` rather than the canonical `v1` history convention. |
| Documentation Consistency | 15 | 20 | Plugin manifests are in sync (both 0.0.10). Kanban schema is valid. lint-* skills all have output contracts and Rule Accumulation sections. Tech-debt.md is actively maintained with 5 open items. The FIFO inversion (design-doc/SKILL.md) noted in tech-debt.md is confirmed resolved. Three lowercase variables in shell scripts (old_pid, pid, alive) deviate from SH-2 convention. Three module-level camelCase constants in server.cjs (frameTemplate, helperScript, helperInjection, clients, debounceTimers) deviate from JS-6. |
| Tech Debt | 11 | 15 | Tech-debt.md is current with 5 open items tracked. HIGH severity: no test coverage for WebSocket server. MEDIUM severity: no CI/CD, bilingual inconsistency in using-worktree/SKILL.md and meeting-facilitator.md. LOW severity: hardcoded paths in update-plugin, stale external link in frame-template.html. Deduction for the HIGH severity open item (no tests) and tracked Korean text violations. |
| **Total** | **83** | **100** | |

## Lint Pass Results (2026-03-28)

### Requirements Compliance (from /lint first pass)
- Requirements Fulfillment: 16/16 acceptance criteria PASS
- Status: PASS

### lint-architecture: PASS
- 5 rules checked: agent-skill separation, skill self-containment, agent registration, dependency direction, model assignment
- 1 WARNING: meeting-facilitator and design-doc-writer agents manage kanban directly (grey-area AS-1)

### lint-code-convention: WARNING
- 5 rules checked: file naming, frontmatter format, JS style, shell style, output language
- Findings: 3 lowercase shell variables, 5 camelCase module-level constants, Korean text in 2 files (tracked in tech-debt.md)

### lint-plugin-structure: PASS
- 5 rules checked: manifest consistency, tool declarations, output contracts, document templates, kanban schema
- All checks passed

### lint-workflow-integrity: PASS
- 5 rules checked: pipeline completeness, writer-reviewer pairing, history rotation, cross-reference integrity, execution boundaries
- 1 WARNING: implement/SKILL.md uses `v{latest}` instead of canonical `v1` in history-based change detection

## Evaluation Date

2026-03-28

## Notes

- Quality score uses Flow plugin's own criteria (Prompt Quality, Agent-Skill Structure, Workflow Integrity, Documentation Consistency, Tech Debt) rather than default harness criteria
- Requirements compliance (16/16 PASS) is factored into Prompt Quality and Workflow Integrity scores
- Known tech-debt items are tracked in harness/tech-debt.md
