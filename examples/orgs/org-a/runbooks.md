# Org A Runbooks

Org-specific procedures for the Org A context.

## Standard Session Header

```text
Foco desta sessao: org-a
Objetivo: <describe work>
Revisao do grafo: <git-commit-ou-revisao>
CIs/relacoes alvo: <ids>
Perfil externo do agente: <define execucao direta, aprovacao ou somente leitura>
```

## Available Runbooks

| Procedure | Risk | Source | Notes |
| --- | --- | --- | --- |
| Read inventory | read-only | `docs/dokploy-operations.md` | Use CLI/MCP discovery and update inventory |
| Incident response | medium | `docs/shared/incident-runbook.md` | Consult Graphify and reconcile divergences |
| Backup review | read-only | `docs/shared/backup-policy.md` | Review schedules and restore evidence |
| Mutation safety | medium/high | `docs/shared/mutation-safety.md` | Graph-first execution and reconciliation contract |

## Org-Specific Procedures

Add procedures here when they differ from shared policy.
