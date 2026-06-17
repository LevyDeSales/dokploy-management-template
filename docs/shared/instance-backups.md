# Dokploy Instance Backups

This file is for backups of the shared Dokploy control plane at `https://dokploy.example.com`.

Org-specific application, database, and volume backups live in `docs/orgs/<org>/backups.md`.

## Instance Backup Matrix

| Scope | Type | Schedule | Timezone | Destination | Retention | Restore owner | Last success | Last restore test | Constraints |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

## Restore Notes

Dokploy instance restore can replace `/etc/dokploy` and the `dokploy-postgres` database. Treat it as a high-risk global operation.

Before restore:

- Confirm explicit approval for global instance restore.
- Capture current panel access, server IP, DNS, Traefik state, and latest backup timestamp.
- Confirm the S3 destination and selected backup file.
- Prepare post-restore login, DNS, Git provider, and Traefik checks.

After restore:

- Verify panel login.
- Verify API/Swagger access.
- Verify both org credentials through read-only CLI checks.
- Verify domains, deployments, and backup schedules for affected services.

## Verification Log

| Date | Backup timestamp | Verification | Result | Notes |
| --- | --- | --- | --- | --- |
