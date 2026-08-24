# Changelog

## [v3.1.2] - Unreleased

### Changed
- Published `skills/backend-architect/` as the canonical full v3.1.2 skill and `skills/backend-architect-lite/` as the canonical lite v3.1.2 skill.
- Declared `skills/` the sole current and installable skills.sh surface; retained `versions/` as a byte-preserved, non-discoverable historical archive.
- Replaced the fixed `docs/product-charter.md` prerequisite with repository-native authoritative-source discovery; the path remains an example, not a requirement.
- Restricted stack-selection blocking to materially insufficient product constraints or quality attributes after discovery.
- Updated lite guidance using the v3.1.1 evidence base to remove stale categorical defaults, hard-coded BFF repository placement, unsupported team-size and test-ratio thresholds, and version-sensitive claims.
- Renamed every archived `versions/**/SKILL.md` manifest to byte-preserved `ARCHIVE.md`, including the v3.1.2 snapshot, so archive content is excluded from normal and full-depth skill discovery.

### Verification
- Confirmed the canonical full payload byte-matches `versions/v3.1.2/ARCHIVE.md` and its archived references.
- Confirmed the v3.1.1 → v3.1.2 full snapshot diff is limited to the version metadata and repository-native source-discovery correction.
- Confirmed normal and full-depth discovery expose only the two canonical `skills/**/SKILL.md` entries, not `versions/**/ARCHIVE.md`.

## [v3.1.1] - 2026-07-20

### Fixed
- Separated authentication, OAuth/OIDC authorization, sessions, and token representation.
- Corrected refresh-token replay defense, REST versioning, RateLimit draft maturity, MCP policy language, and pgvector remediation.
- Replaced categorical framework, microservice, testing, BFF ownership, IaC, observability, and protocol rules with evidence-based gates.
- Added immutable Valkey license evidence and claim-level source traceability for corrected guidance.

### Verification
- Independent read-only audit result: 0 BLOCKER, 0 HIGH, 0 MEDIUM findings.

## [v3.1] - 2026-07-20

### Added
- Added runtime-portability gates for Hono, Bun, and CPython free-threaded builds.
- Added conditional Valkey/Redis selection, PGlite local-first and testing guidance, and durable-execution invariants.
- Added Microsoft Agent Framework, MCP, and A2A boundary guidance with explicit security controls.
- Added OAuth 2.1 draft-status guidance and the pgvector 0.8.2 mitigation for CVE-2026-3172.

### Changed
- Preserved SQLite and real PostgreSQL where their semantics are required instead of treating PGlite as a universal replacement.
- Kept stable Prisma as the production baseline while gating Prisma Next and preview adapters by maturity.
- Replaced categorical vendor recommendations with capability, licensing, operational, and product-constraint decision gates.

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
