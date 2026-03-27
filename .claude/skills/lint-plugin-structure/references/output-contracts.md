# Output Contracts

## Description

All lint-* skills must include a standardized output contract so the lint-reviewer agent can parse and aggregate results. Without this contract, lint results cannot be combined into a unified report.

## Rules

### OC-1: Standard output contract format

Every `.claude/skills/lint-*/SKILL.md` must include an "Output Contract" section with this exact structure:

```markdown
## Output Contract

When reporting results, use this exact format:

## Lint Result: {skill-name}

### Status: PASS | WARNING | FAIL

### Findings

- [FAIL] {filepath}:{line} -- {description}
- [WARNING] {filepath}:{line} -- {description}
- [PASS] {check item} -- {pass reason}

### Summary

- Total checks: {N}
- Pass: {N} / Warning: {N} / Fail: {N}
```

### OC-2: Status must be one of three values

The Status field must be exactly one of: `PASS`, `WARNING`, or `FAIL`. No other values are valid.

### OC-3: Findings must use severity prefixes

Each finding must start with one of: `[FAIL]`, `[WARNING]`, or `[PASS]`. These prefixes enable the lint-reviewer to categorize findings.

### OC-4: Summary must include counts

The Summary section must include:
- Total checks count
- Pass count
- Warning count
- Fail count

### OC-5: Rule Accumulation notice

Every lint-* SKILL.md must include a "Rule Accumulation" section stating that rules are append-only:

```markdown
## Rule Accumulation

Rules in `references/` are append-only. When updating:
- Add new rules at the end of the relevant file
- Update existing rules in place (clarify, add examples)
- Never delete rules -- mark deprecated rules with `[DEPRECATED: reason]`
```
