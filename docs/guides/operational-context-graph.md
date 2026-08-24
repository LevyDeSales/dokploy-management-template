# Operational Context Graph

The CMDB-as-code records the canonized operational graph. Graphify is the
authoritative source of operational truth for consulting, navigating, and
making operational decisions from that graph at the checked-out, reviewed
revision.

The graph describes canonized operational knowledge. It does not claim that a
live platform cannot have changed since that revision. Dokploy, APIs, SSH, and
containers execute a requested action and reveal success, failure, or
divergence after the action.

## Responsibility Boundaries

| Layer | Responsibility |
| --- | --- |
| Repository + CMDB-as-code | Persist sanitized CIs, relationships, evidence, and history |
| Graphify | Query and navigate the canonized operational graph; guide decisions and actions |
| Agent external profile | Decide whether that agent acts freely, requests approval, or is read-only |
| Dokploy/API/SSH | Execute an action and confirm success, failure, or divergence |

Authorization and approval remain outside this repository and outside Graphify.
Agents with different external profiles can use the same graph.

## Graph Location

In a private operations repository, keep context graph records under:

~~~text
docs/orgs/<context-slug>/cmdb/
  cis/
  relationships.yaml
  business-services/
  changes/
  reconciliations/
~~~

Use the templates in docs/templates/ and the public-safe Org A example as the
starting point. Every change record and reconciliation observation names the
Git revision that supplied the graph used for that decision.

## Canonized Relationship Semantics

`docs/shared/cmdb-policy.md` is the canonical definition of CMDB `assertion`,
`reconciliation_status`, and `evidence`, including the boundary between that
classification and Graphify extraction provenance. Do not map Graphify tags to
CMDB fields automatically.

## Graph-First Mutation Flow

1. Query Graphify for target CIs, relationships, evidence, and graph revision.
2. Read the reviewed relationship's assertion, reconciliation status, evidence,
   and graph revision.
3. Let the external agent profile decide execution behavior.
4. Execute with Dokploy, an API, SSH, or the appropriate runtime mechanism.
5. Record a sanitized result in a change record and reconciliation observation.
6. Record a reviewed divergence as `reconciliation_status: conflict` or
   `stale` when that condition applies.

Live discovery is optional reconciliation evidence, not a mandatory preflight.

## Optional Graphify Setup

Graphify is optional in this public template. Install it only in a trusted
operator environment. Its upstream repository is
https://github.com/Graphify-Labs/graphify.

~~~bash
uv tool install graphifyy
graphify install --project --platform codex
graphify .
graphify query "what depends on ci:application:org-a:ragflow-production?"
~~~

Project installation can change AGENTS.md and local Codex configuration. Review
its diff before committing it; this template does not install Graphify, a hook,
an MCP server, Neo4j, or any global dependency automatically.

Graphify processes documentation semantically. Keep .graphifyignore and
.gitignore in place, do not use an ignore-bypassing extraction option, and
exclude raw evidence, credentials, local configuration, backups, dumps, and
logs before building a graph.

## Private Repository Artifacts

Private operations repositories may version these reviewed artifacts:

~~~text
graphify-out/graph.json
graphify-out/graph.html
graphify-out/GRAPH_REPORT.md
~~~

Generate them from the exact commit being consulted:

~~~bash
git rev-parse HEAD
graphify .
git status --short graphify-out/
~~~

Record the resulting commit value as graph_revision in the associated change
record or reconciliation observation. Review generated content for sensitive
identifiers before committing. The public template ships contracts, examples,
and instructions only; it does not commit a generated graph.

## Reconciliation

After an operation or scheduled review, use a read-only source to compare the
selected live resource with the canonized graph. Record one of match, added,
changed, missing, stale, conflict, unverified, or redacted without pasting raw
responses.

A reviewed mismatch may record `reconciliation_status: conflict` or `stale`.
Those states preserve graph context and do not prescribe agent behavior;
reconcilers do not delete CIs or relationships automatically.
