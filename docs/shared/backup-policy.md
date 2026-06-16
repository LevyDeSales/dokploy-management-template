# Backup Policy

This policy covers Dokploy instance backups, database backups, and volume backups.

## Backup Types

| Type | Scope | Storage | Notes |
| --- | --- | --- | --- |
| Dokploy instance backup | Dokploy PostgreSQL database and `/etc/dokploy` | S3 destination | Required for panel recovery; document in `docs/shared/instance-backups.md` |
| Database backup | Database service data | S3 destination | Applies to supported database services |
| Volume backup | Docker named volumes | S3 destination | Does not support bind mounts |
| Manual export | Ad hoc evidence or config export | Secure local or external storage | Use only when needed and redact secrets |

## Required Documentation

Each backup entry should record:

- Organization and project.
- Service or instance scope.
- Backup type.
- S3 destination name, without access keys.
- Schedule and timezone.
- Retention policy.
- Restore owner.
- Last successful backup check.
- Last restore test date.
- Known restore constraints.

Instance backups are shared control-plane artifacts. Do not duplicate them in org backup files.

## Restore Rules

- Do not start a restore without explicit approval.
- Follow `docs/shared/mutation-safety.md` before restore.
- Before restore, capture current service state, active deployment, domain mapping, and latest backup timestamp.
- For volume restores, stop containers that use the target volume and ensure the target volume does not already exist.
- For Dokploy instance restores, expect `/etc/dokploy` and `dokploy-postgres` to be replaced.
- After restore, verify service health, DNS, Traefik routing, logs, and backup schedule.

## Service Design Rule

When a service needs Dokploy Volume Backups, prefer Docker named volumes over bind mounts. Bind mounts can be useful for simple host-visible files, but they are not covered by Dokploy Volume Backups.
