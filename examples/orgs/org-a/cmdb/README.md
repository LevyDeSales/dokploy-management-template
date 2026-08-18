# Org A Canonized Operational Graph

This public-safe example shows how a private operations repository records a
connected CMDB graph. The YAML files are the canonized records; Graphify is the
authoritative interface for querying this checked-out graph revision.

## Layout

- cis/: one record per configuration item.
- relationships.yaml: first-class edges between CIs.
- business-services/: human-facing service context linked to CIs.
- changes/: mutation records linked to graph revision and relationships.
- reconciliations/: sanitized observations after execution or review.

Do not copy real credentials, raw API output, backup archives, or secret values
into these paths.
