#!/usr/bin/env bash
# Tells which sources of a project profile changed since the profile recorded them (C9).
# The profile's `## Sources` section lists each source as "- `<path>`: `<git blob hash>`". Each is
# compared with its blob on the repository's default branch (origin/<default>), never the branch's
# own HEAD; without git (an eval sandbox), with the file in <repo>, hashed in git's blob form.
# Prints "changed: <path> (<old> -> <new>)" or "removed: <path>" for each, nothing when all match.
# A profile with no Sources section gets one, from the sources that exist (agent instructions, CI
# workflows, package manifests, CODEOWNERS), and one line saying so. --record rewrites every hash
# to the current one, after the profile was refreshed.
# Usage: profile-fresh.sh [--record] [--ref <ref>] <profile> <repo>
set -euo pipefail

record=""; ref=""; args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --record) record=1; shift ;;
    --ref) ref="$2"; shift 2 ;;
    -*) echo "unknown argument: $1" >&2; exit 2 ;;
    *) args+=("$1"); shift ;;
  esac
done
[[ ${#args[@]} -eq 2 ]] || { echo "usage: profile-fresh.sh [--record] [--ref <ref>] <profile> <repo>" >&2; exit 2; }
profile="${args[0]}"; repo="${args[1]}"
[[ -f "$profile" ]] || { echo "profile-fresh: no profile at $profile" >&2; exit 2; }

# The yardstick: origin/<default>, else origin/main or origin/master; none in a folder without git.
if [[ -z "$ref" ]] && git -C "$repo" rev-parse --git-dir > /dev/null 2>&1; then
  ref="$(git -C "$repo" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  for r in "$ref" origin/main origin/master; do
    if [[ -n "$r" ]] && git -C "$repo" rev-parse -q --verify "$r^{commit}" > /dev/null 2>&1; then ref="$r"; break; fi
    ref=""
  done
fi
blob() { # <path>: the blob hash at the yardstick, or of the file in the folder; nothing when absent
  if [[ -n "$ref" ]]; then
    git -C "$repo" rev-parse -q --verify "$ref:$1" 2> /dev/null || true
  elif [[ -f "$repo/$1" ]]; then
    { printf 'blob %d\0' "$(wc -c < "$repo/$1" | tr -d ' ')"; cat "$repo/$1"; } | shasum -a 1 | cut -d' ' -f1
  fi
}
listed() { # the files the default sources match, at the yardstick or in the folder
  local pat='^(CLAUDE\.md|\.claude/CLAUDE\.md|AGENTS\.md|[^/]+/(CLAUDE|AGENTS)\.md|\.github/workflows/[^/]+\.ya?ml|package\.json|pyproject\.toml|Makefile|CODEOWNERS|\.github/CODEOWNERS)$'
  if [[ -n "$ref" ]]; then git -C "$repo" ls-tree -r --name-only "$ref" | grep -E "$pat" || true
  else (cd "$repo" && find . -type f -not -path './.git/*' | sed 's#^\./##' | grep -E "$pat" | sort) || true; fi
}

sources="$(sed -n '/^## Sources[[:space:]]*$/,/^## /p' "$profile" | sed -n 's/^- `\([^`]*\)`: `\([0-9a-f]\{7,40\}\)`.*/\1 \2/p')"

if ! grep -q '^## Sources[[:space:]]*$' "$profile"; then
  n=0; lines=""
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    lines+="- \`$f\`: \`$(blob "$f")\`"$'\n'; n=$((n + 1))
  done < <(listed)
  {
    printf '\n## Sources\n\nRecorded on %s by `profile-fresh.sh` from a profile without marks: every fact above changes only with the user'"'"'s yes.\n\n' "$(date +%Y-%m-%d)"
    printf '%s' "$lines"
  } >> "$profile"
  echo "profile-fresh: recorded $n sources in $profile${ref:+ (at $ref)}; it had none"
  exit 0
fi

if [[ -n "$record" ]]; then
  tmpf="$profile.tmp.$$"; n=0  # next to the profile: a sandbox may block the system temp folder
  while IFS= read -r line; do
    if [[ "$line" =~ ^-\ \`([^\`]+)\`:\ \`[0-9a-f]{7,40}\`(.*)$ ]]; then
      line="- \`${BASH_REMATCH[1]}\`: \`$(blob "${BASH_REMATCH[1]}")\`${BASH_REMATCH[2]}"; n=$((n + 1))
    fi
    printf '%s\n' "$line"
  done < "$profile" > "$tmpf"
  mv "$tmpf" "$profile"
  echo "profile-fresh: recorded the current hashes of $n sources${ref:+ (at $ref)}"
  exit 0
fi

while read -r f old; do
  [[ -z "$f" ]] && continue
  new="$(blob "$f")"
  if [[ -z "$new" ]]; then echo "removed: $f"
  elif [[ "$new" != "$old"* ]]; then echo "changed: $f (${old:0:7} -> ${new:0:7})"; fi
done <<<"$sources"
