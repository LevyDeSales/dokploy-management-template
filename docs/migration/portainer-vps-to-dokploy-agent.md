# Portainer VPS to Dokploy Remote Agent

This playbook prepares an existing Portainer-managed VPS to become a Dokploy
remote deployment server. It does not install the Dokploy panel on the
Portainer VPS.

Use this when:

- the VPS currently runs workloads managed by Portainer;
- the Dokploy panel will run on `<NOME_DA_VPS_OU_PROJETO>-Panel`;
- this VPS should become `<NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>`;
- the host must be ready before the final panel registration exists.

## Outcome

After this playbook, the VPS is ready for the Dokploy panel to:

1. connect by SSH;
2. register the host as a remote deployment server;
3. run Dokploy `Setup Server`;
4. validate remote server requirements;
5. receive migrated compose workloads.

## Non-Goals

This playbook does not:

- move production traffic by itself;
- copy database or volume data by itself;
- keep Portainer and Dokploy as active owners of the same stack;
- install a second Dokploy panel on the Portainer VPS.

## Migration Modes

| Mode | Use when | Risk |
| --- | --- | --- |
| New-host migration | A new VPS is available for Dokploy workloads | Lowest |
| In-place host conversion | The existing Portainer VPS must become the Dokploy remote server | Medium |
| Stack-by-stack only | Portainer remains installed while selected stacks move to Dokploy | Medium |

Prefer new-host migration when possible. Use in-place conversion only when cost,
IP reputation, storage location or provider constraints require keeping the
same VPS.

## Ownership Rule

```text
One stack has one active owner: Portainer or Dokploy.
Never let both tools write to the same compose stack, network, database,
persistent volume, public port, reverse proxy, Docker Swarm state, external
network or provider firewall routing at the same time.
```

## Phase 1: Inventory Portainer

Record every stack before changing the host:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
docker volume ls
docker network ls
docker compose version || true
docker version
```

For each Portainer stack, record:

- stack name;
- compose source: Git, web editor or uploaded compose;
- image tags;
- published ports;
- domains;
- environment variable names, without secret values;
- named volumes;
- bind mounts;
- databases;
- Redis or queue services;
- external dependencies;
- backup location;
- rollback owner.

Use `docs/templates/migration-record.md` for each stack and
`docs/templates/portainer-vps-agent-readiness.md` for the host.

## Phase 2: Back Up Before Touching Ownership

Create backup evidence before stopping or moving anything:

```text
host snapshot:
Portainer data backup:
database dumps:
volume archive paths:
bind mount archive paths:
restore test target:
restore test result:
```

If a workload writes to a database, create an application-consistent dump before
cutover. If a workload uses Docker named volumes, remember that Portainer stack
migration does not move volume contents for you.

## Phase 3: Prepare the Host as a Dokploy Remote Server

Follow `docs/guides/remote-agent-preparation.md` and keep these Portainer-specific
rules:

- do not install the full Dokploy panel on this host;
- do not delete Portainer until every selected workload has a rollback path;
- do not expose database, Redis or internal service ports publicly;
- keep SSH root access available for the Dokploy panel setup;
- keep bash as the default shell for the SSH user used by Dokploy;
- use Tailscale or a provider private network when panel-to-host SSH should not
  cross the public internet.

Run preflight checks:

```bash
whoami
command -v bash
docker version
docker ps
ss -tulpen
tailscale status || true
ufw status verbose || true
```

## Phase 4: Freeze One Stack at a Time

For each selected stack:

1. confirm backup and rollback instructions;
2. export or reconstruct the compose definition;
3. normalize compose for Dokploy using `docs/guides/docker-compose-patterns.md`;
4. create `.env.example` with variable names only;
5. create the Dokploy project and compose after the panel registers the host;
6. stop or freeze the Portainer stack before any Dokploy workload starts
   against the same production data, volumes, networks or ports;
7. start the Dokploy stack without public traffic;
8. validate logs and persistence;
9. move DNS or Traefik routing;
10. observe;
11. mark the owner as Dokploy.

Pre-cutover Dokploy test starts are allowed only with cloned or snapshot data,
isolated volumes, no shared external Docker networks, and no shared public or
internal ports.

## Phase 5: Register the Host From the Panel

When the Dokploy panel is ready:

1. create or select the Dokploy SSH key;
2. add this VPS as a remote deployment server;
3. use the public, private or Tailscale IP selected for panel-to-host SSH;

Before running `Setup Server` on an in-place host, confirm host-level ownership:

- no existing Portainer-managed proxy or workload is binding `80/tcp` or
  `443/tcp`, or a maintenance-window handoff is documented;
- the active reverse proxy owner is recorded;
- any existing external Docker networks used by Portainer stacks are
  inventoried;
- DNS/routing rollback is documented before Dokploy Traefik is allowed to own
  public HTTP(S).

Then:

4. run `Setup Server`;
5. validate the remote server;
6. deploy a low-risk stack first.

Do not manually create Dokploy-specific Swarm networks or directories before
the panel setup unless you are following the exact script generated by the
Dokploy panel.

## Phase 6: Retire Portainer Carefully

Portainer can be removed only after:

- every migrated stack has an owner recorded as Dokploy;
- restore has been tested for critical data;
- DNS and HTTP routing are stable;
- monitoring points to the Dokploy-managed workload;
- rollback window has passed.

If any stack remains under Portainer, keep Portainer installed and documented.

## Validation Checklist

- [ ] Host inventory updated.
- [ ] Portainer stack inventory complete.
- [ ] Secrets are not committed to Git.
- [ ] Backups created and restore evidence recorded.
- [ ] SSH root access works from the selected panel network path.
- [ ] Bash is available for Dokploy remote setup.
- [ ] Provider firewall blocks unwanted public ports.
- [ ] Tailscale/private network configured when needed.
- [ ] Dokploy panel can register the server later.
- [ ] First migrated stack has rollback instructions.

## Official Docs

- https://docs.dokploy.com/docs/core/remote-servers
- https://docs.dokploy.com/docs/core/remote-servers/instructions
- https://docs.dokploy.com/docs/core/remote-servers/deployments
- https://docs.dokploy.com/docs/core/remote-servers/validate
- https://docs.portainer.io/user/docker/stacks
- https://docs.portainer.io/user/docker/stacks/add
- https://docs.portainer.io/user/docker/stacks/edit
- https://docs.portainer.io/user/docker/stacks/migrate
- https://docs.portainer.io/user/docker/volumes
