#!/usr/bin/env bash
set -euo pipefail

root="${1:-}"
if [ -z "$root" ]; then
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

if [ ! -d "$root" ]; then
  echo "graph contract root does not exist: $root" >&2
  exit 1
fi

required_files=(
  docs/shared/cmdb-policy.md
  docs/guides/operational-context-graph.md
  docs/templates/configuration-item.yaml
  docs/templates/configuration-relationship.yaml
  docs/templates/business-service.md
  docs/templates/change-record.md
  docs/templates/reconciliation-observation.yaml
  examples/orgs/org-a/cmdb/README.md
)

for path in "${required_files[@]}"; do
  if [ ! -f "$root/$path" ]; then
    echo "missing graph contract file: $path" >&2
    exit 1
  fi
done

ignore_file="$root/.graphifyignore"
if [ ! -f "$ignore_file" ]; then
  echo "missing Graphify ignore file: .graphifyignore" >&2
  exit 1
fi

required_ignores=(
  '.env*'
  '.codex/'
  'backups/'
  '**/*.dump'
  '**/evidence/raw/'
  'graphify-out/'
)

for pattern in "${required_ignores[@]}"; do
  if ! grep -Fqx "$pattern" "$ignore_file"; then
    echo "missing Graphify ignore rule: $pattern" >&2
    exit 1
  fi
done

relationship_template="$root/docs/templates/configuration-relationship.yaml"
required_relationship_fields=(
  '^id:'
  '^from:'
  '^type:'
  '^to:'
  '^assertion:'
  '^reconciliation_status:'
  '^observed_at:'
  '^evidence:'
  '^[[:space:]]+source:'
  '^[[:space:]]+reference:'
)

for field in "${required_relationship_fields[@]}"; do
  if ! grep -Eq "$field" "$relationship_template"; then
    field_name="${field#^}"
    field_name="${field_name%%:*}"
    echo "missing relationship field: $field_name" >&2
    exit 1
  fi
done

prohibited_fields='^[[:space:]]*(authority|direct_actions|approval_required|permission|permissions)[[:space:]]*:'
if grep -RInE "$prohibited_fields" "$root/docs/templates" "$root/examples/orgs"; then
  echo "prohibited graph policy field detected" >&2
  exit 1
fi

echo "operational graph contract OK"
