# Changelog

## [v3.0] - 2026-05-15

### Added
- Added `versions/v3.0/SKILL.md` using the skill-creator compact runtime contract.
- Added `versions/v3.0/references/technical-reference.md` as the curated v3.0 technical basis.
- Added `versions/v3.0/references/source-index.md` for source links and verification status.

### Changed
- Validated v3.0 technical reference against current May 2026 sources and corrected stale or over-strong claims.
- Curated v3.0 references so they are robust local technical bases rather than historical lite dumps.
- Preserved existing lite versions for backward compatibility; v3.0 is the new references-based skill version.

## [v2.0] & [v2.0-lite] - 2026-05-01

### Added
- **Database Architecture** — pgvector, local-first sync (PowerSync, Turso, ElectricSQL, Replicache), vector DBs
- **AI & Agentic Orchestration** — LangGraph, AutoGen, CrewAI, Semantic Kernel, Redis multi-tier memory
- **Backend for Frontend (BFF)** — Pattern, anti-patterns, protocol shift
- **Platform Engineering** — Terraform/OpenTofu, ArgoCD, Infisical, LGTM stack, secrets governance
- **Auth Zero-Trust for AI** — Sandboxing, least-privilege, scoped JWTs
- **Decision Framework** — 10-step architecture flowchart
- **Bootstrap commands** section
- **Verification table** with live-source validation

### Fixed
- **v2.0-lite** — Rebuilt from clone of v2.0 to actual ~450-line condensed version: removed code blocks, extended narratives, Commands section, and full Resources. Matched frontend-architect-lite structure convention.

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
All version claims validated via HTTP API + delegated agent research against live sources (May 2026):
- ✅ github.com/prisma/prisma/releases (7.8.0) — confirmed real
- ✅ platform.openai.com/docs/guides/embeddings (ada-002 deprecated) — confirmed real
- ✅ pyjwt.readthedocs.io (Ed25519PrivateKey) — confirmed real
- ✅ redis.io/docs (XACK consumer groups) — confirmed real
