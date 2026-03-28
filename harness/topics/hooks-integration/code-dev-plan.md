# Code Dev Plan: Hooks Integration

## Phase 1: Hook Script Infrastructure

- What: Create the hooks/scripts/ directory and establish the shared scripting patterns (error trapping, JSON parsing helper, non-blocking exit)
- Where: `hooks/scripts/`
- How: Create directory. Write a small inline helper pattern (node -e JSON parse) that each script will reuse. Establish the bash template: `#!/usr/bin/env bash`, `set +e` for non-blocking, stderr for errors, exit 0 always.
- Verify:
  - `hooks/scripts/` directory exists
  - Template pattern handles malformed JSON without crashing
  - Scripts exit 0 on any error condition

## Phase 2: SubagentStop Hook -- Kanban Auto-Update

- What: Implement the SubagentStop hook script that reads stdin JSON and updates topic kanban.json step transitions
- Where: `hooks/scripts/subagent-kanban.sh`
- How: Read stdin JSON, extract `agent_name` and `exit_reason`. Find implement-phase topic in `harness/kanban.json`. If found, read topic's kanban.json, move first `in_progress` to `done`, move first `backlog` to `in_progress`, update `last_updated`. Skip on agent failure or non-implement phase. Write updated kanban.json back.
- Verify:
  - Successful agent completion moves in_progress step to done
  - Next backlog item moves to in_progress
  - Failed agent leaves kanban unchanged
  - Non-implement-phase topics are ignored
  - Missing kanban files cause no crash (exit 0)

## Phase 3: Stop Hook -- Kanban Summary

- What: Implement the Stop hook script that outputs a one-line kanban progress summary
- Where: `hooks/scripts/stop-summary.sh`
- How: Read `harness/kanban.json` to find in_progress topics. For each, read topic kanban.json, count done/total steps, format one-line summary. Check `stop_hook_active` to prevent recursion. Output nothing if no active topics.
- Verify:
  - Active topic produces `[Flow] <topic>: <step> (<done>/<total> done)` output
  - No active topics produces empty output
  - Infinite loop guard prevents recursion

## Phase 4: SessionStart Hook -- Context Reinjection

- What: Implement the SessionStart hook script that reinjects working context on resume/compact
- Where: `hooks/scripts/session-start.sh`
- How: Read stdin JSON to get `source` field. On `startup`, output welcome message. On `resume`/`compact`, collect: active topics from root kanban, per-topic step status, CORE doc listing (`ls harness/*.md`), last modified files (`git diff --name-only HEAD~1`), last commit (`git log -1 --oneline`). Format as concise summary. On no active topics, output harness summary only.
- Verify:
  - `startup` source outputs welcome message only
  - `resume` source outputs full context with topics, CORE docs, git info
  - `compact` source outputs same as resume
  - No active topics still shows harness summary
  - Output is concise (no full file contents)

## Phase 5: PostToolUse Hook -- Merge Detection

- What: Implement the PostToolUse hook script that detects merges and triggers /core-update
- Where: `hooks/scripts/post-merge.sh`
- How: Parse the tool input or environment to extract the branch name from the merge/pull command. Extract topic from `feature/<topic>` pattern. Read topic's kanban.json to check if lint step is in `done`. If yes, output the trigger message. If not, output nothing.
- Verify:
  - `git merge feature/my-topic` with lint done outputs trigger message
  - `git pull` with merged branch and lint done outputs trigger message
  - Lint not done produces no output
  - Non-feature branch produces no output
  - Malformed branch names cause no crash

## Phase 6: Hook Registry

- What: Update hooks/hooks.json with all 4 hook event declarations (5 entries total)
- Where: `hooks/hooks.json`
- How: Add PostToolUse (2 entries: git merge, git pull), update SessionStart (replace existing welcome-only with new script), add Stop, add SubagentStop. Each entry points to the corresponding script in `hooks/scripts/`. Set appropriate timeouts.
- Verify:
  - hooks.json is valid JSON with `$schema` field preserved
  - 4 hook event types registered: PostToolUse, SessionStart, Stop, SubagentStop
  - PostToolUse has 2 entries with correct `if` fields
  - All script paths resolve to existing files
  - Existing SessionStart welcome behavior preserved (handled within script)

## Phase 7: Implement Skill Kanban Cleanup

- What: Remove kanban step-move logic from implement SKILL.md, replaced by SubagentStop hook
- Where: `skills/implement/SKILL.md`
- How: Remove the kanban update instructions that tell the controller to move steps after each subagent completes. Keep kanban initialization (first-run setup) and phase field updates. Add a note that SubagentStop hook handles step transitions automatically.
- Verify:
  - SKILL.md no longer contains per-step kanban movement instructions for subagent completion
  - Kanban initialization logic (first-run phase population) is preserved
  - Other skills (meeting, design-doc, lint) remain unchanged
  - SKILL.md references the hook-based kanban update
