# Agent Guide

This repository is a public-safe Dokploy operations template. It is designed to
be handed to an AI agent or operator to document, validate, and operate a
self-hosted Dokploy infrastructure without committing secrets or private
runtime state.

## Before Acting

1. Read `README.md`.
2. Read `docs/index.md`.
3. Read `docs/template-setup.md`.
4. Read `docs/dokploy-operations.md`.
5. Read `docs/shared/mutation-safety.md` before any live change.
6. Ask for real values only when needed: Dokploy URL, context names, domain,
   provider, VPS names, SSH user, DNS provider, backup destination, and access
   model.

## Project Scope

- Manage and document one self-hosted Dokploy installation.
- Manage and document the Dokploy organizations or credential contexts exposed
  through that instance.
- Treat servers, projects, environments, applications, compose stacks,
  databases, domains, deployments, backups, schedules, notifications, and
  settings as operations scope.
- Keep repeatable runbooks for Dokploy CLI and MCP usage.
- Use this repository as an operations control plane and documentation base,
  not as an application codebase.

## Rules

- Never ask the user to paste secrets into committed files.
- Never generate real `.env` files in the repo; generate `.env.example` only.
- Never commit `.env.local`, `.codex/config.toml`, private keys, API keys,
  `tfstate`, database dumps, backup archives, raw MCP output, real customer
  names, real hostnames, or real IPs.
- Keep real inventory in `docs/orgs/` only after the repository has been copied
  into a private or intentionally public operations repo.
- Use `examples/orgs/` as scaffolding and examples only.
- Never expose PostgreSQL, Redis, internal dashboards, or application runtime
  ports publicly unless the exposure is intentional and documented.
- If VPSs are not in the same private network or provider, configure a private
  network such as Tailscale before relying on internal connectivity.
- Treat backups as incomplete until restore has been tested.
- When converting a Portainer-managed VPS, inventory stacks, volumes, env var
  names, ownership, backups, and rollback before preparing the host as a
  Dokploy remote server.

## Local Tooling

- CLI wrapper for any context:
  `scripts/dokploy-cli.sh <context> <dokploy command...>`.
- Codex MCP wrapper for any context:
  `scripts/mcp-dokploy-context.sh <context>`.
- Local environment template: `.env.example`.
- Project MCP config example: `.codex/config.toml.example`.
- Repository validation: `scripts/validate-repo.sh`.
- Shell tests: `tests/run.sh`.

## Documentation Architecture

Document Dokploy resources with the same hierarchy used by Dokploy:

```text
Organization -> Project -> Environment -> Service
```

- Context docs live in `docs/orgs/<context-slug>/`.
- Project docs live in `docs/orgs/<context-slug>/projects/<project-slug>/`.
- Service detail lives under
  `docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md`.
- Shared instance and policy docs live in `docs/shared/`.
- Adoption and setup guides live in `docs/guides/`.
- Migration playbooks live in `docs/migration/`.
- Reusable document templates live in `docs/templates/`.
- Public examples live in `examples/`.

Use these context-level files before creating narrower project docs:

- `inventory.md`: read-only resource snapshot.
- `servers.md`: remote servers, build servers, validation, capacity, and
  security posture.
- `domains.md`: domain routing, HTTPS, DNS, path rewrites, and Traefik notes.
- `variables.md`: variable names, scope, purpose, and rotation notes, without
  values.
- `deployments.md`: source, auto deploy, build server, deployment server, and
  rollback notes.
- `backups.md`: context-managed service, database, and volume backup policy and
  restore evidence.
- `access.md`: roles, local env vars, credential references, and external
  access notes, without secrets.
- `runbooks.md`: context-specific operational procedures.
- `decisions.md`: durable context decisions and rationale.
- `settings/`: Git sources, registries, SSH keys, certificates, S3
  destinations, and notifications.

## Session Focus Model

- Use one repository and working directory as the control plane for one
  self-hosted Dokploy instance.
- At the start of operational work, establish one focus: a declared context from
  `DOKPLOY_CONTEXTS`, or `global`.
- For a context focus, use only `scripts/dokploy-cli.sh <context> ...` and the
  matching Codex MCP server unless the user explicitly asks for cross-context
  comparison.
- For `global` focus, read from multiple contexts only when the user explicitly
  asks for cross-context comparison or shared policy work.
- Record context-specific findings and decisions under
  `docs/orgs/<context-slug>/`.
- Do not create separate permanent CWDs per context while contexts share the
  same Dokploy instance and repository configuration.

## Credentials

- `.env.local` is intentionally ignored by Git and is the local source for
  Dokploy credentials.
- Treat `.env.local` as trusted local shell input; do not generate it from
  untrusted data.
- The Dokploy MCP and CLI expect `DOKPLOY_API_KEY`; wrapper scripts map
  context-specific variables into that generic name.
- Context credential variables use
  `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY`.
- The env var value must be the raw API key only, without the visible key label
  or prefix copied from the Dokploy UI.
- IP allowlist or direct private network access is the preferred access path.
  Use `DOKPLOY_CUSTOM_HEADERS` only as a fallback if an access proxy requires
  service-token headers.

## Operating Rules

- Prefer read-only discovery before any mutating operation.
- Follow `docs/shared/mutation-safety.md` before any mutating operation.
- Before destructive operations, collect current organization, project,
  environment, service, server, and backup state.
- Keep MCP redaction enabled with `DOKPLOY_REDACT_ENV=true`.
- Use official Dokploy docs and Swagger before assuming API or CLI command
  shape.
- Document important findings, inventory decisions, and operational procedures
  in `docs/`.
- Use `docs/templates/` when adding project, environment, service, domain,
  variable, deployment, backup, schedule, integration, server, decision, or
  runbook docs.
- Do not store secret values in docs; document only variable names, purpose,
  owner, rotation notes, and sensitivity.
