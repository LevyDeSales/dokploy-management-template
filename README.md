# Dokploy Alltius Operations

This workspace manages and documents the Alltius self-hosted Dokploy server through:

- Dokploy CLI for explicit terminal operations.
- Dokploy MCP for Codex-assisted workflows.
- Git-tracked runbooks for the Dokploy organizations and the servers they manage.

## Links

- Dokploy GitHub: `https://github.com/Dokploy`
- Core docs: `https://docs.dokploy.com/docs/core`
- CLI docs: `https://docs.dokploy.com/docs/cli`
- API docs: `https://docs.dokploy.com/docs/api`
- Templates docs: `https://docs.dokploy.com/docs/templates`
- Alltius Dokploy: `https://dokploy.alltius.dev`
- Alltius Swagger: `https://dokploy.alltius.dev/swagger`

## Scope

This repository is the operations base for the Dokploy instance at `https://dokploy.alltius.dev`.

Current organization contexts:

- `alltius`: Alltius organization credential and managed resources.
- `zapix`: Zapix organization credential and managed resources.

Document server inventory, deployments, backups, and operational decisions in `docs/`.

## Working Model

Use one repository and one normal working directory as the control plane for both organizations. Separate work by session focus and documentation path, not by duplicating the repository.

Session focus examples:

```text
Foco desta sessão: alltius
Use scripts/dokploy-cli.sh alltius ... and MCP dokploy-alltius-org-alltius.
Document decisions in docs/orgs/alltius/.
```

```text
Foco desta sessão: zapix
Use scripts/dokploy-cli.sh zapix ... and MCP dokploy-alltius-org-zapix.
Document decisions in docs/orgs/zapix/.
```

```text
Foco desta sessão: global
Compare both orgs and document shared decisions in docs/shared/.
```

Use Git worktrees only for parallel or larger branch work. Do not use worktrees as the default org separation mechanism.

## Local Environment

Credentials live in `.env.local`, which is ignored by Git. Store only raw API key values, without visible key labels or prefixes from the Dokploy UI.

Required variables:

```bash
DOKPLOY_ALLTIUS_URL="https://dokploy.alltius.dev"
DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY="raw-alltius-api-key"
DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY="raw-zapix-api-key"
```

Optional fallback if IP allowlist is not sufficient:

```bash
DOKPLOY_ALLTIUS_CUSTOM_HEADERS='{"CF-Access-Client-Id":"client-id.access","CF-Access-Client-Secret":"client-secret"}'
```

## CLI Smoke Checks

```bash
scripts/dokploy-cli.sh alltius project all --json
scripts/dokploy-cli.sh zapix project all --json
```

Run arbitrary Dokploy CLI commands through the org wrapper:

```bash
scripts/dokploy-cli.sh alltius server --help
scripts/dokploy-cli.sh zapix application --help
```

## Codex MCP Servers

Project-scoped MCP config is in `.codex/config.toml`.

- `dokploy-alltius-org-alltius`
- `dokploy-alltius-org-zapix`

Restart Codex after changes, then run `/mcp` in the TUI and verify both servers are connected.

## Documentation

- Agent/project instructions: `AGENTS.md`
- Operations runbook: `docs/dokploy-operations.md`
- Session/workspace model: `docs/session-workspace-model.md`
- Alltius org docs: `docs/orgs/alltius/`
- Zapix org docs: `docs/orgs/zapix/`
- Shared docs: `docs/shared/`
- Implementation plan history: `docs/superpowers/plans/`
