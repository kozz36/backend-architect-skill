# Backend Architecture Source Index

Source index for `../SKILL.md` and `technical-reference.md`.

## Verification Policy

- Do not add new version/API/security claims to `../SKILL.md` or `technical-reference.md` without checking the live source.
- Record newly verified claims with date, source URL, and what was confirmed.
- Distinguish normative protocol requirements, project security policy, product maturity, implementation support, and comparative heuristics.
- Prefer immutable release tags, RFCs, specifications, and official security advisories over moving branches or secondary comparisons.
- `Needs re-verification` below applies to inherited claims not independently recorded in the claim-level log; a later verified claim does not validate every statement associated with the same domain.

## Extracted Sources

| Source | URL | Verification Status |
|--------|-----|---------------------|
| fastapi.tiangolo.com | https://fastapi.tiangolo.com | Needs re-verification before new decision claims. |
| docs.sqlalchemy.org | https://docs.sqlalchemy.org/en/20/ | Needs re-verification before new decision claims. |
| orm.drizzle.team | https://orm.drizzle.team | Needs re-verification before new decision claims. |
| prisma.io | https://www.prisma.io/ | Needs re-verification before new decision claims. |
| github.com | https://github.com/pgvector/pgvector | Needs re-verification before new decision claims. |
| langchain-ai.github.io | https://langchain-ai.github.io/langgraph/ | Needs re-verification before new decision claims. |
| microsoft.github.io | https://microsoft.github.io/autogen/ | Needs re-verification before new decision claims. |
| docs.temporal.io | https://docs.temporal.io | Needs re-verification before new decision claims. |
| opentelemetry.io | https://opentelemetry.io/ | Needs re-verification before new decision claims. |
| grafana.com | https://grafana.com/docs/k6/ | Needs re-verification before new decision claims. |
| testcontainers.com | https://testcontainers.com/ | Needs re-verification before new decision claims. |
| infisical.com | https://infisical.com | Needs re-verification before new decision claims. |
| argo-cd.readthedocs.io | https://argo-cd.readthedocs.io | Needs re-verification before new decision claims. |

## New Verification Log

| Date | Claim | Source | Result |
|------|-------|--------|--------|
| 2026-05-15 | FastAPI current validated release is 0.136.1; native SSE added in 0.135.0. | https://fastapi.tiangolo.com/release-notes/ and https://fastapi.tiangolo.com/tutorial/server-sent-events/ | Confirmed. |
| 2026-05-15 | Prisma ORM 7.7.0 exists; Prisma Next extension API and pgvector integration are active but should be treated carefully for preview/extension semantics. | https://www.prisma.io/changelog/2026-04-07 and https://www.prisma.io/blog/prisma-next-roadmap-april-milestone | Confirmed with caveat. |
| 2026-05-15 | pgvectorscale latest located release is 0.9.0; it complements pgvector, not a mandatory default. | https://github.com/timescale/pgvectorscale/ | Confirmed. |
| 2026-05-15 | v3.0 restructuring only; no new technical/version claims added. | Upstream migration record. | Structural change only. |
| 2026-07-20 | Hono is built on Web Standards and documents support for Cloudflare Workers, Fastly, Deno, Bun, Vercel, Netlify, AWS Lambda, and Node.js. | https://hono.dev/docs/ | Confirmed; runtime portability remains conditional on adapters and application dependencies. |
| 2026-07-20 | CPython free-threaded builds are available from 3.13; extensions may re-enable the GIL and known memory, safety, and single-thread performance differences remain. | https://docs.python.org/3/howto/free-threading-python.html | Confirmed; production adoption requires dependency and workload validation rather than a categorical ban. |
| 2026-07-20 | Valkey 8.1 source uses BSD 3-Clause; Redis 8+ offers RSALv2, SSPLv1, or AGPLv3 choices. | https://github.com/valkey-io/valkey/blob/67c8683792fc9ab7e295f833478eca180c5e4691/COPYING and https://redis.io/legal/licenses/ | Confirmed for the content-addressed Valkey 8.1.0 release commit; no blanket claim that application code must be disclosed. Exact use requires policy or legal review. |
| 2026-07-20 | PGlite runs embedded PostgreSQL in browser and JavaScript runtimes; `clone()` supports isolated tests and `dumpDataDir()` output is intended for PGlite reloads. | https://pglite.dev/docs/ and https://github.com/electric-sql/pglite/blob/main/docs/docs/api.md | Confirmed; not documented as a universal SQLite replacement or full production PostgreSQL parity test. |
| 2026-07-20 | Stable Prisma ORM and Prisma Next have distinct maturity paths; non-GA database, adapter, or Next features require explicit readiness checks. | https://www.prisma.io/blog/the-next-evolution-of-prisma-orm and https://github.com/prisma/prisma | Confirmed with maturity gate; no default migration to experimental lines. |
| 2026-07-20 | Vercel Workflows provides managed resumable execution, deterministic replay, steps, sleep, hooks, event persistence, observability, and skew protection. | https://vercel.com/docs/workflows | Confirmed; documented as a platform-coupled durable-execution option, not a queue replacement. |
| 2026-07-20 | Microsoft Agent Framework combines agent, harness, and graph-workflow capabilities and is the documented successor path for AutoGen and Semantic Kernel; package, language, and capability maturity differ. | https://learn.microsoft.com/en-us/agent-framework/overview/ | Confirmed; .NET examples may use prerelease packages and Go is explicitly preview with missing capabilities. Production use requires an exact maturity gate. |
| 2026-07-20 | MCP standardizes LLM host/client/server integration for resources, prompts, and tools and publishes security guidance. | https://modelcontextprotocol.io/specification/2025-11-25 | Protocol semantics confirmed. Several security controls are implementation `SHOULD` guidance or local policy, not universal protocol `MUST` requirements. |
| 2026-07-20 | A2A standardizes communication between opaque agentic applications and is complementary to MCP's agent-to-tool boundary. | https://a2a-protocol.org/latest/ | Confirmed; not a mandatory internal agent framework. |
| 2026-07-20 | OAuth 2.1 revision 15 is an active Internet-Draft that removes the implicit grant and retains separate authorization-code and client-credentials grants. | https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-15 | Confirmed; PKCE guidance applies to authorization-code exchange, not universally to `client_credentials`. |
| 2026-07-20 | pgvector 0.8.2 fixes CVE-2026-3172, a buffer overflow in parallel HNSW index builds that can expose other relations or crash PostgreSQL. | https://www.postgresql.org/about/news/pgvector-082-released-3245/ | Confirmed; inventory affected deployments and update to 0.8.2 or later rather than relying on intended build behavior. |
| 2026-07-20 | OAuth is an authorization framework, OIDC adds authentication, and JWT is a token format rather than an alternative login protocol. | https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-15 and https://openid.net/specs/openid-connect-core-1_0.html and https://www.rfc-editor.org/rfc/rfc7519 | Confirmed; architecture guidance separates these decisions. |
| 2026-07-20 | The active RateLimit header draft defines `RateLimit` and `RateLimit-Policy`; it remains work in progress and requires compatibility validation. | https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-ratelimit-headers | Confirmed with draft maturity gate; provider-specific headers remain explicit contracts. |
| 2026-07-20 | Public-client refresh tokens require sender constraint or refresh-token rotation with replay detection. | https://www.rfc-editor.org/rfc/rfc9700.html | Confirmed; rotation is not the only compliant replay defense. |
| 2026-07-20 | HTTP caches can incorporate selecting request headers into cache keys through `Vary`; API version location has no universal winner. | https://www.rfc-editor.org/rfc/rfc9111.html | Confirmed; versioning guidance is conditional on consumers and intermediaries. |
