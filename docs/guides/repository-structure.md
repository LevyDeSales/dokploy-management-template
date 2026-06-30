# Repository Structure

Use this structure to document infrastructure without mixing private runtime
state into public docs.

```text
.
|-- README.md
|-- AGENTS.md
|-- docs/
|   |-- architecture.md
|   |-- installation.md
|   |-- mcp-conventions.md
|   |-- networking.md
|   |-- portainer-to-dokploy.md
|   |-- references.md
|   |-- templates/
|   `-- decisions/
|-- examples/
|   |-- docker-compose/
|   `-- env/
`-- scripts/
```

## What Goes Where

| Path | Purpose |
| --- | --- |
| `docs/` | durable explanations and runbooks |
| `docs/templates/` | fillable inventories and operational templates |
| `docs/decisions/` | ADRs and durable decisions |
| `examples/docker-compose/` | public-safe compose examples |
| `examples/env/` | public-safe `.env.example` files |
| `scripts/` | validation and helper scripts |

## Stack Folder Pattern

If you create a private operations repo based on this one, keep one folder per
Dokploy stack:

```text
infra/dokploy-apps/<stack>/
|-- docker-compose.example.yml
|-- .env.example
|-- DEPLOY_PLAN.md
`-- BACKUP_AND_STORAGE.md
```

## Public-Safety Rule

Public repos should use placeholders. Private repos may replace placeholders
with real operational values.
