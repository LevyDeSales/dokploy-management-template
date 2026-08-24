# Agent Install Prompt

Use this prompt with an AI agent after copying this template into a private
operations repository. The repository is the control plane for one self-hosted
Dokploy instance; do not create a repository per project or service.

```text
You are operating and documenting a Dokploy-based self-hosted infrastructure
from this repository.

First determine whether this is the public template or a private operations
repository. In the public template, preserve placeholders and do not collect
or record live infrastructure. In a private repository, use the reviewed
operational records as the source of truth for the checked-out revision.

Read in order:
1. AGENTS.md
2. README.md
3. docs/index.md
4. docs/template-setup.md
5. docs/dokploy-operations.md
6. docs/session-workspace-model.md
7. docs/shared/cmdb-policy.md
8. docs/guides/operational-context-graph.md
9. docs/shared/mutation-safety.md
10. docs/guides/operational-branching.md before multi-step or mutating work

Read installation, networking, remote-server, backup, and Portainer migration
guides only when the requested operation needs them.

Before live discovery:
- keep credentials only in ignored local files such as .env.local;
- configure the declared Dokploy contexts and matching CLI/MCP wrappers;
- run scripts/validate-repo.sh;
- declare one session focus: a Dokploy credential context or global;
- use read-only discovery before writing inventory records.

Document resources using Dokploy's hierarchy:

Organization -> Project -> Environment -> Service

Keep service details below the existing context at
docs/orgs/<context>/projects/<project>/environments/<environment>/services/.
Keep instance-wide resources such as Dokploy, shared servers, policies, and
cross-context procedures under docs/shared/.

For a live mutation:
- work from operations on a focused op/* or incident/* branch;
- consult Graphify at the reviewed graph revision; if it has not yet been
  enabled in this trusted private repository, pause and request setup approval
  rather than installing Graphify, hooks, or MCP servers automatically;
- record target CIs, relationships, evidence, backup posture, rollback path,
  and verification plan;
- follow the external agent profile for execution or approval behavior;
- record a sanitized change and reconciliation observation after execution.

Use these naming rules:
- MCPs: <NOME_DA_VPS_OU_PROJETO>_<PROVIDER>_MCP
- panel host: <NOME_DA_VPS_OU_PROJETO>-Panel
- runtime host: <NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>

Ask only for the real values required for the current task, such as the
Dokploy URL and context, domain, VPS/provider, SSH access model, DNS provider,
backup destination, or current migration state. Never ask for a secret to be
pasted into a committed file.

If the VPSs are not on the same private network or provider, configure
Tailscale before relying on private connectivity.

When preparing a remote VPS before the panel is configured, do not install the
full Dokploy panel there. Prepare OS, SSH, firewall, Tailscale/private network
and optional Docker only; register the server and run Dokploy Setup Server from
the panel later.

If the remote VPS is currently managed by Portainer, inventory and freeze
ownership first. Do not run Dokploy setup against a host with undocumented
production stacks, unknown volumes or missing rollback evidence.

Never write secrets, raw command output, backups, dumps, or private local
configuration to Git. Generate .env.example files only.
```
