---
name: backend-architect
description: "Trigger: backend architecture, API design, databases, auth, caching, system design. Choose production backend patterns with local references."
license: Apache-2.0
metadata:
  author: kozz36
  version: "3.1.1"
---

## Activation Contract

Use this skill for backend architecture decisions when the agent must choose, review, or document production-ready technical direction.

- Designing APIs, auth, caching, queues, persistence, or observability.
- Choosing backend frameworks, databases, ORMs, vector stores, or deployment architecture.
- Reviewing a backend plan for scalability, security, or maintainability.

Do not use this skill for generic explanation, copy editing, or one-off code changes that do not affect architecture or reusable implementation patterns.

## Hard Rules

- Read `docs/product-charter.md` before selecting a stack. If it is missing or lacks sufficient product constraints and quality attributes, return the missing decisions as questions and stop selection.
- Prefer boring, observable architecture before distributed complexity.
- After relational requirements are verified, treat PostgreSQL as an initial candidate only when data shape, runtime, consistency, and operations do not establish a better fit.
- Do not mock production infrastructure behavior when integration risk is the point; use containers or focused integration checks.
- Treat runtime portability, dependency licensing, managed-service terms, and data residency as architecture inputs; obtain legal review instead of inferring license obligations.
- Do not substitute an embedded or WASM database for production integration tests unless the tested behavior is demonstrably equivalent.
- Design durable workflows for replay: isolate nondeterminism, make effects idempotent, version long-lived executions, and bound retries.
- Treat MCP tools, A2A agents, and model output as untrusted external boundaries with explicit identity, authorization, consent, validation, and audit.
- Keep BFFs thin: orchestration and protocol translation only, never domain ownership.
- Keep the main answer decision-first; move deep rationale to local references instead of long inline prose.
- Verify version- or API-sensitive claims against live sources before using them in decision guidance.

## Decision Gates

| Need | Action |
|------|--------|
| Missing or insufficient product charter | Return the unresolved constraints and quality-attribute questions; do not recommend a stack. |
| Public API | REST + OpenAPI unless the consumer contract proves another protocol. |
| TS-only app boundary | tRPC can win when one team owns both sides. |
| High-write/event workflow | Consider queues or event-driven design only after consistency boundaries are explicit. |
| Semantic search | Start with pgvector when PostgreSQL is already authoritative; external vector DB only for scale/ops reasons. |
| Portable edge TypeScript API | Evaluate Hono when Web Standards and multi-runtime portability are constraints; retain a runtime-specific framework when its plugins or Node semantics are required. |
| Embedded PostgreSQL semantics | Evaluate PGlite for browser/local-first state, development, or fast tests; keep SQLite for SQLite constraints and real PostgreSQL for production parity. |
| Shared in-memory infrastructure | Compare Valkey, Redis, and managed services by protocol needs, modules, support, license policy, and migration evidence. |
| Long-running or failure-prone process | Use durable execution only when pause/resume, replay, human input, or cross-deployment recovery justify its operational model. |
| Agent interoperability | Use MCP for agent-to-tool/resource boundaries and A2A for independently deployed agent-to-agent boundaries; do not add either inside one process without a portability need. |

## Execution Steps

1. Read `docs/product-charter.md` and extract explicit constraints, quality attributes, team capabilities, runtime, data ownership, security boundaries, and validation paths.
2. If those inputs are insufficient to discriminate between options, return the missing decisions as questions and stop.
3. Select the smallest architecture that satisfies the verified SoT inputs.
4. Read `references/technical-reference.md` when detailed matrices, compatibility and licensing gates, anti-patterns, commands, or source links are needed.
5. State the chosen pattern, rejected alternatives, and what breaks at runtime if the choice is wrong.
6. Record version-sensitive decisions only after live-source verification.

## Output Contract

Return:
- For every recommendation, the exact SoT constraint or quality attribute that justifies it.
- Alternatives rejected with concrete tradeoffs.
- Runtime risks, failure triggers, and mitigation.
- Validation steps or evidence needed before adoption.
- Missing SoT decisions as blocking questions when selection cannot be justified.

## References

- `references/technical-reference.md` — curated technical basis for v3.1.1 decisions.
- `references/source-index.md` — source links and verification status for version-sensitive claims.
