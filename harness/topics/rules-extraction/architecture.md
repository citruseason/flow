# Architecture: Rules Extraction

## Stack

- Markdown -- all documents (CORE, rules, agents, skills, CLAUDE.md)
- JSON -- kanban.json (no changes)
- No runtime code involved

## Structure

```
harness/
  PRODUCT.md              (reduced -- identity, stack, agents, skills, doc flow, links)
  ARCHITECTURE.md         (new -- from PRODUCT.md architecture section)
  PIPELINE.md             (new -- from PRODUCT.md pipeline section)
  OBSERVABILITY.md        (new -- from PRODUCT.md observability section)
  SECURITY.md             (unchanged)
  rules/
    naming.common.md
    naming.javascript.md
    naming.shell.md
    formatting.javascript.md
    formatting.shell.md
    formatting.markdown.md
    imports.javascript.md
    error-handling.javascript.md
    error-handling.shell.md
    error-handling.agent.md
    git.md
    output-language.md

.claude/skills/
  lint-architecture/SKILL.md    (upstream refs updated)
  lint-code-convention/SKILL.md (upstream refs updated)
  lint-plugin-structure/SKILL.md (upstream refs updated)
  lint-workflow-integrity/SKILL.md (upstream refs updated)

skills/
  lint-manage/SKILL.md          (CORE doc list updated)

agents/
  harness-initializer.md        (phases 2 and 6 updated)

CLAUDE.md                       (harness section updated)
```

## Patterns

- **Content extraction, not generation** -- move existing text verbatim; no rewriting or summarizing
- **Domain+stack file naming** -- `{domain}.{stack}.md` for stack-specific, `{domain}.md` for common rules
- **Self-contained documents** -- each rule file readable in isolation, no inter-file references
- **Link-based indirection** -- PRODUCT.md links to extracted docs instead of inlining content
- **Upstream traceability** -- lint-* skills reference specific CORE docs or rule files as their authority source

## Constraints

- Content identity: text moved from PRODUCT.md must be byte-identical in destination files
- No SECURITY.md changes
- No new rules introduced
- PRODUCT.md link section must use relative paths from harness/
- Each lint-* upstream field must point to a file that exists after extraction
- harness-initializer Phase 2 must list all 3 new CORE documents
- harness-initializer Phase 6 must detect and migrate legacy structure (rules in PRODUCT.md)
- CLAUDE.md updates are scoped to `<!-- harness:start -->` / `<!-- harness:end -->` markers
