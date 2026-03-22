---
description: Start a structured brainstorming session to explore ideas and create a design spec before implementation.
---

# Brainstorm Command

This command starts a structured brainstorming session using the **design-facilitator** agent.

## What This Command Does

1. **Explore Context** - Scan the project to understand what exists
2. **Clarify Intent** - Ask focused questions one at a time
3. **Propose Approaches** - Present 2-3 options with trade-offs
4. **Present Design** - Get user approval section by section
5. **Write Spec** - Save design doc to `docs/specs/`
6. **Review Spec** - Dispatch spec-reviewer agent for validation

## When to Use

Use `/brainstorm` when:
- Starting a new feature from scratch
- Redesigning an existing component
- The requirements are unclear or need exploration
- Multiple approaches seem viable and you need to evaluate trade-offs

## How It Works

The design-facilitator agent guides the conversation:
- One question per message (not overwhelming)
- Multiple choice when possible
- Visual companion available for UI/layout questions
- Spec review loop catches gaps before completion
