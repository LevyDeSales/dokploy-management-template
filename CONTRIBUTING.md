# Contributing

Keep contributions public-safe and operationally useful.

## Documentation Standards

- Use placeholders instead of real domains, IPs, project IDs, bucket names or
  customer names.
- Prefer links to official docs over copied external content.
- Keep one document per purpose: architecture, install, migration, backup,
  operations or reference.
- Every command block should be copyable after replacing placeholders.

## Before Opening a PR

```bash
./scripts/validate-repo.sh
git diff --check
```

## Commit Style

Use small commits with direct messages:

```text
docs: add remote server guide
docs: expand portainer migration checklist
chore: add repository validation
```
