# Incident Runbook

Use this runbook for production-impacting Dokploy incidents.

## 1. Set Focus

Declare the session focus before running commands:

```text
Foco desta sessao: <context-slug|global>
Objetivo: incident response
Revisao do grafo: <git-commit-ou-revisao>
CIs/relacoes afetados: <ids>
Perfil externo do agente: <execucao direta, aprovacao ou somente leitura>
```

Use only the matching CLI wrapper and MCP server unless the incident is explicitly cross-context.

## 2. Capture Current State

Query Graphify at the reviewed revision first. Collect live read-only evidence
when it helps triage or reconcile the canonized graph:

- Affected organization, project, environment, and service.
- Current deployment status and latest deployment timestamp.
- Domain and certificate state.
- Server health, disk usage, and relevant logs.
- Backup status and latest successful backup timestamp.
- Recent changes or decisions from `decisions.md`.

## 3. Triage

Classify the likely issue:

| Category | Common signals |
| --- | --- |
| Deployment | Failed build, failed deploy, broken release, queue problem |
| Routing | Domain, certificate, Traefik, DNS, wrong container port |
| Runtime | Crash loop, resource exhaustion, dependency unavailable |
| Data | Database unavailable, migration issue, volume corruption |
| Infrastructure | Server unreachable, firewall, Docker, disk, SSH |

## 4. Mutating Actions

Follow `docs/shared/mutation-safety.md` before any mutating action. A canonical
`declared` or `verified` relationship may orient the action; the external agent
profile decides direct execution, approval, or read-only behavior. This includes
deploy, redeploy, update, restart, start, stop, scale, rollback, restore,
domain changes, variable changes, server changes, and credential rotation.

## 5. Recovery

Prefer the least invasive recovery path:

1. Revert domain/routing changes when the incident is routing-only.
2. Roll back application deployment when the last release is suspect.
3. Restore database or volume only when data corruption or loss is confirmed.
4. Escalate to server-level recovery when the server or Docker layer is unhealthy.

## 6. Closeout

After recovery, document:

- Timeline.
- Root cause or strongest known hypothesis.
- Actions taken.
- Verification commands and results.
- Follow-up decisions.
- Sanitized reconciliation observation, including any `conflict` or `stale`
  relationship discovered during recovery.
