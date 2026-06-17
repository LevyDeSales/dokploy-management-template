# Naming Conventions

Use stable, lowercase slugs for docs paths and explicit display names for Dokploy labels.

## Context Names

| Example context | Meaning | CLI | MCP |
| --- | --- | --- | --- |
| `org-a` | First example organization context | `scripts/dokploy-cli.sh org-a ...` | MCP server with `args = ["org-a"]` |
| `org-b` | Second example organization context | `scripts/dokploy-cli.sh org-b ...` | MCP server with `args = ["org-b"]` |

Use `global` only for cross-context or instance-level work.

## Doc Path Names

- Context slugs: `org-a`, `org-b`.
- Project slugs: use the Dokploy project name normalized to lowercase kebab-case.
- Environment names: prefer `production`, `staging`, `development`, or an explicit client/region/feature name.
- Service names: use the exact Dokploy service name in tables and a normalized slug in environment-level file paths.
- Service slugs only need to be unique inside their environment path, for example `projects/<project>/environments/production/services/api.md`.
- Decision files: keep durable context-wide decisions in `decisions.md`; split only when the file becomes hard to scan.

## Dokploy Resource Names

- Projects should map to a product, client, team, or durable initiative.
- Environments should isolate runtime stage, client, region, or feature branch.
- Services should make the workload type obvious, for example `api`, `worker`, `postgres-main`, `redis-cache`, or `n8n-compose`.
- Domains should be documented by host and path, not only by service.
- Backup names should include scope and cadence, for example `api-postgres-daily` or `n8n-volume-nightly`.

## Credential Labels

Credential variables must match the intended context:

- `org-a` -> `DOKPLOY_CONTEXT_ORG_A_API_KEY`
- `org-b` -> `DOKPLOY_CONTEXT_ORG_B_API_KEY`
- `<context>` -> `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY`

Do not paste API key values into documentation.
