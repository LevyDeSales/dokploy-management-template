# Backups and Restore

Backups are only useful after restore has been tested.

## Backup Scope

| Layer | What to back up |
| --- | --- |
| Dokploy panel | Dokploy database and `/etc/dokploy` |
| Application database | Postgres/MySQL/Mongo dump or volume backup |
| Redis | Snapshot only if data is not disposable |
| Files/uploads | Object storage or volume backup |
| Compose/env shape | `.env.example`, compose examples and runbooks |
| DNS/IaC | Terraform or documented provider state |

## Portainer Host Conversion Evidence

Before converting an existing Portainer VPS into a Dokploy remote server,
record:

- host snapshot or provider backup;
- Portainer data backup;
- compose source for each stack;
- environment variable names without secret values;
- database dumps for stateful services;
- named volume archives;
- bind mount archives;
- restore test result for critical data.

Do not rely on Portainer stack migration or duplication to move persistent
volume contents. Treat data movement as a separate backup and restore task.

## Required Metadata

For each backup, document:

- destination;
- schedule;
- retention;
- encryption model;
- restore command;
- last restore test date;
- owner.

## Restore Test

Minimum restore evidence:

```text
backup id/path:
restore target:
restore date:
checksum or provider metadata:
application validation:
result:
```

## Dokploy Backups

Configure an S3 Destination in Dokploy and create a manual backup before
production. Then enable a schedule.

## Volume Backups

Use Docker named volumes when you want Dokploy volume backups. Bind mounts are
useful for simple files but are less portable.

## Official Docs

- https://docs.dokploy.com/docs/core/backups
- https://docs.dokploy.com/docs/core/volume-backups
