#!/usr/bin/env bash
set -euo pipefail

root="${1:-}"
if [ -z "$root" ]; then
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

if [ ! -d "$root" ]; then
  echo "markdown link root does not exist: $root" >&2
  exit 1
fi

search_paths=()
for path in README.md AGENTS.md CONTRIBUTING.md SECURITY.md docs examples; do
  if [ -e "$root/$path" ]; then
    search_paths+=("$path")
  fi
done

if [ "${#search_paths[@]}" -eq 0 ]; then
  exit 0
fi

cd "$root"
while IFS=$'\t' read -r file link; do
  [ -z "$file" ] && continue
  case "$link" in
    http://*|https://*|mailto:*|\#*|"")
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
done < <(
  while IFS= read -r match; do
    file="${match%%:*}"
    remainder="${match#*:}"
    content="${remainder#*:}"
    while IFS= read -r markdown_link; do
      link="${markdown_link##*\](}"
      link="${link%)}"
      printf '%s\t%s\n' "$file" "$link"
    done < <(printf '%s\n' "$content" | grep -oE '\[[^]]+\]\([^)]+\)')
  done < <(grep -RInE '\[[^]]+\]\(([^)]+)\)' -- "${search_paths[@]}" 2>/dev/null || true)
)
