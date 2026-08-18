# Change Record: CHG-2026-08-17-ragflow-redeploy

Date: 2026-08-17

Scope: org-a

Graph revision: <git-commit-or-tag>

## Requested Mutation

- Objective: Redeploy the RAGFlow application.
- Target CIs: ci:application:org-a:ragflow-production
- Target relationships: rel:ragflow-production:runs-on:ragflow-server
- Requested action: redeploy
- Expected graph impact: no relationship change.
- Rollback path: redeploy the prior reviewed release.

## Execution

- Execution mechanism: dokploy-api
- Result: succeeded
- Verification: deployment and health endpoint checks completed.
- Sanitized evidence reference: deployment/<dokploy-deployment-id>

## Reconciliation

- Observation record: ../reconciliations/2026-08-17-ragflow-monitor.yaml
- Outcome: match
- Follow-up: none
