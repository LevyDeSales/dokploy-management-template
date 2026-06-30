# Migration Record

| Field | Value |
| --- | --- |
| Date | `<YYYY-MM-DD>` |
| Stack | `<stack>` |
| Previous owner | `Portainer` |
| New owner | `Dokploy` |
| Server | `<NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>` |
| Domain | `<app.seudominio.com>` |
| Backup before cutover | `<backup-id-or-path>` |
| Restore tested | `<yes|no>` |
| Host readiness record | `docs/templates/portainer-vps-agent-readiness.md` |
| Result | `<success|rollback>` |

## Evidence

- HTTP:
- containers:
- logs:
- backup:

## Ownership Freeze

- Portainer stack stopped before Dokploy writes to the same data:
- Dokploy stack started after backup:
- Rollback owner:

## Follow-ups

- [ ] remove or archive old Portainer stack after observation
- [ ] update monitoring
- [ ] verify scheduled backups
