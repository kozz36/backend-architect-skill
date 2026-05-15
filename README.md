# 🏗️ backend-architect-skill

> **General-purpose** backend architecture skill for **stack definition at project start**.
> Guides API design, database/ORM selection, auth patterns, caching, system design,
> platform engineering, and AI/vector infrastructure.
> Based on real ecosystem research validated against live sources (May 2026).

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Why This Exists

AI agents (Cursor, Claude Code, Copilot) now consume our codebases directly. A poorly structured `SKILL.md` causes agents to hallucinate patterns, propose deprecated stacks, or omit security hardening entirely.

This skill is a **validated, opinionated reference** for backend architectural decisions — covering framework selection, database architecture, API design, authentication, AI/vector infrastructure, platform engineering, and system design.

Built from a 241-line research document analyzing the 2025-2026 backend ecosystem, then cross-checked against live sources (API verification + delegated agent research).

---

## 📦 Versions

| Version | File | Size | When to Use |
|---------|------|------|-------------|
| **v3.0** (Current) | [`versions/v3.0/SKILL.md`](versions/v3.0/SKILL.md) | ~55 lines + references | Compact runtime skill with curated `references/` and May 2026 source index |
| **v2.0** (Historical) | [`versions/v2.0/SKILL.md`](versions/v2.0/SKILL.md) | ~800 lines | Preserved for backward compatibility; verify claims against v3 source index before reuse |
| **v2.0-lite** (Historical) | [`versions/v2.0-lite/SKILL.md`](versions/v2.0-lite/SKILL.md) | ~450 lines | Preserved for backward compatibility; v3.0 replaces it for active runtime ingestion |
| **v1.0** (Original) | [`versions/v1.0/SKILL.md`](versions/v1.0/SKILL.md) | ~608 lines | Pre-2026 reference. Preserved for backward compatibility |

### What's New in v3.0 (May 2026)

Validated against real ecosystem state:
- ✅ **Prisma 7** — Validated 7.8.0 latest stable via HTTP API + delegated research
- ✅ **Local-First Sync** — PowerSync, Turso, ElectricSQL, Replicache
- ✅ **Vector Search** — pgvector, Pinecone, Milvus, Weaviate, Chroma
- ✅ **AI Agent Orchestration** — LangGraph, AutoGen, CrewAI, Semantic Kernel
- ✅ **Backend for Frontend (BFF)** — Pattern, anti-patterns, protocol shift
- ✅ **Platform Engineering** — Terraform/OpenTofu, ArgoCD, Infisical, LGTM
- ⚠️ **openai-v3 embeddings** — ada-002 deprecated, text-embedding-3-small is current
- ✅ **Zero-Trust Auth for AI** — Sandboxing, least-privilege, scoped JWTs

---

## 🚀 Quick Start

### For AI Agents (Cursor, Claude Code, etc.)

```bash
# Clone into your skills directory
git clone https://github.com/kozz36/backend-architect-skill.git

# Use the version that matches your need:
# - Full → detailed architectural planning
# - Lite → rapid stack selection under constraints
```

### For Human Architects

Open `versions/v3.0/SKILL.md` for the runtime contract, then use `versions/v3.0/references/technical-reference.md` for detailed matrices. Key reference areas:
- **Section 1** — Framework Selection (decision matrix)
- **Section 2** — Database Architecture (PostgreSQL, SQLite, vector DBs)
- **Section 7** — Security & Auth (Zero-Trust, JWT, RBAC)
- **Section 13** — System Design (scalability patterns, load testing)

---

## 📁 Structure

```
versions/
├── v1.0/
│   └── SKILL.md              # Original (pre-2026)
├── v2.0/
│   └── SKILL.md              # Historical full reference
├── v2.0-lite/
│   └── SKILL.md              # Historical condensed reference
└── v3.0/
    ├── SKILL.md              # Current compact runtime contract
    └── references/
        ├── technical-reference.md
        └── source-index.md
docs/
├── CHANGELOG.md              # Verified version history
└── CONTRIBUTING.md           # How to contribute improvements
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
