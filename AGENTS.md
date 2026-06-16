# AGENTS.md

This repository is the Git-tracked operations and documentation workspace for our self-hosted Dokploy.

## Project Scope

- Manage and document the Alltius Dokploy installation at `https://dokploy.alltius.dev`.
- Manage and document the Dokploy organizations available through this instance, currently `Alltius` and `Zapix`.
- Treat servers, projects, environments, applications, databases, domains, deployments, backups, and notifications managed by those organizations as part of this operations scope.
- Keep repeatable runbooks for Dokploy CLI and MCP usage.
- Treat this repository as an operations control plane and documentation base, not as an application codebase.

## Dokploy Targets

- Self-hosted panel: `https://dokploy.alltius.dev`
- Swagger/API reference: `https://dokploy.alltius.dev/swagger`

## Official Documentation

- GitHub: `https://github.com/Dokploy`
- Core: `https://docs.dokploy.com/docs/core`
- CLI: `https://docs.dokploy.com/docs/cli`
- API: `https://docs.dokploy.com/docs/api`
- Templates: `https://docs.dokploy.com/docs/templates`

## Local Tooling

- CLI wrapper for Alltius: `scripts/dokploy-cli.sh alltius <dokploy command...>`
- CLI wrapper for Zapix: `scripts/dokploy-cli.sh zapix <dokploy command...>`
- Codex MCP server for Alltius: `dokploy-alltius-org-alltius`
- Codex MCP server for Zapix: `dokploy-alltius-org-zapix`
- Project MCP config: `.codex/config.toml`
- Operations runbook: `docs/dokploy-operations.md`

## Credentials

- Do not commit real API keys, optional Cloudflare Access secrets, `.env`, `.env.local`, or command output containing secrets.
- `.env.local` is intentionally ignored by Git and is the local source for Dokploy credentials.
- Credential label `dokploy-alltius-org-Alltius` maps to local env var `DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY`.
- Credential label `dokploy-alltius-org-Zapix` maps to local env var `DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY`.
- The env var value must be the raw API key only, without the visible key label or prefix copied from the Dokploy UI.
- The Dokploy MCP and CLI expect `DOKPLOY_API_KEY`; use wrapper scripts to map organization-specific variables into that generic name.
- IP allowlist is the primary access path. Use `DOKPLOY_ALLTIUS_CUSTOM_HEADERS` only as a fallback if Cloudflare Access requires a service token.

## Operating Rules

- Prefer read-only discovery before any mutating operation.
- Confirm before create, update, delete, deploy, redeploy, restart, stop, rollback, prune, rebuild, or credential rotation.
- Before destructive operations, collect current organization, project, environment, service, server, and backup state.
- Keep MCP redaction enabled with `DOKPLOY_REDACT_ENV=true`.
- Use official Dokploy docs and Swagger before assuming API or CLI command shape.
- Document important findings, inventory decisions, and operational procedures in `docs/`.
