#!/usr/bin/env bash
# Tests check.sh: a missing deny-word file fails, unless MY_AGENT_KIT_ALLOW_NO_DENY=1 says so;
# the file is found under $MY_AGENT_KIT_HOME when MY_AGENT_KIT_DENY is unset; and the layout checks
# I1 to I7 fail on a broken fixture, each naming its case.
# Usage: bash scripts/check.test.sh
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

if MY_AGENT_KIT_DENY=/nonexistent bash "$root/scripts/check.sh" >/dev/null 2>&1; then
  echo "FAIL: check.sh passed with a missing deny-word file" >&2; fail=1
else
  echo "ok: missing deny-word file fails"
fi

if MY_AGENT_KIT_DENY=/nonexistent MY_AGENT_KIT_ALLOW_NO_DENY=1 bash "$root/scripts/check.sh" >/dev/null 2>&1; then
  echo "ok: MY_AGENT_KIT_ALLOW_NO_DENY=1 lets it pass"
else
  echo "FAIL: check.sh failed with MY_AGENT_KIT_ALLOW_NO_DENY=1" >&2; fail=1
fi

tmp="$(mktemp -d)"
mkdir -p "$tmp/home" "$tmp/data"
echo "Principles" > "$tmp/data/deny-words.txt"
if HOME="$tmp/home" MY_AGENT_KIT_HOME="$tmp/data" env -u MY_AGENT_KIT_DENY bash "$root/scripts/check.sh" >/dev/null 2>"$tmp/err"; then
  echo "FAIL: check.sh passed with a deny word in \$MY_AGENT_KIT_HOME/deny-words.txt" >&2; fail=1
elif grep -q "contain words from $tmp/data/deny-words.txt" "$tmp/err"; then
  echo "ok: the deny-word file is read from \$MY_AGENT_KIT_HOME"
else
  echo "FAIL: check.sh did not read \$MY_AGENT_KIT_HOME/deny-words.txt: $(head -1 "$tmp/err")" >&2; fail=1
fi
rm -rf "$tmp"


# The layout checks (I1 to I7): a minimal kit passes; each broken copy fails, naming its case.
make_kit() { # <dir>
  local d="$1"
  mkdir -p "$d/.claude-plugin" "$d/scripts" "$d/skills/go" "$d/skills/plan/scope" "$d/rules" \
    "$d/evals/go/a" "$d/evals/scope/a" "$d/mods/my-status/hooks"
  printf '{ "name": "my", "version": "8.0.0", "description": "Fixture kit.", "skills": ["./skills/go", "./skills/plan/scope"] }\n' \
    > "$d/.claude-plugin/plugin.json"
  cp "$root/scripts/check.sh" "$d/scripts/"
  [[ -f "$root/scripts/index.sh" ]] && cp "$root/scripts/index.sh" "$d/scripts/"
  cat > "$d/skills/go/SKILL.md" <<'EOF'
---
name: go
description: "Route a request to the right skill."
disable-model-invocation: false
when: "any request about a plan or a PR"
reads: [rules/core.md, skills/go/index.md]
---

# /my:go

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md` and `${CLAUDE_PLUGIN_ROOT}/skills/go/index.md`.
EOF
  cat > "$d/skills/plan/scope/SKILL.md" <<'EOF'
---
name: scope
description: "Build the plan before any code."
argument-hint: "<ticket>"
disable-model-invocation: true
when: "\"/my:scope\", \"let's plan this ticket\""
reads: [rules/core.md]
---

# /my:scope

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`.

Then `/my:go` again, as [the core rules](../../../rules/core.md) say.

Reply: the plan and the approval question.
EOF
  printf '# Core\n\nThe router reads [its index](../skills/go/index.md).\n' > "$d/rules/core.md"
  # Bare kit paths that exist: a file, a directory, and a path followed by its arguments.
  printf 'Run `scripts/check.sh --fast` on `rules/`, as `rules/core.md` says.\n' >> "$d/rules/core.md"
  # A bare path with a line number or an anchor names the file before it.
  printf 'See `rules/core.md:3` and `rules/core.md#x`.\n' >> "$d/rules/core.md"
  printf 'x\n' > "$d/evals/go/a/prompt.md"
  printf 'x\n' > "$d/evals/scope/a/prompt.md"
  printf '# Evals\n\n## Smoke set\n\n<!-- smoke:start -->\n```text\ngo/a\nscope/a\n```\n<!-- smoke:end -->\n' > "$d/evals/README.md"
  printf '# Kit\n\n<!-- skills:start -->\n<!-- skills:end -->\n' > "$d/README.md"
  printf 'const cmd = "/my:scope";\n' > "$d/mods/my-status/hooks/adapter.ts"
  [[ -f "$d/scripts/index.sh" ]] && bash "$d/scripts/index.sh" --write "$d"
  return 0
}
layout_case() { # <case> <edit command run in the kit> [<label>]: check.sh fails, naming <case>
  local k label="${3:-$1}"; k="$(mktemp -d)"
  make_kit "$k"
  (cd "$k" && eval "$2")
  if MY_AGENT_KIT_DENY=/nonexistent MY_AGENT_KIT_ALLOW_NO_DENY=1 bash "$k/scripts/check.sh" >/dev/null 2>"$k/err"; then
    echo "FAIL: check.sh passed with: $label" >&2; fail=1
  elif grep -qF "$1" "$k/err"; then
    echo "ok: $label fails"
  else
    echo "FAIL: $label: check.sh failed for another reason: $(grep -v '^$' "$k/err" | tail -1)" >&2; fail=1
  fi
  rm -rf "$k"
}
k="$(mktemp -d)"
make_kit "$k"
if MY_AGENT_KIT_DENY=/nonexistent MY_AGENT_KIT_ALLOW_NO_DENY=1 bash "$k/scripts/check.sh" >/dev/null 2>"$k/err"; then
  echo "ok: a well-formed kit passes"
else
  echo "FAIL: a well-formed kit failed: $(grep -v '^$' "$k/err" | tail -1)" >&2; fail=1
fi
rm -rf "$k"
# A mod's script test runs too: a well-formed kit with a passing scripts/ok.test.sh and a failing
# mods/x/scripts/fail.test.sh must fail, naming that test.
tmp="$(mktemp -d)"
make_kit "$tmp"
mkdir -p "$tmp/mods/x/scripts"
printf '#!/usr/bin/env bash\nexit 0\n' > "$tmp/scripts/ok.test.sh"
printf '#!/usr/bin/env bash\nexit 1\n' > "$tmp/mods/x/scripts/fail.test.sh"
if MY_AGENT_KIT_DENY=/nonexistent MY_AGENT_KIT_ALLOW_NO_DENY=1 bash "$tmp/scripts/check.sh" >/dev/null 2>"$tmp/err"; then
  echo "FAIL: check.sh passed with a failing mods/x/scripts/fail.test.sh" >&2; fail=1
elif grep -q "mods/x/scripts/fail.test.sh failed" "$tmp/err"; then
  echo "ok: a failing mod script test fails check.sh"
else
  echo "FAIL: check.sh failed for another reason: $(tail -1 "$tmp/err")" >&2; fail=1
fi
rm -rf "$tmp"
layout_case "missing field" "perl -ni -e 'print unless /^when:/' skills/plan/scope/SKILL.md"
layout_case "unclosed list" "perl -pi -e 's/^reads: \[rules\/core.md\]/reads: [rules\/core.md/' skills/plan/scope/SKILL.md"
layout_case "missing reads path" "perl -pi -e 's/^reads: \[rules\/core.md\]/reads: [rules\/nope.md]/; s/rules\/core.md\`\./rules\/nope.md\`./' skills/plan/scope/SKILL.md"
layout_case "reads and Read first differ" "perl -pi -e 's/^reads: \[rules\/core.md\]/reads: [rules\/core.md, skills\/go\/index.md]/' skills/plan/scope/SKILL.md"
layout_case "stale index" "perl -pi -e 's/Build the plan before any code/Build the plan first/' skills/plan/scope/SKILL.md"
layout_case "orphan eval folder" "mkdir -p evals/ghost/a && echo x > evals/ghost/a/prompt.md"
layout_case "case not in smoke list" "mkdir -p evals/go/b && echo x > evals/go/b/prompt.md"
layout_case "listed case missing" "rm -r evals/scope/a"
layout_pass() { # <label> <edit command run in the kit>: check.sh passes
  local k; k="$(mktemp -d)"
  make_kit "$k"
  (cd "$k" && eval "$2")
  if MY_AGENT_KIT_DENY=/nonexistent MY_AGENT_KIT_ALLOW_NO_DENY=1 bash "$k/scripts/check.sh" >/dev/null 2>"$k/err"; then
    echo "ok: $1 passes"
  else
    echo "FAIL: $1 failed: $(grep -m1 '^check.sh: ' "$k/err")" >&2; fail=1
  fi
  rm -rf "$k"
}
# A skill needs no eval folder; the results of a smoke run never fail a commit.
layout_pass "a skill with no eval folder and no smoke line" "rm -r evals/scope && perl -ni -e 'print unless m{^scope/a\$}' evals/README.md"
layout_pass "a smoke run's results folder" "mkdir -p evals/results/2026 && echo x > evals/results/2026/report.html"
layout_case "missing skill" "echo 'Then run /my:ghost.' >> rules/core.md"
layout_case "missing file" "echo 'Read \`\${CLAUDE_PLUGIN_ROOT}/rules/nope.md\`.' >> rules/core.md"
layout_case "dangling relative link" "echo 'See [the lenses](review-lenses.md).' >> rules/core.md"
layout_case "dangling bare path" "echo 'Read \`rules/missing.md\`.' >> rules/core.md"
layout_case "dangling bare path" "echo 'Read \`rules/missing.md:3\`.' >> rules/core.md" "dangling bare path with a line"
layout_case "second model-invoked skill" "perl -pi -e 's/^disable-model-invocation: true/disable-model-invocation: false/' skills/plan/scope/SKILL.md"
layout_case "mod names a missing skill" "echo 'const two = \"/my:round\";' >> mods/my-status/hooks/adapter.ts"
layout_case "duplicate name" "perl -pi -e 's/^name: go/name: scope/' skills/go/SKILL.md"
layout_case "workflow without Reply line" "perl -ni -e 'print unless /^Reply:/' skills/plan/scope/SKILL.md"
layout_case "workflow without Reply line" "perl -pi -e 's/^Reply: (.*)/Reply: \\1\\n\\nMore text after it./' skills/plan/scope/SKILL.md" "Reply line not at the end"
# A bold **Reply:** line counts as the Reply line.
k="$(mktemp -d)"
make_kit "$k"
perl -pi -e 's/^Reply: /**Reply:** /' "$k/skills/plan/scope/SKILL.md"
if MY_AGENT_KIT_DENY=/nonexistent MY_AGENT_KIT_ALLOW_NO_DENY=1 bash "$k/scripts/check.sh" >/dev/null 2>"$k/err"; then
  echo "ok: a bold Reply line passes"
else
  echo "FAIL: a bold Reply line failed: $(grep -v '^$' "$k/err" | tail -1)" >&2; fail=1
fi
rm -rf "$k"
# The layout checks run whatever plugin.json says: a broken skill fails with no "version" too.
layout_case "missing field" "jq 'del(.version)' .claude-plugin/plugin.json > p.json && mv p.json .claude-plugin/plugin.json && perl -ni -e 'print unless /^when:/' skills/plan/scope/SKILL.md" "missing field with no version"

exit "$fail"
