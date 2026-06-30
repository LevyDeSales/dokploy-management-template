# Remote Servers

Dokploy can manage workloads on servers other than the panel VPS. This keeps
the control plane small and separates application workloads from admin tooling.

If the remote VPS needs to be prepared before the panel is configured, follow
`docs/guides/remote-agent-preparation.md` first.

## Server Types

| Type | Role |
| --- | --- |
| Deployment server | Runs applications, Traefik, volumes and data |
| Build server | Builds application images and pushes them to a registry |

For Docker Compose workloads, use deployment servers. Build servers are useful
for application builds that are expensive or need to happen away from runtime
servers.

## Naming

```text
<NOME_DA_VPS_OU_PROJETO>-Panel
<NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>
```

## Onboarding Checklist

1. Provision the remote VPS.
2. Install base OS updates.
3. Configure SSH key access.
4. Configure provider firewall.
5. Add private network, Tailscale or VPN access if needed.
6. Register the server in Dokploy.
7. Run Dokploy setup for the server.
8. Validate Traefik.
9. Deploy a low-risk compose.
10. Update inventory.

## Inventory Template

Use `docs/templates/host-inventory.md`.

## Official Docs

- https://docs.dokploy.com/docs/core/remote-servers
- https://docs.dokploy.com/docs/core/remote-servers/instructions
- https://docs.dokploy.com/docs/core/remote-servers/deployments
- https://docs.dokploy.com/docs/core/remote-servers/validate
