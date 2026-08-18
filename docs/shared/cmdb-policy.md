# CMDB Policy

This policy defines the CMDB-as-code contract for the canonized operational
graph. The repository persists the reviewed graph; Graphify is the
authoritative source of operational truth for consulting and navigating that
canonized graph at the checked-out revision.

## Responsibility Boundaries

| Layer | Responsibility |
| --- | --- |
| Repository + CMDB-as-code | Persist sanitized CIs, relationships, evidence, and history |
| Graphify | Query and navigate the canonized operational graph; guide decisions and actions |
| Agent external profile | Decide whether that agent acts freely, requests approval, or is read-only |
| Dokploy/API/SSH | Execute an action and confirm success, failure, or divergence |

Authorization and approval are external to this repository and Graphify.
They are not relationship attributes.

## Configuration Items

A CI is a durable operational entity. Use a stable id in the form:

~~~text
ci:<kind>:<scope>:<slug>
~~~

Supported kinds include business-service, organization, project, environment,
application, compose, database, server, volume, domain, certificate, monitor,
backup-destination, secret-reference, registry, source-repository, and
integration.

Every CI records id, kind, name, lifecycle, criticality, owner label, external
identifiers, documentation link, and provenance. A secret reference may name a
secret-store path or label; never record secret values, tokens, keys, headers,
cookies, dumps, or raw command output.

## Relationships

Relationships are first-class records. Use a stable id in the form:

~~~text
rel:<from-slug>:<relationship-type-slug>:<to-slug>
~~~

`relationship-type-slug` is the canonical `type` value with `_` replaced by
`-`. For example, `depends_on` becomes `depends-on` in the relationship ID.

Initial relationship types are:

- delivered_by
- depends_on
- runs_on
- exposes
- monitored_by
- backed_up_to
- uses_secret_ref
- deployed_from
- routes_to
- uses_certificate

A relationship records from, type, to, assertion, status, observed_at, and
sanitized evidence. These are the canonical relationship semantics:

| Concept | Meaning | Operational effect |
| --- | --- | --- |
| assertion | Reviewed CMDB classification of the relationship | Only `declared` or `verified`, together with `status: canonical`, can orient an action under the external agent profile |
| status | Current reconciliation condition of the relationship | `conflict` and `stale` block a later action that depends on the relationship until investigation and review |
| evidence | Sanitized `source` and `reference` that support the record | Proof for the record; it is not another classification |

`assertion` values are `declared`, `verified`, `inferred`, and `ambiguous`.
`status` values are `canonical`, `conflict`, and `stale`. Declared and verified
relationships require evidence and an observation date. Inferred and ambiguous
relationships never independently guide automatic action.

Graphify is not a CI and does not add an operational relationship. Its link to
the CMDB is revision-based: `graph_revision` in a change record or
reconciliation observation identifies the reviewed commit that Graphify
consulted or generated.

Graphify uses provenance tags for its own extraction: `EXTRACTED`, `INFERRED`,
and `AMBIGUOUS`. These tags explain how Graphify found an edge in the consulted
commit. They do not populate or alter `assertion` or `status` automatically.
The CMDB classification is decided by review of the record and its sanitized
evidence.

Do not add authority, direct_actions, approval_required, permission, or
permissions fields to a relationship record.

## Mutation And Reconciliation

Before mutating, consult Graphify for the relevant graph revision, CIs,
relationships, and evidence. Live Dokploy, API, SSH, and container access
executes the action; it is not mandatory discovery before the action.

After execution, record a sanitized reconciliation observation. Valid outcomes
are match, added, changed, missing, stale, conflict, unverified, and redacted.
A live divergence changes the relevant relationship to conflict or stale until
a reviewed update canonizes the new graph. Reconcilers do not delete CIs or
relationships automatically.

## Public Safety

This public template contains placeholders and synthetic examples only. Real
inventory belongs in a private operations repository. Keep raw evidence,
credentials, local configuration, backup archives, and generated sensitive
material out of Git and out of Graphify extraction.
