# Install Dokploy

This guide installs Dokploy on a panel VPS and prepares it to manage remote
servers.

## Prerequisites

| Item | Requirement |
| --- | --- |
| OS | Linux supported by Dokploy, preferably Ubuntu LTS or Debian |
| Minimum resources | 2 GB RAM and 30 GB disk for the panel |
| Access | SSH key access and root privileges |
| Free ports | `80`, `443` and `3000` before install |
| Domain | `<deploy.seudominio.com>` or equivalent |
| Admin protection | Cloudflare Access, Tailscale, VPN or equivalent |
| Backup destination | S3-compatible destination before production |

## 1. Prepare the VPS

```bash
apt update
apt upgrade -y

ss -tulpen | grep -E ':(80|443|3000)\s' || true
```

Stop any service using `80`, `443` or `3000` before installation.

## 2. Install Dokploy

The official install command downloads and executes a remote script as root.
Review the official docs and pin `DOKPLOY_VERSION` when you need repeatable
installs.

Run as root on the panel VPS:

```bash
curl -sSL https://dokploy.com/install.sh | sh
```

If automatic IP detection is not appropriate:

```bash
export ADVERTISE_ADDR="<PANEL_PRIVATE_OR_PUBLIC_IP>"
curl -sSL https://dokploy.com/install.sh | sh
```

If Docker Swarm address pools conflict with provider networking:

```bash
export DOCKER_SWARM_INIT_ARGS="--default-addr-pool 172.20.0.0/16 --default-addr-pool-mask-length 24"
curl -sSL https://dokploy.com/install.sh | sh
```

## 3. First Login

Open temporarily:

```text
http://<PANEL_PUBLIC_IP>:3000
```

Create the first admin user and store credentials in a password manager. Do not
commit credentials to this repo.

## 4. Protect the Panel

Recommended options:

| Option | Use when |
| --- | --- |
| Cloudflare Access | You want identity-protected public admin URL |
| Tailscale | You want private access with no public panel exposure |
| VPN | You already operate a standard VPN |

After a protected domain is working, remove direct `IP:3000` exposure if that
matches your access model:

```bash
docker service update --publish-rm "published=3000,target=3000,mode=host" dokploy
```

Do not close your only access path before validating console, SSH or Tailscale
access.

## 5. Configure Dokploy

Configure:

1. panel domain;
2. Git provider or SSH keys;
3. container registry, especially for private images or build servers;
4. S3 Destination for Dokploy backups;
5. backup schedule;
6. users and roles;
7. notifications.

## 6. Validate

On the panel VPS:

```bash
docker service ls
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
curl -I http://127.0.0.1:3000 || true
```

From your workstation:

```bash
curl -I https://<deploy.seudominio.com>
```

## 7. Update Dokploy

Latest stable, only when you intentionally want the current upstream release:

```bash
curl -sSL https://dokploy.com/install.sh | sh -s update
```

Specific version:

```bash
export DOKPLOY_VERSION="<DOKPLOY_VERSION>"
curl -sSL https://dokploy.com/install.sh | sh -s update
```

## Official Docs

- https://docs.dokploy.com/docs/core/installation
- https://docs.dokploy.com/docs/core/manual-installation
- https://docs.dokploy.com/docs/core/backups

## Remote VPS Agents

This guide is only for the panel VPS. To prepare a separate host that will
later become a Dokploy remote deployment server or build server, use
`docs/guides/remote-agent-preparation.md`.
