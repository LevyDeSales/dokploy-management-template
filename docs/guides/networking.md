# Networking

Use the smallest network surface that supports your operation.

## Decision Matrix

| Situation | Recommended option |
| --- | --- |
| VPSs in same provider private network | Provider private network |
| VPSs in different providers or no private network | Tailscale |
| HTTP app behind NAT or no inbound ports | Cloudflare Tunnel |
| Public application traffic | DNS/Cloudflare to remote VPS public IP |
| Admin panel | Cloudflare Access, Tailscale, VPN or equivalent |

## Tailscale Requirement

If the VPSs are not in the same private network or are not from the same
provider, add and configure Tailscale for observability, administration and
private host-to-host connectivity.

Install:

The Tailscale install command downloads and executes a remote script. Review the
official install docs before running it on production hosts.

```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up
tailscale status
tailscale ip -4
```

Automated setup example:

```bash
export TAILSCALE_AUTH_KEY="<tskey-auth-...>"
tailscale up --auth-key "$TAILSCALE_AUTH_KEY" --hostname "$(hostname -s)"
```

Use the Tailscale `100.x.y.z` address for private monitoring and remote-agent
targets when provider private IPs are unavailable.

## Firewall Baseline

Allow public:

- `80/tcp` and `443/tcp` for public apps;
- no public database ports;
- no public Redis ports;
- no public internal dashboard ports.

Allow private:

```bash
ufw allow in on tailscale0
```

Provider firewall should block public access before Docker's iptables rules can
accidentally expose a container port.

## Cloudflare Tunnel

Cloudflare Tunnel is useful for HTTP services where inbound ports are not
desired. It does not replace a private network for arbitrary TCP service-to-
service traffic.

Dokploy supports routing tunnel traffic through Traefik for HTTP applications.

## Official Docs

- https://tailscale.com/docs/install/linux
- https://docs.dokploy.com/docs/core/guides/tailscale
- https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/
- https://docs.dokploy.com/docs/core/guides/cloudflare-tunnels
