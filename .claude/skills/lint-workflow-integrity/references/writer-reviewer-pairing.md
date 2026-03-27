# Writer-Reviewer Pairing

## Description

Every content-producing (writer) agent must have a corresponding validation (reviewer) agent. Review cycles are capped to prevent infinite loops.

## Rules

### WR-1: Writer-reviewer pairs

Each writer agent must have a paired reviewer:

| Writer | Reviewer | Dispatched By |
|--------|----------|---------------|
| meeting-facilitator | meeting-reviewer | `skills/meeting/SKILL.md` |
| design-doc-writer | design-doc-reviewer | `skills/design-doc/SKILL.md` |

**Agents without pairs (acceptable):**
- `harness-initializer` -- output is reviewed by user confirmation gate instead of an agent
- `lint-reviewer` -- is itself a reviewer, does not produce content that needs further review
- `doc-gardener` -- is itself a reviewer/updater, output is informational

### WR-2: Maximum 3 review iterations

Every skill that dispatches a writer-reviewer pair must specify a maximum of 3 review iterations before escalating to the human.

**Check these skills:**
- `skills/meeting/SKILL.md` -- must mention "max 3 iterations" for meeting-reviewer
- `skills/design-doc/SKILL.md` -- must mention "Maximum 3 review iterations" for design-doc-reviewer

**Detection:**
```bash
grep -i "max.*3.*iteration\|3.*iteration\|maximum.*3" skills/meeting/SKILL.md skills/design-doc/SKILL.md
```

### WR-3: Human escalation on review exhaustion

After 3 iterations, the skill must escalate to the human -- not silently accept, not continue iterating, not auto-approve.

**Expected escalation language:**
- "escalate to human"
- "escalate to the user"
- "human guidance is needed"

### WR-4: Implementation retry cap

The `/lint` skill allows SDD workers to fix failing code, but this is capped at 2 retries (not 3 -- implementation fixes are simpler than document reviews).

**Check:** `skills/lint/SKILL.md` must mention "Maximum 2 retry attempts" or equivalent.

### WR-5: Reviewer model must differ from writer model

Writers use Opus, reviewers use Sonnet. This ensures independent judgment -- the reviewer is not the same model instance that produced the output.
