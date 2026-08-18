# Operational Branching

This repository is an operations control plane, not an application development
codebase. Use branches to isolate infrastructure work, preserve operational
evidence, and keep a remote recovery point.

The public template teaches the model. A private repository created from the
template applies the model to a real Dokploy instance.

## Branch Roles

### Public Template Repository

Keep the public template simple:

| Branch | Purpose |
| --- | --- |
| `main` | Public-safe template source, reusable documentation, examples, scripts, and validation |

Do not create permanent real-operation branches in the public template. The
public template must use placeholders and public-safe examples only.

A private operations repository may document reviewed real inventory, hostnames,
IP references, credential names, ownership, and operational evidence when those
details are part of the intended infrastructure record. Secret values, tokens,
keys, dumps, backup archives, and raw sensitive command output still stay out of
Git.

### Private Operations Repository

In a real operations repository, use `operations` as the canonical branch:

| Branch | Purpose |
| --- | --- |
| `operations` | Canonical operational ledger and recommended default branch |
| `main` | Optional template baseline for importing public template updates |

`operations` is where durable infrastructure knowledge lands: inventory,
decisions, runbooks, deployment notes, backup evidence, domain changes,
incident records, and post-operation findings.

The remote `operations` branch is the restart point. Push it after canonizing
work so another operator, machine, or Codex thread can resume the operation
record.

When first converting a private template clone into a real operations repo:

```bash
git switch -c operations
git push -u origin operations
```

Then make `operations` the default branch in the private repository settings.

## Temporary Branches

Temporary branches isolate one concrete operational intent.

| Pattern | Use | Example |
| --- | --- | --- |
| `op/YYYY-MM-DD-type-slug` | Planned operation | `op/2026-07-01-deploy-n8n` |
| `incident/YYYY-MM-DD-slug` | Incident response or emergency repair | `incident/2026-07-01-traefik-routing-failure` |
| `sync/template-YYYY-MM-DD` | Import template updates into the private operations repo | `sync/template-2026-07-01` |

Use `type` values that describe the action, for example `deploy`, `update`,
`test-domain`, `rotate-credentials`, `restore`, `migrate`, `backup-check`, or
`document`.

Push an active temporary branch when the work is long, risky, interrupted, or
needs handoff:

```bash
git push -u origin op/2026-07-01-deploy-n8n
```

After durable information is merged into `operations`, delete temporary
branches unless audit requirements say otherwise.

## Checkpoint Tags

Before high-risk work, create a checkpoint tag from the latest `operations`
state:

```bash
git switch operations
git pull --ff-only
git tag checkpoint/2026-07-01-before-dokploy-upgrade
git push origin checkpoint/2026-07-01-before-dokploy-upgrade
```

Use checkpoint tags before:

- Dokploy upgrades;
- destructive operations;
- domain cutovers;
- credential rotations;
- restores;
- server migrations;
- bulk deploys;
- changes where rollback depends on knowing the previous documented state.

Checkpoint tags are not infrastructure backups. They only preserve the Git
operation record. Continue following `docs/shared/backup-policy.md` for real
backup and restore requirements.

## Operation Lifecycle

Use this lifecycle for planned work:

```bash
git switch operations
git pull --ff-only
git tag checkpoint/2026-07-01-before-deploy-n8n
git push origin checkpoint/2026-07-01-before-deploy-n8n
git switch -c op/2026-07-01-deploy-n8n
```

During the operation:

1. Declare the session focus: one context from `DOKPLOY_CONTEXTS`, or `global`.
2. Record the objective, Graphify revision, target CIs and relationships,
   evidence, backup posture, blast radius, rollback path, and verification plan.
3. Query Graphify. A `declared` or `verified` relationship with
   `status: canonical` is operational truth for the action; `inferred`,
   `ambiguous`, `conflict`, and `stale` relationships require investigation.
4. Let the agent's external profile decide whether it executes directly, asks
   for approval, or remains read-only.
5. Execute the operation without mandatory live discovery when the reviewed
   graph provides canonized truth.
6. Record sanitized results and a reconciliation observation.
7. Update durable docs under `docs/orgs/`, `docs/shared/`, or `docs/templates/`.
8. Run repository validation.
9. Commit the intended documentation changes on the temporary branch.

Canonize the result:

```bash
scripts/validate-repo.sh
git status --short
# Replace these paths with the exact files changed by the operation.
git add docs/orgs/<context-slug>/ docs/shared/
git commit -m "docs: record n8n deployment operation"
git status --short
git switch operations
git pull --ff-only
git merge --no-ff op/2026-07-01-deploy-n8n
git push origin operations
git branch -d op/2026-07-01-deploy-n8n
git push origin --delete op/2026-07-01-deploy-n8n
```

If the temporary branch was never pushed, skip the remote deletion command.

## Incident Lifecycle

For incidents, prioritize recovery and evidence:

```bash
git switch operations
git pull --ff-only
git switch -c incident/2026-07-01-traefik-routing-failure
```

Record:

- trigger and time discovered;
- affected contexts, projects, environments, services, domains, and users;
- Graphify revision plus affected CIs and relationships;
- observations, evidence, and any detected graph divergence;
- commands or Dokploy actions performed;
- rollback options considered;
- final state and follow-up work.

After recovery, merge durable incident notes into `operations` and push the
remote branch.

## Template Sync Lifecycle

Use `sync/template-*` when importing changes from the public template into a
private operations repository:

```bash
git switch operations
git pull --ff-only
git switch -c sync/template-2026-07-01
git fetch template main
git merge --no-ff template/main
scripts/validate-repo.sh
git switch operations
git merge --no-ff sync/template-2026-07-01
git push origin operations
```

This assumes the public template remote is named `template`:

```bash
git remote add template https://github.com/LevyDeSales/dokploy-management-template.git
```

Resolve conflicts in favor of preserving real operational records and then
adopting improved template docs, scripts, examples, and validation.

## Agent Rules

An AI agent operating a real private repository should:

- read `README.md`, `docs/index.md`, `docs/dokploy-operations.md`,
  `docs/session-workspace-model.md`, this guide, and
  `docs/shared/mutation-safety.md`;
- confirm whether it is in the public template or a private operations repo;
- use `main` only for public template work or optional template baseline work;
- use `operations` as the canonical real operations branch;
- create a focused `op/*` or `incident/*` branch for mutating or multi-step
  operations;
- push active temporary branches when work must be resumable;
- consult Graphify at the reviewed revision before live changes;
- treat canonical `declared` and `verified` relationships as operational truth,
  while following its external profile for approval or direct execution;
- record reconciliation observations after execution and investigate `conflict`
  or `stale` relationships before depending on them again;
- commit only durable operational records;
- keep the temporary branch worktree clean before switching back to
  `operations`;
- merge or summarize durable findings into `operations`;
- push `operations` so the remote remains the recovery point.

## Safety Rules

- Branches are not a permission boundary. A value that is forbidden in
  `operations` is also forbidden in `op/*`, `incident/*`, and
  `sync/template-*`.
- In the public template, do not commit real customer names, private hostnames,
  real IPs, credential references, or live operational evidence.
- In a private operations repository, document only reviewed operational
  identifiers that are intentionally part of the infrastructure record.
- Never commit `.env.local`, `.codex/config.toml`, API keys, private keys,
  service-token headers, auth headers, cookies, `DOKPLOY_CUSTOM_HEADERS`
  values, `tfstate`, database dumps, backup archives, raw MCP output, or command
  output containing secrets.
- Keep credential values in ignored local files or an external secret store.
- Keep real inventory in `docs/orgs/` only after this template has been copied
  into a private or intentionally public operations repository.
- Protect `operations` from force-push and deletion.
- Run `scripts/validate-repo.sh` before merging temporary work into
  `operations`.

## Protection Recommendations

For a private operations repository:

- make `operations` the default branch;
- require the repository validation check before merging into `operations`;
- disable force-push and branch deletion on `operations`;
- allow temporary `op/*`, `incident/*`, and `sync/template-*` branches to be
  created and deleted freely;
- push checkpoint tags before high-risk operations.

This keeps Git useful as an operational record without turning the repository
into an application development project.
