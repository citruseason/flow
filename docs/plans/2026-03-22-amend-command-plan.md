# /amend Command Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `/tdd-workflow` with `/amend` — a revision orchestrator that delegates to existing agents based on change scope.

**Architecture:** New `amender` agent (Opus) acts as orchestrator. It evaluates change requests, discovers relevant spec/plan documents, and delegates to `design-facilitator`, `planner`, and `tdd-guide` in sequence. Existing agents gain an "amend mode" via optional parameters.

**Tech Stack:** Markdown-only (Claude Code plugin system — agents, commands, skills)

**Source Spec:** `docs/specs/2026-03-22-amend-command-design.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `agents/amender.md` | Orchestrator agent — routing, document discovery, delegation |
| Create | `commands/amend.md` | Command definition — description, usage, examples |
| Modify | `agents/design-facilitator.md` | Add amend mode (existing_spec_path parameter) |
| Modify | `agents/planner.md` | Add amend mode (existing_plan_path parameter), add Write/Edit tools |
| Modify | `agents/tdd-guide.md` | Inline tdd-workflow content, remove skill reference |
| Delete | `commands/tdd-workflow.md` | Replaced by /amend |
| Delete | `skills/tdd-workflow/SKILL.md` | Content migrated to tdd-guide |
| Modify | `.claude-plugin/plugin.json` | Add amender agent to agents list |
| Modify | `CLAUDE.md` | Update workflow, agents table, commands, skills |
| Modify | `README.md` | Match CLAUDE.md changes |

---

## Implementation Steps

### Task 1: Create amender agent

The core orchestrator. This is the largest new file and defines the amend workflow.

**Files:**
- Create: `agents/amender.md`

- [ ] **Step 1: Write the amender agent prompt**

```markdown
---
name: amender
description: Revision orchestrator that evaluates change requests and delegates to design-facilitator, planner, and tdd-guide based on scope. Use when modifications are needed to existing specs, plans, or implementation.
tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob"]
model: opus
---

You are a revision orchestrator. When the user requests a change to an existing feature, you assess scope, locate relevant documents, and delegate to specialized agents.

## Your Role

- Receive free-text change requests from the user
- Locate relevant spec and plan documents
- Assess change scope (minor vs. spec-level)
- Delegate to appropriate agents in sequence
- Ensure user confirmation between steps

## What You DO NOT Do

- Write spec or plan content yourself (delegate to design-facilitator and planner)
- Implement code yourself (delegate to tdd-guide)
- Skip user confirmation gates

## Document Discovery

Locate relevant documents using this algorithm:

1. List all files in `docs/specs/` and `docs/plans/`, sorted by date (most recent first)
2. Read the most recent spec and plan
3. If multiple specs/plans exist, read their titles/overviews and match against the change request by topic relevance
4. Present the matched documents to the user for confirmation before proceeding

**Edge cases:**
- **No spec exists:** Inform the user and suggest running `/brainstorm` first
- **No plan exists:** Inform the user and suggest running `/plan` first
- **Multiple matching specs/plans:** Present candidates and ask the user to confirm which one to amend
- **Spec exists but no corresponding plan:** After updating the spec, delegate to planner in create mode (normal `/plan` behavior)

## Routing Logic

Evaluate the change request and select one of two paths.

**Default rule:** When classification is ambiguous, default to Path 2 (safer).

### Path 1: Minor Change

Criteria (ALL must be true):
- Cosmetic changes (image swap, button repositioning, color change) or typo fixes
- No behavioral or architectural impact
- Existing spec/plan still accurately describes the system after the change

Flow:
1. Delegate to `tdd-guide` with the specific change to implement

### Path 2: Spec-level Change

Criteria (ANY triggers Path 2):
- Behavioral changes (error handling, validation logic, timeout values)
- New or removed functionality
- Architectural modifications
- Public API changes (renaming endpoints, changing signatures)
- Existing spec/plan no longer accurately describes the desired system

Flow:
1. Delegate to `design-facilitator` with `existing_spec_path` and change description
2. **User confirmation gate** — show updated spec diff, ask "스펙 변경사항이 맞나요?"
   - Approve: proceed to step 3
   - Request changes: re-run design-facilitator with additional instructions
   - Abort: stop the entire amend flow
3. Delegate to `planner` with `existing_plan_path` and change description
4. **User confirmation gate** — show updated plan diff, ask "플랜 변경사항이 맞나요?"
   - Approve: proceed to step 5
   - Request changes: re-run planner with additional instructions
   - Abort: stop the entire amend flow
5. Delegate to `tdd-guide` with the specific changes to implement

## Workflow Summary

```
User: /amend <change request>
  |
  v
[Document Discovery] -> confirm docs with user
  |
  v
[Assess Scope]
  |
  +--> Path 1 (minor) --> tdd-guide --> done
  |
  +--> Path 2 (spec-level) --> design-facilitator --> user confirms
                                --> planner --> user confirms
                                --> tdd-guide --> done
```
```

- [ ] **Step 2: Commit**

```bash
git add agents/amender.md
git commit -m "feat: add amender orchestrator agent"
```

---

### Task 2: Create /amend command

The command definition that maps `/amend` to the amender agent.

**Files:**
- Create: `commands/amend.md`

- [ ] **Step 1: Write the amend command**

```markdown
---
description: Amend existing specs, plans, and implementation. Assesses change scope and delegates to appropriate agents. For minor changes, goes straight to TDD. For spec-level changes, updates spec -> plan -> TDD with confirmation gates.
---

# Amend Command

This command invokes the **amender** agent to orchestrate revisions.

## What This Command Does

1. **Discover Documents** - Locate relevant spec/plan documents
2. **Assess Scope** - Determine if spec/plan updates are needed
3. **Update Spec** (if needed) - Delegate to design-facilitator, user confirms
4. **Update Plan** (if needed) - Delegate to planner, user confirms
5. **Implement Changes** - Delegate to tdd-guide for TDD implementation

## Usage

```
/amend 로그인 실패 시 에러 메시지를 토스트로 변경해줘
/amend Change error messages to use toast notifications
/amend 버튼 색상을 파란색으로 변경
```

Free-text change request. No file path needed.

## When to Use

Use `/amend` when:
- A feature needs modification after initial implementation
- You discover issues during development that require spec/plan changes
- Code review identified changes that affect the design
- Requirements changed after planning

## How It Works

The amender agent:
1. Finds relevant spec and plan documents automatically
2. Asks you to confirm which documents to amend
3. Routes to the right path based on change scope:
   - **Minor changes** (cosmetic, typo): straight to TDD
   - **Spec-level changes** (behavioral, architectural): spec -> plan -> TDD
4. Requires your confirmation after each document update
```

- [ ] **Step 2: Commit**

```bash
git add commands/amend.md
git commit -m "feat: add /amend command definition"
```

---

### Task 3: Add amend mode to design-facilitator

Add optional `existing_spec_path` parameter support so the agent can update an existing spec rather than creating one from scratch.

**Files:**
- Modify: `agents/design-facilitator.md`

- [ ] **Step 1: Add amend mode section to design-facilitator**

Append a new "## Amend Mode" section after the existing "## Output Format" section (end of file, after line 53). The normal workflow (Steps 1-6) remains unchanged for `/brainstorm` use. The amend mode provides an alternative flow when the amender agent invokes design-facilitator with an existing spec path.

Append to end of `agents/design-facilitator.md`:

```markdown

## Amend Mode

When invoked with an `existing_spec_path` parameter (via the amender agent), operate in amend mode:

- Skip the full brainstorming exploration (Steps 1-4)
- Read the existing spec document
- Apply the change request as a targeted modification
- Present the changes to the user for approval
- Dispatch spec-reviewer after updates

### Amend Mode Workflow

1. Read the existing spec at `existing_spec_path`
2. Understand the change request from the amender
3. Apply targeted modifications to the spec (update only affected sections)
4. Present the updated spec to the user, highlighting what changed
5. Write the updated spec to the same path
6. Dispatch spec-reviewer for validation (max 3 iterations)
```

- [ ] **Step 2: Commit**

```bash
git add agents/design-facilitator.md
git commit -m "feat: add amend mode to design-facilitator agent"
```

---

### Task 4: Add amend mode to planner and add Write/Edit tools

Add optional `existing_plan_path` parameter and expand the tool list.

**Files:**
- Modify: `agents/planner.md`

- [ ] **Step 1: Update planner tools in frontmatter**

Change line 4 from:
```
tools: ["Read", "Grep", "Glob"]
```
to:
```
tools: ["Read", "Write", "Edit", "Grep", "Glob"]
```

- [ ] **Step 2: Add amend mode section to planner**

Append a new "## Amend Mode" section after the last section of the file (after "## Red Flags to Check", line 213). The normal planning flow remains unchanged for `/plan` use.

```markdown

## Amend Mode

When invoked with an `existing_plan_path` parameter (via the amender agent), operate in amend mode:

- Read the existing plan document
- Understand the change request and updated spec
- Update only the affected phases/steps
- Present the changes to the user for approval
- Dispatch plan-reviewer after updates

### Amend Mode Workflow

1. Read the existing plan at `existing_plan_path`
2. Read the updated spec document (path provided by amender)
3. Identify which phases/steps are affected by the change
4. Update only the affected sections of the plan
5. Present the updated plan to the user, highlighting what changed
6. Write the updated plan to the same path
7. Dispatch plan-reviewer for validation (max 3 iterations)
```

- [ ] **Step 3: Commit**

```bash
git add agents/planner.md
git commit -m "feat: add amend mode and Write/Edit tools to planner agent"
```

---

### Task 5: Migrate tdd-workflow content into tdd-guide

Inline the essential reference content from `skills/tdd-workflow/SKILL.md` into the `tdd-guide` agent prompt, then remove the skill reference on line 80.

**Files:**
- Modify: `agents/tdd-guide.md`
- Reference (read-only): `skills/tdd-workflow/SKILL.md`

- [ ] **Step 1: Replace the skill reference with inlined content**

First, read `skills/tdd-workflow/SKILL.md` as the authoritative source. Extract the essential reference sections: mocking patterns, test file organization, coverage thresholds, and common testing mistakes.

Then replace line 80 of `agents/tdd-guide.md`:
```
For detailed mocking patterns and framework-specific examples, see `skill: tdd-workflow`.
```

with the extracted content. The result should look like this (verify against the actual skill file — the content below is a guide, not the sole source of truth):

```markdown
## Mocking External Services

### Supabase Mock
\```typescript
jest.mock('@/lib/supabase', () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn(() => ({
        eq: jest.fn(() => Promise.resolve({
          data: [{ id: 1, name: 'Test Market' }],
          error: null
        }))
      }))
    }))
  }
}))
\```

### Redis Mock
\```typescript
jest.mock('@/lib/redis', () => ({
  searchMarketsByVector: jest.fn(() => Promise.resolve([
    { slug: 'test-market', similarity_score: 0.95 }
  ])),
  checkRedisHealth: jest.fn(() => Promise.resolve({ connected: true }))
}))
\```

### OpenAI Mock
\```typescript
jest.mock('@/lib/openai', () => ({
  generateEmbedding: jest.fn(() => Promise.resolve(
    new Array(1536).fill(0.1)
  ))
}))
\```

## Test File Organization

\```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   └── Button.test.tsx
│   └── MarketCard/
│       ├── MarketCard.tsx
│       └── MarketCard.test.tsx
├── app/
│   └── api/
│       └── markets/
│           ├── route.ts
│           └── route.test.ts
└── e2e/
    ├── markets.spec.ts
    └── auth.spec.ts
\```

## Coverage Thresholds

\```json
{
  "jest": {
    "coverageThresholds": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
\```

## Common Testing Mistakes

### WRONG: Testing Implementation Details
\```typescript
expect(component.state.count).toBe(5)
\```

### CORRECT: Test User-Visible Behavior
\```typescript
expect(screen.getByText('Count: 5')).toBeInTheDocument()
\```

### WRONG: Brittle Selectors
\```typescript
await page.click('.css-class-xyz')
\```

### CORRECT: Semantic Selectors
\```typescript
await page.click('button:has-text("Submit")')
await page.click('[data-testid="submit-button"]')
\```

### WRONG: No Test Isolation
\```typescript
test('creates user', () => { /* ... */ })
test('updates same user', () => { /* depends on previous test */ })
\```

### CORRECT: Independent Tests
\```typescript
test('creates user', () => {
  const user = createTestUser()
})
test('updates user', () => {
  const user = createTestUser()
})
\```
```

- [ ] **Step 2: Commit**

```bash
git add agents/tdd-guide.md
git commit -m "feat: inline tdd-workflow content into tdd-guide agent"
```

---

### Task 6: Delete tdd-workflow command and skill

Remove the files that are now replaced by `/amend` and inlined into `tdd-guide`.

**Files:**
- Delete: `commands/tdd-workflow.md`
- Delete: `skills/tdd-workflow/SKILL.md`

- [ ] **Step 1: Delete tdd-workflow command**

```bash
rm commands/tdd-workflow.md
```

- [ ] **Step 2: Delete tdd-workflow skill and its directory**

```bash
rm -rf skills/tdd-workflow/
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: remove tdd-workflow command and skill (replaced by /amend)"
```

---

### Task 7: Register amender agent in plugin.json

Add the amender agent to the plugin manifest so Claude Code discovers it.

**Files:**
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: Add amender to agents list**

In `.claude-plugin/plugin.json`, add `"./agents/amender.md"` to the `agents` array (line 18-25). The updated array:

```json
"agents": [
    "./agents/spec-reviewer.md",
    "./agents/design-facilitator.md",
    "./agents/planner.md",
    "./agents/plan-reviewer.md",
    "./agents/tdd-guide.md",
    "./agents/code-reviewer.md",
    "./agents/amender.md"
]
```

- [ ] **Step 2: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: register amender agent in plugin manifest"
```

---

### Task 8: Update CLAUDE.md

Update the project documentation to reflect the new workflow.

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update workflow section (lines 11-17)**

Replace:
```
/brainstorm           → spec document (docs/specs/)
/plan <spec-path>     → plan document (docs/plans/)
/tdd                  → TDD implementation (RED → GREEN → REFACTOR)
/code-review          → quality & security review
/tdd-workflow         → apply fixes via TDD
```

with:
```
/brainstorm           → spec document (docs/specs/)
/plan <spec-path>     → plan document (docs/plans/)
/tdd                  → TDD implementation (RED → GREEN → REFACTOR)
/amend                → revision orchestrator (spec → plan → TDD)
/code-review          → quality & security review
```

- [ ] **Step 2: Update Agents table (lines 23-33)**

Replace the agents table with:

```markdown
### Agents (7)

| Agent | Model | Role |
|-------|-------|------|
| design-facilitator | Opus | Brainstorming session facilitator |
| spec-reviewer | Sonnet | Spec document validation |
| planner | Opus | Implementation plan creation |
| plan-reviewer | Sonnet | Plan document validation |
| tdd-guide | Sonnet | TDD cycle enforcement |
| code-reviewer | Sonnet | Security & quality review |
| amender | Opus | Revision orchestrator |
```

- [ ] **Step 3: Update Skills section (lines 36-38)**

Replace:
```markdown
### Skills (3)

- **skills/brainstorming/** - Core brainstorming skill with visual companion and server scripts
- **skills/planning/** - Spec-to-plan conversion with phased implementation steps
- **skills/tdd-workflow/** - TDD patterns, mocking, coverage verification
```

with:
```markdown
### Skills (2)

- **skills/brainstorming/** - Core brainstorming skill with visual companion and server scripts
- **skills/planning/** - Spec-to-plan conversion with phased implementation steps
```

- [ ] **Step 4: Update Commands section (lines 40-46)**

Replace:
```markdown
### Commands (5)

- `/brainstorm` - Start brainstorming session
- `/plan <spec-path>` - Create implementation plan from spec
- `/tdd` - Interactive TDD session
- `/code-review` - Code quality review
- `/tdd-workflow` - Full TDD reference and workflow
```

with:
```markdown
### Commands (5)

- `/brainstorm` - Start brainstorming session
- `/plan <spec-path>` - Create implementation plan from spec
- `/tdd` - Interactive TDD session
- `/amend` - Revision orchestrator (amend spec/plan/implementation)
- `/code-review` - Code quality review
```

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for /amend workflow"
```

---

### Task 9: Update README.md

Update the user-facing documentation to match the new workflow.

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update workflow overview (lines 7-13)**

Replace:
```
/brainstorm           → spec 문서 생성
/plan <spec-path>     → 구현 계획서 생성
/tdd                  → TDD 구현 (RED → GREEN → REFACTOR)
/code-review          → 코드 리뷰
/tdd-workflow         → 수정사항 TDD로 반영
```

with:
```
/brainstorm           → spec 문서 생성
/plan <spec-path>     → 구현 계획서 생성
/tdd                  → TDD 구현 (RED → GREEN → REFACTOR)
/amend                → 수정 (스펙 → 플랜 → TDD 오케스트레이션)
/code-review          → 코드 리뷰
```

- [ ] **Step 2: Update Quick Start usage section**

Find this exact text in the Quick Start code block:
```
# 5. 수정사항 있으면 TDD로 반영
/tdd-workflow
```

Replace with:
```
# 5. 수정사항 있으면
/amend "에러 메시지를 토스트로 변경해줘"
```

- [ ] **Step 3: Update "What's Inside" directory tree (lines 63-103)**

In the agents section, add:
```
|   |-- amender.md                  # 수정 오케스트레이터 (Opus)
```

In the commands section, replace:
```
|   |-- tdd-workflow.md           # /tdd-workflow
```
with:
```
|   |-- amend.md                  # /amend
```

In the skills section, remove:
```
|   |-- tdd-workflow/             # TDD 워크플로우 스킬
|       |-- SKILL.md
```

- [ ] **Step 4: Update "How It Works" section 5 (lines 140-146)**

Replace the `/tdd-workflow` section:
```markdown
### 5. /tdd-workflow — TDD 패턴 레퍼런스

- Unit/Integration/E2E 테스트 패턴
- 외부 서비스 목킹 (Supabase, Redis, OpenAI)
- 커버리지 검증 및 임계값
- 테스팅 안티패턴
```

with:
```markdown
### 5. /amend — 수정 오케스트레이터

- 자연어로 수정 요청 (파일 경로 불필요)
- 변경 규모 자동 판단 (경미 vs 스펙 변경)
- 경미한 변경: 바로 TDD 구현
- 스펙 변경: design-facilitator → planner → tdd-guide 순차 위임
- 각 단계에서 사용자 확인 필수
```

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: update README.md for /amend workflow"
```

---

## Risks & Mitigations

- **Risk:** Amender agent prompt is too long, consuming excessive context
  - Mitigation: Keep routing logic concise; the amender delegates detail to specialized agents
- **Risk:** Design-facilitator amend mode behaves inconsistently with normal mode
  - Mitigation: Clear separation — amend mode has its own workflow subsection, normal flow untouched
- **Risk:** tdd-guide becomes too long after inlining tdd-workflow content
  - Mitigation: Only inline essential reference (mocking patterns, org, thresholds, anti-patterns) — not the full skill

## Success Criteria

- [ ] `/amend` command is registered and discoverable
- [ ] Amender agent correctly routes minor changes to tdd-guide directly
- [ ] Amender agent correctly routes spec-level changes through design-facilitator -> planner -> tdd-guide
- [ ] Design-facilitator supports amend mode (existing_spec_path)
- [ ] Planner supports amend mode (existing_plan_path) and has Write/Edit tools
- [ ] tdd-guide contains inlined TDD reference content
- [ ] `/tdd-workflow` command and skill are removed
- [ ] CLAUDE.md and README.md reflect the new 5-command workflow
- [ ] plugin.json includes amender agent
