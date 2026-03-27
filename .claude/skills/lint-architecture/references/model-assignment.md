# Model Assignment

## Description

Agents are assigned to specific LLM models based on their role. This ensures appropriate capability allocation -- complex generation tasks get the most capable model, while validation tasks use faster models.

## Rules

### MA-1: Writer agents must use Opus

Agents that create, generate, or produce content must have `model: opus` in their frontmatter.

**Writer agents (must be Opus):**
| Agent | File | Role |
|-------|------|------|
| harness-initializer | `agents/harness-initializer.md` | Codebase analysis, harness scaffolding |
| meeting-facilitator | `agents/meeting-facilitator.md` | Meeting dialogue, CPS/PRD generation |
| design-doc-writer | `agents/design-doc-writer.md` | Design document creation |

### MA-2: Reviewer agents must use Sonnet

Agents that validate, review, or check existing content must have `model: sonnet` in their frontmatter.

**Reviewer agents (must be Sonnet):**
| Agent | File | Role |
|-------|------|------|
| meeting-reviewer | `agents/meeting-reviewer.md` | CPS/PRD validation |
| design-doc-reviewer | `agents/design-doc-reviewer.md` | Cross-document consistency |
| doc-gardener | `agents/doc-gardener.md` | Documentation freshness |
| lint-reviewer | `agents/lint-reviewer.md` | Lint aggregation, quality scoring |

### MA-3: Frontmatter must include model field

Every agent file in `agents/` must have a `model` field in its YAML frontmatter. Missing model fields make the agent's capability level ambiguous.

**Detection:**
```bash
# Check each agent file for model field in frontmatter
grep -l "^model:" agents/*.md
```

### MA-4: New agents must follow the classification

When adding a new agent, classify it as writer or reviewer:
- If it produces new content (documents, code, analysis) -> Opus
- If it validates existing content (reviews, checks, scores) -> Sonnet
- If it does both (e.g., doc-gardener validates AND updates) -> Sonnet (validation is primary role)
