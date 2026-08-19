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

- Consult Graphify at the reviewed revision before restore and record the
  target CIs and relationships. A canonical `declared` or `verified`
  relationship can orient the restore without mandatory live discovery.
- The agent's external profile decides whether the restore is executed directly,
  requires approval, or remains read-only.
- Follow `docs/shared/mutation-safety.md` before restore.
- Before restore, record evidence, backup posture, blast radius, rollback path,
  and verification plan; use live state as reconciliation evidence when needed.
- For volume restores, stop containers that use the target volume and ensure the target volume does not already exist.
- For Dokploy instance restores, expect `/etc/dokploy` and `dokploy-postgres` to be replaced.
- After restore, verify service health, DNS, Traefik routing, logs, and backup
  schedule, then record a reconciliation observation.

## Service Design Rule

When a service needs Dokploy Volume Backups, prefer Docker named volumes over bind mounts. Bind mounts can be useful for simple host-visible files, but they are not covered by Dokploy Volume Backups.
