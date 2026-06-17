# Org A Organization

Use this directory for documentation specific to the Org A organization in `https://dokploy.example.com`.

## Operating Context

- CLI wrapper: `scripts/dokploy-cli.sh org-a ...`
- MCP server: Codex MCP server with `args = ["org-a"]`
- Local env var: `DOKPLOY_CONTEXT_ORG_A_API_KEY`

## Files To Add As We Discover State

- `inventory.md`: projects, environments, applications, databases, domains, and servers.
- `servers.md`: server roles, access notes, resource constraints, and maintenance windows.
- `domains.md`: host, path, service, HTTPS, DNS owner, and routing notes.
- `variables.md`: variable names, scopes, purpose, sensitivity, and rotation owner.
- `deployments.md`: deployment source, auto deploy, build server, deployment server, and rollback notes.
- `access.md`: roles, local env vars, and external access notes without secrets.
- `settings/`: Git sources, registries, SSH keys, certificates, S3 destinations, and notifications.
- `decisions.md`: durable operational decisions and rationale.
- `runbooks.md`: context-specific procedures.
- `backups.md`: context-managed service, database, and volume backup and restore notes.
- `projects/`: one directory per discovered Dokploy project.

Start read-only. Mutating operations require explicit confirmation.

Shared Dokploy panel/control-plane backups live in `docs/shared/instance-backups.md`, not in this context directory.

Use `docs/shared/dokploy-reference.md` for the current docs layout and `docs/templates/` when creating project, environment, service, domain, variable, deployment, backup, schedule, integration, server, decision, or runbook docs.
