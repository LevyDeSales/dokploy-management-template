# Security Baseline

This is a baseline for small self-hosted Dokploy infrastructure.

## Access

- SSH by key only.
- Disable password SSH when possible.
- Protect the Dokploy panel with Cloudflare Access, Tailscale, VPN or
  equivalent.
- Use contextual MCP names and store MCP credentials outside Git.
- Give operators the least access they need.

## Network

Public:

- `80/tcp`;
- `443/tcp`.

Private only:

- Dokploy admin port `3000`, unless temporarily needed for bootstrap;
- PostgreSQL;
- Redis;
- internal dashboards;
- metrics agents;
- application runtime ports.

## Docker and Firewall

Docker can bypass UFW by manipulating iptables. Prefer provider firewalls for
public exposure control and treat UFW as an additional layer.

## Secrets

Never commit:

- `.env` files;
- private keys;
- API tokens;
- database dumps;
- backups;
- Terraform state;
- real provider credentials.

## Public Repo Hygiene

Before publishing:

```bash
FORBIDDEN_PATTERNS='your-domain|your-private-ip|your-customer-name' ./scripts/validate-repo.sh
```
