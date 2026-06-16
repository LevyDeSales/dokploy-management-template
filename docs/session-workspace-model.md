# Session And Workspace Model

This repository is the single control plane for the Dokploy instance at `https://dokploy.alltius.dev`.

## Decision

Use one Git repository and one normal working directory for both organizations. Separate work by session focus, wrapper commands, MCP server, and documentation path.

Do not create permanent CWDs for `alltius` and `zapix` while both organizations share the same self-hosted Dokploy instance and the same operational scripts.

Do not use Git worktrees as the default org separation mechanism. Use worktrees only for parallel or larger branch work.

## Session Focus Values

### `alltius`

- CLI: `scripts/dokploy-cli.sh alltius ...`
- MCP: `dokploy-alltius-org-alltius`
- Docs: `docs/orgs/alltius/`

Use this focus for inventory, deployments, backups, domains, servers, and operational decisions scoped to the Alltius organization.

### `zapix`

- CLI: `scripts/dokploy-cli.sh zapix ...`
- MCP: `dokploy-alltius-org-zapix`
- Docs: `docs/orgs/zapix/`

Use this focus for inventory, deployments, backups, domains, servers, and operational decisions scoped to the Zapix organization.

### `global`

- CLI: both wrappers, only when explicitly comparing or coordinating orgs.
- MCP: both servers, only when explicitly comparing or coordinating orgs.
- Docs: `docs/shared/`

Use this focus for shared policies, cross-org incident procedures, backup standards, naming conventions, and Dokploy instance-level documentation.

## Prompt Pattern

Use this pattern at the start of an operational session:

```text
Foco desta sessão: alltius
Objetivo: inventariar servidores e documentar decisões.
Somente leitura até eu aprovar mutações.
```

or:

```text
Foco desta sessão: zapix
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

Do not use a worktree just to switch between `alltius` and `zapix`; use the wrapper commands and documentation paths instead.

Because `.env.local` is ignored, a worktree will not automatically have credentials. If a worktree needs live CLI or MCP checks, intentionally provide credentials through a safe local copy or a documented `.worktreeinclude` decision.

## Separate CWD Rules

Create a separate permanent CWD only if the operational boundary changes materially, for example:

- A second Dokploy instance with a different domain.
- Separate access policy or secret store.
- Different team ownership.
- Incompatible scripts, MCP config, or documentation lifecycle.

Until then, keep one repository.
