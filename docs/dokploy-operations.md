# Dokploy Operations Runbook

This document is the quick reference for managing and documenting a self-hosted Dokploy instance and the resources managed by its credential contexts.

## Targets

- Dokploy panel: `https://dokploy.example.com`
- Swagger/API reference: `https://dokploy.example.com/swagger`

## Official References

- Dokploy GitHub: `https://github.com/Dokploy`
- Core docs: `https://docs.dokploy.com/docs/core`
- CLI docs: `https://docs.dokploy.com/docs/cli`
- API docs: `https://docs.dokploy.com/docs/api`
- Templates docs: `https://docs.dokploy.com/docs/templates`

## Credential Contexts

Use the wrapper scripts so each operation runs with the intended credential context.

| Context | Local env var | CLI wrapper | MCP wrapper |
| --- | --- | --- | --- |
| `org-a` | `DOKPLOY_CONTEXT_ORG_A_API_KEY` | `scripts/dokploy-cli.sh org-a ...` | `scripts/mcp-dokploy-context.sh org-a` |
| `org-b` | `DOKPLOY_CONTEXT_ORG_B_API_KEY` | `scripts/dokploy-cli.sh org-b ...` | `scripts/mcp-dokploy-context.sh org-b` |

`org-a` and `org-b` are example contexts. Replace them with the values in `DOKPLOY_CONTEXTS` when using this template for a real instance.

Store only the raw API key value in `.env.local`; do not include the visible key label or prefix from the Dokploy UI.

## Session Focus

Every operational session should declare one focus before making changes:

- `<context>`: use only the matching CLI/MCP wrappers and document under `docs/orgs/<context-slug>/`.
- `global`: compare or coordinate multiple contexts only when explicitly requested, and document shared work under `docs/shared/`.

Default to read-only discovery. If the work needs to cross context boundaries, state that explicitly before running commands against another context.

## CLI Checks

```bash
scripts/dokploy-cli.sh org-a project all --json
scripts/dokploy-cli.sh org-a organization all --json
scripts/dokploy-cli.sh org-b project all --json
scripts/dokploy-cli.sh org-b organization all --json
```

Useful discovery commands:

```bash
scripts/dokploy-cli.sh org-a server --help
scripts/dokploy-cli.sh org-a project --help
scripts/dokploy-cli.sh org-a environment --help
scripts/dokploy-cli.sh org-a application --help
scripts/dokploy-cli.sh org-a compose --help

scripts/dokploy-cli.sh org-b server --help
scripts/dokploy-cli.sh org-b project --help
scripts/dokploy-cli.sh org-b environment --help
scripts/dokploy-cli.sh org-b application --help
scripts/dokploy-cli.sh org-b compose --help
```

## MCP Servers

Codex project MCP config is created from `.codex/config.toml.example`.

Each declared context should have one MCP server entry whose `args` value matches that context. Example entries:

- `dokploy-org-a` with `args = ["org-a"]`
- `dokploy-org-b` with `args = ["org-b"]`

After copying `.codex/config.toml.example` to `.codex/config.toml` and updating local paths/context args, restart Codex and run `/mcp` to verify the expected servers are connected.

## Server And Resource Documentation

When discovering resources, document durable information here or in a focused file under `docs/`:

- Organization name and credential context.
- Servers managed by the context.
- Projects and environments.
- Applications and compose stacks.
- Databases and persistent volumes.
- Domains and certificates.
- Backup strategy and restore notes.
- Deployment and rollback notes.
- Known operational risks and maintenance windows.

Prefer read-only discovery first. Mutating operations require explicit confirmation.

Use these paths:

- Context inventory and decisions: `docs/orgs/<context-slug>/`
- Cross-context/shared procedures: `docs/shared/`
- Reusable documentation templates: `docs/templates/`

## Resource Taxonomy

Mirror Dokploy's hierarchy in the docs. `docs/shared/dokploy-reference.md` is the canonical map.

```text
Organization -> Project -> Environment -> Service
```

Context-level files:

| File | Purpose |
| --- | --- |
| `inventory.md` | Projects, environments, services, databases, servers, and backups |
| `servers.md` | Deployment servers, build servers, capacity, security, validation |
| `domains.md` | Public routing, HTTPS, DNS owner, Traefik behavior |
| `variables.md` | Variable names, scope, purpose, sensitivity, rotation owner |
| `deployments.md` | Source, auto deploy, build server, deployment server, rollback |
| `backups.md` | Context-managed service, database, and volume backups plus restore evidence |
| `access.md` | Roles, credential labels, external access notes, no secrets |
| `settings/` | Git sources, registries, SSH keys, certificates, S3 destinations, notifications |
| `runbooks.md` | Context-specific procedures |
| `decisions.md` | Durable operational decisions |

Service detail belongs under the environment where the service runs:

```text
docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md
```

Project and context files such as `services.md`, `domains.md`, `variables.md`, `deployments.md`, and `backups.md` are rollups or indexes.

Shared Dokploy panel/control-plane facts live in `docs/shared/instance.md`; shared instance backup evidence lives in `docs/shared/instance-backups.md`.

Use `docs/templates/` when creating new files.

## Discovery Workflow

1. Declare session focus: a context from `DOKPLOY_CONTEXTS`, or `global`.
2. Run read-only CLI or MCP discovery with the matching context credential.
3. Update context-level inventory before creating project-level docs.
4. Create or update project docs only for resources observed in Dokploy.
5. Record decisions separately from inventory so facts and rationale stay distinct.
6. Run verification commands and keep secrets out of Git.

## Safety Rules

- Do not commit `.env.local` or API keys.
- Keep `DOKPLOY_REDACT_ENV=true` for MCP sessions.
- Follow `docs/shared/mutation-safety.md` before any mutating operation.
- Before delete, prune, rebuild, rollback, restore, or credential rotation, collect current state and backup status.
- Prefer official Dokploy docs and `https://dokploy.example.com/swagger` before assuming command or API shape.
