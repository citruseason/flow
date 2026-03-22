# Command-to-Skill Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate Flow plugin from command-based to skill-based architecture — skills own workflow logic, agents become dispatch targets.

**Architecture:** Rename `skills/brainstorming/` to `skills/spec/`, `skills/planning/` to `skills/plan/`. Create 3 new skills (tdd, amend, code-review). Rewrite all 5 skill SKILL.md files. Trim 6 agent prompts (plan-reviewer unchanged). Delete entire `commands/` directory. Update plugin.json, CLAUDE.md, README.md.

**Tech Stack:** Markdown-only (Claude Code plugin system)

**Source Spec:** `docs/specs/2026-03-22-command-to-skill-migration-design.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Rename | `skills/brainstorming/` -> `skills/spec/` | Directory rename via git mv |
| Rewrite | `skills/spec/SKILL.md` | Spec skill — full brainstorming workflow (superpowers-based) |
| Rename | `skills/planning/` -> `skills/plan/` | Directory rename via git mv |
| Rewrite | `skills/plan/SKILL.md` | Plan skill — full planning workflow |
| Create | `skills/tdd/SKILL.md` | TDD skill — full TDD workflow + reference content |
| Create | `skills/amend/SKILL.md` | Amend skill — full orchestration logic |
| Create | `skills/code-review/SKILL.md` | Code review skill — process flow |
| Trim | `agents/design-facilitator.md` | Remove Steps 1-6, keep output format + amend mode |
| Trim | `agents/spec-reviewer.md` | Update "brainstorming" -> "spec" references |
| Trim | `agents/planner.md` | Remove planning process, keep examples + amend mode |
| Trim | `agents/tdd-guide.md` | Move reference content to skill, keep enforcement |
| Trim | `agents/code-reviewer.md` | Remove git-diff steps, keep review checklist |
| Trim | `agents/amender.md` | Remove all workflow logic, keep minimal role |
| Delete | `commands/` | Entire directory (5 files) |
| Update | `.claude-plugin/plugin.json` | Remove commands entry |
| Update | `CLAUDE.md` | New architecture, script paths, workflow |
| Update | `README.md` | Match CLAUDE.md changes |

---

## Implementation Steps

### Task 1: Rename brainstorming directory to spec

**Files:**
- Rename: `skills/brainstorming/` -> `skills/spec/`

- [ ] **Step 1: Rename via git mv**

```bash
cd /Users/user/projects/personal/research/flow
git mv skills/brainstorming skills/spec
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "refactor: rename skills/brainstorming to skills/spec"
```

---

### Task 2: Rewrite spec skill (SKILL.md)

Rewrite `skills/spec/SKILL.md` based on Superpowers brainstorming structure, customized for Flow. The skill owns the full workflow (9-step checklist). Replace the entire file content.

**Files:**
- Rewrite: `skills/spec/SKILL.md`

**Key differences from current version:**
- Frontmatter name: `spec` (was `brainstorming`)
- 9-step checklist (add step 9: transition to `/plan`)
- Terminal state: invoke `/plan` (was "Done")
- Visual companion path: `skills/spec/visual-companion.md` (was `skills/brainstorming/visual-companion.md`)
- Spec-reviewer dispatch (unchanged)
- Amend mode section (keep from current, update references)
- Remove `origin: flow` from frontmatter (not needed)

- [ ] **Step 1: Read the current SKILL.md and Superpowers version for reference**

Read `skills/spec/SKILL.md` (renamed from brainstorming) and compare structure with the Superpowers version at `/Users/user/projects/personal/research/superpowers/skills/brainstorming/SKILL.md` (if available). If the Superpowers path is not accessible, use the structural elements defined in Step 2 below as the authoritative guide.

- [ ] **Step 2: Rewrite SKILL.md**

Key changes to apply:
1. Frontmatter: change `name: brainstorming` to `name: spec`, remove `origin: flow`
2. Checklist step 6: keep `docs/specs/` path
3. Checklist step 7: keep `spec-reviewer` agent (not superpowers' `spec-document-reviewer` subagent)
4. Add checklist step 9: "**Transition to implementation** -- suggest user run `/plan` with the spec path"
5. Process Flow diagram: change terminal state from "Done" to "Suggest /plan" (doublecircle)
6. Line 69: change "The terminal state is user approval of the spec. Do NOT jump to implementation." to "**The terminal state is user approval of the spec, then suggest `/plan`.** Do NOT jump to implementation directly."
7. Visual Companion path: update line 158 from `skills/brainstorming/visual-companion.md` to `skills/spec/visual-companion.md`
8. Keep the Amend Mode section from current design-facilitator agent (this was defined in the spec). Add at end of file:

```markdown
## Amend Mode

When invoked with an `existing_spec_path` parameter (via `/amend`), operate in amend mode:

- Skip the full exploration (Steps 1-4)
- Read the existing spec document
- Apply the change request as a targeted modification
- Present the changes to the user for approval
- Dispatch spec-reviewer after updates

### Amend Mode Workflow

1. Read the existing spec at `existing_spec_path`
2. Understand the change request
3. Apply targeted modifications to the spec (update only affected sections)
4. Present the updated spec to the user, highlighting what changed
5. Write the updated spec to the same path
6. Dispatch spec-reviewer for validation (max 3 iterations)
```

9. Keep the credits line at the bottom

- [ ] **Step 3: Commit**

```bash
git add skills/spec/SKILL.md
git commit -m "refactor: rewrite spec skill with full workflow and amend mode"
```

---

### Task 3: Rename planning directory to plan

**Files:**
- Rename: `skills/planning/` -> `skills/plan/`

- [ ] **Step 1: Rename via git mv**

```bash
cd /Users/user/projects/personal/research/flow
git mv skills/planning skills/plan
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "refactor: rename skills/planning to skills/plan"
```

---

### Task 4: Rewrite plan skill (SKILL.md)

Rewrite `skills/plan/SKILL.md` to own the full planning workflow. Move process logic from `agents/planner.md` into the skill.

**Files:**
- Rewrite: `skills/plan/SKILL.md`

- [ ] **Step 1: Read the current skill and planner agent for reference**

Read `skills/plan/SKILL.md` (renamed from planning) and `agents/planner.md` to understand what content to merge.

- [ ] **Step 2: Rewrite SKILL.md**

The new skill should contain:
1. Frontmatter: `name: plan` (remove `origin: flow`)
2. Full planning process (from planner agent's "Planning Process" section: Requirements Analysis, Architecture Review, Step Breakdown, Implementation Order)
3. Plan Format template (from planner agent)
4. Best Practices (from planner agent)
5. Worked Example (from planner agent — the Stripe example)
6. Sizing and Phasing guidance (from planner agent)
7. Red Flags checklist (from planner agent)
8. Plan save path: `docs/plans/YYYY-MM-DD-<topic>-plan.md`
9. Plan review loop: dispatch `plan-reviewer` agent, max 3 iterations
10. User review gate: ask user to review plan before proceeding
11. Update stale reference: change `/brainstorm` to `/spec` (path reference from spec)
12. Amend Mode section:

```markdown
## Amend Mode

When invoked with an `existing_plan_path` parameter (via `/amend`), operate in amend mode:

- Read the existing plan document
- Understand the change request and updated spec
- Update only the affected phases/steps
- Present the changes to the user for approval
- Dispatch plan-reviewer after updates

### Amend Mode Workflow

1. Read the existing plan at `existing_plan_path`
2. Read the updated spec document (path provided by amend skill)
3. Identify which phases/steps are affected by the change
4. Update only the affected sections of the plan
5. Present the updated plan to the user, highlighting what changed
6. Write the updated plan to the same path
7. Dispatch plan-reviewer for validation (max 3 iterations)
```

- [ ] **Step 3: Commit**

```bash
git add skills/plan/SKILL.md
git commit -m "refactor: rewrite plan skill with full workflow and amend mode"
```

---

### Task 5: Create TDD skill

Create `skills/tdd/SKILL.md` with the full TDD workflow. Move reference content (mocking patterns, test file org, coverage thresholds, common mistakes) FROM `agents/tdd-guide.md` INTO this skill.

**Files:**
- Create: `skills/tdd/SKILL.md`

- [ ] **Step 1: Read tdd-guide agent for reference content**

Read `agents/tdd-guide.md` to extract all content that will move to the skill.

- [ ] **Step 2: Create the TDD skill**

The skill should contain:
1. Frontmatter: `name: tdd`, description about TDD enforcement
2. Full TDD Workflow (RED -> GREEN -> REFACTOR cycle with detailed steps)
3. Test Types Required table (Unit, Integration, E2E)
4. Edge Cases checklist (8 items from tdd-guide)
5. Test Anti-Patterns to Avoid
6. Quality Checklist
7. Mocking External Services (Supabase, Redis, OpenAI mocks — move from tdd-guide lines 80-115)
8. Test File Organization (directory tree — move from tdd-guide lines 117-138)
9. Coverage Thresholds (JSON config — move from tdd-guide lines 140-155)
10. Common Testing Mistakes (WRONG/CORRECT pairs — move from tdd-guide lines 157-203)
11. TDD cycle enforcement note: dispatches `tdd-guide` agent for interactive cycle guidance

```bash
mkdir -p skills/tdd
```

- [ ] **Step 3: Commit**

```bash
git add skills/tdd/SKILL.md
git commit -m "feat: create TDD skill with full workflow and reference content"
```

---

### Task 6: Create amend skill

Create `skills/amend/SKILL.md` with the full orchestration logic. Move ALL workflow logic from `agents/amender.md` into this skill.

**Files:**
- Create: `skills/amend/SKILL.md`

- [ ] **Step 1: Read amender agent for content to move**

Read `agents/amender.md` to extract all workflow logic.

- [ ] **Step 2: Create the amend skill**

The skill should contain:
1. Frontmatter: `name: amend`, description about revision orchestration
2. Document Discovery algorithm (4-step process from amender agent)
3. Edge cases (no spec, no plan, multiple matches, spec without plan) — update `/brainstorm` references to `/spec`
4. Routing Logic with default rule (ambiguous -> Path 2)
5. Path 1 (minor): dispatch `tdd-guide` agent
6. Path 2 (spec-level): dispatch `design-facilitator` agent (with existing_spec_path) -> user confirmation gate -> dispatch `planner` agent (with existing_plan_path) -> user confirmation gate -> dispatch `tdd-guide` agent
7. User Confirmation Gates (approve/request changes/abort)
8. Workflow Summary diagram

**Important:** The skill dispatches agents directly (NOT other skills). Update all `/brainstorm` references to `/spec`.

```bash
mkdir -p skills/amend
```

- [ ] **Step 3: Commit**

```bash
git add skills/amend/SKILL.md
git commit -m "feat: create amend skill with full orchestration logic"
```

---

### Task 7: Create code-review skill

Create `skills/code-review/SKILL.md` with the process flow. The skill owns the git-diff-gathering and report presentation. The agent keeps the review checklist.

**Files:**
- Create: `skills/code-review/SKILL.md`

- [ ] **Step 1: Read code-reviewer agent and code-review command for reference**

Read `agents/code-reviewer.md` and note the git-diff-gathering steps (Review Process lines 12-18) that should move to the skill.

- [ ] **Step 2: Create the code-review skill**

The skill should contain:
1. Frontmatter: `name: code-review`, description about code quality/security review
2. Process flow:
   - Get changed files: `git diff --name-only HEAD`
   - Dispatch `code-reviewer` agent with the changed files
   - Present the review report to the user
3. Blocking rule: CRITICAL or HIGH issues block commit
4. Approval criteria: Approve (no CRITICAL/HIGH), Warning (HIGH only), Block (CRITICAL found)
5. When to use section

```bash
mkdir -p skills/code-review
```

- [ ] **Step 3: Commit**

```bash
git add skills/code-review/SKILL.md
git commit -m "feat: create code-review skill with process flow"
```

---

### Task 8: Trim design-facilitator agent

Remove workflow Steps 1-6 (now in `/spec` skill). Keep output format, constraints, and amend mode.

**Files:**
- Modify: `agents/design-facilitator.md`

- [ ] **Step 1: Read the current agent**

Read `agents/design-facilitator.md`.

- [ ] **Step 2: Trim the agent**

Remove:
- "## Your Role" section (lines 10-16) — orchestration role now in skill
- "## Workflow" section (lines 23-41, Steps 1-6) — workflow now in skill

Keep:
- Frontmatter (update description to reflect dispatch-target role)
- Opening line ("You are a design facilitator...")
- "## What You DO NOT Do" section
- "## Output Format" section
- "## Amend Mode" section

Update description in frontmatter to: "Design spec facilitator dispatched by the /spec skill. Assists with structured design exploration and spec writing."

- [ ] **Step 3: Commit**

```bash
git add agents/design-facilitator.md
git commit -m "refactor: trim design-facilitator to dispatch-target role"
```

---

### Task 9: Trim planner agent

Remove top-level planning process (now in `/plan` skill). Keep worked example, sizing/phasing, red flags, and amend mode.

**Files:**
- Modify: `agents/planner.md`

- [ ] **Step 1: Read the current agent**

Read `agents/planner.md`.

- [ ] **Step 2: Trim the agent**

Remove:
- "## Your Role" section (lines 10-16) — orchestration role now in skill
- "## Planning Process" section (lines 18-45, Steps 1-4) — now in skill

Keep:
- Frontmatter (update description to reflect dispatch-target role)
- Opening line
- "## Plan Format" section
- "## Best Practices" section
- "## Worked Example" section
- "## When Planning Refactors" section
- "## Sizing and Phasing" section
- "## Red Flags to Check" section
- "## Amend Mode" section

Update description in frontmatter to: "Planning specialist dispatched by the /plan skill. Creates detailed, phased implementation plans from spec documents."

- [ ] **Step 3: Commit**

```bash
git add agents/planner.md
git commit -m "refactor: trim planner to dispatch-target role"
```

---

### Task 10: Trim tdd-guide agent

**Prerequisite:** Task 5 (TDD skill creation) must be complete before this task — the reference content must exist in the skill before removing it from the agent.

Move reference content (mocking, file org, coverage, mistakes) to the skill. Keep enforcement role and checklists.

**Files:**
- Modify: `agents/tdd-guide.md`

- [ ] **Step 1: Read the current agent**

Read `agents/tdd-guide.md`.

- [ ] **Step 2: Trim the agent**

Remove (these are now in `skills/tdd/SKILL.md`):
- "## Mocking External Services" section (lines 80-115)
- "## Test File Organization" section (lines 117-138)
- "## Coverage Thresholds" section (lines 140-155)
- "## Common Testing Mistakes" section (lines 157-203)

Keep:
- Frontmatter (update description to reflect dispatch-target role)
- Opening line
- "## Your Role" section
- "## TDD Workflow" section (RED/GREEN/REFACTOR cycle)
- "## Test Types Required" table
- "## Edge Cases You MUST Test" section
- "## Test Anti-Patterns to Avoid" section
- "## Quality Checklist" section

Update description in frontmatter to: "TDD enforcement specialist dispatched by the /tdd skill. Guides the RED-GREEN-REFACTOR cycle and ensures 80%+ coverage."

- [ ] **Step 3: Commit**

```bash
git add agents/tdd-guide.md
git commit -m "refactor: trim tdd-guide to dispatch-target role, move reference content to skill"
```

---

### Task 11: Trim code-reviewer agent

Remove git-diff-gathering steps (now in `/code-review` skill). Keep all review checklist content.

**Files:**
- Modify: `agents/code-reviewer.md`

- [ ] **Step 1: Read the current agent**

Read `agents/code-reviewer.md`.

- [ ] **Step 2: Trim the agent**

Remove:
- "## Review Process" section (lines 10-18) — git diff gathering now in skill

Keep:
- Frontmatter (update description to reflect dispatch-target role)
- Opening line
- "## Confidence-Based Filtering" section
- "## Review Checklist" section (all subsections: Security, Code Quality, React/Next.js, Node.js/Backend, Performance, Best Practices)
- "## Review Output Format" section
- "## Approval Criteria" section
- "## Project-Specific Guidelines" section
- "## AI-Generated Code Review Addendum" section

Update description in frontmatter to: "Code review specialist dispatched by the /code-review skill. Applies security, quality, and best-practice checks to code changes."

- [ ] **Step 3: Commit**

```bash
git add agents/code-reviewer.md
git commit -m "refactor: trim code-reviewer to dispatch-target role"
```

---

### Task 12: Trim amender agent and update spec-reviewer

Trim amender to minimal role description. Update spec-reviewer's stale "brainstorming" references.

**Files:**
- Modify: `agents/amender.md`
- Modify: `agents/spec-reviewer.md`

- [ ] **Step 1: Read both agents**

Read `agents/amender.md` and `agents/spec-reviewer.md`.

- [ ] **Step 2: Trim amender agent**

Replace the entire body (everything after frontmatter) with a minimal role description:

```markdown
You are a revision assistant dispatched by the `/amend` skill.

## Your Role

- Assist with targeted modifications to existing specs and plans
- Follow instructions from the amend skill's orchestration logic
- Do NOT orchestrate the workflow yourself -- the skill handles routing and confirmation gates
```

Update description in frontmatter to: "Revision assistant dispatched by the /amend skill. Assists with targeted modifications to specs and plans."

**Note:** The full-body replacement in Step 2 eliminates the stale `/brainstorm` reference (line 34 in current amender.md) — no separate find/replace needed.

- [ ] **Step 3: Update spec-reviewer references**

In `agents/spec-reviewer.md`:
- Line 3: change "Dispatched automatically during the brainstorming spec review loop" to "Dispatched automatically during the spec review loop"
- Line 12: change "Validate spec documents produced by the brainstorming process" to "Validate spec documents produced by the spec process"

- [ ] **Step 4: Commit**

```bash
git add agents/amender.md agents/spec-reviewer.md
git commit -m "refactor: trim amender to minimal role, update spec-reviewer references"
```

---

### Task 13: Delete commands directory

Remove the entire commands directory. All 5 commands are now replaced by skills.

**Files:**
- Delete: `commands/brainstorm.md`
- Delete: `commands/plan.md`
- Delete: `commands/tdd.md`
- Delete: `commands/amend.md`
- Delete: `commands/code-review.md`

- [ ] **Step 1: Delete commands directory**

```bash
cd /Users/user/projects/personal/research/flow
rm -rf commands/
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "refactor: delete commands directory (replaced by skills)"
```

---

### Task 14: Update plugin.json

Remove the commands entry from the plugin manifest.

**Files:**
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: Read plugin.json**

Read `.claude-plugin/plugin.json`.

- [ ] **Step 2: Remove commands entry**

Remove these lines:
```json
"commands": [
    "./commands/"
],
```

The `skills` and `agents` entries remain unchanged (glob patterns auto-discover new/renamed files).

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "refactor: remove commands from plugin manifest"
```

---

### Task 15: Update CLAUDE.md

Update the project documentation to reflect the new skill-based architecture.

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Read CLAUDE.md**

Read `CLAUDE.md`.

- [ ] **Step 2: Apply all updates**

1. **Workflow section**: Replace command-based workflow with skill-based:
```
/spec              → spec document (docs/specs/)
/plan <spec-path>  → plan document (docs/plans/)
/tdd               → TDD implementation (RED → GREEN → REFACTOR)
/amend             → revision orchestrator (spec → plan → TDD)
/code-review       → quality & security review
```

2. **Skills section**: Update to show 5 skills:
```markdown
### Skills (5)

- **skills/spec/** - Design spec creation with visual companion
- **skills/plan/** - Spec-to-plan conversion with phased implementation
- **skills/tdd/** - TDD workflow with mocking patterns and coverage
- **skills/amend/** - Revision orchestrator (spec → plan → TDD)
- **skills/code-review/** - Security and quality review
```

3. **Commands section**: Remove entirely (no more commands)

4. **Document Flow**: Update references from `/brainstorm` to `/spec`:
```
docs/specs/YYYY-MM-DD-<topic>-design.md    ← /spec output
docs/plans/YYYY-MM-DD-<topic>-plan.md      ← /plan output
```

5. **Visual Companion Server paths**: Update from `skills/brainstorming/` to `skills/spec/`:
```bash
skills/spec/scripts/start-server.sh --project-dir /path/to/project
skills/spec/scripts/stop-server.sh $SCREEN_DIR
```

6. **Overview**: Change "Each step is invoked manually by the user" to reflect skill-based invocation.

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for skill-based architecture"
```

---

### Task 16: Update README.md

Update the user-facing documentation to match the new architecture.

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read README.md**

Read `README.md`.

- [ ] **Step 2: Apply all updates**

1. **Workflow overview** (lines 7-13): Replace with skill-based workflow:
```
/spec              → spec 문서 생성
/plan <spec-path>  → 구현 계획서 생성
/tdd               → TDD 구현 (RED → GREEN → REFACTOR)
/amend             → 수정 (스펙 → 플랜 → TDD 오케스트레이션)
/code-review       → 코드 리뷰
```

2. **Quick Start** (lines 44-59): Update commands to skills:
```bash
# 1. 스펙 작성 → spec 문서
/spec "사용자 인증 기능 추가"

# 2. spec 기반 구현 계획
/plan docs/specs/2026-03-22-auth-design.md

# 3. TDD 구현
/tdd

# 4. 코드 리뷰
/code-review

# 5. 수정사항 있으면
/amend "에러 메시지를 토스트로 변경해줘"
```

3. **What's Inside directory tree**: Remove `commands/` section. Update `skills/` to show all 5 skills:
```
|-- skills/
|   |-- spec/                   # /spec (스펙 작성)
|   |   |-- SKILL.md
|   |   |-- visual-companion.md
|   |   |-- scripts/
|   |
|   |-- plan/                   # /plan (구현 계획)
|   |   |-- SKILL.md
|   |
|   |-- tdd/                    # /tdd (TDD 구현)
|   |   |-- SKILL.md
|   |
|   |-- amend/                  # /amend (수정)
|   |   |-- SKILL.md
|   |
|   |-- code-review/            # /code-review (코드 리뷰)
|       |-- SKILL.md
```

4. **How It Works sections**: Update section titles and content:
- "### 1. /brainstorm" -> "### 1. /spec"
- "### 5. /amend" content stays mostly the same
- All `/brainstorm` references -> `/spec`

5. **Visual Companion server paths**: Update from `skills/brainstorming/` to `skills/spec/`

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: update README.md for skill-based architecture"
```

---

## Risks & Mitigations

- **Risk:** Stale path references after directory renames
  - Mitigation: Path Reference Updates table in spec lists all known references; grep for "brainstorming" and "planning" after completion
- **Risk:** Skills too large (token-heavy when loaded)
  - Mitigation: Keep skills focused on workflow; detailed reference content (worked examples) stays in agent prompts
- **Risk:** Agent prompts trimmed too aggressively
  - Mitigation: Spec's "What to Keep" column provides explicit guidance per agent

## Success Criteria

- [ ] `skills/spec/SKILL.md` owns the full brainstorming workflow with 9-step checklist
- [ ] `skills/plan/SKILL.md` owns the full planning workflow with amend mode
- [ ] `skills/tdd/SKILL.md` owns full TDD workflow including reference content
- [ ] `skills/amend/SKILL.md` owns full orchestration logic with agent dispatch
- [ ] `skills/code-review/SKILL.md` owns process flow with commit blocking
- [ ] 6 agents trimmed to dispatch-target roles (plan-reviewer unchanged)
- [ ] `commands/` directory deleted entirely
- [ ] `plugin.json` has no commands entry
- [ ] No stale references to "brainstorming", "planning", or `/brainstorm` in active files
- [ ] `CLAUDE.md` and `README.md` reflect skill-based architecture
- [ ] Visual Companion paths updated from `skills/brainstorming/` to `skills/spec/`
