# Zapix Organization

Use this directory for documentation specific to the Zapix organization in `https://dokploy.alltius.dev`.

## Operating Context

- CLI wrapper: `scripts/dokploy-cli.sh zapix ...`
- MCP server: `dokploy-alltius-org-zapix`
- Credential label: `dokploy-alltius-org-Zapix`
- Local env var: `DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY`

## Files To Add As We Discover State

- `inventory.md`: projects, environments, applications, databases, domains, and servers.
- `servers.md`: server roles, access notes, resource constraints, and maintenance windows.
- `domains.md`: host, path, service, HTTPS, DNS owner, and routing notes.
- `variables.md`: variable names, scopes, purpose, sensitivity, and rotation owner.
- `deployments.md`: deployment source, auto deploy, build server, deployment server, and rollback notes.
- `access.md`: roles, credential labels, and external access notes without secrets.
- `settings/`: Git sources, registries, SSH keys, certificates, S3 destinations, and notifications.
- `decisions.md`: durable operational decisions and rationale.
- `runbooks.md`: org-specific procedures.
- `backups.md`: org-managed service, database, and volume backup and restore notes.
- `projects/`: one directory per discovered Dokploy project.

Start read-only. Mutating operations require explicit confirmation.

Shared Dokploy panel/control-plane backups live in `docs/shared/instance-backups.md`, not in this org directory.

Use `docs/shared/dokploy-reference.md` for the current docs layout and `docs/templates/` when creating project, environment, service, domain, variable, deployment, backup, schedule, integration, server, decision, or runbook docs.
