---
name: lint-plugin-structure
description: "Check plugin structural integrity -- manifest consistency, tool declarations, output contracts, document templates, and kanban schema compliance."
---

# lint-plugin-structure

Verify that the Flow plugin's structural elements are well-formed: manifests are consistent, agents declare valid tools, lint skills include output contracts, document templates are followed, and kanban files conform to the schema.

## Before Running

Read all files in this skill's `references/` directory to load the detailed rules:
- `references/manifest-consistency.md`
- `references/tool-declarations.md`
- `references/output-contracts.md`
- `references/document-templates.md`
- `references/kanban-schema.md`

## Scope

Check these files and patterns:
- `.claude-plugin/plugin.json` -- plugin manifest
- `.claude-plugin/marketplace.json` -- marketplace manifest
- `agents/*.md` -- agent tool declarations
- `.claude/skills/lint-*/SKILL.md` -- lint skill output contracts
- `skills/meeting/SKILL.md` -- meeting document templates
- `skills/design-doc/SKILL.md` -- design document templates
- `harness/kanban.json` -- root kanban
- `harness/topics/*/kanban.json` -- topic kanban files (if any exist)

## Rules

### Rule 1: Manifest Consistency
- **What:** `plugin.json` version must exactly match `marketplace.json` plugins[0].version. Both files must be updated together.
- **Upstream:** harness/rules/git.md
- **Why:** Version mismatch causes the marketplace to serve a different version than what the plugin declares, leading to install/update failures.
- **Detection:** Read both files, extract version strings, compare for exact equality.
- **Fix:** Update the lagging file to match the other.

### Rule 2: Agent Tool Declaration
- **What:** Agent `tools` arrays must only contain valid Claude Code tool names. Reviewer agents should have minimal tool sets (Read, Grep, Glob). Writer agents may have full access.
- **Upstream:** harness/SECURITY.md#dependencies
- **Why:** Invalid tool names cause agent dispatch failures. Overly permissive tool sets on reviewers risk unintended modifications.
- **Detection:** Parse tools arrays from all agent frontmatter. Validate each tool name against the allowed set: Read, Write, Edit, Bash, Grep, Glob. Check reviewer agents for unnecessary tools.
- **Fix:** Remove invalid tool names. Reduce reviewer tool sets where appropriate.

### Rule 3: Skill Output Contract
- **What:** All lint-* skills must include the standard Status/Findings/Summary output contract format in their SKILL.md.
- **Upstream:** harness/ARCHITECTURE.md#self-contained-skills
- **Why:** The lint-reviewer agent aggregates results from all lint-* skills. Without a consistent format, results cannot be parsed or combined.
- **Detection:** Read each `.claude/skills/lint-*/SKILL.md`. Check for the presence of "Status:", "Findings", and "Summary" in the output contract section.
- **Fix:** Append the standard output contract template to non-compliant lint skills.

### Rule 4: Document Template Compliance
- **What:** Meeting logs, CPS, PRD, and design documents must follow their defined templates as specified in the meeting-facilitator and design-doc-writer agents.
- **Upstream:** harness/PIPELINE.md
- **Why:** Downstream agents and skills expect specific document structures. Deviations break the document flow pipeline.
- **Detection:** When topic documents exist, verify they contain required sections: Meeting Log (Date, Topic, Session, Discussion, Decisions, Unresolved Items), CPS (Context, Problem, Solution), PRD (Functional Requirements, Non-Functional Requirements, User Scenarios, Acceptance Criteria).
- **Fix:** Flag missing sections for the appropriate agent to regenerate.

### Rule 5: Kanban Schema
- **What:** All kanban.json files must follow the defined schema with required fields: topic, phase, last_updated, meetings (array), steps (object with done/in_progress/backlog arrays). Step items must have id and name fields.
- **Upstream:** harness/PIPELINE.md
- **Why:** The /implement skill reads kanban files to determine execution state. Schema violations cause resume failures.
- **Detection:** Parse each kanban.json file and validate against the schema. Check for required top-level fields and correct types.
- **Fix:** Add missing fields with sensible defaults.

## Output Contract

When reporting results, use this exact format:

```
## Lint Result: lint-plugin-structure

### Status: PASS | WARNING | FAIL

### Findings

- [FAIL] {filepath}:{line} -- {description}
- [WARNING] {filepath}:{line} -- {description}
- [PASS] {check item} -- {pass reason}

### Summary

- Total checks: {N}
- Pass: {N} / Warning: {N} / Fail: {N}
```

## Rule Accumulation

Rules in `references/` are append-only. When updating:
- Add new rules at the end of the relevant file
- Update existing rules in place (clarify, add examples)
- Never delete rules -- mark deprecated rules with `[DEPRECATED: reason]`
