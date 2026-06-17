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
- [ ] `DOKPLOY_CUSTOM_HEADERS` appears only as an example or local ignored value.

## Verification Commands

Run:

```bash
git status --short
git check-ignore -v .env.local .codex/config.toml
git ls-files .env .env.local '.env.*.local' .codex/config.toml
tests/run.sh
git grep -n -I -i -E "PRIVATE KEY|BEGIN RSA|BEGIN OPENSSH|(DOKPLOY_CONTEXT_[A-Z0-9_]+_API_KEY|DOKPLOY_API_KEY|DOKPLOY_CUSTOM_HEADERS)=.+|password|secret|token" -- . ':(exclude)docs/publication-checklist.md'
git grep -n -I -E "dokploy-example-org-[ab]|mcp-dokploy-org-[ab]" -- . ':(exclude)docs/publication-checklist.md'
```

Expected:

- `git check-ignore` reports ignore rules for `.env.local` and `.codex/config.toml`.
- `git ls-files` prints no tracked local secret/config files.
- `tests/run.sh` passes.
- Secret-oriented search shows only public-safe instructional text, code-internal variable references, or explicit test placeholders. It must not show real credential values, private keys, service-token headers, customer hostnames, or copied command output.
- Obsolete fixed MCP wrapper search has no matches. `git grep` exits `1` when no matches are found; that is the expected clean result for this check.

## First-Use Smoke Test

On a fresh clone or a new repository created from the template:

```bash
cp .env.example .env.local
chmod 600 .env.local
cp .codex/config.toml.example .codex/config.toml
git check-ignore -v .env.local .codex/config.toml
tests/run.sh
```

Expected: ignored local files are confirmed and tests pass before real credentials are added.
