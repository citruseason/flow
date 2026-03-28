# Test Cases: Hooks Integration

## Unit Tests

| ID | Scenario | Input | Expected Output |
|----|----------|-------|-----------------|
| U-001 | SubagentStop parses valid stdin JSON | `{"agent_name":"worker","exit_reason":"done"}` | Extracts agent_name="worker", exit_reason="done" |
| U-002 | SubagentStop handles malformed JSON | `{invalid` | Exits 0, no kanban change, error to stderr |
| U-003 | SubagentStop handles empty stdin | (empty) | Exits 0, no kanban change |
| U-004 | SubagentStop skips on agent failure | `{"agent_name":"worker","exit_reason":"error"}` | Exits 0, kanban unchanged (AC10) |
| U-005 | SubagentStop moves in_progress to done | kanban with steps.in_progress=[step1] | step1 moves to done array |
| U-006 | SubagentStop moves backlog to in_progress | kanban with backlog=[step2,step3] | step2 moves to in_progress |
| U-007 | SubagentStop updates last_updated | Any valid input | last_updated = current date |
| U-008 | SubagentStop ignores non-implement phase | harness/kanban.json topic phase="design-doc" | No kanban write (AC11) |
| U-009 | SubagentStop ignores missing implement topic | harness/kanban.json has no implement-phase topic | Exits 0, no action |
| U-010 | Stop hook formats summary correctly | Topic "foo" with 3/5 done, current step "impl-phase-4" | `[Flow] foo: impl-phase-4 (3/5 done)` (AC7) |
| U-011 | Stop hook silent on no active topics | harness/kanban.json all topics phase="done" | Empty stdout (AC8) |
| U-012 | Stop hook respects stop_hook_active guard | stop_hook_active marker present | Exits 0, no output |
| U-013 | SessionStart detects startup source | stdin `{"source":"startup"}` | Outputs welcome message only |
| U-014 | SessionStart detects resume source | stdin `{"source":"resume"}` | Outputs full context summary (AC4) |
| U-015 | SessionStart detects compact source | stdin `{"source":"compact"}` | Outputs full context summary (AC5) |
| U-016 | SessionStart lists CORE docs | harness/*.md files exist | Output contains CORE document names (AC6) |
| U-017 | SessionStart includes last commit | git log available | Output contains last commit oneline (AC6) |
| U-018 | SessionStart includes last modified files | git diff HEAD~1 available | Output contains modified file list (AC6) |
| U-019 | SessionStart no-topic harness summary | No in_progress topics | Outputs harness summary without topic details |
| U-020 | PostMerge extracts topic from branch | `feature/hooks-integration` | topic = "hooks-integration" |
| U-021 | PostMerge ignores non-feature branch | `hotfix/urgent-fix` | No output, exits 0 |
| U-022 | PostMerge checks lint done status | topic kanban lint step in done | Outputs trigger message (AC1) |
| U-023 | PostMerge skips when lint not done | topic kanban lint step in backlog | No output (AC3) |
| U-024 | PostMerge handles missing kanban | No kanban.json for topic | Exits 0, no output |
| U-025 | All scripts exit 0 on error | Any script with forced internal error | Exit code = 0 (AC13) |

## Integration Tests

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| I-001 | PostToolUse merge triggers core-update message | 1. Set up topic with lint done 2. Simulate PostToolUse with `git merge feature/<topic>` | stdout contains `/core-update <topic>` trigger message (AC1) |
| I-002 | PostToolUse pull triggers same as merge | 1. Set up topic with lint done 2. Simulate PostToolUse with `git pull` | stdout contains `/core-update <topic>` trigger message (AC2) |
| I-003 | PostToolUse merge blocked by lint status | 1. Set up topic with lint in backlog 2. Simulate merge | No trigger message output (AC3) |
| I-004 | SessionStart resume full context | 1. Create harness with active topic 2. Simulate SessionStart with source=resume | Output includes topic status, CORE docs, git info (AC4, AC6) |
| I-005 | SessionStart compact full context | 1. Same setup 2. source=compact | Same output as resume (AC5) |
| I-006 | Stop hook with active implement topic | 1. Set topic phase=implement, 3 done steps, 2 remaining 2. Run stop script | Output: `[Flow] <topic>: <step> (3/5 done)` (AC7) |
| I-007 | SubagentStop updates kanban file | 1. Set up implement-phase topic with in_progress step 2. Pipe success JSON to script | kanban.json on disk reflects step transition (AC9) |
| I-008 | SubagentStop failure leaves kanban intact | 1. Same setup 2. Pipe failure JSON | kanban.json unchanged on disk (AC10) |
| I-009 | SubagentStop ignores design-doc phase | 1. Set topic phase=design-doc 2. Pipe success JSON | kanban.json unchanged (AC11) |
| I-010 | hooks.json valid structure | 1. Read hooks/hooks.json | Contains PostToolUse, SessionStart, Stop, SubagentStop keys with correct entries (AC14) |
| I-011 | Implement SKILL.md kanban cleanup | 1. Read skills/implement/SKILL.md | No per-step kanban move instructions for subagent completion (AC12) |

## E2E Tests

| ID | Scenario | Action | Expected Outcome |
|----|----------|--------|------------------|
| E-001 | Full merge-to-core-update flow | Merge a feature branch with completed lint | Claude receives trigger message and invokes /core-update (AC1, AC2) |
| E-002 | Session resume restores context | Resume a Claude session with active topic | Claude context includes topic progress, CORE docs, last commit (AC4, AC6) |
| E-003 | Autonomous execution stop summary | Complete autonomous execution with active topic | Stop output shows one-line kanban summary (AC7) |
| E-004 | Subagent completion auto-updates kanban | Subagent finishes during implement phase | Topic kanban reflects step transition without skill-level code (AC9, AC12) |
| E-005 | Error resilience across all hooks | Corrupt kanban.json, missing files, malformed stdin | All hooks exit 0, main workflow unblocked (AC13) |
| E-006 | All 4 hooks registered | Install plugin and inspect hooks.json | 4 event types with 5 total entries present (AC14) |
