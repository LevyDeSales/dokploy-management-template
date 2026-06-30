# MCP Conventions

MCPs are operational tools connected to an AI agent or local Codex setup. Use a
contextual name so multiple infrastructures can be operated from the same
machine without ambiguity.

## Naming Pattern

```text
<NOME_DA_VPS_OU_PROJETO>_<PROVIDER>_MCP
```

Required examples:

```text
<NOME_DA_VPS_OU_PROJETO>_Dokploy_MCP
<NOME_DA_VPS_OU_PROJETO>_Cloudflare_MCP
```

Optional examples:

```text
<NOME_DA_VPS_OU_PROJETO>_Portainer_MCP
<NOME_DA_VPS_OU_PROJETO>_Provider_MCP
```

## Dokploy MCP

This template ships `scripts/mcp-dokploy-context.sh <context>` and
`.codex/config.toml.example`. Create one MCP server entry per context in
`DOKPLOY_CONTEXTS`, with `args = ["<context>"]`.

Use for:

- projects;
- environments;
- compose definitions;
- domains;
- deployments;
- remote servers;
- backups and status checks.

Smoke test:

```bash
codex mcp get "<NOME_DA_VPS_OU_PROJETO>_Dokploy_MCP"
```

Expected evidence:

```text
MCP exists, authenticates, and can list projects without exposing env values.
```

## Cloudflare MCP

Use for:

- DNS records;
- zones;
- proxy status;
- Cloudflare Access;
- edge routes and certificates.

Smoke test:

```bash
codex mcp get "<NOME_DA_VPS_OU_PROJETO>_Cloudflare_MCP"
```

## Rules

- Store MCP secrets outside Git.
- Redact env and compose output when tools support it.
- Do not paste full sensitive MCP responses into docs.
- When MCP output is not enough, use official CLI/API and record short
  evidence.
