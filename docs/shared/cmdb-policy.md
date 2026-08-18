# CMDB Policy

This policy defines the CMDB-as-code contract for the canonized operational
graph. The repository persists the reviewed graph; Graphify is the
authoritative interface for consulting and navigating that graph at the
checked-out revision.

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
rel:<from-slug>:<relationship-type>:<to-slug>
~~~

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
sanitized evidence.

| Field | Values | Meaning |
| --- | --- | --- |
| assertion | declared, verified | Canonized operational truth eligible to guide an action when status is canonical |
| assertion | inferred, ambiguous | Discovery and reconciliation proposal only |
| status | canonical | No known divergence from the canonized graph |
| status | conflict, stale | Investigation is required before a later action |

Declared and verified relationships require evidence and an observation date.
They may guide direct mutation; the agent external profile decides whether that
agent executes directly or asks for approval. Inferred and ambiguous
relationships never independently guide automatic action.

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
