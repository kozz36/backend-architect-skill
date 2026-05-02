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
  version: "2.0-lite"
---

## When to Use

- Starting a new backend project and need rapid framework/stack selection
- Evaluating databases, ORMs, or auth strategies for a team
- Designing API protocols (REST, GraphQL, gRPC, tRPC)
- Planning caching, background jobs, or event-driven patterns
- Setting up observability, health checks, or load testing
- Integrating AI/vector infrastructure or agent orchestration
- Planning local-first or edge-synchronized architectures

---

## 1. Framework Selection

### Decision Matrix

| Scenario | Framework | Reason |
|----------|-----------|--------|
| Python — general API | **FastAPI** | Async, OpenAPI auto-gen, Pydantic validation |
| Python — high performance | **Litestar** | Faster than FastAPI, stricter typing |
| Python — content/admin heavy | **Django + DRF** | ORM, admin, batteries included |
| Node.js — general API | **Fastify** | Fast, schema-based, great plugin ecosystem |
| Node.js — edge / serverless | **Hono** | Ultra-lightweight, multi-runtime |
| Node.js — Bun runtime | **Elysia** | Native Bun, end-to-end types |
| Infrastructure / CLI / binary | **Go (Echo/Chi)** | Single binary, low memory, extreme concurrency |
| Cost-critical at massive scale | **Rust (Axum)** | Max performance, zero GC pauses, deterministic memory safety |

### Team-size rule
- Solo / startup → FastAPI or Fastify (fast iteration)
- Team with TypeScript frontend → Fastify + tRPC (shared types)
- Team preferring Go → Echo or Chi for REST, gRPC for internal services
- Mixed team → FastAPI (Python ubiquity) or Fastify (JS familiarity)

---

## 2. Database Architecture

### Default Choices

| Need | Choice |
|------|--------|
| Primary relational store | **PostgreSQL** — JSONB, arrays, full-text search, extensions |
| Embedded / edge / serverless | **SQLite** — Litestream (replication), Turso (libSQL), rqlite (Raft) |
| Cache / queue / pub-sub | **Redis** |
| Document store (justified) | **MongoDB** — only when schema genuinely variable |
| Time-series | **TimescaleDB** (PostgreSQL extension) or **InfluxDB** |
| Vector search / semantic retrieval | **pgvector** (PostgreSQL extension) or **Pinecone** / **Milvus** |
| Local-first sync engine | **PowerSync**, **Turso**, **ElectricSQL**, or **Replicache** |

### PostgreSQL as Universal Store

PostgreSQL now serves transactional, relational, analytical, AND semantic workloads via **JSONB**, native full-text search, **pgvector** (HNSW/IVF indexing), and **TimescaleDB**.

Use **pgvector** as the default vector strategy for teams already on PostgreSQL. Eliminates data sync overhead with external vector stores.

### SQLite Renaissance (2024–2026)

Production-viable for distributed and edge workloads:
- **Litestream**: streams WAL to S3/GCS — free disaster recovery
- **Turso**: libSQL fork, edge-deployed, HTTP API, per-tenant DBs
- **rqlite**: clustered SQLite with Raft — replicated, lightweight
- **PowerSync**: bidirectional delta sync PostgreSQL ↔ SQLite

Use when: single-region, low-concurrency writes, cost-sensitive, per-tenant isolation, or local-first architectures.

### ORM Choices

| Ecosystem | ORM | Notes |
|-----------|-----|-------|
| Python | **SQLAlchemy 2.0** | Mature, async, unit-of-work, Core expressions |
| Python (FastAPI) | **SQLModel** | SQLAlchemy + Pydantic, less boilerplate |
| Node.js (TypeScript) | **Drizzle** | Type-safe, SQL-like, migration lifecycle |
| Node.js (any) | **Prisma 7** | Schema-first, great DX |

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

- **Versioning**: URL-based wins (`/api/v1/users`) — header versioning hurts caching
- **Pagination**: Offset for simple; **Cursor** for large datasets (consistent under mutations)
- **Rate Limiting**: token bucket or sliding window. Headers: `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`
- **Webhooks**: include event ID for idempotency; HMAC-sign payload; exponential backoff retry

### Backend for Frontend (BFF)

Dedicated backend per client (iOS, Web, Android) to aggregate downstream services, translate protocols, and hide internal schemas.

**Anti-pattern**: BFF must remain spartan. Do NOT absorb domain validations or heavy transactional logic.

**Best practice**: Same stack as frontend team. Host in same monorepo. Assign ownership to frontend team.

---

## 4. Auth & Authorization

### JWT Patterns

```
Access token:  short-lived (15 min), stateless, signed
Refresh token: long-lived (7–30 days), stored in DB, rotated on use
```

**Signing priority**: EdDSA (Ed25519) > ES256 > RS256 > HS256

**Refresh token rotation**: invalidate old on use, issue new pair. Track family for breach detection.

### Auth Protocols

| Scenario | Choice |
|----------|--------|
| First-party app (SPA/mobile) | OAuth2 + PKCE or JWT (access + refresh) |
| First-party app (web app) | Sessions (Redis store) or JWT |
| Third-party OAuth | OAuth2 + PKCE (Authorization Code flow) |
| Machine-to-machine / S2S | API keys (hashed in DB) or client_credentials OAuth2 |
| Enterprise SSO | SAML or OIDC |
| Passwordless 2025 | **Passkeys** (WebAuthn) — phishing-resistant, UX win |

### Sessions vs Tokens

```
Sessions (server-side):
  + Instant revocation, no token size limit
  - Requires shared store (Redis) for multi-instance

JWTs (stateless):
  + No shared store needed, works across services
  - Revocation requires denylist (Redis) or short TTL
```

Use sessions for: monolith, traditional web apps, admin panels.
Use JWTs for: microservices, mobile apps, SPAs, multi-tenant APIs.

### Authorization

| Pattern | Use When |
|---------|----------|
| **RBAC** (Role-Based) | roles → permissions. Simple, audit-friendly. Default for most apps. |
| **ABAC** (Attribute-Based) | policies evaluate user/resource/environment attributes. Complex multi-tenant / compliance. |

### Zero-Trust for Autonomous AI

- Sandboxed execution environments for agent code
- Dynamic credential delegation with least-privilege access
- Strictly scoped JWTs for AI-to-API interactions
- Audit all agent actions via structured logging

---

## 5. Caching

### Default Stack

**Redis** — primary cache, session store, pub/sub, rate limiter, job queue, multi-tier agent memory.

Connection pooling: always use a pool. `max_connections=20` tuned to DB pool size.

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

Enable `CREATE EXTENSION vector;` — 1536-dim default. HNSW index for ANN search. Cosine distance `<=>` for semantic retrieval. Combine with `metadata @> ...` JSONB filters.

### Agent Orchestration Frameworks

| Framework | Paradigm | Best For |
|-----------|----------|----------|
| **LangGraph** | Stateful graph workflows | Auditable, predictable multi-step LLM pipelines |
| **AutoGen** | Multi-agent collaborative dialogue | Enterprise: error handling, distributed gRPC, OTel |
| **CrewAI** | Role-driven agent teams | Rapid prototyping of hierarchical business workflows |
| **Semantic Kernel** | Dynamic function binding | Azure-native apps with semantic memory |

### Redis as Multi-Tier Agent Memory

- Conversation threading: sub-millisecond context retrieval
- State compaction: long-term/short-term memory hierarchy
- Vector search: sub-millisecond knowledge base retrieval
- Volatile state: real-time mutation across agent swarms

---

## 7. Architecture Patterns

### Monolith First (consensus 2024–2026)

```
< 20 engineers    → Monolith (deploy as one unit)
< 5 services      → Modular monolith (internal modules, shared DB)
> 5 services, clear bounded contexts → Microservices (justify each split)
> 50 engineers, org boundaries → Microservices (Conway's Law)
```

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
| **Redis Streams** | Simple pub/sub, same infra as cache, at-least-once via XACK |
| **NATS** | Lightweight, JetStream persistence, fast fan-out |
| **RabbitMQ** | Complex routing, existing AMQP ecosystem |
| **Kafka** | High throughput, event log, replay, analytics pipeline |

Rule: start with Redis Streams. Migrate to Kafka when you need replay or > 100k msg/s.

### Background Jobs & Resilient Workflows

| Tool | Ecosystem | Use When |
|------|-----------|----------|
| **Dramatiq** | Python | Preferred: simpler, reliable, middleware-based |
| **ARQ** | Python | Async-native, Redis-backed, lightweight |
| **BullMQ** | Node.js | Redis-backed, delayed jobs, rate limiting built-in |
| **Temporal** | Any | Long-running workflows, sagas, crash-proof execution |
| **Inngest** | Node.js | Serverless-friendly, event-driven functions |

**Temporal**: workflows resume via deterministic replay from event history (not native stack frames). Survives outages from seconds to months.

---

## 8. Testing

### Test Pyramid

```
Unit tests (70%)       — domain logic, pure functions, no I/O
Integration tests (20%) — real DB, real Redis, Testcontainers
E2E / load tests (10%) — full stack, production-like
```

**Rule**: mock external HTTP calls. Use REAL databases in integration tests. Mocking Postgres is lying to yourself.

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

**Golden rule**: ALL topology is defined, reviewed, regression-tested, and deployed as declarative code.

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
  - Redis: PING
  - Soft dependencies (e.g., Redis as cache): degraded, not failing
```

---

## 10. Decision Framework

### Quick Stack Selector

```
1. LANGUAGE
   ├── Python team?        → FastAPI (default) / Litestar (perf) / Django (content)
   ├── JS/TS team?         → Fastify (default) / Hono (edge) / Elysia (Bun)
   ├── Infra / binary?     → Go
   └── Max perf / cost?    → Rust (Axum)

2. TEAM SIZE
   ├── < 20 engineers      → Monolith or Modular Monolith
   └── > 20, org boundaries → Microservices (justify each split)

3. API CONSUMERS
   ├── Public / third-party → REST + OpenAPI
   ├── Own TS frontend only → tRPC
   ├── Multiple varied clients → GraphQL
   └── Internal services → gRPC

4. DATABASE
   ├── Default             → PostgreSQL
   ├── Edge / embedded     → SQLite + Litestream or Turso
   ├── Vector / AI search  → pgvector (existing PG) or Pinecone (new)
   ├── Local-first sync    → PowerSync or Turso
   ├── Variable schema     → MongoDB (justify)
   └── Time-series         → TimescaleDB

5. ORM
   ├── Python + FastAPI    → SQLModel (simple) / SQLAlchemy 2.0 (complex)
   ├── Node.js + TS        → Drizzle (SQL-like) / Prisma (schema-first)
   └── Complex queries     → Raw SQL for those queries

6. AUTH
   ├── Own users, SPA/mobile → JWT (access + refresh, EdDSA)
   ├── Own users, web app  → Sessions (Redis store)
   ├── Third-party login   → OAuth2 + PKCE
   ├── S2S / M2M           → API keys (hashed) or client_credentials
   └── Enterprise          → OIDC / SAML

7. BACKGROUND JOBS
   ├── Python              → Dramatiq (default) / ARQ (async)
   ├── Node.js             → BullMQ
   └── Long workflows / sagas → Temporal

8. CACHING
   ├── Default             → Redis (Cache-Aside pattern)
   ├── Invalidation        → TTL (simple) → event-driven (consistent)
   └── Connection pool     → Always; max_connections tuned to DB pool size

9. AI / AGENTS
   ├── Vector store (PG native) → pgvector
   ├── Vector store (managed)   → Pinecone
   ├── Agent workflows            → LangGraph
   ├── Multi-agent collaboration  → AutoGen
   └── Agent memory hierarchy     → Redis multi-tier

10. PLATFORM / OBSERVABILITY
    ├── IaC                 → Terraform / OpenTofu
    ├── GitOps              → Argo CD
    ├── Secrets             → Infisical / ESO
    └── Observability       → OpenTelemetry + structlog/pino + Sentry + /health/*
```

### Red Flags

- Raw SQL without parameterized statements → SQL injection
- JWT/API keys in localStorage → security breach
- Global state for server data → use server-state library (TanStack Query / SWR)
- No separation between domain and infra → Clean Architecture instead
- Skipping integration tests with real DB → Testcontainers
- Monolith without modules → Modular Monolith first
- Custom auth without refresh rotation → implement rotation + family tracking
- No health checks in production → /live + /ready probes required
- No structured logging → adopt structlog/pino + OTel
- No ADRs on >2 dev projects → knowledge loss

---

## Resources

- FastAPI docs: https://fastapi.tiangolo.com
- SQLAlchemy 2.0: https://docs.sqlalchemy.org/en/20/
- Drizzle ORM: https://orm.drizzle.team
- Prisma: https://www.prisma.io/
- pgvector: https://github.com/pgvector/pgvector
- LangGraph: https://langchain-ai.github.io/langgraph/
- AutoGen: https://microsoft.github.io/autogen/
- Temporal: https://docs.temporal.io
- OpenTelemetry: https://opentelemetry.io/
- k6 docs: https://grafana.com/docs/k6/
- Testcontainers: https://testcontainers.com/
- Infisical: https://infisical.com
- Argo CD: https://argo-cd.readthedocs.io
