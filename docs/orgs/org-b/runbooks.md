# Org B Runbooks

Org-specific procedures for the Org B context.

## Standard Session Header

```text
Foco desta sessao: org-b
Objetivo: <describe work>
Somente leitura ate eu aprovar mutacoes.
```

## Available Runbooks

| Procedure | Risk | Source | Notes |
| --- | --- | --- | --- |
| Read inventory | read-only | `docs/dokploy-operations.md` | Use CLI/MCP discovery and update inventory |
| Incident response | medium | `docs/shared/incident-runbook.md` | Requires explicit approval for mutating actions |
| Backup review | read-only | `docs/shared/backup-policy.md` | Review schedules and restore evidence |
| Mutation preflight | medium/high | `docs/shared/mutation-safety.md` | Required before live changes |

## Org-Specific Procedures

Add procedures here when they differ from shared policy.
