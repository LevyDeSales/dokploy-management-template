# Dokploy Reference Map

This file is the canonical map from official Dokploy concepts to this repository's documentation layout.

## Official Sources

- Core docs: `https://docs.dokploy.com/docs/core`
- Architecture: `https://docs.dokploy.com/docs/core/architecture`
- Multi-tenancy: `https://docs.dokploy.com/docs/core/multi-tenancy`
- Variables: `https://docs.dokploy.com/docs/core/variables`
- Domains: `https://docs.dokploy.com/docs/core/domains`
- Applications: `https://docs.dokploy.com/docs/core/applications`
- Docker Compose: `https://docs.dokploy.com/docs/core/docker-compose`
- Databases: `https://docs.dokploy.com/docs/core/databases`
- Remote servers: `https://docs.dokploy.com/docs/core/remote-servers`
- Remote server security: `https://docs.dokploy.com/docs/core/remote-servers/security`
- Backups: `https://docs.dokploy.com/docs/core/backups`
- Volume backups: `https://docs.dokploy.com/docs/core/volume-backups`
- Schedule jobs: `https://docs.dokploy.com/docs/core/schedule-jobs`

## Resource Hierarchy

Dokploy resources should be documented using the same hierarchy used by Dokploy:

```text
Organization
  Project
    Environment
      Service
```

## Local Mapping

| Dokploy concept | Local documentation path |
| --- | --- |
| Shared Dokploy instance | `docs/shared/instance.md` |
| Shared instance backups | `docs/shared/instance-backups.md` |
| Canonical mutation rules | `docs/shared/mutation-safety.md` |
| Organization/context | `docs/orgs/<context-slug>/README.md` |
| Context inventory | `docs/orgs/<context-slug>/inventory.md` |
| Context settings | `docs/orgs/<context-slug>/settings/` |
| Servers | `docs/orgs/<context-slug>/servers.md` |
| Context domains rollup | `docs/orgs/<context-slug>/domains.md` |
| Context variables rollup | `docs/orgs/<context-slug>/variables.md` |
| Context deployments rollup | `docs/orgs/<context-slug>/deployments.md` |
| Context service/database/volume backups | `docs/orgs/<context-slug>/backups.md` |
| Project | `docs/orgs/<context-slug>/projects/<project-slug>/README.md` |
| Project cross-environment service index | `docs/orgs/<context-slug>/projects/<project-slug>/services.md` |
| Project shared variables | `docs/orgs/<context-slug>/projects/<project-slug>/variables.md` |
| Project domain rollup | `docs/orgs/<context-slug>/projects/<project-slug>/domains.md` |
| Environment | `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/README.md` |
| Environment service | `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md` |
| Environment domains | `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/domains.md` |
| Environment variables | `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/variables.md` |
| Environment deployments | `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/deployments.md` |
| Environment backups | `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/backups.md` |
| Environment schedules | `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/schedules.md` |
| Environment decisions | `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/decisions.md` |

## Project Layout

Use this layout for each discovered Dokploy project:

```text
docs/orgs/<context-slug>/projects/<project-slug>/
  README.md
  services.md
  domains.md
  variables.md
  deployments.md
  backups.md
  decisions.md
  environments/
    <environment-slug>/
      README.md
      services/
        <service-slug>.md
      domains.md
      variables.md
      deployments.md
      backups.md
      schedules.md
      decisions.md
```

The environment-level service file is the source of detail for a service. Project and context files are rollups or indexes.

## Cross-Cutting Resources

Some Dokploy resources are not owned cleanly by a single project. Keep these at context or shared level:

| Resource | Path |
| --- | --- |
| Git sources | `docs/orgs/<context-slug>/settings/git-sources.md` |
| Registries | `docs/orgs/<context-slug>/settings/registries.md` |
| SSH keys | `docs/orgs/<context-slug>/settings/ssh-keys.md` |
| Certificates | `docs/orgs/<context-slug>/settings/certificates.md` |
| S3 destinations | `docs/orgs/<context-slug>/settings/s3-destinations.md` |
| Notifications | `docs/orgs/<context-slug>/settings/notifications.md` |
| Naming policy | `docs/shared/naming-conventions.md` |
| Domain policy | `docs/shared/domain-policy.md` |
| Variable policy | `docs/shared/variable-policy.md` |
| Backup policy | `docs/shared/backup-policy.md` |
| Server security baseline | `docs/shared/server-security.md` |
| Incident response | `docs/shared/incident-runbook.md` |

## Provenance Rule

The live Dokploy panel and API remain the operational source of truth. This repository is the reviewed operations record: inventory snapshots, decisions, runbooks, naming rules, and restore evidence.

When documenting live state, include:

- Dokploy ID when available.
- Slug or normalized docs path.
- `observed_at` or last observed date.
- Source command/tool.
- Docs path.
- Redaction review status when command output was used.
