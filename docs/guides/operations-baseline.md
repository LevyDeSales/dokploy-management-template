# Operations

This repo should answer:

1. what runs where;
2. how to operate it;
3. how to recover it;
4. why the decision was made.

## Standard Flow

1. Read current inventory.
2. Query `<NOME_DA_VPS_OU_PROJETO>_Dokploy_MCP`.
3. Query `<NOME_DA_VPS_OU_PROJETO>_Cloudflare_MCP` for DNS or edge changes.
4. Validate on the host only when MCP evidence is not enough.
5. Update runbooks and inventory.
6. Validate secrets are not in the diff.
7. Commit small changes.

## Evidence

Use short, reproducible evidence:

- `HTTP 200`;
- compose name;
- service name;
- backup id/path;
- checksum;
- deployment status;
- timestamp.

Do not paste large logs or sensitive provider responses.
