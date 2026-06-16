# Dokploy Instance

This file documents the shared self-hosted Dokploy control plane.

## Instance

| Field | Value |
| --- | --- |
| Panel | `https://dokploy.alltius.dev` |
| Swagger/API | `https://dokploy.alltius.dev/swagger` |
| Session focus | `global` |
| Managed org contexts | `alltius`, `zapix` |

## Architecture Notes

Dokploy's self-hosted architecture includes:

- A Next.js application for UI and backend.
- PostgreSQL for Dokploy configuration and operational data.
- Redis for deployment queues.
- Traefik for reverse proxy, routing, and service discovery.

Use official architecture docs before changing control-plane assumptions:

- `https://docs.dokploy.com/docs/core/architecture`

## Instance-Level Responsibilities

Keep these topics in shared docs, not org docs:

- Dokploy panel access and allowlist posture.
- Control-plane backup and restore evidence.
- Instance upgrades and maintenance windows.
- Shared MCP/CLI setup that affects both org contexts.
- Cross-org incident response.

## Change Rules

- Use `global` session focus for instance-level changes.
- Follow `docs/shared/mutation-safety.md` for any mutating action.
- Keep org-specific service, database, and volume backup docs under `docs/orgs/<org>/backups.md`.
- Keep instance backup and restore evidence in `docs/shared/instance-backups.md`.
