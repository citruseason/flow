---
name: lint-manage
description: "Analyze lint results and code changes to create new lint skills or improve existing rules. Automatically invoked after first /lint pass, or run standalone to maintain lint skill coverage."
---

# Lint Skill Manager

Analyze the results of a lint pass and the session's code changes to evolve the project's lint-* skills. Creates new skills where coverage gaps exist, updates existing rules where patterns have changed, and removes stale references.

## When to Use

- Automatically: invoked by `/lint` after the first verification pass
- Standalone: `/lint-manage` to manually review and evolve lint skills
- After significant refactoring that may have shifted code patterns

## Input

```
/lint-manage
/lint-manage <area>     # focus on specific area (e.g., "auth", "api")
```

When invoked from `/lint`, receives the first-pass lint results as context.

## Process Flow

### Step 1: Collect Context

Gather two sources of information:

**1a. Session code changes:**
```bash
# Uncommitted changes
git diff HEAD --name-only

# Branch changes from main
git diff main...HEAD --name-only 2>/dev/null
```

**1b. Lint results (if available):**
If invoked from `/lint`, read the first-pass lint results to identify:
- Which lint-* skills produced findings
- Which areas had no coverage (no lint-* skill checked them)
- Which checks passed trivially (may indicate stale rules)

### Step 2: Discover Existing lint-* Skills

Scan the project for all lint skills:
```bash
ls .claude/skills/lint-*/SKILL.md 2>/dev/null
```

For each discovered skill:
- Read SKILL.md and all `references/*.md` files
- Extract the file patterns and code areas it covers
- Build a coverage map: `{skill} → {covered files/patterns}`

### Step 3: Coverage Gap Analysis

Map changed files against the coverage map to identify:

| Gap Type | Description | Action |
|----------|-------------|--------|
| **Uncovered files** | Changed files not matched by any lint-* skill | Candidate for new skill or existing skill expansion |
| **Stale references** | Rules referencing deleted/moved files or patterns | Update or remove from references/ |
| **New patterns** | New code patterns not captured by existing rules | Add to relevant skill's references/ |
| **Outdated values** | Config values, identifiers, or type names that changed | Update in references/ |

### Step 4: CREATE vs UPDATE Decision

Apply this decision tree for each gap:

```
For each uncovered file group:
  IF related to an existing lint-* skill's domain:
    → UPDATE: expand existing skill's coverage
  ELSE IF 3+ related files share common rules/patterns:
    → CREATE: new lint-* skill
  ELSE:
    → EXEMPT (no skill needed — config files, docs, etc.)
```

**CORE Document Requirement:** Every rule MUST reference at least one CORE document via an `upstream:` field (e.g., `- **Upstream:** harness/PRODUCT.md#architecture`). When creating or updating rules, identify the relevant CORE document (`harness/PRODUCT.md`, `harness/SECURITY.md`, `harness/BACKEND.md`, `harness/FRONTEND.md`, etc.) and section that justifies the rule. Rules without an `upstream:` reference are incomplete and must not be finalized.

**Exemptions (never need lint skills):**
- Lock files and generated files (package-lock.json, build output)
- Documentation files (README, CHANGELOG, LICENSE)
- Test fixtures (fixtures/, __fixtures__/, test-data/)
- Vendor/third-party code (vendor/, node_modules/)
- CI/CD configuration (.github/, Dockerfile)

### Step 5: Apply Changes (Autonomous)

No user confirmation — apply all changes directly.

#### 5a. Update Existing Skills

For each skill marked for UPDATE:
- Read current SKILL.md and references/
- **Add only** — never remove working checks or rules
- Add new file paths to skill's coverage scope
- Add new rule files to references/ for newly detected patterns
- Update stale file references (renamed/moved files)
- Update changed values (identifiers, config keys, type names)
- **Add `upstream:` reference** — every new rule must include `- **Upstream:** harness/<CORE_DOC>.md#<section>` linking to the CORE document principle it enforces

#### 5b. Create New Skills

For each new skill to CREATE:
- Naming: `lint-{domain}` in kebab-case (e.g., `lint-auth-patterns`, `lint-api-validation`)
- Create `.claude/skills/lint-{name}/SKILL.md` with:

```yaml
---
name: lint-{name}
description: "{one-line description of what this lint skill checks}"
---
```

- Include the standard output contract in SKILL.md:
```markdown
## Output Format
## Lint Result: lint-{name}
### Status: PASS | WARNING | FAIL
### Findings
- [FAIL] {filepath}:{line} — {description}
- [WARNING] {filepath}:{line} — {description}
- [PASS] {check item} — {pass reason}
### Summary
- Total checks: {N}
- Pass: {N} / Warning: {N} / Fail: {N}
```

- Every rule in the new skill MUST include an `upstream:` field referencing a CORE document:
```markdown
### Rule N: {Rule Name}
- **What:** {description}
- **Upstream:** harness/{CORE_DOC}.md#{section}
```

- Create `references/` with rule files split by aspect
- Each rule file must reference **real file paths** (verify with `ls`)
- Include concrete detection patterns (grep/glob commands that work now)
- Include PASS/FAIL criteria for each check
- Include at least 2-3 realistic exceptions (what is NOT a violation)

#### 5c. Remove Stale Content

- Remove references to files confirmed deleted from the codebase
- Remove rules that no longer apply (pattern completely removed)
- Never remove an entire lint-* skill — only flag for user review if all rules are stale

### Step 5d: CORE-Lint Alignment Check

After all creates/updates, verify CORE-lint alignment across all lint skills:

1. **Scan all lint skills:** Read every `.claude/skills/lint-*/SKILL.md` file
2. **Extract rules:** Parse each `### Rule N:` block
3. **Check for `upstream:` field:** Each rule must contain `- **Upstream:** harness/<CORE_DOC>.md#<section>`
4. **Validate CORE doc exists:** Verify the referenced CORE document file exists at `harness/` root (UPPERCASE `.md` files)
5. **Report misalignment:**

```
CORE-Lint Alignment:
- Total rules scanned: N
- Rules with upstream reference: X
- Rules missing upstream reference: Y
  - lint-{skill}/Rule N: {rule name} — no upstream reference
- Invalid upstream references: Z
  - lint-{skill}/Rule N: references harness/{DOC}.md — file not found
```

If any rules are missing `upstream:` references, add them by identifying the most relevant CORE document section for the rule's domain.

### Step 6: Report

Produce a summary of all changes made:

```markdown
## Lint Manage Report

### Coverage Analysis
- Changed files analyzed: N
- Covered by existing skills: X
- Exempted: Y
- Gaps found: Z

### Skills Updated: N
- lint-{name}: added N new rules, updated M references
- lint-{name}: removed N stale file references

### Skills Created: N
- lint-{name}: covers {domain} ({N files}, {M rules})

### No Action Needed:
- lint-{name}: all rules current, no gaps
```

## Quality Criteria for Generated/Updated Skills

All lint skills must have:
- **Real file paths** verified with `ls`, not placeholders
- **Working detection commands** — grep/glob patterns that match current files
- **PASS/FAIL criteria** — clear conditions for each check
- **At least 2-3 realistic exceptions** — patterns that look like violations but aren't
- **Standard output contract** — Status/Findings/Summary format
- **Rules split by aspect** in references/ — not one monolithic rules.md
- **CORE document reference** — every rule has an `upstream:` reference to a CORE document (e.g., `harness/PRODUCT.md#architecture`)

## Important Constraints

- Fully autonomous — no user confirmation needed
- Append-only for rules — never delete rules that still work
- Only create lint skills for patterns that appear in 3+ files
- Exemption list is strict — don't create skills for config/docs/fixtures
- All generated content follows the language setting in the project's CLAUDE.md
