#!/usr/bin/env bash
# Tests evals-with-pack.sh: on a scratch kit, every case of the copy carries the style's body as
# append_system_prompt (prompt.md front matter, case.yaml execution), appended to one that exists, with every
# other key kept; evals/language/ and results/ are not copied; the originals stay as they were; an unknown
# style writes nothing.
# Usage: bash scripts/evals-with-pack.test.sh
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
bad() { echo "FAIL: $*" >&2; fail=1; }

kit="$tmp/kit"
mkdir -p "$kit/mods/my-language/output-styles" "$kit/evals/one/plain" "$kit/evals/one/appended" \
  "$kit/evals/two/yaml" "$kit/evals/language/x-report" "$kit/evals/results/old"
cat > "$kit/mods/my-language/output-styles/XS.md" <<'EOF'
---
name: XS
description: a test style
keep-coding-instructions: true
---

# XS: a test style

- Rule one: "quoted" and `code`.

Last line.
EOF
cat > "$kit/evals/one/plain/prompt.md" <<'EOF'
---
max_turns: 3
allowed_tools: [Read]
---

Do the thing.
EOF
cat > "$kit/evals/one/appended/prompt.md" <<'EOF'
---
max_turns: 5
append_system_prompt: |
  Case text.
allowed_tools: []
---

Do the other thing.
EOF
cat > "$kit/evals/two/yaml/case.yaml" <<'EOF'
schema_version: "1"
name: yaml
context:
  scaffold_script: setup.sh
execution:
  max_turns: 30
  allowed_tools: [Read, Bash]
  prompt: |
    /my:plan:scope do it.
EOF
mkdir -p "$kit/evals/one/plain/graders"
echo "grader" > "$kit/evals/one/plain/graders/g.md"
echo "carries its own style" > "$kit/evals/language/x-report/prompt.md"
echo "old run" > "$kit/evals/results/old/report.html"
before="$(cd "$kit" && find evals -type f -exec cksum {} + | sort)"

out="$(bash "$root/scripts/evals-with-pack.sh" XS "$kit" 2>&1)" || bad "the script failed: $out"
copy="$kit/evals-XS"

expect() { # <file in the copy> <expected content on stdin>
  if [[ ! -f "$copy/$1" ]]; then bad "$1: not in the copy"; return; fi
  diff -u - "$copy/$1" > "$tmp/diff" || { bad "$1 differs from the expected text:"; cat "$tmp/diff" >&2; }
}
expect one/plain/prompt.md <<'EOF'
---
max_turns: 3
allowed_tools: [Read]
append_system_prompt: |
  # XS: a test style

  - Rule one: "quoted" and `code`.

  Last line.
---

Do the thing.
EOF
expect one/appended/prompt.md <<'EOF'
---
max_turns: 5
append_system_prompt: |
  Case text.

  # XS: a test style

  - Rule one: "quoted" and `code`.

  Last line.
allowed_tools: []
---

Do the other thing.
EOF
expect two/yaml/case.yaml <<'EOF'
schema_version: "1"
name: yaml
context:
  scaffold_script: setup.sh
execution:
  append_system_prompt: |
    # XS: a test style

    - Rule one: "quoted" and `code`.

    Last line.
  max_turns: 30
  allowed_tools: [Read, Bash]
  prompt: |
    /my:plan:scope do it.
EOF
[[ "$(cat "$copy/one/plain/graders/g.md" 2>/dev/null)" == "grader" ]] || bad "graders are not copied as they are"
[[ -e "$copy/language" ]] && bad "evals/language/ is copied"
[[ -e "$copy/results" ]] && bad "results/ is copied"
[[ "$(cd "$kit" && find evals -type f -exec cksum {} + | sort)" == "$before" ]] || bad "the originals changed"

# An unknown style writes nothing.
bash "$root/scripts/evals-with-pack.sh" NOPE "$kit" > /dev/null 2>&1 && bad "an unknown style exits 0"
[[ -e "$kit/evals-NOPE" ]] && bad "an unknown style writes evals-NOPE/"

[[ $fail -eq 0 ]] && echo "evals-with-pack.test.sh: OK"
exit $fail
