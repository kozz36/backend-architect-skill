# Backend Architecture Technical Reference

This is the curated v3.1.2 technical basis for architecture decisions. It contains the detailed matrices, decision trees, anti-patterns, commands, and operational guidance that are intentionally too large for `../SKILL.md`.

## How to Use This Reference

- Read `../SKILL.md` first for activation, hard rules, and output contract.
- Use this file only when a decision needs deeper technical detail.
- Treat every named technology and stack below as a candidate baseline, not a default. Adopt it only when a cited constraint or quality attribute from a repository-native authoritative source satisfies its stated criteria.
- Treat version-sensitive claims as requiring verification through `source-index.md` before making new recommendations.
- Treat inherited benchmark, team-size, service-count, and test-ratio claims as non-normative heuristics unless current workload or organizational evidence validates them.

## Reference Scope

Backend stack, API, persistence, auth, caching, observability, AI/vector, and platform decisions.

## Provenance

This reference was curated upstream for v3.0 from a prior lite edition, expanded in v3.1, and corrected in v3.1.1 after an independent source audit.

---

## 1. Framework Selection

### Decision Matrix

Shortlist a framework only after the SoT establishes language/runtime compatibility, team capability, deployment constraints, delivery speed, and measurable performance requirements.

| Scenario | Framework | Reason |
|----------|-----------|--------|
| Python — general API | **FastAPI** | Async, OpenAPI auto-gen, Pydantic validation |
| Python — performance-sensitive API | **Litestar** | Typed ASGI candidate; benchmark the actual workload before claiming an advantage |
| Python — content/admin heavy | **Django + DRF** | ORM, admin, batteries included |
| Node.js — general API | **Fastify** | Fast, schema-based, great plugin ecosystem |
| JS/TS — multi-runtime / edge | **Hono** | Web Standards portability across supported runtimes |
| Node.js — Bun runtime | **Elysia** | Native Bun, end-to-end types |
| Infrastructure / CLI / binary | **Go (Echo/Chi)** | Single binary, low memory, extreme concurrency |
| Cost-critical at massive scale | **Rust (Axum)** | Max performance, zero GC pauses, deterministic memory safety |

### Team Capability Gates
- Prefer a runtime and framework the owning team can operate, profile, secure, and upgrade.
- Evaluate tRPC only when one team controls compatible TypeScript clients and server releases.
- Prefer Go when binary distribution, runtime footprint, concurrency model, and team capability are verified constraints.
- Do not infer framework suitability from team size or scenario labels alone.

### Runtime and Portability Gates

- Hono is built on Web Standards and supports edge runtimes, Deno, Bun, Node.js, and other compatible targets. Prefer it when one HTTP core must remain portable; do not claim zero migration work until adapters, middleware, sockets, filesystem access, and deployment bindings are tested on every target.
- Keep Fastify or another Node-specific framework when mature Node plugins, process APIs, long-lived connections, or existing operational knowledge outweigh runtime portability.
- Treat Bun as a runtime choice, not an automatic framework or deployment default. Validate native dependencies, memory behavior, observability, package compatibility, and provider support under production load.
- CPython free-threaded builds can execute threads without the GIL, but extensions may re-enable it and the runtime has different memory, safety, and performance characteristics. Adopt only after the complete dependency set and workload pass concurrency, soak, and regression tests; never assume an async web service benefits from free threading.

---

## 2. Database Architecture

### Conditional Storage Baselines

| Need | Choice |
|------|--------|
| Primary relational store | **PostgreSQL** — JSONB, arrays, full-text search, extensions |
| Embedded / edge / serverless | **SQLite** — Litestream (replication), Turso (libSQL), rqlite (Raft), or **PGlite** when embedded PostgreSQL semantics are required |
| Cache / queue / pub-sub | **Valkey**, **Redis**, or a compatible managed service after capability, license, and support review |
| Document store (justified) | **MongoDB** — only when schema genuinely variable |
| Time-series | **TimescaleDB** (PostgreSQL extension) or **InfluxDB** |
| Vector search / semantic retrieval | **pgvector** (PostgreSQL extension) or **Pinecone** / **Milvus** |
| Local-first sync engine | **PowerSync**, **Turso**, **ElectricSQL**, or **Replicache** |

### PostgreSQL as a Refutable Relational Baseline

When the SoT requires relational integrity and does not establish conflicting edge, write-concurrency, operational, or data-model constraints, PostgreSQL is the candidate baseline. It can also serve selected document, search, vector, or time-series workloads through **JSONB**, native full-text search, **pgvector** (HNSW/IVF indexing), and **TimescaleDB**; validate each extension against measured workload and operating constraints.

Use **pgvector** as a candidate vector baseline only when PostgreSQL is already authoritative and expected scale, latency, filtering, and operations fit it. This can avoid synchronization with an external vector store.

### SQLite / Edge Persistence (validated May 2026)

Production-viable for distributed and edge workloads:
- **Litestream**: streams WAL to S3/GCS — free disaster recovery
- **Turso**: libSQL fork, edge-deployed, HTTP API, per-tenant DBs
- **rqlite**: clustered SQLite with Raft — replicated, lightweight
- **PowerSync**: bidirectional delta sync PostgreSQL ↔ SQLite

Use when: single-region, low-concurrency writes, cost-sensitive, per-tenant isolation, or local-first architectures.

### PGlite and Local-First

PGlite is an embedded WASM build of PostgreSQL for browser and JavaScript runtimes. Evaluate it for local-first data, offline-capable clients, development databases, and fast tests that need PostgreSQL syntax or selected extensions. Its `clone()` API can isolate test state, and `dumpDataDir()` can persist PGlite state, but data-directory dumps are intended for PGlite rather than arbitrary PostgreSQL versions.

PGlite does not categorically replace SQLite or server PostgreSQL:

- Keep SQLite when footprint, native platform integration, file format, mobile tooling, or SQLite-specific replication is the actual constraint.
- Use real PostgreSQL for tests involving network drivers, authentication, connection pools, replication, failover, server configuration, planner behavior, production extensions, or concurrency semantics not proven equivalent in PGlite.
- Treat ElectricSQL or another sync layer as a separate distributed-systems decision. Specify source of truth, write path, conflict policy, authorization, partial replication, deletion semantics, and recovery before adoption.

### ORM Choices

| Ecosystem | ORM | Notes |
|-----------|-----|-------|
| Python | **SQLAlchemy 2.0** | Mature, async, unit-of-work, Core expressions |
| Python (FastAPI) | **SQLModel** | SQLAlchemy + Pydantic, less boilerplate |
| Node.js (TypeScript) | **Drizzle** | Type-safe, SQL-like, migration lifecycle |
| Node.js (any) | **Prisma 7.7+** | Schema-first; use the stable release line and verify Prisma Next or adapter maturity before adopting non-GA features |

Do not choose between Drizzle and Prisma from benchmark claims alone. Compare query control, migration ownership, generated-client workflow, runtime targets, bundle constraints, observability, raw SQL escape hatches, and team capability. Prisma Next remains a separate maturity decision until the required database and feature set are generally available.

### Patterns
- **Repository Pattern**: abstracts data access; inject via DI for testability
- **Unit of Work**: wraps multiple repos in one transaction
- **CQRS Light**: separate read models (optimized queries) from write models (ORM entities)

---

## 3. API Design

### Protocol Decision Matrix

| Need | Candidate | Required Evidence |
|------|-----------|-------------------|
| Public or independently consumed contract | **REST + OpenAPI** | Resource semantics, compatibility/versioning, cache behavior, and client generation fit |
| Co-released TypeScript client/server boundary | **tRPC** | One owner controls compatible consumers and release coupling is acceptable |
| Consumer-shaped graph queries | **GraphQL** | Query governance, authorization, cost controls, schema evolution, and operations justify it |
| Typed internal RPC or streaming | **gRPC** | Supported clients, protobuf governance, load balancing, observability, and browser boundary fit |
| Server-to-client event stream | **SSE** | One-way ordered events and reconnect semantics fit |
| Bidirectional persistent session | **WebSocket** | Connection lifecycle, backpressure, fan-out, authorization, and infrastructure are designed |

### REST Best Practices

- **Versioning**: choose URI, media-type/header, or additive evolution from consumer compatibility, intermediaries, cache-key configuration, observability, and deprecation needs. Document `Vary` and CDN behavior when headers affect representation.
- **Pagination**: Offset for simple; **Cursor** for large datasets (consistent under mutations)
- **Rate Limiting**: select token bucket, sliding window, or another algorithm from burst and fairness requirements. If adopting the active IETF draft, negotiate support for `RateLimit` and `RateLimit-Policy`; otherwise document the provider-specific contract and do not present draft fields as finalized RFC requirements.
- **Webhooks**: include event ID for idempotency; HMAC-sign payload; exponential backoff retry

### Backend for Frontend (BFF)

Dedicated backend per client (iOS, Web, Android) to aggregate downstream services, translate protocols, and hide internal schemas.

**Anti-pattern**: BFF must remain spartan. Do NOT absorb domain validations or heavy transactional logic.

**Ownership gate**: align BFF ownership, repository placement, stack, deployment, and on-call responsibility with the client boundary and team capabilities. Co-location can reduce coordination but is not an invariant.

---

## 4. Auth & Authorization

### Token Format Patterns

```
Access token: short-lived according to threat model; opaque or structured according to issuer/resource-server contract
Refresh token: longer-lived credential handled only by the authorization server and client; public clients use rotation or sender constraint according to RFC 9700 and provider support
```

**Signing baseline**: prefer asymmetric algorithms supported by every issuer and verifier. Select EdDSA, ES256, or RS256 from interoperability, compliance, key-management, and library support constraints; reserve HS256 for explicitly trusted shared-key boundaries.

**Refresh-token replay defense**: for public clients, use sender-constrained refresh tokens or rotation. When rotating, invalidate the old token, track the token family, and detect reuse.

### Auth Protocols

Select only after the SoT defines client types, identity providers, revocation latency, threat model, compliance boundaries, and session topology.

| Scenario | Choice |
|----------|--------|
| First-party browser/native authentication | OIDC Authorization Code with PKCE when using an external identity provider, or a first-party session design with explicit threat model |
| First-party web session | Server-side session; add a shared store only when multi-instance topology requires it |
| Third-party delegated authorization | OAuth Authorization Code with PKCE; use OIDC when user authentication is required |
| Machine-to-machine / S2S | Workload identity, mutually authenticated credentials, scoped API keys, or `client_credentials` according to provider and threat model |
| Enterprise SSO | OIDC or SAML according to identity-provider and compatibility requirements |
| Passwordless authentication | **Passkeys** (WebAuthn) when account recovery and device portability are designed |

Authentication, delegated authorization, and token representation are separate decisions. OAuth grants authorization and is not a login protocol; OIDC adds authentication. JWT is one possible token format, not an alternative to OAuth or sessions.

### OAuth Security Baseline

OAuth 2.1 remains an active IETF Internet-Draft, so base production policy on stable RFCs and the OAuth 2.0 Security Best Current Practice while tracking the draft:

- Do not use the implicit grant or resource-owner password credentials grant.
- Use Authorization Code with PKCE for browser and native authorization-code clients; PKCE protects authorization-code exchange and is not a blanket requirement for `client_credentials`.
- Keep tokens out of query parameters and logs. Validate issuer, audience, signature, expiry, redirect URIs, and granted scope.
- Rotate or sender-constrain refresh tokens for public clients according to the threat model. Evaluate DPoP or mTLS for sender-constrained access tokens when theft risk justifies their interoperability and key-management cost.

### Sessions, Token Validation, and Representation

```
Server-side sessions:
  + Instant revocation, no token size limit
  - Requires a compatible shared store for multi-instance deployment

Locally validated structured tokens (for example JWT access tokens):
  + Resource servers can validate without per-request introspection
  - Revocation, key rotation, audience control, and stale claims require explicit design

Opaque tokens with introspection:
  + Central authorization state and revocation checks
  - Adds authorization-server availability and latency dependencies
```

Use sessions when immediate revocation and server-side control satisfy the SoT. Choose opaque versus structured access tokens from issuer/resource-server trust, revocation latency, availability, privacy, and interoperability requirements. Do not infer stateless system behavior from JWT encoding alone.

### Authorization

| Pattern | Use When |
|---------|----------|
| **RBAC** (Role-Based) | Candidate baseline when roles map cleanly to permissions and auditability matters. |
| **ABAC** (Attribute-Based) | policies evaluate user/resource/environment attributes. Complex multi-tenant / compliance. |

### Zero-Trust for Autonomous AI

- Sandboxed execution environments for agent code
- Dynamic credential delegation with least-privilege access
- Strictly scoped, short-lived credentials for AI-to-API interactions; choose opaque, JWT, mTLS-bound, or workload-identity representation from the established trust and revocation model
- Audit all agent actions via structured logging

---

## 5. Caching

### Conditional Cache Baseline

Do not add a cache by default. Use **Valkey**, **Redis**, or a compatible managed service as a candidate shared cache, session store, pub/sub, rate limiter, or job backend only when measured latency/throughput or multi-instance coordination requirements justify another operational dependency.

Valkey uses the BSD 3-Clause license. Redis 8 offers RSALv2, SSPLv1, or AGPLv3 licensing. This is a selection input, not proof that ordinary application use forces publication of proprietary application code. Record the exact artifact, version, deployment model, modifications, provider terms, required modules, support model, and organizational license policy; escalate unresolved obligations to qualified counsel. Verify command, persistence, module, cluster, failover, client, and operational compatibility before migration.

Use connection pooling for concurrent long-lived service workloads; size it from database limits, instance concurrency, and load evidence rather than a fixed connection count.

### Patterns

| Pattern | When |
|---------|------|
| **Cache-Aside** (Lazy) | Read-heavy, tolerate stale data |
| **Write-Through** | Consistent but write latency |
| **Write-Behind** | High write throughput, risk of loss |
| **Read-Through** | Library handles miss transparently |

### Invalidation

```
TTL-based:     simplest, stale within window — good for reference data
Event-driven:  publish invalidation event on write — consistent, complex
Tag-based:     tag keys by entity, flush by tag — good for related data
```

---

## 6. AI & Agentic Orchestration

### pgvector (PostgreSQL native)

Enable `CREATE EXTENSION vector;` only when semantic retrieval is required. Set dimensions and distance metric from the selected embedding model; evaluate HNSW/IVF and metadata filtering against recall, latency, write rate, and memory constraints.

Inventory deployed pgvector versions and update affected installations to 0.8.2 or a later fixed release. CVE-2026-3172 is triggered by parallel HNSW index builds and can expose data from other relations or crash PostgreSQL; do not rely on intended usage alone to defer remediation.

### Agent Orchestration Frameworks

| Framework | Paradigm | Best For |
|-----------|----------|----------|
| **LangGraph** | Stateful graph workflows | Auditable, predictable multi-step LLM pipelines |
| **CrewAI** | Role-driven agent teams | Rapid prototyping of hierarchical business workflows |
| **Microsoft Agent Framework** | Agents, harnesses, and graph workflows | Microsoft/Azure-aligned migration candidate; require GA/support verification for the exact language, package, provider, and capability because preview maturity differs |

Choose a framework from control-flow shape, persistence semantics, human approval, tool security, telemetry, provider portability, and team capability. Do not add multi-agent topology when a deterministic function, queue, or single agent is sufficient.

### Agent Interoperability Boundaries

- MCP standardizes host/client/server integration for resources, prompts, and tools. As local defensive policy, apply capability negotiation, least privilege, explicit consent, input/output validation, timeouts, cancellation, audit, and isolation because tool descriptions and remote content are untrusted; do not misstate every control as a protocol-level `MUST`.
- A2A standardizes communication between opaque, independently deployed agents. Use it for discovery, delegation, streaming, and asynchronous cross-agent work only when that remote boundary exists.
- MCP and A2A are complementary, not mandatory internal abstractions. Pin protocol versions and test authentication, authorization, tenant isolation, replay, cancellation, and failure semantics before interoperability claims.

### Volatile Agent Memory

- Conversation threading: low-latency context retrieval when measured
- State compaction: long-term/short-term memory hierarchy
- Vector search: define and measure latency percentiles, recall, corpus size, filters, hardware, and concurrency for the selected store
- Volatile state: real-time mutation across agent swarms

---

## 7. Architecture Patterns

### Monolith First

Begin with a cohesive monolith or modular monolith unless independent ownership, deployment cadence, scaling, isolation, or failure-containment requirements justify a service boundary. Team size and service count are observations, not thresholds.

### Modular Monolith

```
src/
├── users/          # bounded context
│   ├── domain/     # entities, value objects
│   ├── app/        # use cases
│   ├── infra/      # repo impl, external calls
│   └── api/        # routes, schemas
├── billing/
├── notifications/
└── shared/         # auth, db, config
```

Modules communicate via interfaces (not direct cross-imports). Enables future extraction to services.

### Clean / Hexagonal Architecture

```
Domain (entities) → no framework dependencies
Application (use cases) → depends on domain + ports (interfaces)
Infrastructure (adapters) → implements ports: DB, HTTP, queue
API (delivery) → routes call application use cases
```

### Event-Driven

| Tool | Use When |
|------|----------|
| **Valkey/Redis Streams** | Simple stream processing when the selected compatible store is already justified; validate delivery, persistence, and failover semantics |
| **NATS** | Lightweight, JetStream persistence, fast fan-out |
| **RabbitMQ** | Complex routing, existing AMQP ecosystem |
| **Kafka** | High throughput, event log, replay, analytics pipeline |

Candidate baseline: use Valkey or Redis Streams when that store is already justified and the SoT requires modest stream processing. Evaluate Kafka or another broker when replay, retention, partition scale, ecosystem, or measured throughput requires it.

### Background Jobs & Resilient Workflows

| Tool | Ecosystem | Use When |
|------|-----------|----------|
| **Dramatiq** | Python | Candidate when middleware-based workers and its delivery semantics meet the SoT. |
| **ARQ** | Python | Async-native, Redis-backed, lightweight |
| **BullMQ** | Node.js | Redis-backed, delayed jobs, rate limiting built-in |
| **Temporal** | Any | Long-running workflows, sagas, crash-proof execution |
| **Inngest** | Node.js | Serverless-friendly, event-driven functions |
| **Vercel Workflows** | JS/TS/Python | Managed durable execution when Vercel deployment, replay, sleep/hooks, and platform coupling fit the SoT |

**Temporal**: workflows resume via deterministic replay from event history (not native stack frames). Survives outages from seconds to months.

Durable execution does not replace ordinary queues or short background jobs. Adopt it when a process must survive crashes or deployments, pause without consuming compute, wait for external input, or expose replayable state. For every durable workflow:

- Separate deterministic orchestration from side-effecting steps.
- Make external effects idempotent and assign stable idempotency keys.
- Define retry classes, backoff, deadlines, cancellation, compensation, poison-message handling, and manual recovery.
- Version workflow code and prove how in-flight executions survive deployments and schema changes.
- Bound event-history and payload growth; define retention, encryption, residency, and deletion.

---

## 8. Testing

### Test Portfolio

- Unit tests protect deterministic domain policy and pure transformations.
- Integration tests exercise real production engines and protocols, usually through Testcontainers or managed test environments.
- Contract, E2E, load, and recovery tests cover observable boundaries according to risk.
- Select test distribution from failure cost and boundary risk; do not enforce fixed percentages.

**Rule**: mock external HTTP calls at owned boundaries. Use real production engines when planner, locking, protocol, extension, failover, or driver behavior is under test. PGlite can accelerate lower-risk tests but does not prove server PostgreSQL parity.

### Testing Tools

| Layer | Tool | Notes |
|-------|------|-------|
| Unit + Integration | **pytest** + **testcontainers** | Real PostgreSQL in Docker per test run |
| Load testing | **k6** | JS/TS scripted, CI-integrated, outputs to Prometheus/InfluxDB |
| Factory objects | **factory-boy** (Python) | Build test objects dynamically, not hardcoded fixtures |

**k6 disciplines**: smoke, stress (breakpoint), soak (memory leaks), spike, browser emulation (POM), Kubernetes chaos (xk6-disruptor).

---

## 9. Platform Engineering & Observability

### Infrastructure as Code

Select these platform components only when deployment topology, compliance, recovery, team operations, and observability requirements in the SoT justify their lifecycle cost.

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Provisioning** | **Terraform / OpenTofu** | Immutable cloud topology, GPU instance management |
| **GitOps / CD** | **Argo CD / GitLab CI** | Git as single source of truth; automatic drift reconciliation |
| **Secrets Governance** | **Infisical / ESO** | Dynamic injection, rotation, audit; zero `.env` files in runtime |
| **Observability** | **OpenTelemetry + LGTM** | Distributed tracing, metrics, logs, visualization |

When IaC is justified, keep its managed topology declarative, reviewed, tested at the appropriate level, and reconciled against drift. Do not add an IaC control plane where provider-native configuration or a smaller deployment model satisfies the SoT with lower lifecycle cost.

### Observability Stack

| Concern | Tool |
|---------|------|
| Tracing + metrics + logs | **OpenTelemetry** (OTEL SDK) |
| Structured logging Python | **structlog** |
| Structured logging Node.js | **pino** |
| Metrics scraping | **Prometheus** |
| Error tracking | **Sentry** |
| Visualization | **Grafana** |
| Log aggregation | **Loki** |
| Trace backend | **Tempo** |
| Metrics backend | **Mimir** |

### Health Check Endpoints

```
/health/live   → Kubernetes liveness probe (is process alive?)
/health/ready  → Kubernetes readiness probe (can serve traffic?)

Ready probe checks:
  - DB: SELECT 1
  - Shared in-memory store: protocol-appropriate ping
  - Soft dependencies (e.g., cache): degraded, not failing
```

---

## 10. Decision Framework

### Constraint-Matched Candidate Stack

Use this tree only to shortlist options after the source-discovery gate passes. Cite the matching SoT constraint for every branch; labels such as "baseline" never override contrary evidence.

```
1. LANGUAGE
   ├── Python team?        → FastAPI (baseline if general API constraints fit) / Litestar (measured perf) / Django (content)
   ├── JS/TS team?         → Fastify (Node ecosystem) / Hono (Web Standards portability) / Elysia (Bun)
   ├── Infra / binary?     → Go
   └── Max perf / cost?    → Rust (Axum)

2. TEAM SIZE
   ├── Cohesive ownership/deployment → Monolith or Modular Monolith
   └── Independent ownership, deployment, scaling, or isolation → Service boundary after evidence

3. API CONSUMERS
   ├── Public / independent consumers → Evaluate REST + OpenAPI
   ├── Co-released TS boundary → Evaluate tRPC
   ├── Consumer-shaped graph queries → Evaluate GraphQL
   └── Typed internal RPC/streaming → Evaluate gRPC

4. DATABASE
   ├── Relational integrity, compatible operations → PostgreSQL baseline
   ├── Edge / embedded     → SQLite ecosystem or PGlite when PostgreSQL semantics are required
   ├── Vector / AI search  → pgvector (existing PG) or Pinecone (new)
   ├── Local-first sync    → PowerSync or Turso
   ├── Variable schema     → MongoDB (justify)
   └── Time-series         → TimescaleDB

5. ORM
   ├── Python + FastAPI    → SQLModel (simple) / SQLAlchemy 2.0 (complex)
   ├── Node.js + TS        → Drizzle (SQL-like) / Prisma (schema-first)
   └── Complex queries     → Raw SQL for those queries

6. AUTH
   ├── User authentication via IdP → OIDC Authorization Code + PKCE
   ├── First-party web session → Server-side session; shared store only when topology requires it
   ├── Delegated authorization → OAuth grant selected by client and threat model
   ├── S2S / M2M           → Workload identity, scoped keys, mTLS, or client_credentials
   └── Enterprise SSO      → OIDC / SAML

7. BACKGROUND JOBS
   ├── Python              → Dramatiq (worker semantics fit) / ARQ (async)
   ├── Node.js             → BullMQ or another queue when job semantics fit
   └── Long/replayable workflows → Temporal, Inngest, or managed workflow platform by operational constraints

8. CACHING
   ├── Shared low-latency state justified → Valkey, Redis, or managed compatible service
   ├── Invalidation        → TTL (simple) → event-driven (consistent)
   └── Concurrent long-lived service → Pool sized from DB limits and measured concurrency

9. AI / AGENTS
   ├── Vector store (PG native) → pgvector
   ├── Vector store (managed)   → Pinecone
   ├── Agent workflows            → LangGraph
   ├── Microsoft enterprise path  → Microsoft Agent Framework only after exact package/language capability reaches required maturity
   ├── Agent-to-tool portability  → MCP after trust-boundary review
   ├── Remote agent interoperability → A2A after protocol-boundary review
   └── Agent memory hierarchy     → selected durable and volatile stores by retention semantics

10. PLATFORM / OBSERVABILITY
    ├── IaC justified       → Evaluate Terraform / OpenTofu or provider-native alternatives
    ├── GitOps justified    → Evaluate Argo CD or the existing deployment control plane
    ├── Secrets governance  → Select a managed or self-hosted system from rotation and audit needs
    └── Observability       → Define required signals and SLOs before selecting SDKs and backends
```

### Red Flags

- Raw SQL without parameterized statements → SQL injection
- Reusable bearer credentials or server secrets persisted in JavaScript-accessible storage without an explicit browser-app threat model and compensating controls
- Server data placed in process-global state without ownership, freshness, invalidation, or concurrency semantics
- Domain policy coupled to transport or infrastructure where that coupling prevents independent testing or change
- Persistence behavior claimed from mocks or substitutes when production planner, locking, protocol, extension, or failover semantics are the risk under test
- Monolith boundaries with uncontrolled cross-module imports, ownership ambiguity, or transaction leakage
- Public-client refresh tokens without sender constraint or rotation/reuse detection
- Deployments without platform-appropriate liveness, readiness, startup, or dependency-degradation signals when automated routing depends on them
- Logs, traces, or metrics that cannot identify and diagnose required production failure modes; select tooling from the runtime and platform
- Architectural decisions with no durable rationale or ownership record
- Treating an OAuth Internet-Draft as a finalized RFC or applying PKCE to unrelated grants
- Migrating Redis-compatible infrastructure without command, persistence, failover, module, license, and load validation
- Using PGlite as proof of production PostgreSQL network, concurrency, extension, or failover behavior
- Durable workflow side effects without idempotency, retry bounds, versioning, and replay tests
- MCP or A2A endpoints that trust remote descriptions, identities, payloads, or tool results by default

---

## Resources

- FastAPI docs: https://fastapi.tiangolo.com
- SQLAlchemy 2.0: https://docs.sqlalchemy.org/en/20/
- Drizzle ORM: https://orm.drizzle.team
- Prisma: https://www.prisma.io/
- PGlite: https://pglite.dev/
- Valkey: https://valkey.io/
- pgvector: https://github.com/pgvector/pgvector
- LangGraph: https://langchain-ai.github.io/langgraph/
- Microsoft Agent Framework: https://learn.microsoft.com/en-us/agent-framework/
- Model Context Protocol: https://modelcontextprotocol.io/specification/
- A2A Protocol: https://a2a-protocol.org/latest/
- Temporal: https://docs.temporal.io
- Vercel Workflows: https://vercel.com/docs/workflows
- OpenTelemetry: https://opentelemetry.io/
- k6 docs: https://grafana.com/docs/k6/
- Testcontainers: https://testcontainers.com/
- Infisical: https://infisical.com
- Argo CD: https://argo-cd.readthedocs.io
