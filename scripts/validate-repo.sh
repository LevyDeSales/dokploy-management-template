#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

echo "==> Checking required files"
required=(
  README.md
  AGENTS.md
  LICENSE
  SECURITY.md
  CONTRIBUTING.md
  .env.example
  .codex/config.toml.example
  docs/index.md
  docs/template-setup.md
  docs/dokploy-operations.md
  docs/shared/dokploy-reference.md
  docs/shared/mutation-safety.md
  docs/guides/architecture.md
  docs/guides/repository-structure.md
  docs/guides/installation.md
  docs/guides/networking.md
  docs/guides/security.md
  docs/guides/remote-agent-preparation.md
  docs/guides/remote-servers.md
  docs/guides/docker-compose-patterns.md
  docs/guides/backups-restore.md
  docs/migration/portainer-to-dokploy.md
  docs/migration/portainer-vps-to-dokploy-agent.md
  examples/docker-compose/app.dokploy.yml
  examples/env/app.env.example
  scripts/dokploy-cli.sh
  scripts/mcp-dokploy-context.sh
  tests/run.sh
)

for file in "${required[@]}"; do
  test -f "$file" || {
    echo "missing required file: $file" >&2
    exit 1
  }
done

echo "==> Checking shell syntax"
bash -n scripts/*.sh tests/*.sh

echo "==> Running shell tests"
tests/run.sh

echo "==> Checking ASCII"
if LC_ALL=C grep -RIn \
  --exclude-dir=.git \
  --exclude='*.png' \
  --exclude='*.jpg' \
  --exclude='*.jpeg' \
  --exclude='*.gif' \
  '[^ -~	]' . >/tmp/dokploy-template-nonascii.txt; then
  cat /tmp/dokploy-template-nonascii.txt >&2
  exit 1
fi

echo "==> Checking forbidden custom patterns"
if [ -n "${FORBIDDEN_PATTERNS:-}" ]; then
  if grep -RInE --exclude-dir=.git "$FORBIDDEN_PATTERNS" . >/tmp/dokploy-template-forbidden.txt; then
    cat /tmp/dokploy-template-forbidden.txt >&2
    exit 1
  fi
fi

echo "==> Checking accidental committed secret files"
if find . -path ./.git -prune -o \( \
  -name '.env' -o \
  -name '.env.*' -o \
  -name '*.pem' -o \
  -name '*.key' -o \
  -name 'id_rsa*' -o \
  -name 'id_ed25519*' -o \
  -name 'terraform.tfstate' -o \
  -name 'terraform.tfstate.*' -o \
  -name '*.dump' -o \
  -name '*.sql' -o \
  -name '*.bak' \
\) -print | grep -vE '(\.env\.example|\.env\..*\.example)$' >/tmp/dokploy-template-secret-files.txt; then
  cat /tmp/dokploy-template-secret-files.txt >&2
  exit 1
fi

echo "==> Checking high-confidence secret patterns"
if grep -RInE \
  --exclude-dir=.git \
  --exclude='validate-repo.sh' \
  '(-----BEGIN (RSA |OPENSSH |EC |DSA |PRIVATE )?PRIVATE KEY-----|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9]{20,}|tskey-[A-Za-z0-9-]{10,})' \
  . >/tmp/dokploy-template-secret-patterns.txt; then
  cat /tmp/dokploy-template-secret-patterns.txt >&2
  exit 1
fi

echo "==> Checking markdown links to local docs"
while IFS=: read -r file link; do
  [ -z "$file" ] && continue
  case "$link" in
    http://*|https://*|mailto:*|"#"*|"")
      continue
      ;;
  esac

  target="${link%%#*}"
  target="${target#./}"
  base="$(dirname "$file")"
  if [ ! -e "$base/$target" ] && [ ! -e "$target" ]; then
    echo "broken local link in $file: $link" >&2
    exit 1
  fi
done < <(grep -RhoInE '\[[^]]+\]\(([^)]+)\)' -- README.md AGENTS.md CONTRIBUTING.md SECURITY.md docs examples \
  | sed -E 's/^([^:]+):.*\]\(([^)]+)\).*$/\1:\2/')

echo "OK"
