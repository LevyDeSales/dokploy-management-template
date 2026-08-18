# Dokploy Instance

This file documents the shared self-hosted Dokploy control plane.

## Instance

| Field | Value |
| --- | --- |
| Panel | `https://dokploy.example.com` |
| Swagger/API | `https://dokploy.example.com/swagger` |
| Example managed contexts | `org-a`, `org-b` |

## Architecture Notes

Dokploy's self-hosted architecture includes:

- A Next.js application for UI and backend.
- PostgreSQL for Dokploy configuration and operational data.
- Redis for deployment queues.
- Traefik for reverse proxy, routing, and service discovery.

Use official architecture docs before changing control-plane assumptions:

- `https://docs.dokploy.com/docs/core/architecture`

## Instance-Level Responsibilities

Keep these topics in shared docs, not context docs:

- Dokploy panel access and allowlist posture.
- Control-plane backup and restore evidence.
- Instance upgrades and maintenance windows.
- Shared MCP/CLI setup that affects multiple contexts.
- Cross-context incident response.

## Change Rules

- Use `global` session focus for instance-level changes.
- Consult Graphify at the reviewed revision and record target CIs and
  relationships; the agent's external profile decides direct execution,
  approval, or read-only behavior.
- Follow `docs/shared/mutation-safety.md` for any mutating action.
- Keep context-specific service, database, and volume backup docs under `docs/orgs/<context-slug>/backups.md`.
- Keep instance backup and restore evidence in `docs/shared/instance-backups.md`.
