#!/usr/bin/env bash
# Validates the plugin and blocks employer- or person-specific words.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
deny_file="${MY_AGENT_KIT_DENY:-${MY_AGENT_KIT_HOME:-$HOME/.my-agent-kit}/deny-words.txt}"

claude plugin validate "$root"

if [[ -f "$deny_file" ]]; then
  pattern="$(grep -v -e '^#' -e '^[[:space:]]*$' "$deny_file" | paste -sd '|' -)"
  if [[ -n "$pattern" ]]; then
    hits="$(git -C "$root" grep -n -i -I -E "$pattern" -- . ':!scripts/check.sh' || true)"
    if [[ -n "$hits" ]]; then
      echo "Privacy check failed: these lines contain words from $deny_file" >&2
      echo "$hits" >&2
      exit 1
    fi
  fi
elif [[ "${MY_AGENT_KIT_ALLOW_NO_DENY:-}" == "1" ]]; then
  echo "Privacy check skipped: $deny_file not found (MY_AGENT_KIT_ALLOW_NO_DENY=1)" >&2
else
  echo "Privacy check failed: $deny_file not found. Create it, or set MY_AGENT_KIT_ALLOW_NO_DENY=1 on a machine without it." >&2
  exit 1
fi

# The layout checks I1 to I7 (the layout of skill folders and rules/):
# frontmatter and "Read first:" (I1), the index (I2), eval folders (I3), no missing skill or file (I4),
# only the router model-invoked (I5), the mod's commands (I6), unique names (I7).
fm() { # <file> <key>: the frontmatter value, surrounding quotes removed; nothing when absent
  awk -v k="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, k ":") == 1 {
      v = substr($0, length(k) + 2); sub(/^[ \t]+/, "", v); sub(/[ \t]+$/, "", v)
      if (v ~ /^".*"$/) v = substr(v, 2, length(v) - 2)
      print v; found = 1; exit
    }
    END { if (!found) exit 1 }' "$1"
}
layout_checks() {
  local errs=0 f rel k v reads first names="" n d
  err() { echo "check.sh: $1" >&2; errs=$((errs + 1)); }
  cd "$root"
  while IFS= read -r f; do
    rel="${f#./}"
    if [[ "$(head -1 "$f")" != "---" ]] || [[ "$(awk 'NR > 1 && $0 == "---" { print "y"; exit }' "$f")" != "y" ]]; then
      err "missing field: $rel has no closed frontmatter"; continue
    fi
    for k in name description disable-model-invocation when reads; do
      fm "$f" "$k" > /dev/null || err "missing field: $rel has no '$k'"
    done
    n="$(fm "$f" name || true)"
    [[ -n "$n" ]] && names+="$n"$'\n'
    v="$(fm "$f" disable-model-invocation || true)"
    [[ "$v" == "true" || "$v" == "false" ]] || err "missing field: $rel: disable-model-invocation is '$v', not true or false"
    [[ "$v" == "false" && "$n" != "go" ]] && err "second model-invoked skill: $rel ($n) sets disable-model-invocation: false; only go may"
    v="$(fm "$f" reads || true)"
    if [[ -n "$v" && ! "$v" =~ ^\[.*\]$ ]]; then
      err "unclosed list: $rel: reads is '$v', not a closed [ ... ] list"; continue
    fi
    reads="$(tr -d '[]' <<<"$v" | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$' | sort -u || true)"
    while IFS= read -r p; do
      [[ -z "$p" || -e "$root/$p" ]] || err "missing reads path: $rel reads $p, which does not exist"
    done <<<"$reads"
    first="$(grep -m1 '^Read first:' "$f" | grep -o '\${CLAUDE_PLUGIN_ROOT}/[^`]*' | sed 's#^\${CLAUDE_PLUGIN_ROOT}/##' | sort -u || true)"
    [[ "$first" == "$reads" ]] || err "reads and Read first differ: $rel: reads [$(paste -sd, - <<<"$reads")], Read first [$(paste -sd, - <<<"$first")]"
  done < <(find ./skills -name SKILL.md | sort)

  while IFS= read -r n; do [[ -n "$n" ]] && err "duplicate name: two skills are named $n"; done < <(sort <<<"$names" | uniq -d)

  bash "$root/scripts/index.sh" --check "$root" 2>/dev/null || err "stale index: skills/go/index.md or the README skill list differs from scripts/index.sh (run it with --write)"

  for d in evals/*/; do
    d="${d%/}"; d="${d#evals/}"
    [[ "$d" == "results" ]] && continue
    grep -qxF "$d" <<<"$names" || err "orphan eval folder: evals/$d names no skill"
  done
  while IFS= read -r n; do
    [[ -z "$n" || -d "evals/$n" ]] || err "skill without eval folder: $n has no evals/$n/"
  done <<<"$names"

  local texts=()
  for p in skills rules README.md .claude/CLAUDE.md; do [[ -e "$p" ]] && texts+=("$p"); done
  while IFS=: read -r rel _ v; do
    grep -qxF "$v" <<<"$names" || err "missing skill: $rel names /my:$v"
  done < <(grep -rnoIE '/my:[a-z][a-z0-9-]*' "${texts[@]}" | sed 's#:/my:#:#')
  while IFS=: read -r rel _ v; do
    v="${v%.}"; v="${v%,}"
    [[ -e "$root/$v" ]] || err "missing file: $rel names \${CLAUDE_PLUGIN_ROOT}/$v"
  done < <(grep -rnoIE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./-]+' "${texts[@]}" | sed 's#:\${CLAUDE_PLUGIN_ROOT}/#:#')
  while IFS=: read -r rel _ v; do
    v="${v#*](}"; v="${v%)}"; v="${v%%#*}"
    [[ -z "$v" || "$v" == *://* || "$v" == mailto:* || "$v" == *"<"* ]] && continue
    [[ -e "$(dirname "$root/$rel")/$v" ]] || err "dangling relative link: $rel links to $v"
  done < <(grep -rnoIE '\]\([^) ]+\)' "${texts[@]}")

  if [[ -d mods/my-status/hooks ]]; then
    while IFS=: read -r rel _ v; do
      grep -qxF "$v" <<<"$names" || err "mod names a missing skill: $rel fills in /my:$v"
    done < <(grep -rnoIE '/my:[a-z][a-z0-9-]*' mods/my-status/hooks | sed 's#:/my:#:#')
  fi
  cd - > /dev/null
  [[ $errs -eq 0 ]]
}
layout_checks || { echo "check.sh: layout checks failed" >&2; exit 1; }

# The scripts' own tests and the mods' script tests (check.test.sh tests this file, so it runs apart).
# Inside a git hook, git exports GIT_DIR and GIT_INDEX_FILE: a test's own repositories would then
# write to this one.
shopt -s nullglob
for t in "$root"/scripts/*.test.sh "$root"/mods/*/scripts/*.test.sh; do
  [[ "$t" == "$root/scripts/check.test.sh" ]] && continue
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_PREFIX -u GIT_COMMON_DIR -u GIT_OBJECT_DIRECTORY \
    -u GIT_ALTERNATE_OBJECT_DIRECTORIES bash "$t" > /dev/null || { echo "check.sh: ${t#"$root"/} failed" >&2; exit 1; }
done

echo "check.sh: OK"
