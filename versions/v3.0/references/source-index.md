# Backend Architecture Source Index

Source index for `../SKILL.md` and `technical-reference.md`.

## Verification Policy

- Do not add new version/API/security claims to `../SKILL.md`, `technical-reference.md`, or `../../../docs/CHANGELOG.md` without checking the live source.
- Record newly verified claims with date, source URL, and what was confirmed.
- Existing URLs below were extracted from the pre-v3 lite material and should be re-checked when used for new claims.

## Extracted Sources

| Source | URL | Verification Status |
|--------|-----|---------------------|
| fastapi.tiangolo.com | https://fastapi.tiangolo.com | Needs re-verification before new changelog claims. |
| docs.sqlalchemy.org | https://docs.sqlalchemy.org/en/20/ | Needs re-verification before new changelog claims. |
| orm.drizzle.team | https://orm.drizzle.team | Needs re-verification before new changelog claims. |
| prisma.io | https://www.prisma.io/ | Needs re-verification before new changelog claims. |
| github.com | https://github.com/pgvector/pgvector | Needs re-verification before new changelog claims. |
| langchain-ai.github.io | https://langchain-ai.github.io/langgraph/ | Needs re-verification before new changelog claims. |
| microsoft.github.io | https://microsoft.github.io/autogen/ | Needs re-verification before new changelog claims. |
| docs.temporal.io | https://docs.temporal.io | Needs re-verification before new changelog claims. |
| opentelemetry.io | https://opentelemetry.io/ | Needs re-verification before new changelog claims. |
| grafana.com | https://grafana.com/docs/k6/ | Needs re-verification before new changelog claims. |
| testcontainers.com | https://testcontainers.com/ | Needs re-verification before new changelog claims. |
| infisical.com | https://infisical.com | Needs re-verification before new changelog claims. |
| argo-cd.readthedocs.io | https://argo-cd.readthedocs.io | Needs re-verification before new changelog claims. |

## New Verification Log

| Date | Claim | Source | Result |
|------|-------|--------|--------|
| 2026-05-15 | FastAPI current validated release is 0.136.1; native SSE added in 0.135.0. | https://fastapi.tiangolo.com/release-notes/ and https://fastapi.tiangolo.com/tutorial/server-sent-events/ | Confirmed. |
| 2026-05-15 | Prisma ORM 7.7.0 exists; Prisma Next extension API and pgvector integration are active but should be treated carefully for preview/extension semantics. | https://www.prisma.io/changelog/2026-04-07 and https://www.prisma.io/blog/prisma-next-roadmap-april-milestone | Confirmed with caveat. |
| 2026-05-15 | pgvectorscale latest located release is 0.9.0; it complements pgvector, not a mandatory default. | https://github.com/timescale/pgvectorscale/ | Confirmed. |
| 2026-05-15 | v3.0 restructuring only; no new technical/version claims added. | Local migration from `versions/v2.0-lite/SKILL.md` | Structural change only. |
