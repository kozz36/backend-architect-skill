---
name: backend-architect-lite
description: "Trigger: concise backend architecture decisions, stack selection, API, persistence, auth, caching, and system design. Produce constraint-backed production guidance."
license: Apache-2.0
metadata:
  author: kozz36
  version: "3.1.2"
---

## Activation Contract

Use this skill to choose, review, or document a production backend direction when concise, decision-first guidance is needed.

- Designing APIs, persistence, auth, caching, queues, observability, or deployment architecture.
- Choosing frameworks, databases, ORMs, vector stores, or agent boundaries.
- Reviewing a backend plan for scalability, security, operability, or maintainability.

Do not use this skill for generic explanation, copy editing, or one-off code changes that do not affect architecture or reusable implementation patterns.

## Hard Rules

- Discover repository-native authoritative sources for product constraints, quality attributes, team capability, runtime, data ownership, security boundaries, and validation paths before selection. `docs/product-charter.md` is only one possible example.
- If material inputs are insufficient to discriminate between options, return the missing decisions as questions and stop selection.
- Treat every named technology as a candidate, not a default. Prefer the smallest boring, observable architecture that satisfies verified constraints.
- Treat runtime portability, licensing, managed-service terms, residency, retention, and legal obligations as architecture inputs. Obtain legal review for unresolved obligations; do not infer them.
- Do not use mocks, embedded engines, or WASM databases as proof of production behavior when engine, driver, protocol, locking, extension, failover, or concurrency behavior is the risk.
- Design durable workflows for replay: isolate nondeterminism, make effects idempotent, version long-lived executions, and bound retries.
- Treat MCP tools, A2A agents, and model output as untrusted external boundaries with explicit identity, authorization, consent, validation, timeouts, cancellation, isolation, and audit.
- Verify every new version-, API-, licensing-, or security-sensitive claim against a live primary source before recommendation.

## Selection Gates

| Verified need | Candidate direction | Required evidence / fallback |
|---|---|---|
| Public or independently consumed API | REST + OpenAPI | Consumer semantics, compatibility, caching, and client-generation fit; otherwise assess the proven protocol need. |
| Co-released TypeScript boundary | tRPC | One owner controls compatible clients and server releases; otherwise keep an explicit contract. |
| Graph queries, typed RPC, SSE, or WebSocket | GraphQL, gRPC, SSE, or WebSocket | Authorization, cost/backpressure, lifecycle, observability, and infrastructure fit; do not infer from transport preference. |
| Relational integrity | PostgreSQL candidate baseline | Data shape, runtime, consistency, and operations do not prove a better fit. |
| SQLite / edge / local-first | SQLite ecosystem or PGlite candidate | Product requirements, measured workload, consistency/recovery, deployment, and operations support the model. |
| Semantic retrieval with authoritative PostgreSQL | pgvector candidate | Scale, latency, filtering, recall, write rate, memory, and operations fit; otherwise evaluate a justified external store. |
| Variable schema or time series | MongoDB or TimescaleDB/InfluxDB candidate | Actual data model and operations justify the extra system. |
| Shared cache, session, pub/sub, queue, or rate limit | Valkey, Redis, or compatible managed service | Measured latency/throughput or multi-instance coordination needs justify the dependency. |
| High-write/event workflow | Queue or event-driven design | Consistency boundaries, delivery, retention, replay, failure, and operations are explicit. |
| Long-running, replayable, failure-prone process | Durable execution | Pause/resume, replay, human input, or cross-deployment recovery justify its model. |
| Portable edge TypeScript API | Hono candidate | Web Standards and multi-runtime portability are constraints; retain runtime-specific frameworks when plugins or Node semantics are required. |
| Agent interoperability | MCP at tool/resource boundary; A2A at independent remote-agent boundary | A real portability or remote deployment boundary exists; do not add either inside one process by default. |

## Execution Order

1. Discover and read the repository-native sources of truth.
2. Stop with material product, quality, security, data, residency, workload, or operational questions that prevent discrimination.
3. Select the smallest constraint-matched candidate stack; cite the exact source-of-truth constraint for every choice.
4. Define API, data ownership, trust, consistency, failure, observability, and recovery boundaries before adding distributed components.
5. State rejected alternatives, runtime failure triggers, mitigation, validation evidence, and fallback.
6. Verify live primary-source evidence before recording version-sensitive guidance.

## Runtime and Data Choices

### Framework and Runtime Portability

- Shortlist FastAPI for general Python APIs, Litestar only after workload benchmarks support it, Django + DRF for justified content/admin needs, Fastify for Node plugin ecosystems, Hono for portable Web Standards HTTP, Elysia for verified Bun constraints, Go for verified binary/runtime-footprint constraints, and Rust/Axum for measured cost/performance requirements.
- Hono portability still requires target-specific tests of adapters, middleware, sockets, filesystem access, and deployment bindings. Keep Fastify or another Node-specific framework when Node plugins, process APIs, long-lived connections, or operational knowledge win.
- Treat Bun as a runtime choice, not an automatic framework or deployment default. Validate native dependencies, memory, observability, package compatibility, provider support, and production load.
- Free-threaded CPython can execute threads without the GIL, but extensions can re-enable it and memory, safety, and performance behavior differs. Adopt only after the complete dependency set and workload pass concurrency, soak, and regression tests; do not assume async services benefit.
- Prefer a runtime the owning team can operate, profile, secure, and upgrade. Do not infer suitability from team size, labels, or benchmark claims alone.

### Persistence, Local-First, and ORM

- PostgreSQL is a refutable relational baseline only when integrity, runtime, consistency, and operations fit. Validate JSONB, full-text, pgvector, TimescaleDB, and every extension against measured workload and operating constraints.
- Treat Litestream, Turso/libSQL, rqlite, and PowerSync as a shortlist, not a general production-viability claim. Verify topology, write contention, replication/failover, latency, recovery objectives, provider terms, and operational ownership before adoption.
- Evaluate PGlite for browser/local-first state, development, or fast tests requiring PostgreSQL syntax or selected extensions. Keep SQLite for SQLite constraints and real PostgreSQL for production parity.
- PGlite does not prove network drivers, authentication, pools, replication, failover, server configuration, planner behavior, production extensions, or unproven concurrency semantics. Define sync source of truth, write path, conflicts, authorization, partial replication, deletion, and recovery independently.
- Choose SQLAlchemy/SQLModel, Drizzle, or Prisma from query control, migration ownership, runtime and bundle constraints, observability, raw-SQL escape hatches, and team capability. Keep stable Prisma separate from Prisma Next or non-GA adapters until exact maturity is proven.
- Use repository, unit-of-work, and CQRS-light patterns only when their transaction, testability, and read/write-model tradeoffs fit the codebase.

### Caching, Licensing, and Managed Terms

- Do not add a cache by default. Select cache-aside, write-through, write-behind, read-through, TTL, event-driven, or tag invalidation from freshness, consistency, loss, and operational requirements.
- Compare Valkey, Redis, and managed services by protocol behavior, modules, support, migration evidence, command/persistence/cluster/failover compatibility, and load validation.
- Valkey BSD 3-Clause and Redis 8 RSALv2, SSPLv1, or AGPLv3 are selection inputs, not a conclusion about an application's publication obligations. Record the exact artifact, version, deployment, modifications, provider terms, modules, support model, and organizational policy; escalate unresolved obligations to qualified counsel.
- Size connection pools from database limits, instance concurrency, and measured load. Include residency, retention, encryption, deletion, and provider terms in data-service decisions.

## API, Identity, and Security

- Keep BFFs thin: orchestration and protocol translation only, never domain ownership. Align ownership, placement, stack, deployment, and on-call responsibility with the client boundary.
- Choose API versioning from compatibility, intermediaries, cache keys, observability, and deprecation needs; document `Vary` and CDN behavior when headers select representations. Use cursor pagination when mutation consistency requires it. Sign webhooks, include idempotency IDs, and design retry.
- Select authentication only after client types, identity providers, revocation latency, threat model, compliance, and session topology are known. OAuth is authorization, OIDC adds authentication, and JWT is a token format.
- Use Authorization Code with PKCE for browser/native authorization-code clients; do not apply PKCE blindly to `client_credentials`. Keep tokens out of query parameters and logs; validate issuer, audience, signature, expiry, redirects, and scope.
- For public-client refresh tokens, use rotation with token-family reuse detection or sender constraint. Choose sessions, opaque tokens, or structured tokens from trust, revocation, availability, privacy, and interoperability requirements.
- Select RBAC when roles map cleanly to auditable permissions; use ABAC only when attribute policy complexity is justified. Use scoped, short-lived credentials and structured audit for autonomous AI.

## Workflows, Agents, and Retrieval

- Begin with a cohesive or modular monolith unless independent ownership, deployment, scaling, isolation, or failure-containment evidence justifies a service boundary. Keep domain, application ports, infrastructure adapters, and delivery concerns separable when the codebase needs independent testing and change.
- For queues and events, choose streams, NATS, RabbitMQ, Kafka, or a managed option from delivery, persistence, replay, retention, partition scale, ecosystem, throughput, and operational evidence.
- Durable execution does not replace ordinary queues or short jobs. For each durable workflow, separate deterministic orchestration from effects; use stable idempotency keys; define retry classes, backoff, deadlines, cancellation, compensation, poison handling, and manual recovery; version in-flight execution compatibility; and bound history/payload growth with retention, encryption, residency, and deletion.
- Enable pgvector only when semantic retrieval is required. Inventory deployed versions and update affected installations to 0.8.2 or later fixed releases for CVE-2026-3172; parallel HNSW index builds can expose other-relation data or crash PostgreSQL.
- Choose agent frameworks from control flow, persistence, human approval, tool security, telemetry, provider portability, and team capability. A deterministic function, queue, or single agent remains preferable when sufficient.
- MCP is for host/client/server tool, resource, and prompt integration; A2A is for opaque independently deployed agent applications. Pin protocol versions and test authentication, authorization, tenant isolation, replay, cancellation, and failure semantics. Remote descriptions, identities, payloads, and tool results are never trusted by default.

## Observability, Privacy, and Testing

- Define required signals and SLOs before selecting OpenTelemetry, logging, metrics, traces, dashboards, error tracking, or infrastructure control planes. Use structured logs; make liveness, readiness, startup, and dependency-degradation behavior platform-appropriate.
- Keep IaC declarative, reviewed, tested, and reconciled when topology warrants it; prefer provider-native or smaller deployment controls when they satisfy the source of truth at lower lifecycle cost.
- Keep secrets out of runtime `.env` assumptions and logs. Design audit records, data residency, retention, encryption, deletion, and legal review with the selected trust and data boundaries.
- Use unit tests for deterministic policy; integration tests with real engines/protocols when their behavior is under test; and contract, E2E, load, recovery, and security tests according to boundary risk. PGlite can accelerate lower-risk tests but does not prove server PostgreSQL parity.
- Test recovery, replay, idempotency, authorization, tenant isolation, cancellation, and failure semantics wherever the selected architecture relies on them.

## Live Evidence and Failure Checks

- The full runtime's source index records source status and claim-level verification history. Re-check live primary sources before adding or changing a version, API, license, security, or protocol-maturity claim.
- Distinguish protocol requirements, local policy, product maturity, implementation support, and comparative heuristics. Prefer immutable releases, RFCs, specifications, and official security advisories.
- Reject a candidate when its required evidence is absent. Report the failure trigger, runtime impact, evidence needed, and the smaller fallback that still satisfies the verified source of truth.
- Red flags: parameterless raw SQL; browser-accessible reusable credentials without a threat model; unowned process-global state; transport-owned domain policy; mocked proof of production-engine behavior; uncontrolled module coupling; missing refresh-token replay defense; missing health/degradation signals; unbounded durable side effects; or MCP/A2A boundaries that trust remote input by default.

## Output Contract

Return:

- The exact source-of-truth constraint or quality attribute justifying every recommendation.
- Selected pattern and rejected alternatives with concrete tradeoffs.
- Runtime risks, failure triggers, mitigation, fallback, and validation evidence needed before adoption.
- Security, privacy, licensing, managed-service, residency, retention, and legal-review constraints when applicable.
- Missing material product, constraint, quality, workload, or operational decisions as blocking questions when selection cannot be justified.
