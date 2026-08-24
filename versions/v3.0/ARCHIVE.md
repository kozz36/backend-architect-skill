---
name: backend-architect
description: "Trigger: backend architecture, API design, databases, auth, caching, system design. Choose production backend patterns with local references."
license: Apache-2.0
metadata:
  author: kozz36
  version: "3.0"
---

## Activation Contract

Use this skill for backend architecture decisions when the agent must choose, review, or document production-ready technical direction.

- Designing APIs, auth, caching, queues, persistence, or observability.
- Choosing backend frameworks, databases, ORMs, vector stores, or deployment architecture.
- Reviewing a backend plan for scalability, security, or maintainability.

Do not use this skill for generic explanation, copy editing, or one-off code changes that do not affect architecture or reusable implementation patterns.

## Hard Rules

- Prefer boring, observable architecture before distributed complexity.
- Use PostgreSQL as the default relational baseline unless data shape or operations prove otherwise.
- Do not mock production infrastructure behavior when integration risk is the point; use containers or focused integration checks.
- Keep BFFs thin: orchestration and protocol translation only, never domain ownership.
- Keep the main answer decision-first; move deep rationale to local references instead of long inline prose.
- Verify new version/API claims before adding them to changelogs or decision guidance.

## Decision Gates

| Need | Action |
|------|--------|
| Public API | REST + OpenAPI unless the consumer contract proves another protocol. |
| TS-only app boundary | tRPC can win when one team owns both sides. |
| High-write/event workflow | Consider queues or event-driven design only after consistency boundaries are explicit. |
| Semantic search | Start with pgvector when PostgreSQL is already authoritative; external vector DB only for scale/ops reasons. |

## Execution Steps

1. Identify product constraints, team skill, runtime, data ownership, security boundary, and validation path.
2. Select the smallest architecture that satisfies those constraints.
3. Read `references/technical-reference.md` when detailed matrices, anti-patterns, commands, or source links are needed.
4. State the chosen pattern, rejected alternatives, and what breaks at runtime if the choice is wrong.
5. Add or update changelog entries only for verified technical changes.

## Output Contract

Return:
- Recommended decision and why.
- Alternatives rejected with concrete tradeoffs.
- Runtime risks, failure triggers, and mitigation.
- Validation steps or evidence needed before adoption.

## References

- `references/technical-reference.md` — curated technical basis for v3.0 decisions.
- `references/source-index.md` — source links and verification status for version-sensitive claims.
