# Template Setup

Use this checklist after creating a repository from this template.

## 1. Choose Repository Mode

If this repository remains the public template, keep `main` as the only
permanent branch.

If this is a private repository for a real Dokploy instance, create an
`operations` branch and make it the default branch in the repository settings:

```bash
git switch -c operations
git push -u origin operations
```

Use `main` only as an optional template baseline for importing future template
updates. See `docs/guides/operational-branching.md`.

## 2. Configure Local Secrets

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
DOKPLOY_CLI_VERSION=0.29.4
DOKPLOY_MCP_VERSION=0.29.3
```

Store only raw API key values. Do not commit `.env.local`. Treat
`.env.local` as trusted local shell input.

## 3. Rename Or Add Contexts

If your real contexts are not `org-a` and `org-b`:

1. Update `DOKPLOY_CONTEXTS`.
2. Add matching `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY` variables.
3. Copy or adapt scaffolding from `examples/orgs/` into `docs/orgs/`.
4. Update the MCP server names and `args` in `.codex/config.toml`.

Context normalization uppercases names and changes non-alphanumeric characters to `_`.

Examples:

| Context slug | API key variable |
| --- | --- |
| `customer-prod` | `DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY` |
| `read.only` | `DOKPLOY_CONTEXT_READ_ONLY_API_KEY` |

## 4. Configure MCP

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

## 5. Verify Read-Only Access

Run:

```bash
scripts/dokploy-cli.sh org-a project all --json
scripts/dokploy-cli.sh org-a organization all --json
```

Replace `org-a` with each context listed in `DOKPLOY_CONTEXTS`.

Only update inventories after read-only checks work.

## 6. Verify Git Safety

Run:

```bash
git check-ignore -v .env.local .codex/config.toml
scripts/validate-repo.sh
```

Expected: `.env.local` and `.codex/config.toml` are ignored, local tests pass,
links resolve, and public-safety checks pass.
