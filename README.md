# 🏗️ backend-architect-skill

> **General-purpose** backend architecture skill for **stack definition at project start**.
> Guides API design, database/ORM selection, auth patterns, caching, system design,
> platform engineering, and AI/vector infrastructure.
> Based on real ecosystem research validated against live sources (July 2026).

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Why This Exists

AI agents (Cursor, Claude Code, Copilot) now consume our codebases directly. A poorly structured `SKILL.md` causes agents to hallucinate patterns, propose deprecated stacks, or omit security hardening entirely.

This skill is a **validated, opinionated reference** for backend architectural decisions — covering framework selection, database architecture, API design, authentication, AI/vector infrastructure, platform engineering, and system design.

Built from a 241-line research document analyzing the 2025-2026 backend ecosystem, then cross-checked against live sources (API verification + delegated agent research).

---

## 📦 Canonical Skills and Archives

`skills/` is the sole authoritative and installable surface. `versions/` contains immutable historical release snapshots only; it is not an installation target.

| Canonical skill | Version | Installable file | When to use |
|-----------------|---------|------------------|-------------|
| **backend-architect** (full) | **v3.1.2** | [`skills/backend-architect/SKILL.md`](skills/backend-architect/SKILL.md) | Detailed, evidence-gated backend architecture decisions with local references |
| **backend-architect-lite** | **v3.1.2** | [`skills/backend-architect-lite/SKILL.md`](skills/backend-architect-lite/SKILL.md) | Concise stack-definition guidance with the same constraint-first safeguards |

### What's New in v3.1.2

- Replaces the mandatory `docs/product-charter.md` dependency with repository-native authoritative-source discovery; that path is now only an example.
- Blocks stack selection only when material product constraints or quality attributes remain insufficient after discovery.
- Publishes independent canonical full and lite skills under `skills/`; archived release directories remain unchanged.
- Audits lite guidance for stale path, layout, vendor-coupling, categorical, and version-sensitive claims using the v3.1.1 evidence base.

### Historical Archives

| Version | Archive | Notes |
|---------|---------|-------|
| v3.1.1 | [`versions/v3.1.1/`](versions/v3.1.1/) | Previous full runtime release |
| v3.1 | [`versions/v3.1/`](versions/v3.1/) | July 2026 runtime portability and architecture update |
| v3.0 | [`versions/v3.0/`](versions/v3.0/) | May 2026 references-based runtime skill |
| v2.0 | [`versions/v2.0/`](versions/v2.0/) | Historical full reference |
| v2.0-lite | [`versions/v2.0-lite/`](versions/v2.0-lite/) | Historical condensed reference |
| v1.0 | [`versions/v1.0/`](versions/v1.0/) | Original release |

---

## 🚀 Quick Start

### For AI Agents (Cursor, Claude Code, etc.)

Browse the canonical package on [skills.sh](https://skills.sh/kozz36/backend-architect-skill), then install exactly one canonical skill:

```bash
# Full current canonical guidance
npx skills add kozz36/backend-architect-skill --skill backend-architect

# Lite current canonical guidance
npx skills add kozz36/backend-architect-skill --skill backend-architect-lite

# Pin either skill to a published Git ref when one is available
npx skills add kozz36/backend-architect-skill@<published-ref> --skill backend-architect
```

The `@...` suffix selects a Git ref, while `--skill` selects the canonical full or lite entry under `skills/`. Do not install from `versions/`.

### For Human Architects

Open `skills/backend-architect/SKILL.md` for the full runtime contract, then use `skills/backend-architect/references/technical-reference.md` for detailed matrices. For concise guidance, open `skills/backend-architect-lite/SKILL.md`. Key full-reference areas:
- **Section 1** — Framework Selection (decision matrix)
- **Section 2** — Database Architecture (PostgreSQL, SQLite, vector DBs)
- **Section 4** — Authentication and authorization
- **Section 6** — AI and agentic orchestration
- **Section 7** — Architecture patterns and durable workflows

---

## 📁 Structure

```
skills/                        # Authoritative, installable skills.sh surface
├── backend-architect/         # Full v3.1.2
│   ├── SKILL.md
│   └── references/
│       ├── technical-reference.md
│       └── source-index.md
└── backend-architect-lite/    # Lite v3.1.2
    └── SKILL.md
versions/                      # Archive-only historical snapshots
├── v1.0/
├── v2.0/
├── v2.0-lite/
├── v3.0/
├── v3.1/
├── v3.1.1/
└── v3.1.2/                    # Full v3.1.2 release snapshot
docs/
├── CHANGELOG.md               # Verified version history
└── CONTRIBUTING.md            # How to contribute improvements
```

---

## 🔍 Verification Methodology

Every version claim was validated against live sources:

| Source | Verification Method | Status |
|--------|---------------------|--------|
| Prisma 7 exists | HTTP API + GitHub releases | ✅ Real (7.8.0, Apr 2026) |
| ada-002 deprecated | OpenAI API docs | ✅ Confirmed |
| JWT EdDSA key type | PyJWT documentation | ✅ Requires Ed25519PrivateKey object |
| Redis Streams at-least-once | redis.io docs | ✅ Via XACK consumer groups |

---

## 🤝 Contributing

This skill is maintained as a living document. See [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) for:
- How to propose additions (new frameworks, updated versions)
- Verification requirements before merging
- Style guide (tables > narrative, decision trees > lists)

---

## 📝 License

Apache-2.0

---

**Maintained by:** [@kozz36](https://github.com/kozz36)  
**Research base:** "Propuesta de Actualización de Habilidades Profesionales" (241-line ecosystem analysis, 2026)
