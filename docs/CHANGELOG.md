# Changelog

## [v2.0] & [v2.0-lite] - 2026-05-01

### Added
- **Database Architecture** — pgvector, local-first sync (PowerSync, Turso, ElectricSQL, Replicache), vector DBs
- **AI & Agentic Orchestration** — LangGraph, AutoGen, CrewAI, Semantic Kernel, Redis multi-tier memory
- **Backend for Frontend (BFF)** — Pattern, anti-patterns, protocol shift
- **Platform Engineering** — Terraform/OpenTofu, ArgoCD, Infisical, LGTM stack, secrets governance
- **Auth Zero-Trust for AI** — Sandboxing, least-privilege, scoped JWTs
- **Decision Framework** — 10-step architecture flowchart
- **Bootstrap commands** section
- **Verification table** with Playwright-validated sources

### Changed
- **JWT** — EdDSA code fixed to use proper key objects; added aud/iss claims
- **Redis Streams** — corrected "at-most-once" → "at-least-once" (XACK)
- **Health checks** — sanitized error details, soft dependency pattern
- **pgvector** — corrected similarity formula range ([-1,1] not [0,1])
- **Rate limit headers** — X-RateLimit-* → IETF RateLimit-*
- **OpenAI embeddings** — ada-002 → text-embedding-3-small
- **BFF** — clarified web vs. mobile ownership
- **Temporal** — corrected "stack frames" → "deterministic replay"

### Security
- **SQL injection** warning on raw SQL
- **RBAC** multi-role support
- **OAuth2 + PKCE** for first-party SPAs
- **Passkeys (WebAuthn)** recommendation

## [v1.0] — Original
- Initial release. 608 lines covering: framework selection, REST/GraphQL, PostgreSQL/MongoDB, JWT, caching, testing, basic patterns.

---

### Verifications
All version claims validated via Playwright and delegations against live sources (May 2026):
- ✅ github.com/prisma/prisma/releases (7.8.0) — confirmed real
- ✅ platform.openai.com/docs/guides/embeddings (ada-002 deprecated) — confirmed real
- ✅ pyjwt.readthedocs.io (Ed25519PrivateKey) — confirmed real
- ✅ redis.io/docs (XACK consumer groups) — confirmed real
