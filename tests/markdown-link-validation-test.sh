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

mkdir -p "$fixture/docs/guide" "$fixture/docs/cis"
printf '[CI](../cis/example.yaml)\n' >"$fixture/docs/guide/graph.md"
printf 'id: ci:example\n' >"$fixture/docs/cis/example.yaml"

if "$PROJECT_ROOT/scripts/validate-markdown-links.sh" "$fixture" >/dev/null 2>&1; then
  pass "accepts a valid relative markdown link"
else
  fail "accepts a valid relative markdown link"
fi

printf '[broken](missing.md) and [valid](../cis/example.yaml)\n' >"$fixture/docs/guide/multiple-links.md"
if "$PROJECT_ROOT/scripts/validate-markdown-links.sh" "$fixture" >"$fixture/output" 2>&1; then
  fail "rejects a broken link when followed by a valid link"
elif grep -Fq "docs/guide/multiple-links.md" "$fixture/output"; then
  pass "rejects a broken link when followed by a valid link"
else
  fail "reports source file for a broken link among multiple links"
fi
rm "$fixture/docs/guide/multiple-links.md"

rm "$fixture/docs/cis/example.yaml"
if "$PROJECT_ROOT/scripts/validate-markdown-links.sh" "$fixture" >"$fixture/output" 2>&1; then
  fail "rejects a broken relative markdown link"
elif grep -Fq "docs/guide/graph.md" "$fixture/output"; then
  pass "rejects a broken relative markdown link"
else
  fail "reports source file for broken markdown link"
fi

if [ "$failures" -ne 0 ]; then
  printf '%s test failure(s)\n' "$failures" >&2
  exit 1
fi
