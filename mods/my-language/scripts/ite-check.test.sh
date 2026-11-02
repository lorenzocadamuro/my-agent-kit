#!/usr/bin/env bash
# Tests ite-check.py: each rule stays silent just under its limit and fires just over it; code, tables
# and headings are not prose; stdin works; the exit status is 0 with findings; the last line counts.
# The samples are Italian on purpose (.claude/CLAUDE.md).
# Usage: bash mods/my-language/scripts/ite-check.test.sh [checker]  (default: ite-check.py beside this script)
set -uo pipefail

checker="${1:-$(dirname "$0")/ite-check.py}"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# n words: "test test ... test".
w() { yes test | head -n "$1" | paste -sd ' ' -; }
run() { printf '%s\n' "$1" > "$tmp/in.md"; python3 "$checker" "$tmp/in.md" 2>&1; }
# found|clean <rule> <label> <sample>: the sample has (or has not) a finding of that rule.
found() {
  local out; out="$(run "$3")"
  if grep -qE "^[0-9]+: $1: " <<<"$out"; then echo "ok: $2"; else echo "FAIL: $2: no $1 finding"$'\n'"$out" >&2; fail=1; fi
}
clean() {
  local out; out="$(run "$3")"
  if grep -qE "^[0-9]+: $1: " <<<"$out"; then echo "FAIL: $2: unexpected $1 finding"$'\n'"$out" >&2; fail=1; else echo "ok: $2"; fi
}
# none <label> <sample>: no finding at all.
none() {
  local out; out="$(run "$2")"
  if grep -qx 'findings: 0 hard, 0 soft · 0.0 per 100 words' <<<"$out" && ! grep -qE '^[0-9]+: ' <<<"$out"; then
    echo "ok: $1"
  else
    echo "FAIL: $1: findings reported"$'\n'"$out" >&2; fail=1
  fi
}

# sentence-length: over 25 words.
clean sentence-length "25 words: no finding" "$(w 25)."
found sentence-length "26 words: found" "$(w 26)."
clean sentence-length "two list items of 20 words are two sentences" "- $(w 20)"$'\n'"- $(w 20)"
clean sentence-length "a full stop ends a sentence" "$(w 15). $(w 15)."
found sentence-length "no sentence end after \"es.\"" "$(w 15) es. $(w 15)."
found sentence-length "no sentence end inside \"plan.md\"" "$(w 13) plan.md $(w 13)."

# paragraph-length: over 6 sentences.
clean paragraph-length "6 sentences: no finding" "$(printf 'Il test passa. %.0s' 1 2 3 4 5 6)"
found paragraph-length "7 sentences: found" "$(printf 'Il test passa. %.0s' 1 2 3 4 5 6 7)"

# di-chain: three "di" within eight consecutive words.
clean di-chain "two \"di\": no finding" "La data di inizio del piano."
found di-chain "three \"di\": found" "La data di inizio della revisione del piano."
found di-chain "the third \"di\" at word 8 of the window: found" "Uso di uno due tre di cinque sei di otto."
clean di-chain "the third \"di\" at word 9 of the window: no finding" "Uso di uno due tre di cinque sei sette di nove."
found di-chain "\"dell’\" with a typographic apostrophe counts" "La data di inizio della revisione dell’archivio."

# gerund, with its stop list.
found gerund "\"verificandolo\" found" "Apro il file verificandolo."
clean gerund "\"prendo\" not a gerund" "Prendo il file."
clean gerund "\"quando\" not a gerund" "Apro il file quando serve."
clean gerund "\"comando\" not a gerund" "Il comando apre il file."

# passive: viene/vengono/verrà... + participle, at most one adverb between.
found passive "\"viene subito eseguito\" found" "Il test viene subito eseguito."
clean passive "\"viene subito\" not passive" "Il test viene subito."
found passive "\"verrà verificato\" found" "Il file verrà verificato."

# support-verb.
found support-verb "\"effettua\" found" "Lo script effettua il controllo."
found support-verb "\"procede alla\" found" "Il round procede alla modifica."

# passive-si (soft).
found passive-si "\"si\" + verb found" "Si aggiorna il file."
clean passive-si "\"sì\" not taken for \"si\"" "Sì, aggiorna il file."

# What is not prose.
none "a fenced block holding a long sentence" '```'$'\n'"$(w 30)."$'\n''```'
none "inline code holding a long sentence" "Esegui \`$(w 30)\` ora."
none "a table row and a heading holding a long sentence" "| $(w 30) |"$'\n\n'"# $(w 30)"

# Stdin, the exit status, the last line.
out="$(printf '%s.\n' "$(w 26)" | python3 "$checker" 2>&1)"
if grep -qE '^1: sentence-length: ' <<<"$out"; then echo "ok: input on stdin"; else echo "FAIL: input on stdin"$'\n'"$out" >&2; fail=1; fi
printf '%s.\n' "$(w 26)" > "$tmp/in.md"
out="$(python3 "$checker" "$tmp/in.md" 2>&1)"; status=$?
if [[ $status -eq 0 ]]; then echo "ok: exit 0 with findings"; else echo "FAIL: exit $status with findings" >&2; fail=1; fi
last="$(tail -n 1 <<<"$out")"
if [[ "$last" == "findings: 1 hard, 0 soft · 3.8 per 100 words" ]]; then
  echo "ok: the per-100-words line"
else
  echo "FAIL: the last line is \"$last\"" >&2; fail=1
fi

[[ $fail -eq 0 ]] && echo "ite-check.test.sh: OK"
exit $fail
