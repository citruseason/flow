---
name: vercel-react-best-practices
description: "React and Next.js performance optimization guidelines from Vercel Engineering. Use when writing, reviewing, or refactoring React/Next.js code to ensure optimal performance patterns. Triggers on tasks involving React components, Next.js pages, data fetching, bundle optimization, or performance improvements. 64 rules across 8 categories."
origin: vercel-labs
---

# Vercel React Best Practices

Comprehensive performance optimization guide for React and Next.js applications, maintained by Vercel. Contains 64 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:

- Writing new React components or Next.js pages
- Implementing data fetching (client or server-side)
- Reviewing code for performance issues
- Refactoring existing React/Next.js code
- Optimizing bundle size or load times

## Rule Categories by Priority

| Priority | Category                   | Impact      | Prefix      |
| -------- | -------------------------- | ----------- | ----------- |
| 1        | Eliminating Waterfalls     | CRITICAL    | `async-`    |
| 2        | Bundle Size Optimization   | CRITICAL    | `bundle-`   |
| 3        | Server-Side Performance    | HIGH        | `server-`   |
| 4        | Client-Side Data Fetching  | MEDIUM-HIGH | `client-`   |
| 5        | Re-render Optimization     | MEDIUM      | `rerender-` |
| 6        | Rendering Performance      | MEDIUM      | `rendering-`|
| 7        | JavaScript Performance     | LOW-MEDIUM  | `js-`       |
| 8        | Advanced Patterns          | LOW         | `advanced-` |

## Quick Reference

### 1. Eliminating Waterfalls (CRITICAL)

- `async-defer-await` - Move await into branches where actually used
- `async-parallel` - Use Promise.all() for independent operations
- `async-dependencies` - Use better-all for partial dependencies
- `async-api-routes` - Start promises early, await late in API routes
- `async-suspense-boundaries` - Use Suspense to stream content

### 2. Bundle Size Optimization (CRITICAL)

- `bundle-barrel-imports` - Import directly, avoid barrel files
- `bundle-dynamic-imports` - Use next/dynamic for heavy components
- `bundle-defer-third-party` - Load analytics/logging after hydration
- `bundle-conditional` - Load modules only when feature is activated
- `bundle-preload` - Preload on hover/focus for perceived speed

### 3. Server-Side Performance (HIGH)

- `server-auth-actions` - Authenticate server actions like API routes
- `server-cache-react` - Use React.cache() for per-request deduplication
- `server-cache-lru` - Use LRU cache for cross-request caching
- `server-dedup-props` - Avoid duplicate serialization in RSC props
- `server-hoist-static-io` - Hoist static I/O to module level
- `server-serialization` - Minimize data passed to client components
- `server-parallel-fetching` - Restructure components to parallelize fetches
- `server-after-nonblocking` - Use after() for non-blocking operations

### 4-8. Additional Rules

Categories 4-8 cover client-side data fetching, re-render optimization, rendering performance, JavaScript performance, and advanced patterns with 44 additional rules.

## Full Rules Reference

For detailed explanations and code examples for all 64 rules, read:
`skills/react-best-practices/references/AGENTS.md`

---

*Source: [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices). MIT License.*
