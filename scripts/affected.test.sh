#!/usr/bin/env bash
# Tests affected.sh: given changed files, it lists the eval cases they reach: the cases of each skill
# whose folder holds a changed file, whose `reads` lists one (in the working tree or, with --base, in
# that version), or whose folder text names one by path or basename; a rule file that names a changed
# file passes its own readers on. It only reports.
# Usage: bash scripts/affected.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/affected.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ok() { echo "ok: $1"; }
ko() { echo "FAIL: $1" >&2; fail=1; }

k="$tmp/kit"
for s in plan/scope plan/run pr/review pr/sync improve/note improve/log; do mkdir -p "$k/skills/$s"; done
mkdir -p "$k/rules"
for c in scope/a scope/b run/a review/a sync/a note/a log/a; do mkdir -p "$k/evals/$c/graders"; echo x > "$k/evals/$c/prompt.md"; done
mkdir -p "$k/evals/results/x"
echo "# Asking" > "$k/rules/asking.md"
echo "# Core. Questions follow [asking.md](asking.md)." > "$k/rules/core.md"
echo "# Lenses" > "$k/rules/lenses.md"
skill() { # <dir> <name> <reads> <body>
  printf -- '---\nname: %s\ndescription: "x"\ndisable-model-invocation: true\nwhen: "x"\nreads: [%s]\n---\n\n%s\n' "$2" "$3" "$4" > "$k/skills/$1/SKILL.md"
}
skill plan/scope scope "rules/asking.md" "Plan."
skill plan/run run "" "Step 3: follow \`\${CLAUDE_PLUGIN_ROOT}/rules/asking.md\` at a gate."
skill pr/review review "rules/core.md" "Review."
skill pr/sync sync "rules/lenses.md" "Sync."
skill improve/note note "" "Note."
echo "Uses the template-x.md file." > "$k/skills/improve/log/helper.md"
skill improve/log log "" "Log."

list() { bash "$script" --root "$k" "$@" 2>&1; }
has() { grep -qxF "$1" <<<"$out"; }

out="$(list rules/asking.md)"; rc=$?
[[ $rc -eq 0 ]] && ok "exits 0" || ko "exit code $rc"
has evals/scope/a && has evals/scope/b && ok "a skill whose reads lists the file: all its cases" || ko "scope cases missing: $out"
has evals/run/a && ok "a skill that names the file only in a step" || ko "run missing: $out"
has evals/review/a && ok "a skill reached through another rule file (core.md names asking.md)" || ko "review missing: $out"
if has evals/sync/a || has evals/note/a; then ko "an unrelated skill is listed: $out"; else ok "unrelated skills are not listed"; fi
if grep -q results <<<"$out"; then ko "results folder listed"; else ok "the results folder is not a case"; fi

out="$(list skills/improve/log/helper.md)"
has evals/log/a && ok "a skill whose folder holds the changed file" || ko "log missing: $out"
if has evals/scope/a; then ko "scope listed for a log file"; else ok "only that skill"; fi

out="$(list template-x.md)"
has evals/log/a && ok "a skill whose folder text names the basename" || ko "log missing for a basename: $out"

out="$(list evals/note/a/prompt.md)"
has evals/note/a && ok "a changed case lists itself" || ko "note/a missing: $out"

# --base: a skill whose reads listed the file in the base version is still listed after the trim.
git -C "$k" init -q && git -C "$k" -c user.email=t@t -c user.name=t add -A &&
  git -C "$k" -c user.email=t@t -c user.name=t commit -qm base || ko "fixture repo"
skill pr/sync sync "" "Sync."
out="$(list rules/lenses.md)"
if has evals/sync/a; then ko "sync listed without --base"; else ok "without --base only the working tree's reads count"; fi
out="$(list --base HEAD rules/lenses.md)"
has evals/sync/a && ok "--base: reads of the base version count too" || ko "sync missing with --base: $out"

[[ $fail -eq 0 ]] && echo "affected.test.sh: OK" || { echo "affected.test.sh: FAILED" >&2; exit 1; }
