# Contributing to backend-architect-skill

This skill is a **living document**. The backend ecosystem mutates quarterly. Stale information is worse than no information.

## What We Accept

| Change Type | Example | Likelihood of Merge |
|-------------|---------|---------------------|
| **New framework release** | "Prisma 8 shipped with X" | High (with verification) |
| **Security advisory** | "CVE for PostgreSQL 17" | High (with source link) |
| **Correction** | "JWT EdDSA now requires X format" | High (with proof) |
| **New domain** | "Edge database patterns" | Medium (needs rationale) |
| **Rewrite for readability** | "Section X is unclear" | Medium (must keep tables) |
| **Style-only** | "Better wording" | Low (unless ambiguous) |

## What We Reject

- ❌ Unverified version claims ("I heard Turso v2 is coming")
- ❌ Narrative-heavy additions ("The landscape has shifted dramatically...")
- ❌ Vendor marketing copy ("Revolutionary breakthrough...")
- ❌ Breaking structural changes without discussion first

## Style Guide

This is a skill for **AI agents**, not a blog post.

### Format Rules

1. **Tables > bullet lists** for comparisons
2. **Decision trees (`if X then Y`)** over paragraphs
3. **Prohibitions (`Do NOT`, `Red Flags`)** must be explicit
4. **One concept per section** — no digressions
5. **Links to live sources** for every version claim

### Tone

- Direct. Technical. Zero marketing.
- "Avoid" → say why (memory, latency, consistency penalty)
- "Prefer" → say when the exception applies

## Verification Requirements

Every claim about a **version number, feature, or security status** must include one of:

- Playwright snapshot of official docs page
- Link to GitHub release/tag
- Link to CVE or security advisory
- Link to official RFC or specification

## How to Submit

### Pull Request Workflow (REQUIRED)

This repo follows the **issue-first, PR-mandatory** workflow:

```
1. Open an issue describing the change
2. Wait for `status:approved` label (maintainer review)
3. Create branch: `type/description` (e.g., `feat/auth-section`, `fix/redis-typo`)
4. Implement changes with conventional commits
5. Update `docs/CHANGELOG.md`
6. Open PR with `Closes #N` in body
7. Add exactly one `type:*` label
8. Wait for automated checks to pass
9. Maintainer merges
```

**NEVER push directly to `main`.** Direct pushes are blocked by branch protection.

### Branch Naming

```
^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)\/[a-z0-9._-]+$
```

| Type | Example |
|------|---------|
| `feat/` | `feat/pgvector-hybrid-search` |
| `fix/` | `fix/jwt-eddsa-code` |
| `docs/` | `docs/temporal-section` |
| `chore/` | `chore/update-prisma-7.9` |

### Conventional Commits

Format: `type(scope): description`

| Type | PR Label | When |
|------|----------|------|
| `feat` | `type:feature` | New section or capability |
| `fix` | `type:bug` | Correction or error |
| `docs` | `type:docs` | Documentation change |
| `refactor` | `type:refactor` | Restructure without content change |
| `chore` | `type:chore` | Maintenance, tool updates |

### Commit Checklist

- [ ] Linked an approved issue (`Closes #N`)
- [ ] Added exactly one `type:*` label
- [ ] Conventional commit format
- [ ] No `Co-Authored-By` trailers
- [ ] Playwright verification included for version claims
- [ ] `docs/CHANGELOG.md` updated

Original direct-push workflow (DEPRECATED — kept for historical reference):

1. Fork the repo
2. Edit the relevant `SKILL.md`
3. Update `docs/CHANGELOG.md`
4. ~~Push to main~~ → **Use PR workflow above**

## Version Policy

- **Patch (x.x.1)** — Corrections, clarifications, link fixes
- **Minor (x.1.0)** — New sections, updated framework versions, new tools
- **Major (2.0.0 → 3.0.0)** — Structural rewrites, new paradigms, breaking recommendations

## Topics for Future Exploration

- Edge-first database patterns (Turso, LiteFS, SQLite on Cloudflare Workers)
- WebAssembly integration in backend services (Wasmtime, Wasmer)
- Multi-tenant data isolation strategies (row-level security, schema-per-tenant)
- AI-generated API contract testing

If you have validated research on any of these, open an issue first to discuss scope.
