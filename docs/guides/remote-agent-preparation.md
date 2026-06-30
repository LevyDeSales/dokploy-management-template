# Remote VPS Agent Preparation

This guide prepares a remote VPS before it is registered in a Dokploy panel.
Use it for a host that will later become a Dokploy deployment server or build
server.

## Important Distinction

Do not install the full Dokploy panel on this host unless this VPS is intended
to be `<NOME_DA_VPS_OU_PROJETO>-Panel`.

For remote servers, the Dokploy panel remains the control plane. The panel
connects to the remote VPS over SSH, registers the server, runs the Dokploy
remote setup flow and validates the result.

## Can This Be Prepared Before the Panel?

Yes, the VPS can be prepared before the exact panel configuration exists.

You can prepare:

- OS updates and baseline packages;
- root SSH access using keys;
- bash as the default shell;
- hostname and inventory metadata;
- provider firewall rules;
- Tailscale, VPN or provider private network access;
- optional Docker installation for early validation;
- backup mount points or data disk layout.

You should wait for the panel before:

- creating the Dokploy remote server record;
- selecting the panel-managed SSH key;
- running Dokploy `Setup Server`;
- validating Dokploy remote server checks;
- deploying the first application or compose stack.

The reason is simple: Dokploy's official remote server flow starts from an
existing Dokploy UI. The panel stores the remote server record, chooses the SSH
key, runs the setup action and validates the server.

Treat this guide as host preflight, not as a complete Dokploy agent install.

## Existing Portainer Host

If the remote VPS is currently managed by Portainer, follow
`docs/migration/portainer-vps-to-dokploy-agent.md` before using this generic preflight.
That playbook adds the missing inventory, backup, ownership freeze and rollback
steps needed for an in-place host conversion.

## Target State Before Registration

The host is ready for panel registration when:

- the server is reachable over SSH from the operator or panel network path;
- the SSH user has root privileges;
- bash is available and can be used by the remote setup scripts;
- public inbound traffic is limited to the ports required for the intended
  workload;
- private connectivity is available when the panel and remote VPS are not in
  the same provider private network;
- no application data has been migrated yet;
- no production DNS points to the host yet.

## 1. Prepare the Operating System

Run on the remote VPS:

```bash
apt update
apt upgrade -y
apt install -y bash ca-certificates curl git jq ufw fail2ban
```

Set a durable hostname:

```bash
hostnamectl set-hostname "<NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>"
```

## 2. Prepare SSH

Dokploy remote setup requires root access. Use key-based authentication and
record the SSH user and port in `docs/templates/host-inventory.md`.

Baseline checks:

```bash
whoami
echo "$SHELL"
command -v bash
ss -tulpen | grep ssh || true
```

If the default shell is not bash, change it before registering the server in
Dokploy.

## 3. Prepare Networking

If the panel VPS and remote VPS share the same provider private network, use
that private address for administrative traffic when possible.

If they do not share a private network, configure Tailscale before relying on
private connectivity:

The Tailscale install command downloads and executes a remote script. Review the
official install docs before running it on production hosts.

```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --hostname "<NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>"
tailscale ip -4
```

Use the Tailscale `100.x.y.z` address for private observability, admin access
and panel-to-server SSH if that is your chosen access model.

## 4. Prepare Firewall

For a deployment server that will receive public HTTP traffic, allow:

- `80/tcp`;
- `443/tcp`;
- the SSH port only from trusted source IPs or private network paths.

For a build-only server, do not open public `80/tcp` or `443/tcp` unless a
separate service explicitly needs them.

Example deployment-server UFW baseline:

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
ufw status verbose
```

For a build-only server, omit `ufw allow 80/tcp` and `ufw allow 443/tcp`.

Prefer provider firewalls for public exposure controls because Docker can
modify host firewall rules through iptables.

## 5. Optional: Install Docker Early

Dokploy can configure missing remote-server dependencies during `Setup Server`.
Installing Docker early is still useful when you want to validate the VPS
before the panel exists.

The Docker convenience script downloads and executes remote code. Prefer your
distribution packages or review the script before using it on production hosts.

```bash
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

systemctl enable --now docker
docker version
```

Do not initialize Dokploy-specific Swarm, networks or directories manually
unless you are intentionally following the commands generated by the Dokploy
panel for that server.

## 6. Register Later in Dokploy

After the panel is ready:

1. create or select the SSH key in Dokploy;
2. add the remote server using the public, private or Tailscale IP selected for
   panel-to-server SSH;
3. choose whether the host is a deployment server or build server;
4. run `Setup Server` from the Dokploy remote server page;
5. open the Validate tab and wait for all required checks to pass;
6. deploy a low-risk compose or application;
7. update the host inventory.

## Deployment Server Versus Build Server

| Host type | Can be prepared early? | Requires panel setup later? | Notes |
| --- | --- | --- | --- |
| Deployment server | Yes | Yes | Runs apps, Traefik, volumes and data |
| Build server | Yes | Yes | Builds application images and needs a registry |
| Panel server | No, different flow | Not applicable | Install full Dokploy with `docs/guides/installation.md` |

## Official Docs

- https://docs.dokploy.com/docs/core/remote-servers
- https://docs.dokploy.com/docs/core/remote-servers/instructions
- https://docs.dokploy.com/docs/core/remote-servers/deployments
- https://docs.dokploy.com/docs/core/remote-servers/validate
- https://docs.dokploy.com/docs/core/remote-servers/security
- https://docs.dokploy.com/docs/core/guides/tailscale
