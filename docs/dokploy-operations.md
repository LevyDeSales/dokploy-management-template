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

## Session Focus

Every operational session should declare one focus before making changes:

- `alltius`: use only Alltius CLI/MCP and document under `docs/orgs/alltius/`.
- `zapix`: use only Zapix CLI/MCP and document under `docs/orgs/zapix/`.
- `global`: compare or coordinate both orgs and document under `docs/shared/`.

Default to read-only discovery. If the work needs to cross org boundaries, state that explicitly before running commands against the second org.

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

Use these paths:

- Alltius inventory and decisions: `docs/orgs/alltius/`
- Zapix inventory and decisions: `docs/orgs/zapix/`
- Cross-org/shared procedures: `docs/shared/`
- Reusable documentation templates: `docs/templates/`

## Resource Taxonomy

Mirror Dokploy's hierarchy in the docs. `docs/shared/dokploy-reference.md` is the canonical map.

```text
Organization -> Project -> Environment -> Service
```

Org-level files:

| File | Purpose |
| --- | --- |
| `inventory.md` | Projects, environments, services, databases, servers, and backups |
| `servers.md` | Deployment servers, build servers, capacity, security, validation |
| `domains.md` | Public routing, HTTPS, DNS owner, Traefik behavior |
| `variables.md` | Variable names, scope, purpose, sensitivity, rotation owner |
| `deployments.md` | Source, auto deploy, build server, deployment server, rollback |
| `backups.md` | Org-managed service, database, and volume backups plus restore evidence |
| `access.md` | Roles, credential labels, external access notes, no secrets |
| `settings/` | Git sources, registries, SSH keys, certificates, S3 destinations, notifications |
| `runbooks.md` | Org-specific procedures |
| `decisions.md` | Durable operational decisions |

Service detail belongs under the environment where the service runs:

```text
docs/orgs/<org>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md
```

Project and org files such as `services.md`, `domains.md`, `variables.md`, `deployments.md`, and `backups.md` are rollups or indexes.

Shared Dokploy panel/control-plane facts live in `docs/shared/instance.md`; shared instance backup evidence lives in `docs/shared/instance-backups.md`.

Use `docs/templates/` when creating new files.

## Discovery Workflow

1. Declare session focus: `alltius`, `zapix`, or `global`.
2. Run read-only CLI or MCP discovery with the matching org credential.
3. Update org-level inventory before creating project-level docs.
4. Create or update project docs only for resources observed in Dokploy.
5. Record decisions separately from inventory so facts and rationale stay distinct.
6. Run verification commands and keep secrets out of Git.

## Safety Rules

- Do not commit `.env.local` or API keys.
- Keep `DOKPLOY_REDACT_ENV=true` for MCP sessions.
- Follow `docs/shared/mutation-safety.md` before any mutating operation.
- Before delete, prune, rebuild, rollback, restore, or credential rotation, collect current state and backup status.
- Prefer official Dokploy docs and `https://dokploy.alltius.dev/swagger` before assuming command or API shape.
