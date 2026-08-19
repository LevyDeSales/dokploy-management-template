# Dokploy Instance Backups

This file is for backups of the shared Dokploy control plane at `https://dokploy.example.com`.

Context-specific application, database, and volume backups live in `docs/orgs/<context-slug>/backups.md`.

## Instance Backup Matrix

| Scope | Type | Schedule | Timezone | Destination | Retention | Restore owner | Last success | Last restore test | Constraints |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

## Restore Notes

Dokploy instance restore can replace `/etc/dokploy` and the `dokploy-postgres` database. Treat it as a high-risk global operation.

Before restore:

- Consult Graphify at the reviewed revision and record the global target CIs,
  relationships, and evidence supporting the restore. The external agent profile
  decides direct execution, approval, or read-only behavior.
- Record panel access, server, DNS, Traefik, and backup facts as reconciliation
  evidence when they are needed; they are not mandatory live discovery before a
  canonical graph-based action.
- Confirm the S3 destination and selected backup file.
- Prepare post-restore login, DNS, Git provider, and Traefik checks.

After restore:

- Verify panel login.
- Verify API/Swagger access.
- Verify declared context credentials through read-only CLI checks.
- Verify domains, deployments, and backup schedules for affected services.
- Create a sanitized reconciliation observation for the control-plane graph.

## Verification Log

| Date | Backup timestamp | Verification | Result | Notes |
| --- | --- | --- | --- | --- |
