# Zapix Projects

Create one directory per Dokploy project after read-only discovery.

Use `docs/shared/dokploy-reference.md` as the canonical layout.

## Expected Project Layout

```text
docs/orgs/zapix/projects/<project-slug>/
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

Service detail belongs in the environment where the service runs. Project-level files are rollups or indexes.

Use templates from `docs/templates/` when creating project files.
