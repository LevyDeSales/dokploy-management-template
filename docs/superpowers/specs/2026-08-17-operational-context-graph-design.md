# Operational Context Graph Design

## Goal

Extend the Dokploy Management Template with a public-safe CMDB-as-code contract
that records a canonized operational graph. Graphify is the authoritative
source of operational truth for consulting, navigating, and making operational
decisions from that graph at the checked-out, reviewed revision.

## Problem

The template has a strong Dokploy hierarchy and human-readable inventory, but
dependencies are distributed across Markdown tables. An operator cannot
deterministically discover the impact of a server, domain, database, monitor,
backup destination, or secret reference without manually joining documents. It
also applies one mandatory approval rule to all agents even though
authorization belongs to the agent deployment profile.

## Design Decision

The CMDB-as-code records the canonized operational graph; Graphify is its
authoritative consultation, navigation, and operational-decision layer.
Declared and verified relationships with evidence and an observation date are
sufficient operational truth to begin a mutation. Dokploy APIs, SSH, and
containers execute the mutation and reconcile divergence; they are not a
mandatory live-discovery preflight.

This truth claim is limited to the Graphify graph generated from the exact
reviewed repository revision being consulted. It does not claim that a live
platform has not changed after that revision. A later observation that differs
from the canonized graph changes the relationship to conflict or stale until it
is investigated and canonized again.

## Responsibility Boundaries

| Layer | Responsibility |
| --- | --- |
| Repository + CMDB-as-code | Persist sanitized CIs, relationships, evidence, and history |
| Graphify | Query and navigate the canonized operational graph; guide decisions and actions |
| Agent external profile | Decide whether that agent acts freely, requests approval, or is read-only |
| Dokploy/API/SSH | Execute an action and confirm success, failure, or divergence |

Access policy, authorization, and approval do not belong to this repository or
to Graphify. Two agents can consult the same graph: an autonomous agent may
execute directly, while another requests approval according to its external
profile.

## Canonized Graph Contract

### Configuration items

The contract represents business services; Dokploy organizations, projects,
environments, and services; servers; databases; volumes; domains;
certificates; registries; backup destinations; monitors; source repositories;
secret references; and integrations such as Cloudflare, Checkmate, Infisical,
and Contabo.

Every CI record has a stable id, kind, name, lifecycle state, criticality,
owner label, external identifiers, documentation link, and provenance. A
secret reference may identify an approved secret-store path or label, but never
a secret value, token, cookie, key, header, dump, or raw command output.

### Relationships

Relationships are first-class records. Initial types are delivered_by,
depends_on, runs_on, exposes, monitored_by, backed_up_to, uses_secret_ref,
deployed_from, routes_to, and uses_certificate.

Each record contains id, from, type, to, assertion, status, observed_at, and
an evidence object with source and reference. It contains no approval,
permission, agent-capability, or secondary confidence fields.

~~~yaml
id: rel:app:ragflow:production:monitored-by:health
from: ci:app:ragflow:production
type: monitored_by
to: ci:checkmate:monitor:ragflow-health
assertion: declared
status: canonical
observed_at: 2026-08-17T10:15:00Z
evidence:
  source: checkmate-api
  reference: monitor/ragflow-health
~~~

| Field | Value | Meaning | Eligible to direct an action? |
| --- | --- | --- | --- |
| assertion | declared | Reviewed operational assertion with evidence and observation date | Yes, if status is canonical and the external agent profile allows it |
| assertion | verified | Reviewed assertion confirmed by an observation | Yes, if status is canonical and the external agent profile allows it |
| assertion | inferred | Plausible connection derived by Graphify or an operator | No; use for discovery and reconciliation proposals |
| assertion | ambiguous | Evidence supports more than one interpretation | No; investigate first |
| status | conflict | A later observation disagrees with the canonized relationship | No; investigate first |
| status | stale | Relationship exceeded its review window or source is unavailable | No; investigate first |

Assertion records how the relationship entered the canonized graph. Status
represents its current reconciliation condition. A relation used for action
must be declared or verified and neither conflict nor stale.

Graphify provenance tags (`EXTRACTED`, `INFERRED`, and `AMBIGUOUS`) explain how
the tool found an edge in the consulted revision. They are not CMDB assertion
or status values and do not update those values automatically. Graphify is not
a CI or operational relationship; `graph_revision` links a change or
reconciliation record to the commit consulted for the decision.

## Operational Flow

1. The agent queries Graphify for the CI, relationships, evidence, and graph
   revision relevant to the requested action.
2. If the relationship is declared or verified, the agent treats it as
   operational truth for that revision.
3. The external agent profile decides whether to execute directly or request
   approval.
4. The agent executes the mutation without mandatory live discovery.
5. The result becomes a reconciliation observation with timestamp, source,
   outcome, and sanitized evidence reference.
6. If the executing platform diverges from the graph, the relationship becomes
   conflict or stale; a later action requires investigation and a new
   canonized review.

CMDB relationships whose assertion is inferred or ambiguous are useful for
discovery, investigation, and reconciliation proposals, but cannot alone
trigger an automatic operational action.

## Graphify Integration

Graphify is opt-in in the public template. The template supplies the contract,
examples, an operational guide, and .graphifyignore; it does not install a
hook, MCP server, Neo4j, a tool dependency, or generated graph artifacts.

Private operational repositories may version graphify-out/graph.json,
graphify-out/graph.html, and the Graphify report after reviewing their inputs
and generated output for sensitivity. These artifacts represent the navigable
revision of the canonized graph. Their producing commit must match the
CMDB-as-code revision used for an operational decision.

The guide must state that Graphify can process documentation semantically.
Operators use .graphifyignore and existing Git ignores to exclude credentials,
raw evidence, command output, backup archives, dumps, and other sensitive
material before building a private graph.

## Template Changes

The first implementation PR adds:

- docs/shared/cmdb-policy.md for CMDB-as-code, provenance, lifecycle, and
  relationship-semantics rules;
- docs/guides/operational-context-graph.md for Graphify consultation,
  generation, reconciliation, and safe private-repository usage;
- templates for a CI, relationship, business service, change record, and
  reconciliation observation;
- sanitized CMDB and relationship examples under examples/orgs/org-a/;
- .graphifyignore and narrowly scoped Graphify generated-artifact ignores;
- updates to README.md, AGENTS.md, the documentation index, Dokploy reference
  map, mutation safety, and operational branching guidance;
- deterministic repository checks for the new contract files, public-safe
  Graphify exclusions, and prohibited approval-policy fields in templates and
  examples.

## Mutation-Policy Replacement

AGENTS.md and docs/shared/mutation-safety.md replace the global
human-approval prerequisite with this rule:

> Before mutating, an agent must consult the operational graph. Approval need
> is decided by the agent external profile, not by this repository. Actions
> based on declared or verified relationships may be executed directly by
> agents capable of doing so. Record the result and reconcile divergence.

The remaining safety material continues to require correct scope, rollback
planning, backups where appropriate, verification of the executed result, and
sanitized operational records. Those controls are execution and reconciliation
requirements, not a repository-level authorization policy.

## Reconciliation Contract

Reconcilers are read-only adapters that compare a selected live source with the
canonized graph after an operation or during a scheduled review. They emit
sanitized observations classified as match, added, changed, missing, stale,
conflict, unverified, or redacted.

The first PR defines the record format and templates only. It does not call
Dokploy, Cloudflare, Infisical, Checkmate, Contabo, SSH, or container APIs
because the public template has no live instance, credentials, or
source-specific compatibility contract. A future adapter consumes the same
record format and cannot delete a CI or relationship automatically.

## Validation and Testing

The first PR adds deterministic, dependency-free checks to the Bash validation
flow. They verify required graph-contract material, Graphify exclusions for
known sensitive paths, and absence of approval-policy fields in public
templates and examples.

Tests are added before the validation behavior. They demonstrate a passing
contract fixture and rejected prohibited fields. Full YAML-schema validation
and live-source reconciliation tests are follow-up work once the repository
selects a portable YAML runtime; no ad-hoc parser is added.

## Non-Goals

- Treating a live platform as mandatory discovery before every mutation.
- Storing secrets or raw live evidence in Git or Graphify output.
- Embedding authorization, approval, or agent-capability policy in CMDB data.
- Installing Graphify globally or changing a contributor local Codex setup.
- Requiring Neo4j, a shared MCP server, or any network service.
- Implementing provider collectors in the public template.

## Acceptance Criteria

1. The template describes a canonized operational graph with stable CIs and
   first-class typed relationships.
2. Declared and verified relationships have evidence and observation dates and
   can guide direct actions according to an external agent profile.
3. Inferred, ambiguous, conflict, and stale relationships cannot alone guide
   automatic actions.
4. Repository documentation no longer imposes a single human-approval policy
   before every mutation.
5. Graphify is documented as the authoritative source of operational truth for
   the reviewed graph revision, with safe opt-in generation guidance.
6. Private operational repositories have instructions for versioning reviewed
   Graphify artifacts; the public template contains no generated artifact or
   live operational data.
7. Repository validation and tests cover the new static contract and the full
   existing validation suite continues to pass.
