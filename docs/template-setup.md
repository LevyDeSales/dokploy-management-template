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
