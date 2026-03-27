---
name: lint-validate
description: "Validate the health and correctness of all project lint-* skills. Checks structure, output contract, rule freshness, and detection command validity. Automatically invoked before second /lint pass."
---

# Lint Skill Validator

Validate that all project lint-* skills are properly structured, their rules reference real code, and their detection commands actually work. Automatically fixes issues found.

## When to Use

- Automatically: invoked by `/lint` after `/lint-manage` and before the second verification pass
- Standalone: `/lint-validate` to manually check lint skill health

## Process Flow

### Step 1: Discover All lint-* Skills

```bash
ls .claude/skills/lint-*/SKILL.md 2>/dev/null
```

If no lint-* skills found, report "No lint skills to validate" and exit.

### Step 2: Validate Each Skill

For each discovered `lint-{name}` skill, run these checks:

#### 2a. Structure Validation

| Check | Criteria | Severity |
|-------|----------|----------|
| Frontmatter exists | Has `---` delimited YAML with `name` and `description` | FAIL |
| Name matches directory | `name` field matches directory name `lint-{name}` | FAIL |
| Output contract present | SKILL.md contains Status/Findings/Summary format | FAIL |
| references/ directory exists | `.claude/skills/lint-{name}/references/` exists | WARNING |
| At least 1 rule file | references/ contains at least one `.md` file | WARNING |
| Exceptions documented | SKILL.md mentions exceptions or false positives | WARNING |

#### 2b. Rule Freshness Validation

For each `references/*.md` file:

1. **Extract file paths** — find all file paths referenced in the rule
2. **Verify existence** — check each path exists in the codebase:
   ```bash
   ls <file-path> 2>/dev/null || echo "MISSING: <file-path>"
   ```
3. **Extract detection patterns** — find grep/glob commands in the rule
4. **Dry-run detection** — execute one sample command per rule file to verify it produces output:
   ```bash
   # Run the command, check exit code
   <detection-command> > /dev/null 2>&1 && echo "WORKS" || echo "BROKEN"
   ```
5. **Check for empty rules** — flag rule files that contain no actionable checks

| Check | Criteria | Severity |
|-------|----------|----------|
| Referenced files exist | All file paths in rules point to real files | FAIL |
| Detection commands work | At least one command per rule produces output | WARNING |
| Rules are non-empty | Rule files contain actual check logic, not just headers | WARNING |
| Glob patterns match | File glob patterns match at least one file | WARNING |

#### 2c. Consistency Validation

| Check | Criteria | Severity |
|-------|----------|----------|
| No duplicate skills | No two lint-* skills cover the exact same files/patterns | WARNING |
| Output contract format consistent | All skills use the same Status/Findings/Summary structure | FAIL |

### Step 3: Auto-Fix (Autonomous)

For each issue found, apply fixes automatically:

**FAIL-severity fixes:**
- Missing frontmatter → generate from directory name and existing content
- Name mismatch → update `name` field to match directory
- Missing output contract → append standard contract template to SKILL.md
- Missing file references → remove the broken reference from rule files

**WARNING-severity fixes:**
- Missing references/ → create empty directory
- Empty rule files → flag in report (don't delete — may be intentional placeholder)
- Broken detection commands → update pattern based on current file structure
- Duplicate coverage → flag in report for manual review

**Cannot auto-fix:**
- Duplicate skills (requires human judgment on which to keep)
- Rules that are entirely stale (all references broken — flag for review)

### Step 4: Re-validate Fixed Skills

After fixes are applied, re-run validation only on skills that had issues:

```markdown
### Re-validation
| Skill | Before | After |
|-------|--------|-------|
| lint-architecture | 2 FAIL, 1 WARNING | PASS |
| lint-code-convention | 1 WARNING | PASS |
```

### Step 5: Health Report

```markdown
## Lint Skill Health Report

### Summary
- Skills validated: N
- Healthy: X
- Fixed: Y
- Needs manual review: Z

### Per-Skill Status
| Skill | Structure | Rules | Detection | Overall |
|-------|-----------|-------|-----------|---------|
| lint-architecture | PASS | PASS | PASS | HEALTHY |
| lint-code-convention | PASS | FIXED | PASS | FIXED |
| lint-react-optimization | PASS | PASS | WARNING | REVIEW |

### Issues Fixed
- lint-code-convention: removed 2 references to deleted files
- lint-code-convention: updated glob pattern for renamed directory

### Needs Manual Review
- lint-react-optimization: detection command for hook rules produces no matches — rule may be aspirational or stale

### All Healthy
- lint-architecture: 5 rules, all current
```

## Important Constraints

- Fully autonomous — no user confirmation needed
- Never delete an entire lint-* skill — only flag for review
- Never delete rule files — only fix or flag
- Fixes are conservative — when in doubt, flag for review instead of modifying
- All validation uses real filesystem checks (ls, grep), not assumptions
