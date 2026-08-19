# Shared Dokploy Operations

Use this directory for cross-context and Dokploy instance-level documentation.

## Scope

- Shared backup policy.
- Shared naming conventions.
- Cross-context incident response.
- Dokploy instance-level maintenance.
- Procedures that apply to multiple declared contexts.

Use `global` session focus when editing this directory from live Dokploy state.

## Files

- `dokploy-reference.md`: mapping from official Dokploy concepts to local docs.
- `instance.md`: shared self-hosted Dokploy control plane.
- `instance-backups.md`: shared Dokploy panel/control-plane backup and restore evidence.
- `cmdb-policy.md`: canonized CI, relationship, provenance, and reconciliation rules.
- `mutation-safety.md`: canonical graph-first execution and reconciliation rules for live changes.
- `naming-conventions.md`: naming and path rules for contexts, projects, environments, services, backups, and credentials.
- `domain-policy.md`: domain documentation and change rules.
- `variable-policy.md`: variable scoping and no-secret documentation rules.
- `backup-policy.md`: instance, database, and volume backup rules.
- `server-security.md`: remote server security baseline.
- `incident-runbook.md`: cross-context incident response workflow.
