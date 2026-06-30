# Server Security Baseline

Use this checklist for every Dokploy-managed server and build server.

## Required Fields

| Field | Notes |
| --- | --- |
| Server name | Exact Dokploy name |
| Role | Dokploy UI, deployment server, build server, or cluster node |
| Provider | VPS or cloud provider |
| Region | Physical or provider region |
| Public IP | Use placeholders or masked values in public repos; store real values only in private operations repos |
| SSH port | Document if non-standard |
| Firewall owner | UFW, provider firewall, or both |
| Traefik status | Local or remote Traefik |
| Docker cleanup | Enabled, disabled, or manual |
| Maintenance window | Expected low-risk window |

## Baseline

- Ubuntu or Debian-compatible operating system where supported.
- Regular system updates.
- UFW installed, active, default incoming deny.
- Provider firewall configured for public exposure control.
- Docker port exposure reviewed because Docker can bypass UFW rules through iptables.
- SSH key authentication enabled.
- SSH password authentication disabled.
- Fail2Ban installed and protecting SSH.
- Dokploy validation status recorded after setup changes.

## Change Rules

- Document firewall and SSH changes before applying them.
- Do not expose service ports directly unless the risk and reason are documented.
- Prefer Traefik domain routing for public HTTP/S access.
- Re-run validation after remote server setup, security hardening, or Docker/network changes.
