---
name: backend-architect-lite
description: >
  Concise general-purpose backend architecture skill for stack definition at project start.
  Covers API design, database/ORM selection, auth patterns, caching, system design.
  Trigger: When starting a new backend project under time constraints and need to define the stack
  — choosing languages/frameworks, selecting databases, or making rapid architectural decisions.
license: Apache-2.0
metadata:
  author: kozz36
  version: "3.1.2"
---

## When to Use

- Starting a new backend project and need rapid framework/stack selection
- Evaluating databases, ORMs, or auth strategies for a team
- Designing API protocols (REST, GraphQL, gRPC, tRPC)
- Planning caching, background jobs, or event-driven patterns
- Setting up observability, health checks, or load testing
- Integrating AI/vector infrastructure or agent orchestration
- Planning local-first or edge-synchronized architectures

## Decision Inputs

Before selecting a stack, discover repository-native authoritative sources for product constraints, quality attributes, team capability, runtime, data ownership, security boundaries, and validation paths. `docs/product-charter.md` is one possible example, not a required path. If material inputs remain insufficient to discriminate between options, return the missing decisions as questions and stop.

---

## 1. Framework Selection

### Decision Matrix

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

---

## 2. Database Architecture

### Conditional Storage Baselines

| Need | Choice |
|------|--------|
| Primary relational store | **PostgreSQL** — JSONB, arrays, full-text search, extensions |
| Embedded / edge / serverless | **SQLite** — Litestream (replication), Turso (libSQL), rqlite (Raft) |
| Cache / queue / pub-sub | **Valkey**, **Redis**, or a compatible managed service after capability, license, and support review |
| Document store (justified) | **MongoDB** — only when schema genuinely variable |
| Time-series | **TimescaleDB** (PostgreSQL extension) or **InfluxDB** |
| Vector search / semantic retrieval | **pgvector** (PostgreSQL extension) or **Pinecone** / **Milvus** |
| Local-first sync engine | **PowerSync**, **Turso**, **ElectricSQL**, or **Replicache** |

### PostgreSQL as a Refutable Relational Baseline

When the repository-native sources require relational integrity and do not establish conflicting edge, write-concurrency, operational, or data-model constraints, PostgreSQL is a candidate baseline. It can also serve selected document, search, vector, or time-series workloads through **JSONB**, native full-text search, **pgvector**, and **TimescaleDB**; validate each extension against measured workload and operating constraints.

Use **pgvector** as a candidate vector baseline only when PostgreSQL is already authoritative and expected scale, latency, filtering, and operations fit it. This can avoid synchronization with an external vector store.

### SQLite / Edge Persistence

Production-viable for distributed and edge workloads:
- **Litestream**: streams WAL to S3/GCS — free disaster recovery
- **Turso**: libSQL fork, edge-deployed, HTTP API, per-tenant DBs
- **rqlite**: clustered SQLite with Raft — replicated, lightweight
- **PowerSync**: bidirectional delta sync PostgreSQL ↔ SQLite

Use when: single-region, low-concurrency writes, cost-sensitive, per-tenant isolation, or local-first architectures.

### ORM Choices

| Ecosystem | ORM | Notes |
|-----------|-----|-------|
| Python | **SQLAlchemy** | Mature, async, unit-of-work, Core expressions |
| Python (FastAPI) | **SQLModel** | SQLAlchemy + Pydantic, less boilerplate |
| Node.js (TypeScript) | **Drizzle** | Type-safe, SQL-like, migration lifecycle |
| Node.js (any) | **Prisma** | Schema-first; use the stable release line and verify non-GA feature maturity before adoption |

### Patterns
- **Repository Pattern**: abstracts data access; inject via DI for testability
- **Unit of Work**: wraps multiple repos in one transaction
- **CQRS Light**: separate read models (optimized queries) from write models (ORM entities)

---

## 3. API Design

### Protocol Decision Matrix

| Scenario | Protocol |
|----------|----------|
| Public API, third-party consumers | **REST + OpenAPI** |
| Frontend-only, TypeScript stack | **tRPC** (end-to-end types, no schema drift) |
| Flexible queries, multiple clients | **GraphQL** (Apollo / Strawberry) |
| Internal microservice communication | **gRPC** (protobuf, streaming, low latency) |
| Real-time / streaming | **WebSocket** or **SSE** |

### REST Best Practices

- **Versioning**: choose URI, media-type/header, or additive evolution from consumer compatibility, intermediaries, cache-key configuration, observability, and deprecation needs. Document `Vary` and CDN behavior when headers affect representation.
- **Pagination**: Offset for simple; **Cursor** for large datasets (consistent under mutations)
- **Rate Limiting**: select token bucket, sliding window, or another algorithm from burst and fairness requirements. If adopting the active IETF draft, negotiate support for `RateLimit` and `RateLimit-Policy`; otherwise document the provider-specific contract.
- **Webhooks**: include event ID for idempotency; HMAC-sign payload; exponential backoff retry

### Backend for Frontend (BFF)

Dedicated backend per client (iOS, Web, Android) to aggregate downstream services, translate protocols, and hide internal schemas.

**Anti-pattern**: BFF must remain spartan. Do NOT absorb domain validations or heavy transactional logic.

**Ownership gate**: align BFF ownership, repository placement, stack, deployment, and on-call responsibility with the client boundary and team capabilities. Co-location can reduce coordination but is not an invariant.

---

## 4. Auth & Authorization

### JWT Patterns

```
Access token: short-lived according to the threat model; opaque or structured according to the issuer/resource-server contract
Refresh token: longer-lived credential handled only by the authorization server and client; public clients use rotation or sender constraint according to RFC 9700 and provider support
```

**Signing baseline**: prefer asymmetric algorithms supported by every issuer and verifier. Select EdDSA, ES256, or RS256 from interoperability, compliance, key-management, and library support constraints; reserve HS256 for explicitly trusted shared-key boundaries.

**Refresh token rotation**: invalidate old on use, issue new pair. Track family for breach detection.

### Auth Protocols

| Scenario | Choice |
|----------|--------|
| First-party browser/native authentication | OIDC Authorization Code with PKCE when using an external identity provider, or a first-party session design with an explicit threat model |
| First-party web session | Server-side session; add a shared store only when multi-instance topology requires it |
| Third-party delegated authorization | OAuth Authorization Code with PKCE; use OIDC when user authentication is required |
| Machine-to-machine / S2S | Workload identity, mutually authenticated credentials, scoped API keys, or `client_credentials` according to provider and threat model |
| Enterprise SSO | OIDC or SAML according to identity-provider and compatibility requirements |
| Passwordless authentication | **Passkeys** (WebAuthn) when account recovery and device portability are designed |

### Sessions vs Tokens

```
Server-side sessions:
  + Instant revocation, no token size limit
  - Requires a compatible shared store for multi-instance deployment

Locally validated structured tokens (for example JWT access tokens):
  + Resource servers can validate without per-request introspection
  - Revocation, key rotation, audience control, and stale claims require explicit design
```

Use sessions when immediate revocation and server-side control satisfy the repository-native sources. Choose opaque versus structured access tokens from issuer/resource-server trust, revocation latency, availability, privacy, and interoperability requirements; do not infer stateless system behavior from JWT encoding alone.

### Authorization

| Pattern | Use When |
|---------|----------|
| **RBAC** (Role-Based) | Candidate baseline when roles map cleanly to permissions and auditability matters. |
| **ABAC** (Attribute-Based) | policies evaluate user/resource/environment attributes. Complex multi-tenant / compliance. |

### Zero-Trust for Autonomous AI

- Sandboxed execution environments for agent code
- Dynamic credential delegation with least-privilege access
- Strictly scoped, short-lived credentials for AI-to-API interactions; choose opaque, JWT, mTLS-bound, or workload-identity representation from established trust and revocation requirements
- Audit all agent actions via structured logging

---

## 5. Caching

### Conditional Cache Baseline

Do not add a cache by default. Use **Valkey**, **Redis**, or a compatible managed service as a candidate shared cache, session store, pub/sub, rate limiter, or job backend only when measured latency/throughput or multi-instance coordination requirements justify another operational dependency.

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

### Agent Orchestration Frameworks

| Framework | Paradigm | Best For |
|-----------|----------|----------|
| **LangGraph** | Stateful graph workflows | Auditable, predictable multi-step LLM pipelines |
| **CrewAI** | Role-driven agent teams | Rapid prototyping of hierarchical business workflows |
| **Microsoft Agent Framework** | Agents, harnesses, and graph workflows | Microsoft/Azure-aligned migration candidate; require exact package, provider, and capability maturity verification |

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

Example layout; adapt paths and module boundaries to repository conventions:

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

Candidate baseline: use Valkey or Redis Streams when that store is already justified and the repository-native sources require modest stream processing. Evaluate Kafka or another broker when replay, retention, partition scale, ecosystem, or measured throughput requires it.

### Background Jobs & Resilient Workflows

| Tool | Ecosystem | Use When |
|------|-----------|----------|
| **Dramatiq** | Python | Candidate when middleware-based workers and delivery semantics meet the repository-native sources |
| **ARQ** | Python | Async-native, Redis-backed, lightweight |
| **BullMQ** | Node.js | Redis-backed, delayed jobs, rate limiting built-in |
| **Temporal** | Any | Long-running workflows, sagas, crash-proof execution |
| **Inngest** | Node.js | Serverless-friendly, event-driven functions |

**Temporal**: workflows resume via deterministic replay from event history (not native stack frames). Survives outages from seconds to months.

---

## 8. Testing

### Test Portfolio

- Unit tests protect deterministic domain policy and pure transformations.
- Integration tests exercise real production engines and protocols, usually through Testcontainers or managed test environments.
- Contract, E2E, load, and recovery tests cover observable boundaries according to risk.
- Select test distribution from failure cost and boundary risk; do not enforce fixed percentages.

**Rule**: mock external HTTP calls at owned boundaries. Use real production engines when planner, locking, protocol, extension, failover, or driver behavior is under test.

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

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Provisioning** | **Terraform / OpenTofu** | Immutable cloud topology, GPU instance management |
| **GitOps / CD** | **Argo CD / GitLab CI** | Git as single source of truth; automatic drift reconciliation |
| **Secrets Governance** | **Infisical / ESO** | Dynamic injection, rotation, audit; zero `.env` files in runtime |
| **Observability** | **OpenTelemetry + LGTM** | Distributed tracing, metrics, logs, visualization |

When infrastructure as code is justified, keep its managed topology declarative, reviewed, tested at the appropriate level, and reconciled against drift. Do not add an infrastructure control plane where provider-native configuration or a smaller deployment model satisfies the repository-native sources with lower lifecycle cost.

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
  - Soft dependencies (for example, cache): degraded, not failing
```

---

## 10. Decision Framework

### Quick Stack Selector

```
1. LANGUAGE
   ├── Python team?        → FastAPI (baseline if general API constraints fit) / Litestar (measured performance) / Django (content)
   ├── JS/TS team?         → Fastify (Node ecosystem) / Hono (Web Standards portability) / Elysia (Bun)
   ├── Infra / binary?     → Go
   └── Max perf / cost?    → Rust (Axum)

2. TEAM AND BOUNDARIES
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
   ├── Vector / AI search  → pgvector (existing PG) or a managed vector store when justified
   ├── Local-first sync    → Evaluate a sync engine from conflict and topology requirements
   ├── Variable schema     → MongoDB (justify)
   └── Time-series         → TimescaleDB

5. ORM
   ├── Python + FastAPI    → SQLModel (simple) / SQLAlchemy (complex)
   ├── Node.js + TS        → Drizzle (SQL-like) / Prisma (schema-first)
   └── Complex queries     → Raw SQL for those queries

6. AUTH
   ├── User authentication via IdP → OIDC Authorization Code + PKCE
   ├── First-party web session → Server-side session; shared store only when topology requires it
   ├── Delegated authorization → OAuth grant selected by client and threat model
   ├── S2S / M2M           → Workload identity, scoped keys, mTLS, or client_credentials
   └── Enterprise SSO      → OIDC / SAML

7. BACKGROUND JOBS
   ├── Python              → Dramatiq or ARQ when delivery semantics fit
   ├── Node.js             → BullMQ or another queue when job semantics fit
   └── Long/replayable workflows → Temporal, Inngest, or managed workflow platform by operational constraints

8. CACHING
   ├── Shared low-latency state justified → Valkey, Redis, or managed compatible service
   ├── Invalidation        → TTL (simple) → event-driven (consistent)
   └── Concurrent long-lived service → Pool sized from DB limits and measured concurrency

9. AI / AGENTS
   ├── Vector store (PG native) → pgvector
   ├── Vector store (managed)   → Select when scale or operations justify it
   ├── Agent workflows            → LangGraph when workflow semantics fit
   ├── Microsoft enterprise path  → Microsoft Agent Framework only after exact maturity verification
   └── Agent memory hierarchy     → Select durable and volatile stores by retention semantics

10. PLATFORM / OBSERVABILITY
    ├── IaC justified       → Evaluate Terraform / OpenTofu or provider-native alternatives
    ├── GitOps justified    → Evaluate Argo CD or the existing deployment control plane
    ├── Secrets governance  → Select a managed or self-hosted system from rotation and audit needs
    └── Observability       → Define required signals and SLOs before selecting SDKs and backends
```

### Red Flags

- Raw SQL without parameterized statements → SQL injection
- JWT/API keys in localStorage → security breach
- Server data placed in process-global state without ownership, freshness, invalidation, or concurrency semantics
- No separation between domain and infra → Clean Architecture instead
- Skipping integration tests with real DB → Testcontainers
- Monolith without modules → Modular Monolith first
- Custom auth without refresh rotation → implement rotation + family tracking
- No health checks in production → /live + /ready probes required
- No structured logging → adopt structlog/pino + OTel
- Architectural decisions with no durable rationale or ownership record

---

## Resources

- FastAPI docs: https://fastapi.tiangolo.com
- SQLAlchemy: https://docs.sqlalchemy.org/en/20/
- Drizzle ORM: https://orm.drizzle.team
- Prisma: https://www.prisma.io/
- pgvector: https://github.com/pgvector/pgvector
- LangGraph: https://langchain-ai.github.io/langgraph/
- Microsoft Agent Framework: https://learn.microsoft.com/en-us/agent-framework/
- Temporal: https://docs.temporal.io
- OpenTelemetry: https://opentelemetry.io/
- k6 docs: https://grafana.com/docs/k6/
- Testcontainers: https://testcontainers.com/
- Infisical: https://infisical.com
- Argo CD: https://argo-cd.readthedocs.io
