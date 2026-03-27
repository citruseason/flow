# Manifest Consistency

## Description

The Flow plugin has two manifest files that must stay in sync. Version drift between them causes marketplace discovery and installation failures.

## Rules

### MC-1: Version fields must match exactly

The version string in `.claude-plugin/plugin.json` at path `$.version` must exactly equal the version string in `.claude-plugin/marketplace.json` at path `$.plugins[0].version`.

**Current state:**
- `plugin.json` version: `"0.0.12"`
- `marketplace.json` plugins[0].version: `"0.0.12"`

**Detection:**
```bash
# Extract versions and compare
jq -r '.version' .claude-plugin/plugin.json
jq -r '.plugins[0].version' .claude-plugin/marketplace.json
```

### MC-2: Patch-only versioning until 1.0.0

Version increments must only change the patch component (third number). The major and minor versions must remain 0.0.x until the project reaches 1.0.0.

**Correct progression:** 0.0.10 -> 0.0.11 -> 0.0.12
**Incorrect:** 0.0.10 -> 0.1.0 (minor bump before 1.0.0)

### MC-3: Both files must be updated together

When changing the version in one file, the other file must be updated in the same commit. A commit that changes only one version file is a violation.

**Detection:** Check git diff for commits that modify one manifest but not the other:
```bash
git log --oneline -- .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

### MC-4: Plugin name consistency

The `name` field in `plugin.json` must match the `plugins[0].name` in `marketplace.json`. Currently both should be `"flow"`.

### MC-5: Agent paths must resolve

Every path in `plugin.json` `agents` array must point to an existing file relative to the plugin root.

**Current agents array:**
```json
[
  "./agents/harness-initializer.md",
  "./agents/meeting-facilitator.md",
  "./agents/meeting-reviewer.md",
  "./agents/design-doc-writer.md",
  "./agents/design-doc-reviewer.md",
  "./agents/doc-gardener.md",
  "./agents/lint-reviewer.md"
]
```

**Detection:**
```bash
# For each path in the agents array, verify the file exists
ls agents/harness-initializer.md agents/meeting-facilitator.md agents/meeting-reviewer.md agents/design-doc-writer.md agents/design-doc-reviewer.md agents/doc-gardener.md agents/lint-reviewer.md 2>&1
```
