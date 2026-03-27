---
name: lint-code-convention
description: "Check code convention compliance -- file naming, frontmatter format, JavaScript style, shell script style, and output language. Run after writing or modifying code."
---

# lint-code-convention

Verify that all files in the Flow plugin follow established naming, formatting, and style conventions. This skill checks conventions that ensure consistency across the prompt-driven codebase.

## Before Running

Read all files in this skill's `references/` directory to load the detailed rules:
- `references/naming-conventions.md`
- `references/frontmatter-format.md`
- `references/javascript-style.md`
- `references/shell-style.md`
- `references/output-language.md`

## Scope

Check these directories and file patterns:
- `agents/*.md` -- agent definition naming and frontmatter
- `skills/*/SKILL.md` -- skill definition naming and frontmatter
- `skills/*/references/*.md` -- reference file naming
- `skills/meeting/scripts/*.cjs` -- JavaScript style
- `skills/meeting/scripts/*.sh` -- Shell script style
- `skills/meeting/scripts/*.js` -- JavaScript style
- All generated output files -- English language

## Rules

### Rule 1: File Naming
- **What:** Agents use kebab-case.md. Skill directories use kebab-case/. Skill entry files are SKILL.md (uppercase). Reference files use kebab-case.md. Dated documents use YYYY-MM-DD-kebab-case.md.
- **Upstream:** harness/PRODUCT.md#conventions
- **Why:** Consistent naming makes files predictable and discoverable by both humans and agents.
- **Detection:** Glob for all .md files in agents/ and skills/. Check each filename against the naming pattern for its location.
- **Fix:** Rename files to match the convention.

### Rule 2: Frontmatter Format
- **What:** Agent frontmatter requires: name, description, tools, model. Skill frontmatter requires: name, description. All frontmatter uses YAML between `---` delimiters.
- **Upstream:** harness/PRODUCT.md#conventions
- **Why:** Claude Code parses frontmatter to discover and configure agents and skills. Missing fields cause silent failures.
- **Detection:** Parse YAML frontmatter from each agent and skill file. Verify required fields are present.
- **Fix:** Add missing frontmatter fields.

### Rule 3: JavaScript Style
- **What:** 2-space indentation, single quotes, semicolons required, `const` by default (use `let` only when reassignment is needed), camelCase for functions and variables, SCREAMING_SNAKE_CASE for constants, CommonJS format (.cjs extension or `require`/`module.exports`).
- **Upstream:** harness/PRODUCT.md#conventions
- **Why:** The project uses zero-dependency Node.js with CommonJS. Consistent style aids readability.
- **Detection:** Check .cjs and .js files for: tab characters (should be spaces), double quotes (should be single), missing semicolons at end of statements, `var` usage (should be const/let).
- **Fix:** Apply the correct style conventions.

### Rule 4: Shell Script Style
- **What:** SCREAMING_SNAKE_CASE for variables, `[[ ]]` for conditionals (not `[ ]`), `$()` for command substitution (not backticks), JSON format for error output, `#!/usr/bin/env bash` shebang.
- **Upstream:** harness/PRODUCT.md#conventions
- **Why:** Modern bash conventions improve portability and readability. JSON error output enables structured parsing.
- **Detection:** Check .sh files for: shebang line, backtick usage, single-bracket conditionals, non-JSON error output.
- **Fix:** Update to match shell conventions.

### Rule 5: Output Language
- **What:** All generated content must be in English. This includes agent prompts, skill definitions, harness documents, lint rules, and all artifacts produced during the workflow.
- **Upstream:** harness/PRODUCT.md#conventions
- **Why:** English output ensures agent readability across all LLM models and enables consistent cross-referencing.
- **Detection:** Scan generated files for non-ASCII character runs that suggest non-English content (Korean, Japanese, Chinese characters).
- **Fix:** Translate affected content to English.

## Output Contract

When reporting results, use this exact format:

```
## Lint Result: lint-code-convention

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
