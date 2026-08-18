#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

failures=0

fail() {
  printf 'not ok - %s\n' "$1" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'ok - %s\n' "$1"
}

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT

for path in \
  docs/shared/cmdb-policy.md \
  docs/guides/operational-context-graph.md \
  docs/templates/configuration-item.yaml \
  docs/templates/business-service.md \
  docs/templates/change-record.md \
  docs/templates/reconciliation-observation.yaml \
  examples/orgs/org-a/cmdb/README.md; do
  mkdir -p "$fixture/$(dirname "$path")"
  printf 'public-safe fixture\n' >"$fixture/$path"
done

mkdir -p "$fixture/docs/templates"
cat >"$fixture/docs/templates/configuration-relationship.yaml" <<'EOF'
id: rel:example
from: ci:source
type: depends_on
to: ci:target
assertion: declared
reconciliation_status: canonical
observed_at: 2026-08-17T00:00:00Z
evidence:
  source: fixture
  reference: fixture/relationship
EOF

cat >"$fixture/.graphifyignore" <<'EOF'
.env*
.codex/
backups/
**/*.dump
**/evidence/raw/
graphify-out/
EOF

if "$PROJECT_ROOT/scripts/validate-operational-graph.sh" "$fixture" >/dev/null 2>&1; then
  pass "accepts complete graph contract"
else
  fail "accepts complete graph contract"
fi

sed 's/^reconciliation_status:/status:/' "$fixture/docs/templates/configuration-relationship.yaml" >"$fixture/legacy-status.yaml"
mv "$fixture/legacy-status.yaml" "$fixture/docs/templates/configuration-relationship.yaml"
if "$PROJECT_ROOT/scripts/validate-operational-graph.sh" "$fixture" >"$fixture/output" 2>&1; then
  fail "rejects legacy status relationship field"
elif grep -Fq "reconciliation_status" "$fixture/output"; then
  pass "rejects legacy status relationship field"
else
  fail "names missing reconciliation_status field"
fi

sed 's/^status:/reconciliation_status:/' "$fixture/docs/templates/configuration-relationship.yaml" >"$fixture/current-status.yaml"
mv "$fixture/current-status.yaml" "$fixture/docs/templates/configuration-relationship.yaml"

grep -v '^observed_at:' "$fixture/docs/templates/configuration-relationship.yaml" >"$fixture/relationship-without-observed-at.yaml"
mv "$fixture/relationship-without-observed-at.yaml" "$fixture/docs/templates/configuration-relationship.yaml"
if "$PROJECT_ROOT/scripts/validate-operational-graph.sh" "$fixture" >"$fixture/output" 2>&1; then
  fail "rejects relationship without observed_at"
elif grep -Fq "observed_at" "$fixture/output"; then
  pass "rejects relationship without observed_at"
else
  fail "names missing observed_at field"
fi

printf 'observed_at: 2026-08-17T00:00:00Z\n' >>"$fixture/docs/templates/configuration-relationship.yaml"
printf 'approval_required: true\n' >>"$fixture/docs/templates/configuration-relationship.yaml"
if "$PROJECT_ROOT/scripts/validate-operational-graph.sh" "$fixture" >"$fixture/output" 2>&1; then
  fail "rejects approval policy field"
elif grep -Fq "approval_required" "$fixture/output"; then
  pass "rejects approval policy field"
else
  fail "names prohibited policy field"
fi

if [ "$failures" -ne 0 ]; then
  printf '%s test failure(s)\n' "$failures" >&2
  exit 1
fi
