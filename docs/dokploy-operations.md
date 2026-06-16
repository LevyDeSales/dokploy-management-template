# Dokploy Operations Runbook

This document is the quick reference for managing and documenting the Alltius self-hosted Dokploy instance and the resources managed by its organizations.

## Targets

- Dokploy panel: `https://dokploy.alltius.dev`
- Swagger/API reference: `https://dokploy.alltius.dev/swagger`

## Official References

- Dokploy GitHub: `https://github.com/Dokploy`
- Core docs: `https://docs.dokploy.com/docs/core`
- CLI docs: `https://docs.dokploy.com/docs/cli`
- API docs: `https://docs.dokploy.com/docs/api`
- Templates docs: `https://docs.dokploy.com/docs/templates`

## Organization Contexts

Use the wrapper scripts so each operation runs with the intended organization credential.

| Context | Credential label | Local env var | CLI wrapper |
| --- | --- | --- | --- |
| `alltius` | `dokploy-alltius-org-Alltius` | `DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY` | `scripts/dokploy-cli.sh alltius ...` |
| `zapix` | `dokploy-alltius-org-Zapix` | `DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY` | `scripts/dokploy-cli.sh zapix ...` |

Store only the raw API key value in `.env.local`; do not include the visible key label or prefix from the Dokploy UI.

## CLI Checks

```bash
scripts/dokploy-cli.sh alltius project all --json
scripts/dokploy-cli.sh alltius organization all --json
scripts/dokploy-cli.sh zapix project all --json
scripts/dokploy-cli.sh zapix organization all --json
```

Useful discovery commands:

```bash
scripts/dokploy-cli.sh alltius server --help
scripts/dokploy-cli.sh alltius project --help
scripts/dokploy-cli.sh alltius environment --help
scripts/dokploy-cli.sh alltius application --help
scripts/dokploy-cli.sh alltius compose --help

scripts/dokploy-cli.sh zapix server --help
scripts/dokploy-cli.sh zapix project --help
scripts/dokploy-cli.sh zapix environment --help
scripts/dokploy-cli.sh zapix application --help
scripts/dokploy-cli.sh zapix compose --help
```

## MCP Servers

Codex project MCP config lives in `.codex/config.toml`.

- `dokploy-alltius-org-alltius`
- `dokploy-alltius-org-zapix`

After changing `.codex/config.toml` or `.env.local`, restart Codex and run `/mcp` to verify both servers are connected.

## Server And Resource Documentation

When discovering resources, document durable information here or in a focused file under `docs/`:

- Organization name and credential context.
- Servers managed by the org.
- Projects and environments.
- Applications and compose stacks.
- Databases and persistent volumes.
- Domains and certificates.
- Backup strategy and restore notes.
- Deployment and rollback notes.
- Known operational risks and maintenance windows.

Prefer read-only discovery first. Mutating operations require explicit confirmation.

## Safety Rules

- Do not commit `.env.local` or API keys.
- Keep `DOKPLOY_REDACT_ENV=true` for MCP sessions.
- Before delete, prune, rebuild, rollback, or credential rotation, collect current state and backup status.
- Prefer official Dokploy docs and `https://dokploy.alltius.dev/swagger` before assuming command or API shape.
