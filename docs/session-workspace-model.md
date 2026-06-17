# Session And Workspace Model

This repository is the single control plane for the Dokploy instance at `https://dokploy.example.com`.

## Decision

Use one Git repository and one normal working directory for both organizations. Separate work by session focus, wrapper commands, MCP server, and documentation path.

Do not create permanent CWDs for `org-a` and `org-b` while both organizations share the same self-hosted Dokploy instance and the same operational scripts.

Do not use Git worktrees as the default org separation mechanism. Use worktrees only for parallel or larger branch work.

## Session Focus Values

### `org-a`

- CLI: `scripts/dokploy-cli.sh org-a ...`
- MCP: `dokploy-org-a`
- Docs: `docs/orgs/org-a/`

Use this focus for inventory, deployments, backups, domains, servers, and operational decisions scoped to the Org A organization.

### `org-b`

- CLI: `scripts/dokploy-cli.sh org-b ...`
- MCP: `dokploy-org-b`
- Docs: `docs/orgs/org-b/`

Use this focus for inventory, deployments, backups, domains, servers, and operational decisions scoped to the Org B organization.

### `global`

- CLI: both wrappers, only when explicitly comparing or coordinating orgs.
- MCP: both servers, only when explicitly comparing or coordinating orgs.
- Docs: `docs/shared/`

Use this focus for shared policies, cross-org incident procedures, backup standards, naming conventions, and Dokploy instance-level documentation.

## Documentation Routing

Route documentation by scope:

| Scope | Path |
| --- | --- |
| Org A facts and decisions | `docs/orgs/org-a/` |
| Org B facts and decisions | `docs/orgs/org-b/` |
| Cross-org policy and instance procedures | `docs/shared/` |
| New resource document models | `docs/templates/` |

Within each org, start with `inventory.md` and then create project-level docs under `projects/<project-slug>/` only after the project is observed in Dokploy. Follow `docs/shared/dokploy-reference.md` for the current layout.

## Prompt Pattern

Use this pattern at the start of an operational session:

```text
Foco desta sessão: org-a
Objetivo: inventariar servidores e documentar decisões.
Somente leitura até eu aprovar mutações.
```

or:

```text
Foco desta sessão: org-b
Objetivo: revisar deployments e backups.
Somente leitura até eu aprovar mutações.
```

or:

```text
Foco desta sessão: global
Objetivo: comparar políticas de backup entre orgs.
Somente leitura até eu aprovar mutações.
```

## Worktree Rules

Use a worktree when:

- Two independent documentation or configuration branches need to move in parallel.
- A larger change needs branch isolation before merge.
- A Codex thread should work in the background without disturbing the foreground checkout.

Do not use a worktree just to switch between `org-a` and `org-b`; use the wrapper commands and documentation paths instead.

Because `.env.local` is ignored, a worktree will not automatically have credentials. If a worktree needs live CLI or MCP checks:

1. Create an untracked `.env.local` inside that worktree.
2. Set restrictive permissions with `chmod 600 .env.local`.
3. Store only the raw API key values already documented in `.env.example`.
4. Run `git check-ignore -v .env.local` before using it.
5. Never commit copied credentials or command output containing credentials.

## Separate CWD Rules

Create a separate permanent CWD only if the operational boundary changes materially, for example:

- A second Dokploy instance with a different domain.
- Separate access policy or secret store.
- Different team ownership.
- Incompatible scripts, MCP config, or documentation lifecycle.

Until then, keep one repository.
