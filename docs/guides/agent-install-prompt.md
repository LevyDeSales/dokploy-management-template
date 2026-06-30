# Agent Install Prompt

Use this prompt with an AI agent after forking or copying this repo.

```text
You are helping me replicate a Dokploy-based self-hosted infrastructure.

Use this repository as the source of truth for architecture, naming,
installation, networking, backups and migration patterns.

Read in order:
1. README.md
2. docs/index.md
3. docs/guides/architecture.md
4. docs/guides/installation.md
5. docs/guides/networking.md
6. docs/guides/mcp-conventions.md
7. docs/guides/remote-agent-preparation.md
8. docs/migration/portainer-vps-to-dokploy-agent.md
9. docs/guides/remote-servers.md
10. docs/guides/backups-restore.md

Use these naming rules:
- MCPs: <NOME_DA_VPS_OU_PROJETO>_<PROVIDER>_MCP
- panel host: <NOME_DA_VPS_OU_PROJETO>-Panel
- runtime host: <NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>

Before making changes, ask me for:
- project/VPS prefix;
- domain;
- VPS provider;
- Cloudflare zone;
- SSH user and access model;
- whether the VPSs share a private network;
- backup destination;
- whether this is a fresh VPS or an existing Portainer-managed VPS;
- Portainer stack list and ownership target;
- current Portainer backup status;
- first low-risk stack to deploy or migrate.

If the VPSs are not on the same private network or provider, configure
Tailscale before relying on private connectivity.

When preparing a remote VPS before the panel is configured, do not install the
full Dokploy panel there. Prepare OS, SSH, firewall, Tailscale/private network
and optional Docker only; register the server and run Dokploy Setup Server from
the panel later.

If the remote VPS is currently managed by Portainer, inventory and freeze
ownership first. Do not run Dokploy setup against a host with undocumented
production stacks, unknown volumes or missing rollback evidence.

Never write secrets to Git. Generate .env.example files only.
```
