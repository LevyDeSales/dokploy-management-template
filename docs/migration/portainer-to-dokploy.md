# Portainer to Dokploy Migration

This playbook migrates stacks gradually from Portainer to Dokploy without
mixing operational ownership.

## Main Rule

```text
One stack has one owner: Portainer or Dokploy.
Never both at the same time.
```

## Choose the Migration Shape

| Shape | Use when | Primary doc |
| --- | --- | --- |
| Stack migration | Only selected Portainer stacks move to Dokploy | This file |
| Existing VPS becomes Dokploy remote server | The Portainer host itself will become the Dokploy deployment server | `docs/migration/portainer-vps-to-dokploy-agent.md` |
| Fresh remote VPS | A new host will receive migrated workloads | `docs/guides/remote-agent-preparation.md` |

This file focuses on stack ownership transfer. If the existing Portainer VPS
must become the remote Dokploy server, complete
`docs/migration/portainer-vps-to-dokploy-agent.md` before registering the server in the
panel.

## Mapping

| Portainer | Dokploy | Notes |
| --- | --- | --- |
| Stack | Project + Docker Compose | Use one project per operational domain or product |
| Stack env | Compose Environment tab | Compose must use `env_file: .env` or `${VAR_NAME}` |
| Docker endpoint | Remote server | Register in inventory |
| Published ports | Domain/Traefik | Prefer domains over public container ports |
| Docker volumes | Named volumes or `../files` | Named volumes are better for volume backups |
| Manual secrets | Password manager + Dokploy env | Never migrate secrets to Git |

## Migration Checklist

1. Select a low-risk stack.
2. Export compose from Portainer.
3. Inventory env vars without copying secret values into Git.
4. Map volumes, databases, Redis and external dependencies.
5. Confirm recent backup.
6. Test restore if data matters.
7. Normalize compose for Dokploy.
8. Create the Dokploy project/compose.
9. Stop or freeze the Portainer stack before any Dokploy workload starts
   against the same production data, volumes, networks or ports.
10. Start the Dokploy stack without public traffic.
11. Cut DNS if needed.
12. Validate HTTP, logs, persistence and backup.
13. Mark the owner as Dokploy.
14. Remove the old Portainer stack after observation.

Pre-cutover Dokploy test starts are allowed only with cloned or snapshot data,
isolated volumes, no shared external Docker networks, and no shared public or
internal ports.

## Rollback

Rollback must be written before cutover:

1. Stop Dokploy stack.
2. Restore data if the new stack wrote to persistent storage.
3. Start Portainer stack.
4. Revert DNS if changed.
5. Validate the public flow.
6. Record the reason.

## Template

Use `docs/templates/migration-record.md`.
