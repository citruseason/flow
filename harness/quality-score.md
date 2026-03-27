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

## Current Baseline

To be filled after first quality assessment.
