# Publication Checklist

Use this checklist before making the repository public or marking it as a GitHub template.

## Repository Metadata

- [ ] Repository description explains that this is a Dokploy operations template.
- [ ] Repository topics include `dokploy`, `self-hosted`, `operations`, `runbook`, `mcp`, and `codex`.
- [ ] Repository owner selected and committed an explicit license before public release.
- [ ] Default branch points at the public template branch.
- [ ] GitHub template repository setting is enabled if this repository should be cloned through "Use this template".

## Secret And Environment Hygiene

- [ ] `.env.local` is ignored by Git.
- [ ] `.codex/config.toml` is ignored by Git.
- [ ] No real Dokploy URLs, API keys, service-token headers, private keys, customer names, internal hostnames, or command output containing secrets are tracked.
- [ ] Full Git history has been scanned before publishing or force-updating a public template.
- [ ] `DOKPLOY_CUSTOM_HEADERS` appears only as an example or local ignored value.

## Verification Commands

Run:

```bash
git status --short
git check-ignore -v .env.local .codex/config.toml
git ls-files .env .env.local '.env.*.local' .codex/config.toml
scripts/validate-repo.sh
git grep -n -I -i -E "PRIVATE KEY|BEGIN RSA|BEGIN OPENSSH|ghp_|github_pat_|AKIA|xox[baprs]-|sk-[A-Za-z0-9]{20,}|tskey-" $(git rev-list --all) -- . || true
git grep -n -I -i -E "<private-name>|<private-domain>" $(git rev-list --all) -- . || true
```

Expected:

- `git check-ignore` reports ignore rules for `.env.local` and `.codex/config.toml`.
- `git ls-files` prints no tracked local secret/config files.
- `scripts/validate-repo.sh` passes.
- History-oriented searches show no real credential values, private keys,
  service-token headers, customer hostnames, customer names, or copied command
  output. If historical commits contain private identifiers, choose a history
  rewrite or a new clean repository before calling the public template fully
  sanitized.

## First-Use Smoke Test

On a fresh clone or a new repository created from the template:

```bash
cp .env.example .env.local
chmod 600 .env.local
cp .codex/config.toml.example .codex/config.toml
git check-ignore -v .env.local .codex/config.toml
scripts/validate-repo.sh
```

Expected: ignored local files are confirmed and validation passes before real
credentials are added.
