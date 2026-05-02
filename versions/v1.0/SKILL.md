---
name: backend-architect
description: >
  General-purpose backend architecture skill for stack definition at project start.
  Guides API design, database/ORM selection, auth patterns, caching, and system design.
  Trigger: When starting a new backend project and need to define the stack,
  choosing between languages/frameworks (Node/Django/Go/Rust/etc.), selecting databases,
  or making cross-platform architectural decisions.
license: Apache-2.0
metadata:
  author: kozz36
  version: "1.0"
---

## When to Use

- Designing a new API (REST, GraphQL, gRPC, tRPC)
- Choosing a database or ORM for a project
- Planning authentication and authorization systems
- Scaling a backend or deciding between monolith and microservices
- Implementing caching, background jobs, or event-driven patterns
- Setting up observability, health checks, or load testing
- Any architectural decision with long-term tradeoffs

---

## 1. Framework Selection

### Decision Matrix

| Scenario | Framework | Reason |
|----------|-----------|--------|
| Python — general API | **FastAPI** | Async, OpenAPI auto-gen, ecosystem |
| Python — high performance | **Litestar** | Faster than FastAPI, stricter typing |
| Python — content/admin heavy | **Django + DRF** | ORM, admin, batteries included |
| Node.js — general API | **Fastify** | Fast, schema-based, great plugin ecosystem |
| Node.js — edge / serverless | **Hono** | Ultra-lightweight, multi-runtime |
| Node.js — Bun runtime | **Elysia** | Native Bun, end-to-end types |
| Infrastructure / CLI / binary | **Go** | Single binary, low memory, concurrency |
| Cost-critical at massive scale | **Rust (Axum)** | Max performance, zero GC pauses |

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
| Embedded / edge / serverless | **SQLite** — with Litestream (replication) or Turso (distributed) |
| Distributed SQLite | **rqlite** (Raft consensus), **Turso** (libSQL) |
| Cache / queue / pub-sub | **Redis** (see Caching section) |
| Document store (justified) | **MongoDB** — only when schema is genuinely variable |
| Time-series | **TimescaleDB** (PostgreSQL extension) or **InfluxDB** |

### SQLite Renaissance (2024–2025)

SQLite is now production-viable for many workloads:
- **Litestream**: streams WAL to S3/GCS — free disaster recovery
- **Turso**: libSQL fork, edge-deployed, HTTP API, per-tenant DBs
- **rqlite**: clustered SQLite with Raft — replicated, lightweight

Use when: single-region, low-concurrency writes, cost-sensitive, or per-tenant isolation.

### ORM vs Raw SQL

```
Schema-first, complex queries → Raw SQL (psycopg3, asyncpg)
Rapid prototyping, teams      → ORM
Mixed (recommended)           → ORM for CRUD, raw SQL for reports/analytics
```

### ORM Choices

| Ecosystem | ORM | Notes |
|-----------|-----|-------|
| Python | **SQLAlchemy 2.0** | Mature, async support, unit-of-work |
| Python (FastAPI) | **SQLModel** | SQLAlchemy + Pydantic, less boilerplate |
| Node.js (TypeScript) | **Drizzle** | Type-safe, SQL-like syntax, no magic |
| Node.js (any) | **Prisma 7** | Schema-first, migrations, great DX |

### Patterns

- **Repository Pattern**: abstracts data access; inject via DI for testability
- **Unit of Work**: wraps multiple repos in one transaction (SQLAlchemy Session is UoW)
- **CQRS Light**: separate read models (optimized queries) from write models (ORM entities); no full event sourcing needed for most apps

```python
# Repository pattern with SQLAlchemy 2.0
class UserRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, user_id: UUID) -> User | None:
        result = await self.session.get(User, user_id)
        return result

    async def get_by_email(self, email: str) -> User | None:
        stmt = select(User).where(User.email == email)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()
```

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

**Versioning**: URL-based wins in practice (`/api/v1/users`) — header versioning hurts caching and tooling.

**Pagination**:
- Offset (`?page=2&limit=20`): simple, but expensive on large datasets (OFFSET scans)
- Cursor (`?after=eyJpZCI6MTAwfQ`): scalable, consistent under mutations — prefer for feeds and large tables

**Rate Limiting**: token bucket or sliding window. Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.

**Webhook Design**:
```python
# Idempotency: include event ID, receiver deduplicates
# HMAC signing: sign payload with shared secret
import hmac, hashlib

def verify_webhook(payload: bytes, signature: str, secret: str) -> bool:
    expected = hmac.new(
        secret.encode(), payload, hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected}", signature)

# Retry: exponential backoff (1s, 5s, 30s, 5m, 30m)
# Delivery guarantee: at-least-once — always include event_id for dedup
```

### OpenAPI

FastAPI generates OpenAPI automatically. For other frameworks:
- **Litestar**: built-in OpenAPI
- **Fastify**: `@fastify/swagger` + `@fastify/swagger-ui`
- **Go**: `swaggo/swag` or `oapi-codegen`

Always include: request/response schemas, error responses (400, 401, 403, 404, 422, 500), auth scheme.

---

## 4. Auth & Authorization

### JWT Patterns

```
Access token:  short-lived (15 min), stateless, signed
Refresh token: long-lived (7–30 days), stored in DB, rotated on use
```

**Signing algorithm priority**: EdDSA (Ed25519) > ES256 (ECDSA P-256) > RS256 (RSA 2048) > HS256 (shared secret — avoid for multi-service)

```python
# FastAPI JWT pattern
from datetime import datetime, timedelta, UTC
import jwt  # PyJWT

SECRET_KEY = "..."  # from env
ALGORITHM = "EdDSA"

def create_access_token(subject: str) -> str:
    expire = datetime.now(UTC) + timedelta(minutes=15)
    return jwt.encode({"sub": subject, "exp": expire}, SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token(subject: str) -> str:
    expire = datetime.now(UTC) + timedelta(days=30)
    token = secrets.token_urlsafe(32)
    # Store hash(token) in DB with user_id + expiry
    return token
```

**Refresh token rotation**: invalidate old token on use, issue new pair. Track family for breach detection (if rotated token is reused → family was stolen → revoke all).

### Auth Protocols

| Scenario | Choice |
|----------|--------|
| First-party app (your own users) | JWT (access + refresh) or sessions |
| Third-party OAuth (Google, GitHub) | OAuth2 + PKCE (Authorization Code flow) |
| Machine-to-machine / S2S | API keys (hashed in DB) or client_credentials OAuth2 |
| Enterprise SSO | SAML or OIDC |
| Passwordless 2025 | **Passkeys** (WebAuthn) — phishing-resistant, UX win |

### Sessions vs Tokens

```
Sessions (server-side):
  + Instant revocation
  + No token size limit
  - Requires shared session store (Redis) for multi-instance
  - Stateful

JWTs (stateless):
  + No shared store needed
  + Works across services
  - Revocation requires denylist (Redis) or short TTL
  - Token size grows with claims
```

Use sessions for: monolith, traditional web apps, admin panels.
Use JWTs for: microservices, mobile apps, SPAs, multi-tenant APIs.

### Authorization

**RBAC** (Role-Based): roles → permissions. Simple, audit-friendly. Use for most apps.

**ABAC** (Attribute-Based): policies evaluate attributes (user, resource, environment). Use for complex multi-tenant or compliance-heavy systems.

```python
# FastAPI RBAC dependency
from fastapi import Depends, HTTPException, status

def require_role(*roles: str):
    def dependency(current_user: User = Depends(get_current_user)):
        if current_user.role not in roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)
        return current_user
    return dependency

# Usage
@router.delete("/users/{id}", dependencies=[Depends(require_role("admin", "superuser"))])
async def delete_user(id: UUID): ...
```

---

## 5. Caching

### Default Stack

**Redis** — primary cache, session store, pub/sub, rate limiter, job queue.

Connection pooling: always use a pool. FastAPI + Redis: `redis.asyncio.ConnectionPool` with `max_connections=20`.

### Patterns

| Pattern | When |
|---------|------|
| **Cache-Aside** (Lazy) | Read-heavy, tolerate stale data. Check cache → miss → read DB → populate cache |
| **Write-Through** | Write to cache and DB together. Consistent but write latency |
| **Write-Behind** | Write to cache, async flush to DB. High write throughput, risk of loss |
| **Read-Through** | Cache fetches from DB on miss transparently (library handles it) |

### Invalidation Strategies

```
TTL-based:        simplest, stale within window — good for reference data
Event-driven:     publish cache-invalidation event on write — consistent, complex
Tag-based:        tag cache keys by entity, flush by tag — good for related data
```

```python
# Cache-Aside pattern with FastAPI + Redis
async def get_user(user_id: UUID, redis: Redis, db: AsyncSession) -> User:
    cache_key = f"user:{user_id}"
    cached = await redis.get(cache_key)
    if cached:
        return User.model_validate_json(cached)

    user = await UserRepository(db).get_by_id(user_id)
    if user:
        await redis.setex(cache_key, 300, user.model_dump_json())  # TTL: 5 min
    return user
```

---

## 6. Architecture Patterns

### Monolith First (consensus 2024)

Teams under 20 engineers: start with a monolith. Microservices add operational complexity that kills small teams.

```
< 20 engineers    → Monolith (deploy as one unit)
< 5 services      → Modular monolith (internal modules, shared DB)
> 5 services, clear bounded contexts → Microservices (justify each split)
> 50 engineers, org boundaries → Microservices (Conway's Law)
```

### Modular Monolith Structure

```
src/
├── users/          # bounded context
│   ├── domain/     # entities, value objects
│   ├── app/        # use cases, services
│   ├── infra/      # repository impl, external calls
│   └── api/        # routes, schemas
├── billing/
├── notifications/
└── shared/         # cross-cutting (auth, db, config)
```

Modules communicate via **interfaces** (not direct imports across layers). This allows future extraction to services.

### Clean / Hexagonal Architecture

```
Domain (entities, value objects) — no framework dependencies
Application (use cases) — depends on domain + ports (interfaces)
Infrastructure (adapters) — implements ports: DB, HTTP, queue
API (delivery) — FastAPI routes call application use cases
```

```python
# Port (interface) in application layer
from abc import ABC, abstractmethod

class UserRepository(ABC):
    @abstractmethod
    async def get_by_id(self, user_id: UUID) -> User | None: ...
    @abstractmethod
    async def save(self, user: User) -> None: ...

# Adapter (implementation) in infrastructure layer
class PostgresUserRepository(UserRepository):
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, user_id: UUID) -> User | None:
        return await self.session.get(UserModel, user_id)
```

### Event-Driven

| Tool | Use When |
|------|----------|
| **Redis Streams** | Simple pub/sub, same infra as cache, at-most-once ok |
| **NATS** | Lightweight, JetStream for persistence, fast fan-out |
| **RabbitMQ** | Complex routing, existing AMQP ecosystem |
| **Kafka** | High throughput, event log, replay, analytics pipeline |

Rule: start with Redis Streams. Migrate to Kafka when you need replay, audit log, or > 100k msg/s.

### Background Jobs

| Tool | Ecosystem | Use When |
|------|-----------|----------|
| **Dramatiq** | Python | Preferred over Celery: simpler, reliable, middleware-based |
| **ARQ** | Python | Async-native, Redis-backed, lightweight |
| **BullMQ** | Node.js | Redis-backed, delayed jobs, rate limiting built-in |
| **Temporal** | Any | Long-running workflows, sagas, retry orchestration |
| **Inngest** | Node.js | Serverless-friendly, event-driven functions |

```python
# Dramatiq example (Python)
import dramatiq
from dramatiq.brokers.redis import RedisBroker

broker = RedisBroker(url="redis://localhost:6379")
dramatiq.set_broker(broker)

@dramatiq.actor(max_retries=3, min_backoff=1000)
def send_welcome_email(user_id: str) -> None:
    user = get_user(user_id)
    email_service.send(user.email, "Welcome!")
```

---

## 7. Testing

### Test Pyramid

```
Unit tests (70%)      — domain logic, pure functions, no I/O
Integration tests (20%) — real DB, real Redis, Testcontainers
E2E / load tests (10%)  — full stack, production-like
```

**Rule**: mock external HTTP calls (httpx mock, respx), but use REAL databases in integration tests. Mocking Postgres is lying to yourself.

### Testcontainers

```python
# pytest + testcontainers for real PostgreSQL
import pytest
from testcontainers.postgres import PostgresContainer
from sqlalchemy.ext.asyncio import create_async_engine

@pytest.fixture(scope="session")
def postgres():
    with PostgresContainer("postgres:16") as pg:
        yield pg

@pytest.fixture(scope="session")
async def engine(postgres):
    url = postgres.get_connection_url().replace("postgresql://", "postgresql+asyncpg://")
    engine = create_async_engine(url)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    await engine.dispose()
```

### Factory Pattern

Use factories (not fixtures with hardcoded data) to build test objects:

```python
# factory-boy example
import factory
from factory.alchemy import SQLAlchemyModelFactory

class UserFactory(SQLAlchemyModelFactory):
    class Meta:
        model = User

    id = factory.LazyFunction(uuid4)
    email = factory.Sequence(lambda n: f"user{n}@example.com")
    name = factory.Faker("name")
    role = "user"
```

### Load Testing

**k6** is the default. Scripted in JS, integrates with CI, outputs InfluxDB/Prometheus metrics.

```javascript
// k6 smoke test
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = { vus: 10, duration: '30s' };

export default function () {
  const res = http.get('http://localhost:8000/api/v1/users');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

---

## 8. Observability

### Standard Stack

| Concern | Tool |
|---------|------|
| Tracing + metrics + logs | **OpenTelemetry** (vendor-neutral, OTEL SDK) |
| Structured logging Python | **structlog** |
| Structured logging Node.js | **pino** |
| Metrics scraping | **Prometheus** |
| Error tracking | **Sentry** |
| Visualization | **Grafana** |

### OpenTelemetry Setup (FastAPI)

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor

provider = TracerProvider()
provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
trace.set_tracer_provider(provider)

FastAPIInstrumentor.instrument_app(app)
SQLAlchemyInstrumentor().instrument(engine=engine)
```

### Structured Logging

```python
import structlog

log = structlog.get_logger()

# Context is carried through the request
log.info("user.created", user_id=str(user.id), email=user.email, role=user.role)
# Output: {"event": "user.created", "user_id": "...", "email": "...", "role": "user", "timestamp": "..."}
```

### Health Check Endpoints

```python
@app.get("/health/live")
async def liveness():
    """Kubernetes liveness probe — is the process alive?"""
    return {"status": "ok"}

@app.get("/health/ready")
async def readiness(db: AsyncSession = Depends(get_db), redis: Redis = Depends(get_redis)):
    """Kubernetes readiness probe — can it serve traffic?"""
    try:
        await db.execute(text("SELECT 1"))
        await redis.ping()
        return {"status": "ok", "db": "ok", "cache": "ok"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))
```

---

## 9. Decision Framework

Full architecture flowchart:

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

9. OBSERVABILITY
   └── Always              → OpenTelemetry + structlog/pino + Sentry + /health/*
```

---

## Commands

```bash
# FastAPI project bootstrap
uv init my-api && cd my-api
uv add fastapi uvicorn[standard] sqlalchemy[asyncio] asyncpg pydantic-settings redis structlog

# Run with hot reload
uvicorn app.main:app --reload --port 8000

# Fastify project bootstrap
npm create fastify@latest my-api -- --lang=ts
npm install @fastify/swagger @fastify/swagger-ui @fastify/rate-limit

# Drizzle ORM setup
npm install drizzle-orm pg && npm install -D drizzle-kit @types/pg
npx drizzle-kit generate && npx drizzle-kit migrate

# Testcontainers (Python)
uv add --dev testcontainers pytest-asyncio factory-boy

# k6 load test
k6 run scripts/load-test.js

# OpenTelemetry auto-instrumentation (Python)
uv add opentelemetry-sdk opentelemetry-instrumentation-fastapi opentelemetry-instrumentation-sqlalchemy opentelemetry-exporter-otlp
```

## Resources

- **FastAPI docs**: https://fastapi.tiangolo.com
- **SQLAlchemy 2.0**: https://docs.sqlalchemy.org/en/20/
- **Drizzle ORM**: https://orm.drizzle.team
- **Testcontainers Python**: https://testcontainers-python.readthedocs.io
- **OpenTelemetry Python**: https://opentelemetry-python.readthedocs.io
- **k6 docs**: https://grafana.com/docs/k6/latest/
- **Temporal**: https://docs.temporal.io
