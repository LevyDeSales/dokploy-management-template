# Dokploy Management Template

Public reference and GitHub template for documenting, operating, and rebuilding
self-hosted infrastructure managed with Dokploy.

This repository is an operations control plane, not an application codebase.
Keep live credentials, private hostnames, IPs, dumps, backups, and local MCP
config only in ignored local files or a private repository created from this
template.

## What This Gives You

- Repeatable Dokploy CLI wrapper:
  `scripts/dokploy-cli.sh <context> <dokploy command...>`.
- Repeatable Dokploy MCP wrapper:
  `scripts/mcp-dokploy-context.sh <context>`.
- Example Codex MCP config in `.codex/config.toml.example`.
- Public-safe guides for installation, architecture, networking, remote
  servers, backups, Docker Compose patterns, and Portainer migration.
- Documentation organized around Dokploy's model:
  `Organization -> Project -> Environment -> Service`.
- A CMDB-as-code contract with canonized CIs and relationships that Graphify
  consults as the operational graph for the reviewed revision.
- Validation for public repository hygiene, links, shell scripts, and local
  tests.

## Quick Start

1. Create a new repository from this template.
2. Copy `.env.example` to `.env.local`.
3. Set `DOKPLOY_URL` to your self-hosted Dokploy panel URL.
4. Set `DOKPLOY_CONTEXTS` to your context slugs, for example `prod staging`.
5. Add one raw API key variable per context using
   `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY`.
6. Review `DOKPLOY_CLI_VERSION` and `DOKPLOY_MCP_VERSION`; pin them unless you
   intentionally want to update the tooling.
7. Copy `.codex/config.toml.example` to `.codex/config.toml`.
8. Replace `/absolute/path/to/dokploy-management-template` with your repository
   path.
9. Adjust each MCP server `args = ["<context>"]` value to match your contexts.
10. Run read-only checks before documenting live state.

Example `.env.local` shape:

```bash
DOKPLOY_URL=https://dokploy.example.com
DOKPLOY_CONTEXTS="org-a org-b"
DOKPLOY_CONTEXT_ORG_A_API_KEY=
DOKPLOY_CONTEXT_ORG_B_API_KEY=
DOKPLOY_CLI_VERSION=0.29.4
DOKPLOY_MCP_VERSION=0.29.3
```

Context normalization uppercases the slug and changes non-alphanumeric
characters to `_`.

| Context slug | API key variable |
| --- | --- |
| `org-a` | `DOKPLOY_CONTEXT_ORG_A_API_KEY` |
| `customer-prod` | `DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY` |
| `read.only` | `DOKPLOY_CONTEXT_READ_ONLY_API_KEY` |

## First Commands

```bash
scripts/validate-repo.sh
scripts/dokploy-cli.sh org-a project all --json
scripts/dokploy-cli.sh org-a organization all --json
```

Replace `org-a` with a context listed in `DOKPLOY_CONTEXTS`.

## Operational Branching

This public template keeps `main` as the reusable, public-safe source.

After creating a private repository for a real Dokploy instance, use an
`operations` branch as the canonical operational ledger and recommended default
branch. Use temporary branches such as `op/YYYY-MM-DD-deploy-service`,
`incident/YYYY-MM-DD-routing-failure`, and `sync/template-YYYY-MM-DD` for
specific work, then merge durable findings back into `operations`.

See `docs/guides/operational-branching.md` for the full workflow, including
checkpoint tags, agent behavior, and safety rules.

## Documentation Map

Start here:

- `docs/index.md`: documentation index.
- `docs/template-setup.md`: first-use setup checklist.
- `docs/dokploy-operations.md`: operational runbook.
- `docs/session-workspace-model.md`: session focus and workspace model.
- `docs/references.md`: official references.
- `docs/publication-checklist.md`: public release checklist.

Adoption and migration guides:

- `docs/guides/architecture.md`
- `docs/guides/installation.md`
- `docs/guides/networking.md`
- `docs/guides/remote-agent-preparation.md`
- `docs/guides/remote-servers.md`
- `docs/guides/operational-branching.md`
- `docs/guides/operational-context-graph.md`
- `docs/guides/docker-compose-patterns.md`
- `docs/guides/backups-restore.md`
- `docs/migration/portainer-to-dokploy.md`
- `docs/migration/portainer-vps-to-dokploy-agent.md`

Operations model:

- `docs/shared/dokploy-reference.md`: canonical concept-to-path map.
- `docs/shared/cmdb-policy.md`: canonized graph and reconciliation rules.
- `docs/shared/mutation-safety.md`: graph-first mutation and reconciliation rules.
- `docs/shared/backup-policy.md`: backup and restore documentation rules.
- `docs/shared/domain-policy.md`: domain change rules.
- `docs/shared/variable-policy.md`: variable documentation rules.
- `docs/shared/server-security.md`: server baseline.
- `docs/shared/incident-runbook.md`: incident flow.

Reusable material:

- `docs/templates/`: fillable operational templates.
- `examples/docker-compose/`: public-safe compose examples.
- `examples/env/`: public-safe env examples.
- `examples/orgs/`: example context documentation.

## Canonical Layout

Service detail belongs under the environment where the service runs:

```text
docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md
```

Use `examples/orgs/` only as scaffolding. Real inventory belongs in
`docs/orgs/` in your private or derived operations repository.

## Safety

- In this public template, do not commit real IPs/domains, customer names,
  private hostnames, credential references, or live operational evidence.
- In a private operations repository created from this template, document only
  approved real operational identifiers that are intentionally part of the
  infrastructure record.
- Never commit `.env.local`, `.codex/config.toml`, real API keys,
  service-token headers, auth headers, cookies, private keys, backups, dumps,
  `tfstate`, raw MCP output, or command output containing secrets.
- Keep `DOKPLOY_REDACT_ENV=true` for MCP sessions.
- Consult Graphify for the reviewed canonized graph before any mutating
  operation. The external agent profile decides whether to execute directly or
  request approval.
- Follow `docs/shared/mutation-safety.md` before destructive or state-changing
  work.
- Use official Dokploy docs and your panel Swagger page before assuming CLI or
  API shape.

## Official Dokploy References

- GitHub: `https://github.com/Dokploy`
- Core docs: `https://docs.dokploy.com/docs/core`
- CLI docs: `https://docs.dokploy.com/docs/cli`
- API docs: `https://docs.dokploy.com/docs/api`
- Templates docs: `https://docs.dokploy.com/docs/templates`

## License

MIT. See `LICENSE`.
