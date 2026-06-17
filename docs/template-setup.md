# Template Setup

Use this checklist after creating a repository from this template.

## 1. Configure Local Secrets

Copy `.env.example` to `.env.local` and fill local values:

```bash
DOKPLOY_URL=https://dokploy.example.com
DOKPLOY_CONTEXTS="org-a org-b"
DOKPLOY_CONTEXT_ORG_A_API_KEY=
DOKPLOY_CONTEXT_ORG_B_API_KEY=
```

Store only raw API key values. Do not commit `.env.local`.

## 2. Configure MCP

Copy `.codex/config.toml.example` to `.codex/config.toml` and replace `/absolute/path/to/dokploy-management-template` with this repository's absolute path.

Keep `.codex/config.toml` untracked because it contains local paths.

## 3. Rename Contexts

If your real contexts are not `org-a` and `org-b`:

- Rename directories under `docs/orgs/`.
- Update `DOKPLOY_CONTEXTS`.
- Add matching `DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY` variables.
- Add or update MCP wrapper scripts if you want one named wrapper per context.

Context normalization uppercases names and changes non-alphanumeric characters to `_`. For example, `customer-prod` becomes `DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY`.

## 4. Verify Read-Only Access

Run:

```bash
scripts/dokploy-cli.sh org-a project all --json
scripts/dokploy-cli.sh org-b project all --json
```

Only update inventories after read-only checks work.
