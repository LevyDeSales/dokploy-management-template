# Dokploy Management Template

This template creates an operations and documentation workspace for a self-hosted Dokploy instance through:

- Dokploy CLI for explicit terminal operations.
- Dokploy MCP for Codex-assisted workflows.
- Git-tracked runbooks for the Dokploy organizations and the servers they manage.

## Links

- Dokploy GitHub: `https://github.com/Dokploy`
- Core docs: `https://docs.dokploy.com/docs/core`
- CLI docs: `https://docs.dokploy.com/docs/cli`
- API docs: `https://docs.dokploy.com/docs/api`
- Templates docs: `https://docs.dokploy.com/docs/templates`
- Example Dokploy: `https://dokploy.example.com`
- Example Swagger: `https://dokploy.example.com/swagger`

## Scope

This repository is the operations base for one Dokploy instance. Replace `https://dokploy.example.com` with your real self-hosted Dokploy URL.

Current organization contexts:

- `org-a`: Org A organization credential and managed resources.
- `org-b`: Org B organization credential and managed resources.

Document server inventory, deployments, backups, and operational decisions in `docs/`.

## Bootstrap

1. Copy `.env.example` to `.env.local`.
2. Set `DOKPLOY_URL` and one `DOKPLOY_CONTEXT_<NAME>_API_KEY` per context.
3. Copy `.codex/config.toml.example` to `.codex/config.toml` and replace the absolute paths.
4. Rename `docs/orgs/org-a/` and `docs/orgs/org-b/` or keep them as example contexts.
5. Run read-only CLI checks before documenting live state.

## Working Model

Use one repository and one normal working directory as the control plane for both organizations. Separate work by session focus and documentation path, not by duplicating the repository.

Session focus examples:

```text
Foco desta sessão: org-a
Use scripts/dokploy-cli.sh org-a ... and MCP dokploy-example-org-a.
Document decisions in docs/orgs/org-a/.
```

```text
Foco desta sessão: org-b
Use scripts/dokploy-cli.sh org-b ... and MCP dokploy-example-org-b.
Document decisions in docs/orgs/org-b/.
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
DOKPLOY_URL="https://dokploy.example.com"
DOKPLOY_CONTEXTS="org-a org-b"
DOKPLOY_CONTEXT_ORG_A_API_KEY="raw-org-a-api-key"
DOKPLOY_CONTEXT_ORG_B_API_KEY="raw-org-b-api-key"
```

Optional fallback if IP allowlist is not sufficient:

```bash
DOKPLOY_CUSTOM_HEADERS='{"Header-Name":"header-value"}'
```

## CLI Smoke Checks

```bash
scripts/dokploy-cli.sh org-a project all --json
scripts/dokploy-cli.sh org-b project all --json
```

Run arbitrary Dokploy CLI commands through the org wrapper:

```bash
scripts/dokploy-cli.sh org-a server --help
scripts/dokploy-cli.sh org-b application --help
```

## Codex MCP Servers

Project-scoped MCP config is generated from `.codex/config.toml.example`. Keep `.codex/config.toml` local and untracked because it contains machine-specific paths.

- `dokploy-example-org-a`
- `dokploy-example-org-b`

Restart Codex after changes, then run `/mcp` in the TUI and verify both servers are connected.

## Documentation

- Agent/project instructions: `AGENTS.md`
- Template setup: `docs/template-setup.md`
- Operations runbook: `docs/dokploy-operations.md`
- Session/workspace model: `docs/session-workspace-model.md`
- Dokploy concept map: `docs/shared/dokploy-reference.md`
- Shared instance docs: `docs/shared/instance.md`
- Mutation safety rules: `docs/shared/mutation-safety.md`
- Org A docs: `docs/orgs/org-a/`
- Org B docs: `docs/orgs/org-b/`
- Shared docs: `docs/shared/`
- Reusable templates: `docs/templates/`

## Documentation Architecture

The canonical documentation architecture is `docs/shared/dokploy-reference.md`.

Dokploy resources are organized as:

```text
Organization -> Project -> Environment -> Service
```

Use org-level docs first for inventory and cross-project views. Service detail belongs under the environment where the service runs, using this pattern:

```text
docs/orgs/<org>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md
```

Project and org files such as `services.md`, `domains.md`, `variables.md`, `deployments.md`, and `backups.md` are rollups or indexes.

Copy from `docs/templates/` for new project, environment, service, domain, variable, deployment, backup, schedule, integration, server, decision, and runbook files.
