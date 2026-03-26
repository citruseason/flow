# Plan Format & Worked Example

## Plan Format Template

```markdown
# Implementation Plan: [Feature Name]

## Overview
[2-3 sentences: what the plan covers and how it is phased — not a restatement of the feature]

## Spec Reference
`docs/specs/YYYY-MM-DD-<topic>-design.md`

## Implementation Steps

### Phase 1: [Phase Name] ([N] files)
이 Phase 완료 후 검증: [verification command or criteria]

1. **[Step Name]** (File: path/to/file.ts)
   - Action: Specific action to take
   - Why: Reason for this step
   - Dependencies: None / Requires step X
   - Risk: Low/Medium/High

2. **[Step Name]** (File: path/to/file.ts)
   ...

### Phase 2: [Phase Name]
...

## Testing Strategy
- Unit tests: [files to test]
- Integration tests: [flows to test]
- E2E tests: [user journeys to test]

## Risks & Mitigations
- **Risk**: [Description]
  - Mitigation: [How to address]

## Success Criteria
[Only plan-specific verification steps not already in the spec's success criteria]
- [ ] Criterion 1
- [ ] Criterion 2

## Execution Strategy
- type: direct | worktree
- branch_prefix: feature/<topic>
```

## Worked Example: Adding Stripe Subscriptions

A complete plan showing the level of detail expected:

```markdown
# Implementation Plan: Stripe Subscription Billing

## Overview
3 phases: database schema + webhook backend first, then checkout flow, then feature gating.
Each phase is independently verifiable.

## Spec Reference
`docs/specs/2026-03-22-stripe-billing-design.md`

## Implementation Steps

### Phase 1: Database & Backend (2 files)
이 Phase 완료 후 검증: migration succeeds, webhook endpoint returns 200 for test events

1. **Create subscription migration** (File: supabase/migrations/004_subscriptions.sql)
   - Action: CREATE TABLE subscriptions with RLS policies
   - Why: Store billing state server-side, never trust client
   - Dependencies: None
   - Risk: Low

2. **Create Stripe webhook handler** (File: src/app/api/webhooks/stripe/route.ts)
   - Action: Handle checkout.session.completed, customer.subscription.updated,
     customer.subscription.deleted events
   - Why: Keep subscription status in sync with Stripe
   - Dependencies: Step 1 (needs subscriptions table)
   - Risk: High — webhook signature verification is critical

### Phase 2: Checkout Flow (2 files)
이 Phase 완료 후 검증: Stripe test-mode checkout completes, subscription row created

3. **Create checkout API route** (File: src/app/api/checkout/route.ts)
   - Action: Create Stripe Checkout session with price_id and success/cancel URLs
   - Why: Server-side session creation prevents price tampering
   - Dependencies: Step 1
   - Risk: Medium — must validate user is authenticated

4. **Build pricing page** (File: src/components/PricingTable.tsx)
   - Action: Display three tiers with feature comparison and upgrade buttons
   - Why: User-facing upgrade flow
   - Dependencies: Step 3
   - Risk: Low

### Phase 3: Feature Gating (1 file)
이 Phase 완료 후 검증: free user redirected from pro route, pro user passes through

5. **Add tier-based middleware** (File: src/middleware.ts)
   - Action: Check subscription tier on protected routes, redirect free users
   - Why: Enforce tier limits server-side
   - Dependencies: Steps 1-2 (needs subscription data)
   - Risk: Medium — must handle edge cases (expired, past_due)

## Testing Strategy
- Unit tests: Webhook event parsing, tier checking logic
- Integration tests: Checkout session creation, webhook processing
- E2E tests: Full upgrade flow (Stripe test mode)

## Risks & Mitigations
- **Risk**: Webhook events arrive out of order
  - Mitigation: Use event timestamps, idempotent updates
- **Risk**: User upgrades but webhook fails
  - Mitigation: Poll Stripe as fallback, show "processing" state

## Success Criteria
- [ ] All tests pass with 80%+ coverage
- [ ] Stripe test-mode webhook roundtrip verified

## Execution Strategy
- type: direct
- branch_prefix: feature/stripe-billing
```
