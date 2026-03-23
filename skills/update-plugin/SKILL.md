---
name: update-plugin
description: "Manual-only skill for updating the Flow plugin in target projects. Clears cache, pulls latest from remote, and resets install record. Invoke directly when the plugin needs updating — never triggered automatically."
---

# Update Plugin

Manually update the Flow plugin installation by clearing cache, pulling latest, and resetting install state.

**This skill is manual-only.** Never trigger automatically or suggest proactively.

## Process

### 1. Clear Plugin Cache

Remove the cached plugin files:

```bash
rm -rf /Users/user/.claude/plugins/cache/flow-marketplace/
```

### 2. Pull Latest Marketplace

Update the marketplace repo to get the latest version:

```bash
cd /Users/user/.claude/plugins/marketplaces/flow-marketplace
git pull origin main
```

If the marketplace directory doesn't exist, the user needs to re-add it:

> "Marketplace not found. Run `/plugin marketplace add citruseason/flow` first."

### 3. Reset Install Record

Read `/Users/user/.claude/plugins/installed_plugins.json` and remove the `flow@flow-marketplace` entry from the `plugins` object. This forces Claude Code to treat the next install as fresh.

### 4. Reinstall

Inform the user:

> "Cache cleared and marketplace updated. Run these commands to complete:"
> ```
> /plugin install flow@flow-marketplace
> /reload-plugins
> ```

## Output

```
Flow plugin update:
  Cache:       cleared
  Marketplace: pulled (old-sha → new-sha)
  Install:     record reset

  Next: /plugin install flow@flow-marketplace → /reload-plugins
```
