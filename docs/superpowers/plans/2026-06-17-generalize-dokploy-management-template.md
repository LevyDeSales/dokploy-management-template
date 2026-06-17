# Generalize Dokploy Management Template Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the current `template/dokploy-management-template` branch into a public-ready, reusable Dokploy operations template with generic context handling, clear onboarding, and release hygiene checks.

**Architecture:** Keep this repository as a documentation and operations control plane, not an application. Preserve the existing Dokploy hierarchy (`Organization -> Project -> Environment -> Service`) while making `org-a` and `org-b` explicit examples instead of hard-coded assumptions in scripts and MCP configuration.

**Tech Stack:** Bash scripts, Markdown documentation, Codex MCP project config, Dokploy CLI via `npx -y @dokploy/cli@latest`, Dokploy MCP via `npx -y --package @dokploy/mcp@latest dokploy-mcp`.

---

## Target File Structure

- Modify: `scripts/dokploy-context.sh`
  - Responsibility: normalize and resolve any declared Dokploy context to `DOKPLOY_API_KEY`.
- Modify: `scripts/dokploy-cli.sh`
  - Responsibility: run Dokploy CLI for any declared context.
- Modify: `scripts/mcp-dokploy-context.sh`
  - Responsibility: run Dokploy MCP for any declared context.
- Delete: `scripts/mcp-dokploy-org-a.sh`
  - Responsibility removed: fixed context wrapper duplicated by generic MCP args.
- Delete: `scripts/mcp-dokploy-org-b.sh`
  - Responsibility removed: fixed context wrapper duplicated by generic MCP args.
- Modify: `.codex/config.toml.example`
  - Responsibility: show two example MCP server entries using `command` plus `args`.
- Modify: `.env.example`
  - Responsibility: document public-safe environment variables and context naming.
- Modify: `AGENTS.md`
  - Responsibility: define repo rules for template users without binding scripts to only two orgs.
- Modify: `README.md`
  - Responsibility: public landing page, quick start, safety model, and repository contents.
- Modify: `docs/template-setup.md`
  - Responsibility: first-run checklist after creating a repository from the template.
- Modify: `docs/dokploy-operations.md`
  - Responsibility: generic operations runbook for any declared context.
- Modify: `docs/session-workspace-model.md`
  - Responsibility: explain focus values as examples plus the generic context model.
- Modify: `docs/shared/naming-conventions.md`
  - Responsibility: document naming rules without treating `org-a` and `org-b` as the only choices.
- Modify: `docs/shared/domain-policy.md`
  - Responsibility: use generic org examples.
- Modify: `docs/shared/instance.md`
  - Responsibility: identify `org-a` and `org-b` as example contexts.
- Modify: `docs/shared/mutation-safety.md`
  - Responsibility: require explicit context names for mutations.
- Modify: `docs/templates/*.md`
  - Responsibility: use `<context-slug>` or `<org-slug>` consistently.
- Create: `tests/run.sh`
  - Responsibility: run all template verification checks.
- Create: `tests/dokploy-context-test.sh`
  - Responsibility: test Bash context normalization and API key resolution.
- Create: `docs/publication-checklist.md`
  - Responsibility: gate public release on secret scanning, setup verification, and repository metadata.

## Task 1: Add Context Script Tests

**Files:**
- Create: `tests/dokploy-context-test.sh`
- Create: `tests/run.sh`

- [ ] **Step 1: Create the failing context tests**

Create `tests/dokploy-context-test.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

failures=0

fail() {
  printf 'not ok - %s\n' "$1" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'ok - %s\n' "$1"
}

assert_eq() {
  local name="$1"
  local actual="$2"
  local expected="$3"

  if [ "$actual" = "$expected" ]; then
    pass "$name"
  else
    fail "$name: expected '$expected', got '$actual'"
  fi
}

reset_dokploy_env() {
  unset DOKPLOY_CONTEXT
  unset DOKPLOY_CONTEXT_ENV
  unset DOKPLOY_CONTEXTS
  unset DOKPLOY_CONTEXT_ORG_A_API_KEY
  unset DOKPLOY_CONTEXT_ORG_B_API_KEY
  unset DOKPLOY_CONTEXT_PROD_API_KEY
  unset DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY
  unset DOKPLOY_CONTEXT_READ_ONLY_API_KEY
  unset DOKPLOY_API_KEY
}

# shellcheck source=../scripts/dokploy-context.sh
source "$PROJECT_ROOT/scripts/dokploy-context.sh"

reset_dokploy_env
assert_eq "normalizes hyphenated context names" "$(normalize_context "customer-prod")" "CUSTOMER_PROD"
assert_eq "normalizes dotted context names" "$(normalize_context "read.only")" "READ_ONLY"

reset_dokploy_env
assert_eq "defaults to example contexts" "$(available_contexts)" "org-a org-b"

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod customer-prod"
if context_is_declared "customer-prod"; then
  pass "finds declared context"
else
  fail "finds declared context"
fi

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod customer-prod"
if context_is_declared "staging"; then
  fail "rejects undeclared context"
else
  pass "rejects undeclared context"
fi

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod customer-prod"
export DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY="raw-test-key"
resolve_dokploy_context "customer-prod"
assert_eq "exports selected context" "$DOKPLOY_CONTEXT" "customer-prod"
assert_eq "exports normalized context name" "$DOKPLOY_CONTEXT_ENV" "CUSTOMER_PROD"
assert_eq "maps selected context API key" "$DOKPLOY_API_KEY" "raw-test-key"

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod"
if resolve_dokploy_context "missing" >/tmp/dokploy-context-test.err 2>&1; then
  fail "unknown context exits nonzero"
else
  assert_eq "unknown context exits with code 2" "$?" "2"
fi

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod"
if resolve_dokploy_context "prod" >/tmp/dokploy-context-test.err 2>&1; then
  fail "missing API key exits nonzero"
else
  assert_eq "missing API key exits with code 2" "$?" "2"
fi

if [ "$failures" -ne 0 ]; then
  printf '%s test failure(s)\n' "$failures" >&2
  exit 1
fi
```

Create `tests/run.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$PROJECT_ROOT"/scripts/*.sh
bash -n "$PROJECT_ROOT"/tests/*.sh

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$PROJECT_ROOT"/scripts/*.sh "$PROJECT_ROOT"/tests/*.sh
fi

"$PROJECT_ROOT/tests/dokploy-context-test.sh"
```

- [ ] **Step 2: Make the test scripts executable**

Run:

```bash
chmod +x tests/dokploy-context-test.sh tests/run.sh
```

- [ ] **Step 3: Run tests and capture the current result**

Run:

```bash
tests/run.sh
```

Expected: the tests may fail before script refactoring if shellcheck is installed and flags existing script issues. Keep the failure output visible for the next task.

- [ ] **Step 4: Commit the failing or baseline tests**

Run:

```bash
git add tests/dokploy-context-test.sh tests/run.sh
git commit -m "test: add dokploy context script checks"
```

## Task 2: Generalize MCP Script Entry Points

**Files:**
- Modify: `scripts/dokploy-context.sh`
- Modify: `scripts/dokploy-cli.sh`
- Modify: `scripts/mcp-dokploy-context.sh`
- Delete: `scripts/mcp-dokploy-org-a.sh`
- Delete: `scripts/mcp-dokploy-org-b.sh`
- Modify: `.codex/config.toml.example`

- [ ] **Step 1: Keep `scripts/dokploy-context.sh` generic and improve usage helpers**

Replace `scripts/dokploy-context.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/dokploy-env.sh
source "$SCRIPT_DIR/dokploy-env.sh"

normalize_context() {
  printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/_/g'
}

available_contexts() {
  if [ -n "${DOKPLOY_CONTEXTS:-}" ]; then
    printf '%s\n' "$DOKPLOY_CONTEXTS"
  else
    printf 'org-a org-b\n'
  fi
}

context_is_declared() {
  local context="$1"
  local declared

  for declared in $(available_contexts); do
    if [ "$declared" = "$context" ]; then
      return 0
    fi
  done

  return 1
}

print_context_usage() {
  local command_name="$1"

  {
    printf 'Usage: %s <context> %s\n' "$command_name" "${2:-}"
    printf 'Available contexts: %s\n' "$(available_contexts)"
    printf 'Context API key variable format: DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY\n'
  } >&2
}

resolve_dokploy_context() {
  local context="$1"
  local normalized
  local key_var
  local key_value

  if ! context_is_declared "$context"; then
    echo "Unknown Dokploy context '$context'. Available contexts: $(available_contexts)" >&2
    return 2
  fi

  normalized="$(normalize_context "$context")"
  key_var="DOKPLOY_CONTEXT_${normalized}_API_KEY"
  key_value="${!key_var:-}"

  if [ -z "$key_value" ]; then
    echo "$key_var is required for Dokploy context '$context'" >&2
    return 2
  fi

  export DOKPLOY_CONTEXT="$context"
  export DOKPLOY_CONTEXT_ENV="$normalized"
  export DOKPLOY_API_KEY="$key_value"
}
```

- [ ] **Step 2: Update CLI usage to use the shared helper**

Replace `scripts/dokploy-cli.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/dokploy-context.sh
source "$SCRIPT_DIR/dokploy-context.sh"

if [ "$#" -lt 2 ]; then
  print_context_usage "scripts/dokploy-cli.sh" "<dokploy command...>"
  exit 2
fi

context="$1"
shift

resolve_dokploy_context "$context"

exec npx -y @dokploy/cli@latest "$@"
```

- [ ] **Step 3: Keep the MCP runner generic**

Replace `scripts/mcp-dokploy-context.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/dokploy-context.sh
source "$SCRIPT_DIR/dokploy-context.sh"

if [ "$#" -ne 1 ]; then
  print_context_usage "scripts/mcp-dokploy-context.sh" ""
  exit 2
fi

resolve_dokploy_context "$1"

export DOKPLOY_ENABLED_TAGS="${DOKPLOY_ENABLED_TAGS:-project,environment,application,compose,domain,deployment,postgres,redis,server,settings,backup,notification,organization}"
export DOKPLOY_REDACT_ENV="${DOKPLOY_REDACT_ENV:-true}"
export DOKPLOY_TIMEOUT="${DOKPLOY_TIMEOUT:-30000}"
export DOKPLOY_RETRY_ATTEMPTS="${DOKPLOY_RETRY_ATTEMPTS:-2}"
export DOKPLOY_RETRY_DELAY="${DOKPLOY_RETRY_DELAY:-1000}"

exec npx -y --package @dokploy/mcp@latest dokploy-mcp
```

- [ ] **Step 4: Remove fixed example wrappers**

Run:

```bash
rm scripts/mcp-dokploy-org-a.sh scripts/mcp-dokploy-org-b.sh
```

- [ ] **Step 5: Update Codex MCP config example to pass context args**

Replace `.codex/config.toml.example` with:

```toml
# Copy this file to `.codex/config.toml` and replace `/absolute/path/to/dokploy-management-template`
# with this repository's absolute path.
#
# Keep `.codex/config.toml` local and untracked because it contains machine-specific paths.
# Add one mcp_servers entry per Dokploy context listed in DOKPLOY_CONTEXTS.

[mcp_servers.dokploy-org-a]
command = "/absolute/path/to/dokploy-management-template/scripts/mcp-dokploy-context.sh"
args = ["org-a"]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "prompt"
enabled = true

[mcp_servers.dokploy-org-b]
command = "/absolute/path/to/dokploy-management-template/scripts/mcp-dokploy-context.sh"
args = ["org-b"]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "prompt"
enabled = true
```

- [ ] **Step 6: Run script tests**

Run:

```bash
tests/run.sh
```

Expected: all tests pass.

- [ ] **Step 7: Commit the generic script entry points**

Run:

```bash
git add scripts/dokploy-context.sh scripts/dokploy-cli.sh scripts/mcp-dokploy-context.sh .codex/config.toml.example
git rm scripts/mcp-dokploy-org-a.sh scripts/mcp-dokploy-org-b.sh
git commit -m "refactor: generalize dokploy context entrypoints"
```

## Task 3: Make Environment Examples Public-Safe

**Files:**
- Modify: `.env.example`
- Modify: `.gitignore`

- [ ] **Step 1: Replace `.env.example` with clearer context guidance**

Replace `.env.example` with:

```bash
# Self-hosted Dokploy panel URL.
DOKPLOY_URL=https://dokploy.example.com

# Space-separated context slugs. Keep names lowercase and shell-friendly.
DOKPLOY_CONTEXTS="org-a org-b"

# Context: org-a
# Store only the raw API key value, without the visible key label or UI prefix.
DOKPLOY_CONTEXT_ORG_A_API_KEY=

# Context: org-b
# Store only the raw API key value, without the visible key label or UI prefix.
DOKPLOY_CONTEXT_ORG_B_API_KEY=

# Add more contexts by appending the slug to DOKPLOY_CONTEXTS and adding a matching
# DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY variable.
# Example: customer-prod -> DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY

# Optional fallback only if IP allowlist or direct panel access is not sufficient.
# DOKPLOY_CUSTOM_HEADERS={"Header-Name":"header-value"}
```

- [ ] **Step 2: Extend `.gitignore` for local generated files**

Ensure `.gitignore` contains:

```gitignore
.env
.env.local
.env.*.local
.codex/config.toml
node_modules/
npm-debug.log*
.DS_Store
tmp/
logs/
```

- [ ] **Step 3: Run secret-oriented checks against tracked examples**

Run:

```bash
rg -n --hidden -S "raw-[a-z-]*api-key|DOKPLOY_CONTEXT_.*=.*[A-Za-z0-9_-]{16,}|PRIVATE KEY|BEGIN RSA|password|secret|token" .env.example .codex/config.toml.example README.md AGENTS.md docs scripts
```

Expected: the command may print instructional mentions of `secret` or `token`; it must not print real credential values, private keys, or non-example API keys.

- [ ] **Step 4: Commit public-safe environment examples**

Run:

```bash
git add .env.example .gitignore
git commit -m "docs: clarify public-safe dokploy environment setup"
```

## Task 4: Rewrite Public Entry Documentation

**Files:**
- Modify: `README.md`
- Modify: `docs/template-setup.md`

- [ ] **Step 1: Replace the README introduction and quick start**

Replace `README.md` with:

```markdown
# Dokploy Management Template

This repository is a public template for managing and documenting a self-hosted Dokploy instance with Git-tracked runbooks, local CLI wrappers, and Codex MCP context entries.

It is an operations control plane, not an application codebase. Store live credentials only in local ignored files.

## What This Gives You

- A repeatable Dokploy CLI wrapper: `scripts/dokploy-cli.sh <context> <dokploy command...>`.
- A repeatable Dokploy MCP wrapper: `scripts/mcp-dokploy-context.sh <context>`.
- Example Codex MCP config in `.codex/config.toml.example`.
- Documentation organized as `Organization -> Project -> Environment -> Service`.
- Shared safety rules for inventory, deployments, backups, domains, variables, and destructive operations.

## Official Dokploy References

- GitHub: `https://github.com/Dokploy`
- Core docs: `https://docs.dokploy.com/docs/core`
- CLI docs: `https://docs.dokploy.com/docs/cli`
- API docs: `https://docs.dokploy.com/docs/api`
- Templates docs: `https://docs.dokploy.com/docs/templates`

## Quick Start

1. Create a new repository from this template.
2. Copy `.env.example` to `.env.local`.
3. Set `DOKPLOY_URL` to your self-hosted Dokploy panel URL.
4. Set `DOKPLOY_CONTEXTS` to your context slugs, for example `prod staging`.
5. Add one raw API key variable per context using `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY`.
6. Copy `.codex/config.toml.example` to `.codex/config.toml`.
7. Replace `/absolute/path/to/dokploy-management-template` with your repository path.
8. Adjust each MCP server `args = ["<context>"]` value to match your contexts.
9. Run read-only checks before documenting live state.

Example `.env.local` shape:

```bash
DOKPLOY_URL=https://dokploy.example.com
DOKPLOY_CONTEXTS="org-a org-b"
DOKPLOY_CONTEXT_ORG_A_API_KEY=
DOKPLOY_CONTEXT_ORG_B_API_KEY=
```

Context normalization uppercases the slug and changes non-alphanumeric characters to `_`.

Examples:

| Context slug | API key variable |
| --- | --- |
| `org-a` | `DOKPLOY_CONTEXT_ORG_A_API_KEY` |
| `customer-prod` | `DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY` |
| `read.only` | `DOKPLOY_CONTEXT_READ_ONLY_API_KEY` |

## Read-Only Smoke Checks

```bash
scripts/dokploy-cli.sh org-a project all --json
scripts/dokploy-cli.sh org-a organization all --json
```

Replace `org-a` with any context listed in `DOKPLOY_CONTEXTS`.

## Codex MCP

Project-scoped MCP config is generated from `.codex/config.toml.example`.

Each Dokploy context should have one MCP server entry:

```toml
[mcp_servers.dokploy-org-a]
command = "/absolute/path/to/dokploy-management-template/scripts/mcp-dokploy-context.sh"
args = ["org-a"]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "prompt"
enabled = true
```

Restart Codex after changes, then run `/mcp` in the TUI and verify the servers are connected.

## Working Model

Start operational work by declaring one focus:

```text
Foco desta sessão: org-a
Objetivo: inventariar projetos e ambientes.
Somente leitura até eu aprovar mutações.
```

Use one repository and one normal working directory as the control plane for all contexts on the same Dokploy instance. Separate work by focus, wrapper command, MCP server, and documentation path.

Use Git worktrees only for parallel documentation or larger branch work.

## Documentation Map

- Agent/project instructions: `AGENTS.md`
- Template setup: `docs/template-setup.md`
- Operations runbook: `docs/dokploy-operations.md`
- Session/workspace model: `docs/session-workspace-model.md`
- Dokploy concept map: `docs/shared/dokploy-reference.md`
- Shared instance docs: `docs/shared/instance.md`
- Mutation safety rules: `docs/shared/mutation-safety.md`
- Example org docs: `docs/orgs/org-a/` and `docs/orgs/org-b/`
- Shared docs: `docs/shared/`
- Reusable templates: `docs/templates/`

Service detail belongs under the environment where the service runs:

```text
docs/orgs/<context-slug>/projects/<project-slug>/environments/<environment-slug>/services/<service-slug>.md
```

Copy from `docs/templates/` for new project, environment, service, domain, variable, deployment, backup, schedule, integration, server, decision, and runbook files.

## Safety

- Do not commit `.env.local`, real API keys, service-token headers, private keys, or command output containing secrets.
- Keep `DOKPLOY_REDACT_ENV=true` for MCP sessions.
- Prefer read-only discovery before any mutating operation.
- Follow `docs/shared/mutation-safety.md` before destructive or state-changing work.
- Use official Dokploy docs and your panel Swagger page before assuming CLI or API shape.
```

- [ ] **Step 2: Replace template setup checklist**

Replace `docs/template-setup.md` with:

```markdown
# Template Setup

Use this checklist after creating a repository from this template.

## 1. Configure Local Secrets

Copy `.env.example` to `.env.local`:

```bash
cp .env.example .env.local
chmod 600 .env.local
```

Edit `.env.local`:

```bash
DOKPLOY_URL=https://dokploy.example.com
DOKPLOY_CONTEXTS="org-a org-b"
DOKPLOY_CONTEXT_ORG_A_API_KEY=
DOKPLOY_CONTEXT_ORG_B_API_KEY=
```

Store only raw API key values. Do not commit `.env.local`.

## 2. Rename Or Add Contexts

If your real contexts are not `org-a` and `org-b`:

1. Update `DOKPLOY_CONTEXTS`.
2. Add matching `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY` variables.
3. Rename or duplicate directories under `docs/orgs/`.
4. Update the MCP server names and `args` in `.codex/config.toml`.

Context normalization uppercases names and changes non-alphanumeric characters to `_`.

Examples:

| Context slug | API key variable |
| --- | --- |
| `customer-prod` | `DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY` |
| `read.only` | `DOKPLOY_CONTEXT_READ_ONLY_API_KEY` |

## 3. Configure MCP

Copy `.codex/config.toml.example` to `.codex/config.toml`:

```bash
cp .codex/config.toml.example .codex/config.toml
```

Replace `/absolute/path/to/dokploy-management-template` with this repository's absolute path.

Each context needs one MCP server entry:

```toml
[mcp_servers.dokploy-org-a]
command = "/absolute/path/to/dokploy-management-template/scripts/mcp-dokploy-context.sh"
args = ["org-a"]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "prompt"
enabled = true
```

Keep `.codex/config.toml` untracked because it contains local paths.

## 4. Verify Read-Only Access

Run:

```bash
scripts/dokploy-cli.sh org-a project all --json
scripts/dokploy-cli.sh org-a organization all --json
```

Replace `org-a` with each context listed in `DOKPLOY_CONTEXTS`.

Only update inventories after read-only checks work.

## 5. Verify Git Safety

Run:

```bash
git check-ignore -v .env.local .codex/config.toml
tests/run.sh
```

Expected: `.env.local` and `.codex/config.toml` are ignored, and local tests pass.
```

- [ ] **Step 3: Run Markdown search for obsolete fixed wrappers**

Run:

```bash
rg -n "mcp-dokploy-org-a|mcp-dokploy-org-b|dokploy-example-org-a|dokploy-example-org-b" README.md docs AGENTS.md .codex/config.toml.example
```

Expected: no matches after all documentation tasks are complete.

- [ ] **Step 4: Commit public entry documentation**

Run:

```bash
git add README.md docs/template-setup.md
git commit -m "docs: rewrite public template quick start"
```

## Task 5: Generalize Agent And Operations Docs

**Files:**
- Modify: `AGENTS.md`
- Modify: `docs/dokploy-operations.md`
- Modify: `docs/session-workspace-model.md`
- Modify: `docs/shared/naming-conventions.md`
- Modify: `docs/shared/domain-policy.md`
- Modify: `docs/shared/instance.md`
- Modify: `docs/shared/mutation-safety.md`

- [ ] **Step 1: Update `AGENTS.md` tooling and focus rules**

Edit `AGENTS.md` so these sections use generic context language:

```markdown
## Local Tooling

- CLI wrapper for any context: `scripts/dokploy-cli.sh <context> <dokploy command...>`
- Codex MCP wrapper for any context: `scripts/mcp-dokploy-context.sh <context>`
- Example contexts: `org-a` and `org-b`
- Project MCP config example: `.codex/config.toml.example`
- Operations runbook: `docs/dokploy-operations.md`
- Session and workspace model: `docs/session-workspace-model.md`
```

```markdown
## Session Focus Model

- Use this single repository and working directory as the control plane for one self-hosted Dokploy instance.
- At the start of operational work, establish one focus: a declared context from `DOKPLOY_CONTEXTS`, or `global`.
- For a context focus, use only `scripts/dokploy-cli.sh <context> ...` and the matching Codex MCP server unless the user explicitly asks for cross-context comparison.
- For `global` focus, read from multiple contexts only when the user explicitly asks for cross-context comparison or shared policy work.
- Record context-specific findings and decisions under `docs/orgs/<context-slug>/`.
- Do not create separate permanent CWDs per context while contexts share the same Dokploy instance and repository configuration.
```

```markdown
## Credentials

- Do not commit real API keys, optional access proxy secrets, `.env`, `.env.local`, or command output containing secrets.
- `.env.local` is intentionally ignored by Git and is the local source for Dokploy credentials.
- The Dokploy MCP and CLI expect `DOKPLOY_API_KEY`; use wrapper scripts to map context-specific variables into that generic name.
- Context credential variables use `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY`.
- The env var value must be the raw API key only, without the visible key label or prefix copied from the Dokploy UI.
- IP allowlist or direct network access is the preferred access path. Use `DOKPLOY_CUSTOM_HEADERS` only as a fallback if an access proxy requires service-token headers.
```

- [ ] **Step 2: Update `docs/dokploy-operations.md`**

Replace fixed context tables with this generic table:

```markdown
| Context | Local env var | CLI wrapper | MCP wrapper |
| --- | --- | --- | --- |
| `org-a` | `DOKPLOY_CONTEXT_ORG_A_API_KEY` | `scripts/dokploy-cli.sh org-a ...` | `scripts/mcp-dokploy-context.sh org-a` |
| `org-b` | `DOKPLOY_CONTEXT_ORG_B_API_KEY` | `scripts/dokploy-cli.sh org-b ...` | `scripts/mcp-dokploy-context.sh org-b` |
```

Add this paragraph below the table:

```markdown
`org-a` and `org-b` are example contexts. Replace them with the values in `DOKPLOY_CONTEXTS` when using this template for a real instance.
```

- [ ] **Step 3: Update `docs/session-workspace-model.md`**

Replace the decision paragraph with:

```markdown
Use one Git repository and one normal working directory for all contexts on a single self-hosted Dokploy instance. Separate work by declared session focus, wrapper commands, MCP server entries, and documentation path.
```

Replace fixed focus headings with:

```markdown
### Context Focus

- CLI: `scripts/dokploy-cli.sh <context> ...`
- MCP: the Codex MCP server entry whose `args` value is `["<context>"]`
- Docs: `docs/orgs/<context-slug>/`

Use this focus for inventory, deployments, backups, domains, servers, and operational decisions scoped to one Dokploy organization or credential context.
```

- [ ] **Step 4: Update shared policies**

In `docs/shared/naming-conventions.md`, use:

```markdown
| Example context | Meaning | CLI | MCP |
| --- | --- | --- | --- |
| `org-a` | First example organization context | `scripts/dokploy-cli.sh org-a ...` | MCP server with `args = ["org-a"]` |
| `org-b` | Second example organization context | `scripts/dokploy-cli.sh org-b ...` | MCP server with `args = ["org-b"]` |
```

In `docs/shared/domain-policy.md`, use:

```markdown
| Field | Required | Example |
| --- | --- | --- |
| Organization/context | Yes | `org-a`, `org-b`, or your real context slug |
```

In `docs/shared/instance.md`, use:

```markdown
| Field | Value |
| --- | --- |
| Panel | `https://dokploy.example.com` |
| Swagger/API | `https://dokploy.example.com/swagger` |
| Example managed contexts | `org-a`, `org-b` |
```

In `docs/shared/mutation-safety.md`, use:

```markdown
| Session focus | A declared context from `DOKPLOY_CONTEXTS`, or `global` |
```

- [ ] **Step 5: Search for obsolete fixed names**

Run:

```bash
rg -n "dokploy-example-org-a|dokploy-example-org-b|mcp-dokploy-org-a|mcp-dokploy-org-b" AGENTS.md docs README.md .codex/config.toml.example scripts
```

Expected: no matches.

- [ ] **Step 6: Commit generalized operations docs**

Run:

```bash
git add AGENTS.md docs/dokploy-operations.md docs/session-workspace-model.md docs/shared/naming-conventions.md docs/shared/domain-policy.md docs/shared/instance.md docs/shared/mutation-safety.md
git commit -m "docs: generalize dokploy operations model"
```

## Task 6: Normalize Templates And Example Org Docs

**Files:**
- Modify: `docs/templates/*.md`
- Modify: `docs/orgs/org-a/**/*.md`
- Modify: `docs/orgs/org-b/**/*.md`

- [ ] **Step 1: Update reusable template metadata**

Replace template metadata values such as:

```markdown
Org: `<org-a|org-b>`
```

with:

```markdown
Context: `<context-slug>`
```

Replace:

```markdown
Org: `<org-a|org-b|global>`
```

with:

```markdown
Scope: `<context-slug|global>`
```

- [ ] **Step 2: Add example-context notice to org READMEs**

Add this paragraph under the title in `docs/orgs/org-a/README.md` and `docs/orgs/org-b/README.md`:

```markdown
This directory is an example context shipped with the public template. Rename or duplicate it to match a real context from `DOKPLOY_CONTEXTS`.
```

- [ ] **Step 3: Update example org access files**

In `docs/orgs/org-a/access.md`, keep the existing table shape but update MCP references:

```markdown
| CLI wrapper | `scripts/dokploy-cli.sh org-a ...` |
| MCP server | Codex MCP server with `args = ["org-a"]` |
| Local env var | `DOKPLOY_CONTEXT_ORG_A_API_KEY` |
```

In `docs/orgs/org-b/access.md`, use:

```markdown
| CLI wrapper | `scripts/dokploy-cli.sh org-b ...` |
| MCP server | Codex MCP server with `args = ["org-b"]` |
| Local env var | `DOKPLOY_CONTEXT_ORG_B_API_KEY` |
```

- [ ] **Step 4: Update inventory files**

In `docs/orgs/org-a/inventory.md`, use:

```markdown
| Dokploy instance | `https://dokploy.example.com` |
| Context | `org-a` |
| MCP server | Codex MCP server with `args = ["org-a"]` |
```

In `docs/orgs/org-b/inventory.md`, use:

```markdown
| Dokploy instance | `https://dokploy.example.com` |
| Context | `org-b` |
| MCP server | Codex MCP server with `args = ["org-b"]` |
```

- [ ] **Step 5: Search for old credential labels**

Run:

```bash
rg -n "Credential label|dokploy-example|Org: `<org-a\\|org-b" docs
```

Expected: no matches for old credential labels or old template metadata.

- [ ] **Step 6: Commit normalized docs**

Run:

```bash
git add docs/templates docs/orgs
git commit -m "docs: normalize example context documentation"
```

## Task 7: Add Public Publication Checklist

**Files:**
- Create: `docs/publication-checklist.md`

- [ ] **Step 1: Create public release checklist**

Create `docs/publication-checklist.md`:

```markdown
# Publication Checklist

Use this checklist before making the repository public or marking it as a GitHub template.

## Repository Metadata

- [ ] Repository description explains that this is a Dokploy operations template.
- [ ] Repository topics include `dokploy`, `self-hosted`, `operations`, `runbook`, `mcp`, and `codex`.
- [ ] Repository owner selected and committed an explicit license before public release.
- [ ] Default branch points at the public template branch.
- [ ] GitHub template repository setting is enabled if this repository should be cloned through "Use this template".

## Secret And Environment Hygiene

- [ ] `.env.local` is ignored by Git.
- [ ] `.codex/config.toml` is ignored by Git.
- [ ] No real Dokploy URLs, API keys, service-token headers, private keys, customer names, internal hostnames, or command output containing secrets are tracked.
- [ ] `DOKPLOY_CUSTOM_HEADERS` appears only as an example or local ignored value.

## Verification Commands

Run:

```bash
git status --short
git check-ignore -v .env.local .codex/config.toml
tests/run.sh
rg -n --hidden -S "PRIVATE KEY|BEGIN RSA|BEGIN OPENSSH|DOKPLOY_CONTEXT_.*=.*[A-Za-z0-9_-]{16,}|DOKPLOY_CUSTOM_HEADERS=.*\\{|password|secret|token" . ':!docs/publication-checklist.md'
rg -n "dokploy-example-org-a|dokploy-example-org-b|mcp-dokploy-org-a|mcp-dokploy-org-b" .
```

Expected:

- `git check-ignore` reports ignore rules for `.env.local` and `.codex/config.toml`.
- `tests/run.sh` passes.
- Secret-oriented search shows only public-safe instructional text.
- Obsolete fixed MCP wrapper search has no matches.

## First-Use Smoke Test

On a fresh clone or a new repository created from the template:

```bash
cp .env.example .env.local
chmod 600 .env.local
cp .codex/config.toml.example .codex/config.toml
git check-ignore -v .env.local .codex/config.toml
tests/run.sh
```

Expected: ignored local files are confirmed and tests pass before real credentials are added.
```

- [ ] **Step 2: Link checklist from README**

Add this bullet to the README documentation map:

```markdown
- Publication checklist: `docs/publication-checklist.md`
```

- [ ] **Step 3: Commit publication checklist**

Run:

```bash
git add README.md docs/publication-checklist.md
git commit -m "docs: add public publication checklist"
```

## Task 8: Final Verification And Branch Readiness

**Files:**
- No file edits expected.

- [ ] **Step 1: Run script tests**

Run:

```bash
tests/run.sh
```

Expected: all tests pass.

- [ ] **Step 2: Run obsolete-name search**

Run:

```bash
rg -n "dokploy-example-org-a|dokploy-example-org-b|mcp-dokploy-org-a|mcp-dokploy-org-b" .
```

Expected: no matches.

- [ ] **Step 3: Run context example search**

Run:

```bash
rg -n "org-a|org-b|Org A|Org B" README.md AGENTS.md docs .env.example .codex/config.toml.example scripts
```

Expected: matches remain only where `org-a` and `org-b` are presented as example contexts or example docs.

- [ ] **Step 4: Run secret-oriented search**

Run:

```bash
rg -n --hidden -S "PRIVATE KEY|BEGIN RSA|BEGIN OPENSSH|DOKPLOY_CONTEXT_.*=.*[A-Za-z0-9_-]{16,}|DOKPLOY_CUSTOM_HEADERS=.*\\{|password|secret|token" . ':!docs/publication-checklist.md'
```

Expected: matches are either absent or clearly instructional public-safe text, with no real credentials or service-token header values.

- [ ] **Step 5: Review branch status**

Run:

```bash
git status --short --branch
git log --oneline --decorate -5
```

Expected: branch is clean after commits and the latest commits match the task commits above.

- [ ] **Step 6: Decide public release path**

Use one of these paths:

```bash
# Path A: make this branch the default public template branch through repository settings.
git push origin template/dokploy-management-template
```

```bash
# Path B: publish the template branch as main after review.
git switch main
git merge --ff-only template/dokploy-management-template
git push origin main
```

Only use Path B if `main` is intended to be the public template default branch.

## Self-Review Notes

- Spec coverage: the plan covers script generalization, MCP config, public docs, template setup, example org docs, tests, secret hygiene, and branch publication.
- Placeholder scan: the plan uses example values intentionally (`org-a`, `org-b`, `https://dokploy.example.com`, and `/absolute/path/to/dokploy-management-template`) and marks them as examples to replace during setup.
- Type and name consistency: context slug normalization consistently maps `<context>` to `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY`; MCP config consistently uses `scripts/mcp-dokploy-context.sh` with `args = ["<context>"]`.
