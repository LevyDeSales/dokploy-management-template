# AGENTS.md

This repository is a Git-tracked operations and documentation workspace for a self-hosted Dokploy instance.

## Project Scope

- Manage and document one self-hosted Dokploy installation, using `https://dokploy.example.com` as the placeholder URL.
- Manage and document the Dokploy organizations available through this instance, using `Org A` and `Org B` as example contexts.
- Treat servers, projects, environments, applications, databases, domains, deployments, backups, and notifications managed by those organizations as part of this operations scope.
- Keep repeatable runbooks for Dokploy CLI and MCP usage.
- Treat this repository as an operations control plane and documentation base, not as an application codebase.

## Dokploy Targets

- Self-hosted panel: `https://dokploy.example.com`
- Swagger/API reference: `https://dokploy.example.com/swagger`

## Official Documentation

- GitHub: `https://github.com/Dokploy`
- Core: `https://docs.dokploy.com/docs/core`
- CLI: `https://docs.dokploy.com/docs/cli`
- API: `https://docs.dokploy.com/docs/api`
- Templates: `https://docs.dokploy.com/docs/templates`

## Local Tooling

- CLI wrapper for Org A: `scripts/dokploy-cli.sh org-a <dokploy command...>`
- CLI wrapper for Org B: `scripts/dokploy-cli.sh org-b <dokploy command...>`
- Codex MCP server for Org A: `dokploy-org-a`
- Codex MCP server for Org B: `dokploy-org-b`
- Project MCP config example: `.codex/config.toml.example`
- Operations runbook: `docs/dokploy-operations.md`
- Session and workspace model: `docs/session-workspace-model.md`

## Documentation Architecture

Document Dokploy resources with the same hierarchy used by Dokploy:

```text
Organization -> Project -> Environment -> Service
```

- Organization docs live in `docs/orgs/org-a/` and `docs/orgs/org-b/`.
- Project docs live in `docs/orgs/<org>/projects/<project-slug>/`.
- Service detail lives under `docs/orgs/<org>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md`.
- Shared instance and policy docs live in `docs/shared/`.
- Reusable document templates live in `docs/templates/`.
- The concept map is `docs/shared/dokploy-reference.md`.
- Mutation safety rules live in `docs/shared/mutation-safety.md`.

Use these org-level files before creating narrower project docs:

- `inventory.md`: read-only resource snapshot.
- `servers.md`: remote servers, build servers, validation, capacity, and security posture.
- `domains.md`: domain routing, HTTPS, DNS, path rewrites, and Traefik notes.
- `variables.md`: variable names, scope, purpose, and rotation notes, without values.
- `deployments.md`: source, auto deploy, build server, deployment server, and rollback notes.
- `backups.md`: org-managed service, database, and volume backup policy and restore evidence.
- `access.md`: roles, credential labels, and external access notes, without secrets.
- `runbooks.md`: org-specific operational procedures.
- `decisions.md`: durable org decisions and rationale.
- `settings/`: Git sources, registries, SSH keys, certificates, S3 destinations, and notifications.

Keep shared panel/control-plane docs in `docs/shared/instance.md` and shared panel/control-plane backup evidence in `docs/shared/instance-backups.md`.

## Session Focus Model

- Use this single repository and working directory as the control plane for both organizations.
- At the start of operational work, establish one focus: `org-a`, `org-b`, or `global`.
- For `org-a` focus, use only `scripts/dokploy-cli.sh org-a ...` and MCP server `dokploy-org-a` unless the user explicitly asks for cross-org comparison.
- For `org-b` focus, use only `scripts/dokploy-cli.sh org-b ...` and MCP server `dokploy-org-b` unless the user explicitly asks for cross-org comparison.
- For `global` focus, read from both orgs and document cross-org decisions under `docs/shared/`.
- Record org-specific findings and decisions under `docs/orgs/org-a/` or `docs/orgs/org-b/`.
- Do not create separate permanent CWDs per org while both orgs share the same Dokploy instance and repository configuration.
- Use Git worktrees only for parallel documentation or larger branch work. Do not use worktrees as the normal org-separation mechanism.
- If using a worktree, remember `.env.local` is ignored. Create an untracked `.env.local` inside that worktree with restrictive permissions; never commit copied credentials.

## Credentials

- Do not commit real API keys, optional access proxy secrets, `.env`, `.env.local`, or command output containing secrets.
- `.env.local` is intentionally ignored by Git and is the local source for Dokploy credentials.
- Credential label `dokploy-org-a` maps to local env var `DOKPLOY_CONTEXT_ORG_A_API_KEY`.
- Credential label `dokploy-org-b` maps to local env var `DOKPLOY_CONTEXT_ORG_B_API_KEY`.
- The env var value must be the raw API key only, without the visible key label or prefix copied from the Dokploy UI.
- The Dokploy MCP and CLI expect `DOKPLOY_API_KEY`; use wrapper scripts to map organization-specific variables into that generic name.
- IP allowlist or direct network access is the preferred access path. Use `DOKPLOY_CUSTOM_HEADERS` only as a fallback if an access proxy requires service-token headers.

## Operating Rules

- Prefer read-only discovery before any mutating operation.
- Follow `docs/shared/mutation-safety.md` before any mutating operation.
- Before destructive operations, collect current organization, project, environment, service, server, and backup state.
- Keep MCP redaction enabled with `DOKPLOY_REDACT_ENV=true`.
- Use official Dokploy docs and Swagger before assuming API or CLI command shape.
- Document important findings, inventory decisions, and operational procedures in `docs/`.
- Use `docs/templates/` when adding project, environment, service, domain, variable, deployment, backup, schedule, integration, server, decision, or runbook docs.
- Do not store secret values in docs; document only variable names, purpose, owner, rotation notes, and sensitivity.
