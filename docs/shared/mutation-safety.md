# Mutation Safety And Reconciliation

This document defines the execution and reconciliation contract for live
Dokploy work. It deliberately does not define an authorization policy: whether
an agent acts directly, asks for approval, or remains read-only is decided by
that agent's external profile.

## Graph Consultation

Before mutating live infrastructure, consult the operational graph through
Graphify at the Git revision being used for the operation. Record the graph
revision, target CIs, target relationships, and the evidence that supports the
decision.

| Relationship condition | Graph meaning |
| --- | --- |
| `declared` or `verified` with `reconciliation_status: canonical` | Current canonized relationship subset |
| `inferred` or `ambiguous` | Discovery, investigation, or reconciliation proposal only |
| `reconciliation_status: conflict` or `stale` | Reviewed discrepancy or freshness context; the external profile decides its response |

The current canonized relationship subset contains `declared` or `verified`
relationships with `reconciliation_status: canonical`, evidence, and
`observed_at`. A live Dokploy, SSH, or container discovery is useful for
reconciliation but is not a mandatory preflight when the reviewed graph already
provides that truth.

## Execution Preparation

Record the following before a material operation:

| Field | Required record |
| --- | --- |
| Session focus | A declared context from `DOKPLOY_CONTEXTS`, or `global` |
| Graph revision | Reviewed Git commit or revision queried through Graphify |
| Target scope | CI and relationship IDs for the organization, service, server, or instance |
| Evidence | Evidence references and `observed_at` values used for the decision |
| Backup posture | Latest relevant backup and restore constraints |
| Blast radius | Domains, services, servers, data, and users affected |
| Rollback path | Revert, redeploy previous version, restore, or manual recovery |
| Verification plan | Commands or checks that will prove the result |

Do not store authorization grants, approver identities, permissions, or secret
values in the CMDB relationship records.

## Agent External Profile

Two agents can consult the same reviewed graph and behave differently. An agent
whose external profile permits direct execution may act on a canonical
`declared` or `verified` relationship. An agent whose profile requires approval
or is read-only must follow that external policy. The repository and Graphify
do not impose either behavior.

## After Mutation

After a mutating operation:

1. Verify the expected result with the planned checks.
2. Check logs, deployment status, domain routing, and backups when relevant.
3. Create a sanitized change record and reconciliation observation.
4. If platform state diverges from the graph, record a reviewed
   `reconciliation_status: conflict` or `stale`; do not silently overwrite the
   canonized record.
5. Update the CMDB and supporting docs through review, then regenerate the
   private Graphify artifacts for that reviewed revision when they are used.
6. Never commit secrets, raw sensitive output, backup archives, or dumps.
