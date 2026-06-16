# Dokploy CLI + MCP Alltius Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure this workspace as the operational and documentation control point for managing the Alltius self-hosted Dokploy instance through both the Dokploy CLI and the Dokploy MCP server.

**Architecture:** Use the Dokploy CLI for deterministic human/scripted operations and Dokploy MCP for Codex-assisted inspection and orchestration. Keep Dokploy secrets outside tracked files by forwarding named local environment variables into small wrapper scripts that map each organization credential to the generic `DOKPLOY_API_KEY` expected by Dokploy tools.

**Tech Stack:** Node.js 22, npm 11, `@dokploy/cli`, `@dokploy/mcp`, Codex `.codex/config.toml`, local shell environment.

---

## Current Context

- Workspace: `/home/imac/all-projects/Dokploy-Alltius`
- Git: not initialized yet.
- Node: available locally.
- npm: available locally.
- Dokploy CLI: not currently found on `PATH`.
- Dokploy MCP source: `https://github.com/Dokploy/mcp`
- Dokploy CLI source: `https://github.com/Dokploy/cli`
- T3code env check: `/home/imac/all-projects/T3code` exists, but no `.env` or `.env.*` file was present during planning.
- Public self-hosted URL check after IP allowlist: `https://dokploy.alltius.dev` responds with HTTP 200. `https://dokploy.alltius.dev/swagger` redirects to `/`.
- Credential check on 2026-06-16: `dokploy-alltius-org-Alltius` and `dokploy-alltius-org-Zapix` validate against `/api/trpc/user.get` when the local env vars contain the raw API key value without the UI label/prefix.

## Operating Decisions

- Keep this workspace as a small operations repo/runbook, not a fork of Dokploy CLI or MCP.
- Use project-scoped Codex MCP config at `.codex/config.toml` once this directory is initialized as a trusted project.
- Create `AGENTS.md` using the Codex `/init` intent: this is a project for management and management documentation of our Alltius Dokploy.
- Do not store Dokploy API keys in Git.
- Prefer shell environment or a local ignored `.env` for CLI usage.
- Keep organization credentials named explicitly and map them to `DOKPLOY_API_KEY` only inside wrapper scripts.
- Start MCP with a filtered tool set instead of loading all Dokploy tools on day one.
- Enable MCP response redaction with `DOKPLOY_REDACT_ENV=true`.

## Official Links

- Dokploy GitHub: `https://github.com/Dokploy`
- Dokploy core docs: `https://docs.dokploy.com/docs/core`
- Dokploy CLI docs: `https://docs.dokploy.com/docs/cli`
- Dokploy API docs: `https://docs.dokploy.com/docs/api`
- Dokploy templates docs: `https://docs.dokploy.com/docs/templates`

## Alltius Dokploy Links

- Self-hosted panel: `https://dokploy.alltius.dev`
- Swagger: `https://dokploy.alltius.dev/swagger`

## Required Values From Alltius And Zapix

Capture these values out-of-band before execution:

- `DOKPLOY_ALLTIUS_URL`: `https://dokploy.alltius.dev`
- Credential label `dokploy-alltius-org-Alltius`: stored locally as `DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY`
- Credential label `dokploy-alltius-org-Zapix`: stored locally as `DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY`
- Store only the raw API key value in these variables. Do not include labels such as `my_agent`, `my-agent`, `dokploy-alltius-org-Alltius`, or `dokploy-alltius-org-Zapix`.
- Optional Cloudflare Access headers, only if IP allowlist stops being sufficient: stored locally as `DOKPLOY_ALLTIUS_CUSTOM_HEADERS`
- `DOKPLOY_ALLTIUS_CUSTOM_HEADERS` format:

```json
{"CF-Access-Client-Id":"client-id.access","CF-Access-Client-Secret":"client-secret"}
```

## File Map

- Create: `.gitignore`
  - Keeps local env files and temporary operation output out of Git.
- Create: `.env.example`
  - Documents required Dokploy environment variables without real secrets.
- Create: `AGENTS.md`
  - Stores durable Codex instructions for this operations/documentation project.
- Create: `.codex/config.toml`
  - Adds project-scoped Dokploy MCP servers for Alltius and Zapix organization credentials.
- Create: `README.md`
  - Gives operators a short runbook for CLI auth, MCP validation, and safe usage.
- Create: `scripts/mcp-dokploy-alltius-org-alltius.sh`
  - Starts Dokploy MCP using the Alltius organization credential.
- Create: `scripts/mcp-dokploy-alltius-org-zapix.sh`
  - Starts Dokploy MCP using the Zapix organization credential.
- Create: `scripts/dokploy-cli.sh`
  - Runs Dokploy CLI with `alltius` or `zapix` credential mapping.
- Optional create later: `scripts/dokploy-smoke.sh`
  - Re-runs the standard read-only smoke checks.

---

### Task 1: Initialize Operations Workspace Files

**Files:**
- Create: `.gitignore`
- Create: `.env.example`
- Create: `AGENTS.md`
- Create: `README.md`

- [ ] **Step 1: Create `.gitignore`**

```gitignore
.env
.env.local
.env.*.local
node_modules/
npm-debug.log*
.DS_Store
tmp/
logs/
```

- [ ] **Step 2: Create `.env.example`**

```env
DOKPLOY_ALLTIUS_URL=https://dokploy.alltius.dev

# Credential label: dokploy-alltius-org-Alltius
DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY=

# Credential label: dokploy-alltius-org-Zapix
DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY=

# Optional fallback only when IP allowlist is not sufficient.
DOKPLOY_ALLTIUS_CUSTOM_HEADERS={"CF-Access-Client-Id":"client-id.access","CF-Access-Client-Secret":"client-secret"}
```

- [ ] **Step 3: Create `AGENTS.md`**

```markdown
# AGENTS.md

This repository is the operations and documentation workspace for managing our self-hosted Dokploy instance.

## Project Purpose

- Manage and document the Alltius Dokploy installation.
- Keep repeatable runbooks for Dokploy CLI and MCP usage.
- Prefer read-only discovery before any mutating operation.
- Treat this repository as an operations control plane, not as an application codebase.

## Dokploy Targets

- Self-hosted panel: `https://dokploy.alltius.dev`
- Swagger: `https://dokploy.alltius.dev/swagger`

## Official Documentation

- GitHub: `https://github.com/Dokploy`
- Core: `https://docs.dokploy.com/docs/core`
- CLI: `https://docs.dokploy.com/docs/cli`
- API: `https://docs.dokploy.com/docs/api`
- Templates: `https://docs.dokploy.com/docs/templates`

## Credentials

- Do not commit real API keys, optional Cloudflare Access secrets, `.env`, or command output containing secrets.
- Credential label `dokploy-alltius-org-Alltius` maps to local env var `DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY`.
- Credential label `dokploy-alltius-org-Zapix` maps to local env var `DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY`.
- The env var value must be the raw API key only, without the visible key label or prefix copied from the Dokploy UI.
- The Dokploy MCP and CLI expect `DOKPLOY_API_KEY`; use wrapper scripts to map organization-specific variables into that generic name.
- IP allowlist is the primary access path. Use `DOKPLOY_ALLTIUS_CUSTOM_HEADERS` only as a fallback if Cloudflare Access requires a service token.

## Operating Rules

- Confirm before create, update, delete, deploy, redeploy, restart, stop, rollback, prune, rebuild, or credential rotation.
- Before destructive operations, collect current project/environment/service state.
- Keep MCP redaction enabled with `DOKPLOY_REDACT_ENV=true`.
- Use official Dokploy docs and Swagger before assuming API or CLI command shape.
```

- [ ] **Step 4: Create `README.md`**

````markdown
# Dokploy Alltius Operations

This workspace manages and documents the Alltius self-hosted Dokploy server through:

- Dokploy CLI for explicit terminal operations.
- Dokploy MCP for Codex-assisted workflows.

## Links

- Dokploy GitHub: `https://github.com/Dokploy`
- Core docs: `https://docs.dokploy.com/docs/core`
- CLI docs: `https://docs.dokploy.com/docs/cli`
- API docs: `https://docs.dokploy.com/docs/api`
- Templates docs: `https://docs.dokploy.com/docs/templates`
- Alltius Dokploy: `https://dokploy.alltius.dev`
- Alltius Swagger: `https://dokploy.alltius.dev/swagger`

## Local Environment

Create a local `.env` file or export these variables in the shell:

```bash
export DOKPLOY_ALLTIUS_URL="https://dokploy.alltius.dev"
export DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY="raw-alltius-api-key"
export DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY="raw-zapix-api-key"
# Optional fallback only:
# export DOKPLOY_ALLTIUS_CUSTOM_HEADERS='{"CF-Access-Client-Id":"client-id.access","CF-Access-Client-Secret":"client-secret"}'
```

Do not commit `.env` or tokens.

## CLI Smoke Check

```bash
dokploy --help
scripts/dokploy-cli.sh alltius project all --json
scripts/dokploy-cli.sh zapix project all --json
```

## Codex MCP Smoke Check

Restart Codex after changing `.codex/config.toml`, then run `/mcp` in the TUI and verify `dokploy-alltius-org-alltius` and `dokploy-alltius-org-zapix` are connected.
````

- [ ] **Step 5: Verify files exist**

Run:

```bash
test -f .gitignore && test -f .env.example && test -f AGENTS.md && test -f README.md
```

Expected: command exits with status `0`.

---

### Task 2: Add Credential Mapping Scripts

**Files:**
- Create: `scripts/mcp-dokploy-alltius-org-alltius.sh`
- Create: `scripts/mcp-dokploy-alltius-org-zapix.sh`
- Create: `scripts/dokploy-cli.sh`

- [ ] **Step 1: Create script directory**

Run:

```bash
mkdir -p scripts
```

- [ ] **Step 2: Create `scripts/mcp-dokploy-alltius-org-alltius.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

export DOKPLOY_URL="${DOKPLOY_ALLTIUS_URL:-https://dokploy.alltius.dev}"
export DOKPLOY_API_KEY="${DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY:?DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY is required}"
export DOKPLOY_CUSTOM_HEADERS="${DOKPLOY_ALLTIUS_CUSTOM_HEADERS:-}"
export DOKPLOY_ENABLED_TAGS="${DOKPLOY_ENABLED_TAGS:-project,environment,application,compose,domain,deployment,postgres,redis,server,settings,backup,notification,organization}"
export DOKPLOY_REDACT_ENV="${DOKPLOY_REDACT_ENV:-true}"
export DOKPLOY_TIMEOUT="${DOKPLOY_TIMEOUT:-30000}"
export DOKPLOY_RETRY_ATTEMPTS="${DOKPLOY_RETRY_ATTEMPTS:-2}"
export DOKPLOY_RETRY_DELAY="${DOKPLOY_RETRY_DELAY:-1000}"

exec npx -y --package @dokploy/mcp@latest dokploy-mcp
```

- [ ] **Step 3: Create `scripts/mcp-dokploy-alltius-org-zapix.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

export DOKPLOY_URL="${DOKPLOY_ALLTIUS_URL:-https://dokploy.alltius.dev}"
export DOKPLOY_API_KEY="${DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY:?DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY is required}"
export DOKPLOY_CUSTOM_HEADERS="${DOKPLOY_ALLTIUS_CUSTOM_HEADERS:-}"
export DOKPLOY_ENABLED_TAGS="${DOKPLOY_ENABLED_TAGS:-project,environment,application,compose,domain,deployment,postgres,redis,server,settings,backup,notification,organization}"
export DOKPLOY_REDACT_ENV="${DOKPLOY_REDACT_ENV:-true}"
export DOKPLOY_TIMEOUT="${DOKPLOY_TIMEOUT:-30000}"
export DOKPLOY_RETRY_ATTEMPTS="${DOKPLOY_RETRY_ATTEMPTS:-2}"
export DOKPLOY_RETRY_DELAY="${DOKPLOY_RETRY_DELAY:-1000}"

exec npx -y --package @dokploy/mcp@latest dokploy-mcp
```

- [ ] **Step 4: Create `scripts/dokploy-cli.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: scripts/dokploy-cli.sh <alltius|zapix> <dokploy command...>" >&2
  exit 2
fi

org="$1"
shift

export DOKPLOY_URL="${DOKPLOY_ALLTIUS_URL:-https://dokploy.alltius.dev}"
export DOKPLOY_CUSTOM_HEADERS="${DOKPLOY_ALLTIUS_CUSTOM_HEADERS:-}"

case "$org" in
  alltius)
    export DOKPLOY_API_KEY="${DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY:?DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY is required}"
    ;;
  zapix)
    export DOKPLOY_API_KEY="${DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY:?DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY is required}"
    ;;
  *)
    echo "Unknown org '$org'. Use 'alltius' or 'zapix'." >&2
    exit 2
    ;;
esac

exec dokploy "$@"
```

- [ ] **Step 5: Make scripts executable**

Run:

```bash
chmod +x scripts/mcp-dokploy-alltius-org-alltius.sh scripts/mcp-dokploy-alltius-org-zapix.sh scripts/dokploy-cli.sh
```

- [ ] **Step 6: Verify scripts fail closed when credentials are absent**

Run:

```bash
env -u DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY scripts/dokploy-cli.sh alltius project all --json
```

Expected: command exits non-zero with `DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY is required`.

---

### Task 3: Install And Validate Dokploy CLI

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Install CLI globally**

Run:

```bash
npm install -g @dokploy/cli@latest
```

Expected: npm completes without errors.

- [ ] **Step 2: Verify CLI command is available**

Run:

```bash
dokploy --help
```

Expected: help output lists Dokploy command groups such as `project`, `application`, `compose`, and `postgres`.

- [ ] **Step 3: Authenticate using local environment**

Preferred:

```bash
scripts/dokploy-cli.sh alltius project all --json
scripts/dokploy-cli.sh zapix project all --json
```

Alternative:

```bash
DOKPLOY_API_KEY="$DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY" dokploy auth -u "$DOKPLOY_ALLTIUS_URL" -t "$DOKPLOY_API_KEY"
DOKPLOY_API_KEY="$DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY" dokploy auth -u "$DOKPLOY_ALLTIUS_URL" -t "$DOKPLOY_API_KEY"
```

Expected: JSON list of projects or an empty JSON list if the token has access but no projects exist.

- [ ] **Step 4: Document first successful read-only check**

Append to `README.md`:

```markdown
## Last Known Read-only Check

- Command: `scripts/dokploy-cli.sh alltius project all --json`
- Command: `scripts/dokploy-cli.sh zapix project all --json`
- Expected status: successful API response from Alltius Dokploy.
- Token scope: read access confirmed for project listing.
```

---

### Task 4: Add Project-scoped Codex MCP Config

**Files:**
- Create: `.codex/config.toml`

- [ ] **Step 1: Create `.codex/config.toml`**

```toml
[mcp_servers.dokploy-alltius-org-alltius]
command = "scripts/mcp-dokploy-alltius-org-alltius.sh"
env_vars = [
  "DOKPLOY_ALLTIUS_URL",
  "DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY",
  "DOKPLOY_ALLTIUS_CUSTOM_HEADERS"
]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "prompt"
enabled = true

[mcp_servers.dokploy-alltius-org-zapix]
command = "scripts/mcp-dokploy-alltius-org-zapix.sh"
env_vars = [
  "DOKPLOY_ALLTIUS_URL",
  "DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY",
  "DOKPLOY_ALLTIUS_CUSTOM_HEADERS"
]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "prompt"
enabled = true
```

- [ ] **Step 2: Restart Codex**

Close and reopen Codex in `/home/imac/all-projects/Dokploy-Alltius`.

Expected: Codex loads project-scoped `.codex/config.toml` because this project is trusted.

- [ ] **Step 3: Verify MCP server is visible**

Run in the Codex TUI:

```text
/mcp
```

Expected: `dokploy-alltius-org-alltius` and `dokploy-alltius-org-zapix` appear as active MCP servers.

- [ ] **Step 4: Run read-only MCP smoke checks**

Ask Codex to list Dokploy projects and environments using each MCP server.

Expected: MCP returns project/environment data without exposing secret-bearing fields.

---

### Task 5: Define Safe Operating Policy

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add operating policy**

Append to `README.md`:

```markdown
## Operating Policy

- Read-only checks can run directly: project list, environment list, deployment history, server status.
- Mutating actions require explicit confirmation: create, update, delete, deploy, redeploy, stop, restart, rollback.
- Destructive or broad actions require a backup/status check first: delete resources, prune Docker, database rebuild, password rotation.
- Use CLI for exact one-off commands.
- Use MCP for investigation, multi-step planning, and assisted orchestration.
- Keep `DOKPLOY_REDACT_ENV=true` for MCP sessions.
- Use `dokploy-alltius-org-Alltius` for the Alltius organization credential.
- Use `dokploy-alltius-org-Zapix` for the Zapix organization credential.
```

- [ ] **Step 2: Verify no secrets were written**

Run:

```bash
grep -R "my-agent\\|my_agent\\|DOKPLOY_ALLTIUS_ORG_.*=." .env.example README.md AGENTS.md .codex scripts
```

Expected: no real API token appears in tracked files. `.env.example` may contain empty env var declarations only.

---

### Task 6: Optional Automation Script

**Files:**
- Create: `scripts/dokploy-smoke.sh`

- [ ] **Step 1: Create script directory**

Run:

```bash
mkdir -p scripts
```

- [ ] **Step 2: Create `scripts/dokploy-smoke.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

: "${DOKPLOY_URL:?DOKPLOY_URL is required}"
: "${DOKPLOY_API_KEY:?DOKPLOY_API_KEY is required}"

dokploy project all --json >/tmp/dokploy-alltius-projects.json
echo "Dokploy project listing succeeded."
```

- [ ] **Step 3: Make it executable**

Run:

```bash
chmod +x scripts/dokploy-smoke.sh
```

- [ ] **Step 4: Run smoke check**

Run:

```bash
scripts/dokploy-smoke.sh
```

Expected: `Dokploy project listing succeeded.`

---

## Verification Matrix

- CLI installed: `dokploy --help` succeeds.
- CLI auth works: `scripts/dokploy-cli.sh alltius project all --json` and `scripts/dokploy-cli.sh zapix project all --json` return valid JSON.
- Codex MCP configured: `/mcp` shows `dokploy-alltius-org-alltius` and `dokploy-alltius-org-zapix`.
- MCP auth works: read-only project listing succeeds through both MCP servers.
- Secret handling is clean: no real `DOKPLOY_API_KEY` is committed or printed.
- Tool noise is limited: MCP starts with filtered tags instead of every Dokploy category.
- Cloudflare Access fallback works only if needed: requests succeed when `DOKPLOY_ALLTIUS_CUSTOM_HEADERS` contains valid service-token headers.

## Execution Order

1. Create workspace files.
2. Add credential mapping scripts.
3. Install and validate CLI.
4. Add Codex MCP config.
5. Restart Codex and run MCP smoke checks.
6. Add optional smoke script after the first successful CLI call.

## Sources

- Dokploy GitHub: `https://github.com/Dokploy`
- Dokploy core docs: `https://docs.dokploy.com/docs/core`
- Dokploy CLI docs: `https://docs.dokploy.com/docs/cli`
- Dokploy API docs: `https://docs.dokploy.com/docs/api`
- Dokploy templates docs: `https://docs.dokploy.com/docs/templates`
- Dokploy CLI README: `https://github.com/Dokploy/cli`
- Dokploy MCP README: `https://github.com/Dokploy/mcp`
- Codex MCP configuration: OpenAI Codex manual, Model Context Protocol section.
