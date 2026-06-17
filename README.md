# Dokploy Management Template

This repository is a public template for managing and documenting a self-hosted Dokploy instance with Git-tracked runbooks, local CLI wrappers, and Codex MCP context entries.

It is an operations control plane, not an application codebase. Store live credentials only in local ignored files.

## What This Gives You

- A repeatable Dokploy CLI wrapper: `scripts/dokploy-cli.sh <context> <dokploy command...>`.
- A repeatable Dokploy MCP wrapper: `scripts/mcp-dokploy-context.sh <context>`.
- Example Codex MCP config in `.codex/config.toml.example`.
- Documentation organized as `Organization -> Project -> Environment -> Service`.
- Shared safety rules for inventory, deployments, backups, domains, variables, and destructive operations.

## Official Dokploy References

- GitHub: `https://github.com/Dokploy`
- Core docs: `https://docs.dokploy.com/docs/core`
- CLI docs: `https://docs.dokploy.com/docs/cli`
- API docs: `https://docs.dokploy.com/docs/api`
- Templates docs: `https://docs.dokploy.com/docs/templates`

## Quick Start

1. Create a new repository from this template.
2. Copy `.env.example` to `.env.local`.
3. Set `DOKPLOY_URL` to your self-hosted Dokploy panel URL.
4. Set `DOKPLOY_CONTEXTS` to your context slugs, for example `prod staging`.
5. Add one raw API key variable per context using `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY`.
6. Copy `.codex/config.toml.example` to `.codex/config.toml`.
7. Replace `/absolute/path/to/dokploy-management-template` with your repository path.
8. Adjust each MCP server `args = ["<context>"]` value to match your contexts.
9. Run read-only checks before documenting live state.

Example `.env.local` shape:

```bash
DOKPLOY_URL=https://dokploy.example.com
DOKPLOY_CONTEXTS="org-a org-b"
DOKPLOY_CONTEXT_ORG_A_API_KEY=
DOKPLOY_CONTEXT_ORG_B_API_KEY=
```

Context normalization uppercases the slug and changes non-alphanumeric characters to `_`.

Examples:

| Context slug | API key variable |
| --- | --- |
| `org-a` | `DOKPLOY_CONTEXT_ORG_A_API_KEY` |
| `customer-prod` | `DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY` |
| `read.only` | `DOKPLOY_CONTEXT_READ_ONLY_API_KEY` |

## Read-Only Smoke Checks

```bash
scripts/dokploy-cli.sh org-a project all --json
scripts/dokploy-cli.sh org-a organization all --json
```

Replace `org-a` with any context listed in `DOKPLOY_CONTEXTS`.

## Codex MCP

Project-scoped MCP config is generated from `.codex/config.toml.example`.

Each Dokploy context should have one MCP server entry:

```toml
[mcp_servers.dokploy-org-a]
command = "/absolute/path/to/dokploy-management-template/scripts/mcp-dokploy-context.sh"
args = ["org-a"]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "prompt"
enabled = true
```

Restart Codex after changes, then run `/mcp` in the TUI and verify the servers are connected.

## Working Model

Start operational work by declaring one focus:

```text
Foco desta sessão: org-a
Objetivo: inventariar projetos e ambientes.
Somente leitura até eu aprovar mutações.
```

Use one repository and one normal working directory as the control plane for all contexts on the same Dokploy instance. Separate work by focus, wrapper command, MCP server, and documentation path.

Use Git worktrees only for parallel documentation or larger branch work.

## Documentation Map

- Agent/project instructions: `AGENTS.md`
- Template setup: `docs/template-setup.md`
- Operations runbook: `docs/dokploy-operations.md`
- Session/workspace model: `docs/session-workspace-model.md`
- Dokploy concept map: `docs/shared/dokploy-reference.md`
- Shared instance docs: `docs/shared/instance.md`
- Mutation safety rules: `docs/shared/mutation-safety.md`
- Example org docs: `docs/orgs/org-a/` and `docs/orgs/org-b/`
- Shared docs: `docs/shared/`
- Reusable templates: `docs/templates/`

Service detail belongs under the environment where the service runs:

```text
docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md
```

Copy from `docs/templates/` for new project, environment, service, domain, variable, deployment, backup, schedule, integration, server, decision, and runbook files.

## Safety

- Do not commit `.env.local`, real API keys, service-token headers, private keys, or command output containing secrets.
- Keep `DOKPLOY_REDACT_ENV=true` for MCP sessions.
- Prefer read-only discovery before any mutating operation.
- Follow `docs/shared/mutation-safety.md` before destructive or state-changing work.
- Use official Dokploy docs and your panel Swagger page before assuming CLI or API shape.
