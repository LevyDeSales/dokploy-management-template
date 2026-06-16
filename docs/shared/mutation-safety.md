# Mutation Safety

This is the canonical preflight rule for all Dokploy-changing operations in this repository.

## Actions Requiring Approval

Get explicit approval before any action that can change live Dokploy state:

- Create, update, rename, move, delete, or archive.
- Deploy, redeploy, rollback, rebuild, restart, start, stop, scale, or cancel deployment.
- Restore, prune, cleanup, remove volume, reset data, or use a danger zone action.
- Change domains, certificates, HTTPS settings, internal path, strip path, DNS, or exposed ports.
- Change environment variables, secrets, build commands, start commands, compose files, mounts, resources, replicas, registry settings, or webhooks.
- Change server setup, SSH, firewall, Docker, Traefik, storage, cleanup, cluster, deployment server, or build server settings.
- Rotate, create, revoke, or copy API keys, SSH keys, registry credentials, S3 credentials, Git source credentials, service tokens, or notification credentials.
- Change user roles, organization access, SSO, custom roles, or audit/logging settings.

## Required Preflight

Before approval is requested, collect and document:

| Field | Required |
| --- | --- |
| Session focus | `alltius`, `zapix`, or `global` |
| Target scope | Organization, project, environment, service, server, or instance |
| Current state | Read-only CLI/MCP/API evidence |
| Backup posture | Latest relevant backup and restore constraints |
| Blast radius | Domains, services, servers, data, and users affected |
| Rollback path | Revert, redeploy previous version, restore, or manual recovery |
| Verification plan | Commands or checks to prove the result |

## Approval Format

Approval should name the action and scope, for example:

```text
Aprovado: redeploy do service api no projeto acme, environment production, org alltius.
```

If approval is broad or ambiguous, narrow the action before mutating state.

## After Mutation

After a mutating operation:

1. Verify the expected state.
2. Check logs, deployment status, domain routing, and backups when relevant.
3. Update the matching docs path.
4. Record decisions separately from inventory.
