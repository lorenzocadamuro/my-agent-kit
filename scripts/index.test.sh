#!/usr/bin/env bash
# Tests index.sh: it builds the router's index and the README skill list from each skill's frontmatter,
# in the order of plugin.json's skills array, grouped by area folder, the router itself left out of the
# index; --write writes both, --check fails when either is stale.
# Usage: bash scripts/index.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/index.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ok() { echo "ok: $1"; }
ko() { echo "FAIL: $1" >&2; fail=1; }

k="$tmp/kit"
mkdir -p "$k/.claude-plugin" "$k/skills/go" "$k/skills/plan/scope" "$k/skills/plan/run" "$k/skills/pr/review"
cat > "$k/.claude-plugin/plugin.json" <<'EOF'
{ "name": "my", "version": "8.0.0", "skills": ["./skills/go", "./skills/plan/scope", "./skills/plan/run", "./skills/pr/review"] }
EOF
skill() { # <dir> <name> <model-invoked false|true> <description> <when>
  cat > "$k/$1/SKILL.md" <<EOF
---
name: $2
description: "$4"
disable-model-invocation: $3
when: "$5"
reads: []
---

# $2
EOF
}
skill skills/go go false "Route a request to the right skill." "any request about planning, PRs or the kit"
skill skills/plan/scope scope true "Build the plan, before any code." "\\\"/my:scope\\\", \\\"let's plan this ticket\\\""
skill skills/plan/run run true "Run the plan to the next gate." "\\\"run the plan\\\""
skill skills/pr/review review true "Review a PR as a senior would." "\\\"review this PR\\\""
printf '# Kit\n\nIntro.\n\n<!-- skills:start -->\nold list\n<!-- skills:end -->\n\nAfter.\n' > "$k/README.md"

# --check fails before anything is written.
if bash "$script" --check "$k" >/dev/null 2>&1; then ko "--check passed with no index"; else ok "--check fails with no index"; fi

bash "$script" --write "$k" || ko "--write failed"
idx="$k/skills/go/index.md"
if [[ -f "$idx" ]]; then ok "--write writes skills/go/index.md"; else ko "no skills/go/index.md"; fi

# The index: every skill but the router, grouped by area, in the skills array's order, with its
# command, file, description and trigger phrases (quotes unescaped).
grep -q '^## plan$' "$idx" && grep -q '^## pr$' "$idx" && ok "index groups by area" || ko "index has no area groups"
if grep -q '/my:go' "$idx"; then ko "the router lists itself"; else ok "the router is left out of the index"; fi
line="$(grep -n 'skills/plan/scope/SKILL.md' "$idx" | cut -d: -f1)"
line2="$(grep -n 'skills/plan/run/SKILL.md' "$idx" | cut -d: -f1)"
[[ -n "$line" && -n "$line2" && "$line" -lt "$line2" ]] && ok "skills follow the array's order" || ko "order: scope at '$line', run at '$line2'"
grep -q '`/my:scope`' "$idx" && grep -q 'Build the plan, before any code.' "$idx" && ok "index names command and description" || ko "index misses scope's command or description"
grep -qF "\"/my:scope\", \"let's plan this ticket\"" "$idx" && ok "index carries the trigger phrases, unescaped" || ko "index misses scope's when"

# The README list: the router first, then one group per area, between the markers; the rest kept.
grep -q '^Intro\.$' "$k/README.md" && grep -q '^After\.$' "$k/README.md" && ok "README text outside the markers kept" || ko "README text outside the markers lost"
if grep -q '^old list$' "$k/README.md"; then ko "README list not replaced"; else ok "README list replaced"; fi
block="$(sed -n '/<!-- skills:start/,/<!-- skills:end/p' "$k/README.md")"
grep -q '^- `/my:go`: Route a request to the right skill\.$' <<<"$block" && ok "README lists the router" || ko "README misses the router"
grep -q '^\*\*pr\*\*$' <<<"$block" && grep -q '^- `/my:review`: Review a PR as a senior would\.$' <<<"$block" && ok "README groups by area" || ko "README misses the pr group"

if bash "$script" --check "$k" >/dev/null 2>&1; then ok "--check passes when current"; else ko "--check failed on a fresh index"; fi

# Stale index: a description changes, nothing is rewritten.
perl -pi -e 's/Run the plan to the next gate\./Run the whole plan./' "$k/skills/plan/run/SKILL.md"
if bash "$script" --check "$k" >/dev/null 2>"$tmp/err"; then ko "--check passed with a stale index"
elif grep -q 'stale' "$tmp/err"; then ok "--check fails on a stale index"; else ko "--check failed for another reason: $(head -1 "$tmp/err")"; fi
bash "$script" --write "$k"
# Stale README alone.
perl -pi -e 's/^- `\/my:review`.*/- `\/my:review`: edited by hand/' "$k/README.md"
if bash "$script" --check "$k" >/dev/null 2>"$tmp/err"; then ko "--check passed with a stale README list"
elif grep -q 'README.md' "$tmp/err"; then ok "--check fails on a stale README list"; else ko "--check failed for another reason: $(head -1 "$tmp/err")"; fi

exit "$fail"
