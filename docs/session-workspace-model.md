# Session And Workspace Model

This repository is the single control plane for the Dokploy instance at `https://dokploy.example.com`.

## Decision

Use one Git repository and one normal working directory for all contexts on a single self-hosted Dokploy instance. Separate work by declared session focus, wrapper commands, MCP server entries, and documentation path.

Do not create permanent CWDs for individual contexts while they share the same self-hosted Dokploy instance and the same operational scripts.

Do not use Git worktrees as the default context separation mechanism. Use worktrees only for parallel or larger branch work.

Session focus chooses the Dokploy credential context and documentation path.
Branches isolate a concrete operation. In a private operations repository, keep
durable state on `operations` and use focused temporary branches for mutating or
multi-step work. See `docs/guides/operational-branching.md`.

## Session Focus Values

### Context Focus

- CLI: `scripts/dokploy-cli.sh <context> ...`
- MCP: the Codex MCP server entry whose `args` value is `["<context>"]`
- Docs: `docs/orgs/<context-slug>/`

Use this focus for inventory, deployments, backups, domains, servers, and operational decisions scoped to one Dokploy organization or credential context.

### `global`

- CLI: multiple context wrappers, only when explicitly comparing or coordinating contexts.
- MCP: multiple context server entries, only when explicitly comparing or coordinating contexts.
- Docs: `docs/shared/`

Use this focus for shared policies, cross-context incident procedures, backup standards, naming conventions, and Dokploy instance-level documentation.

## Documentation Routing

Route documentation by scope:

| Scope | Path |
| --- | --- |
| Context facts and decisions | `docs/orgs/<context-slug>/` |
| Cross-context policy and instance procedures | `docs/shared/` |
| New resource document models | `docs/templates/` |

Within each context, start with `inventory.md` and then create project-level docs
under `projects/<project-slug>/` after reconciling discovery evidence or
recording a reviewed canonized source in the CMDB. Follow
`docs/shared/dokploy-reference.md` for the current layout.

## Prompt Pattern

Use this pattern at the start of an operational session:

```text
Foco desta sessao: <context>
Objetivo: inventariar servidores e documentar decisoes.
Revisao do grafo: <git-commit-ou-revisao>
Perfil externo do agente: <execucao direta, aprovacao ou somente leitura>
```

or:

```text
Foco desta sessao: global
Objetivo: comparar politicas de backup entre contextos.
Revisao do grafo: <git-commit-ou-revisao>
Perfil externo do agente: <execucao direta, aprovacao ou somente leitura>
```

## Worktree Rules

Use a worktree when:

- Two independent documentation or configuration branches need to move in parallel.
- A larger change needs branch isolation before merge.
- A Codex thread should work in the background without disturbing the foreground checkout.

Do not use a worktree just to switch between contexts; use the wrapper commands and documentation paths instead.

For most operations, one normal checkout is enough:

```bash
git switch operations
git pull --ff-only
git switch -c op/YYYY-MM-DD-type-slug
```

Create a worktree only when another branch must stay active in parallel.

Because `.env.local` is ignored, a worktree will not automatically have credentials. If a worktree needs live CLI or MCP checks:

1. Create an untracked `.env.local` inside that worktree.
2. Set restrictive permissions with `chmod 600 .env.local`.
3. Set raw API key values only for the variable names shown in `.env.example`.
4. Run `git check-ignore -v .env.local` before using it.
5. Never commit copied credentials or command output containing credentials.

## Separate CWD Rules

Create a separate permanent CWD only if the operational boundary changes materially, for example:

- A second Dokploy instance with a different domain.
- Separate access policy or secret store.
- Different team ownership.
- Incompatible scripts, MCP config, or documentation lifecycle.

Until then, keep one repository.
