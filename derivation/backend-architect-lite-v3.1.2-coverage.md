# backend-architect-lite v3.1.2 Review Coverage Matrix

This review aid maps the generated lite runtime to the exact v3.1.2 full inputs declared by `backend-architect-lite-v3.1.2.json`. It is outside the install surface. It supports independent semantic review; it is not semantic proof and does not replace live-source verification for new volatile claims.

| Invariant ID | Category | Full source | Lite coverage to inspect |
|---|---|---|---|
| `activation-exclusions` | runtime-contract | Full runtime, Activation Contract | Activation Contract preserves architecture-only activation and exclusions. |
| `source-discovery-stop-gate` | runtime-contract | Full runtime, Hard Rules / Decision Gates | Hard Rules and Execution Order require repository-native discovery and stop on insufficient inputs. |
| `candidate-selection-conditionality` | decision-gate | Technical reference, How to Use | Hard Rules and Selection Gates make every technology conditional rather than default. |
| `runtime-portability` | runtime-gate | Technical reference, Runtime and Portability Gates | Framework and Runtime Portability covers Hono target testing, Bun validation, and free-threaded CPython gates. |
| `sqlite-edge-shortlist` | data-gate | Technical reference, SQLite / Edge Persistence | Persistence section treats Litestream, Turso/libSQL, rqlite, and PowerSync as a workload/deployment shortlist. |
| `pglite-parity-limits` | data-gate | Technical reference, PGlite and Local-First | Persistence section keeps SQLite and real PostgreSQL constraints and lists unproven PGlite parity domains. |
| `data-license-legal-residency` | governance-gate | Full runtime, Hard Rules | Hard Rules and Caching/Licensing cover terms, policy, counsel, residency, retention, encryption, and deletion. |
| `api-bff-protocol` | boundary-gate | Technical reference, API Design / BFF | Selection Gates and API/Identity section condition protocols and retain a thin BFF boundary. |
| `auth-security` | security-gate | Technical reference, Auth & Authorization | API/Identity section covers OAuth/OIDC/JWT separation, PKCE scope, validation, refresh defense, token choices, and RBAC/ABAC. |
| `cache-compatibility` | operations-gate | Technical reference, Caching | Caching/Licensing section gates cache addition, invalidation strategy, compatibility, migration, licensing, and pool sizing. |
| `durable-workflows` | reliability-gate | Technical reference, Background Jobs & Resilient Workflows | Workflows section covers deterministic orchestration, idempotency, retries, compensation, recovery, versioning, and bounded retention. |
| `agent-trust-boundaries` | security-gate | Technical reference, Agent Interoperability Boundaries | Selection Gates and Workflows section separate MCP/A2A use and require trust controls and protocol tests. |
| `pgvector-cve-remediation` | security-remediation | Technical reference, pgvector | Workflows section requires inventory and 0.8.2-or-later remediation for CVE-2026-3172. |
| `privacy-observability` | operations-gate | Technical reference, durable workflow and platform guidance | Workflows and Observability sections require retention, encryption, residency, deletion, structured telemetry, and operational signals. |
| `testing-production-parity` | validation-gate | Technical reference, Testing | Hard Rules and Observability/Privacy/Testing distinguish production-engine integration proof from lower-risk PGlite acceleration. |
| `live-evidence-version-rules` | evidence-gate | Source index, Verification Policy | Live Evidence and Failure Checks requires live primary-source review and evidence classification. |
| `execution-order` | runtime-contract | Full runtime, Execution Steps | Execution Order sequences source discovery, stop gate, selection, boundary definition, risk/fallback, and live evidence. |
| `rejected-alternatives-risks-fallback` | output-contract | Full runtime, Execution Steps / Output Contract | Execution Order and Output Contract require rejected alternatives, failure triggers, mitigation, fallback, and evidence. |
| `output-contract` | output-contract | Full runtime, Output Contract | Lite Output Contract retains constraint justification, tradeoffs, risks, governance constraints, and blocking questions. |

## Independent Review Procedure

1. Start from the three source hashes in `backend-architect-lite-v3.1.2.json`, not a prior lite or archive artifact.
2. For every row, compare the source section against the named lite section and decide whether the compacted wording preserves the decision/safety outcome.
3. Check omissions are limited to rationale, examples, exhaustive tables, and repeated links; the manifest records these omissions.
4. Run `bash scripts/validate-backend-architect-lite-derivation.sh --self-test` for mechanical checks. Treat its success as integrity evidence only, never as semantic approval.
