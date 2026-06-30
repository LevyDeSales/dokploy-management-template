# Architecture

This repo documents a small self-hosted platform where Dokploy is the control
plane and application workloads run on one or more remote servers.

## Goals

- Keep the platform understandable by one operator.
- Make rebuild and migration possible from documentation.
- Keep public traffic on application domains and protected admin traffic on a
  separate access path.
- Keep data recoverable through tested backups.

## Logical Model

```text
Users
|
`-- DNS / Cloudflare
    `-- remote VPS public IP
        `-- Traefik managed by Dokploy
            `-- application containers

Operator / AI agent
|
|-- <NOME_DA_VPS_OU_PROJETO>_Dokploy_MCP
|-- <NOME_DA_VPS_OU_PROJETO>_Cloudflare_MCP
`-- SSH over private network, Tailscale or VPN
```

## Components

| Component | Role | Source of truth |
| --- | --- | --- |
| Dokploy | Deploy control plane, domains, logs, deployments and remote servers | Dokploy panel/MCP |
| Panel VPS | Runs Dokploy and platform administration | inventory docs |
| Remote VPS | Runs apps, Traefik, volumes and application data | Dokploy + inventory |
| Cloudflare | DNS, proxy, Access and edge rules | Cloudflare MCP/Terraform |
| Registry | Stores application images | registry provider |
| Object storage | Stores backups and large application assets | backup runbook |
| Tailscale/private network | Private administrative connectivity | network docs |

## Host Naming

```text
<NOME_DA_VPS_OU_PROJETO>-Panel
<NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>
```

Examples:

```text
project-panel
project-api
project-automation
```

## MCP Naming

```text
<NOME_DA_VPS_OU_PROJETO>_Dokploy_MCP
<NOME_DA_VPS_OU_PROJETO>_Cloudflare_MCP
```

## Ownership Rule

```text
One stack has one operational owner: Portainer or Dokploy.
Never let both write to the same database, volume or network at the same time.
```

## Workload Placement

| Workload | Recommended placement |
| --- | --- |
| Dokploy panel | Panel VPS only |
| Customer or application workloads | Remote VPS |
| Databases and Redis | Same operational domain as the app, unless deliberately external |
| Monitoring | Panel VPS or dedicated monitoring VPS |
| Build workloads | Dedicated build server only when builds are heavy |

## Scaling

Start with:

1. one panel VPS;
2. one remote deployment VPS;
3. one low-risk app;
4. one backup destination;
5. one external monitor.

Add additional remote servers, build servers or clusters only when operational
load justifies the extra moving parts.
