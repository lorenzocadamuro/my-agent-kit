#!/usr/bin/env bash
# Checks the my-language mod's packs and manifest: every output style's front matter and scope (I5), no
# content rule in a style (I6), STE's notice and THIRD-PARTY.md (I7), the style text the kit's language eval
# cases carry (I8), and that the mod validates and hooks only session.start and command.run (I4).
# Usage: bash mods/my-language/scripts/packs.test.sh [mod folder]  (default: this script's mod)
set -uo pipefail

mod="$(cd "${1:-$(dirname "$0")/..}" && pwd)"
fail=0
bad() { echo "FAIL: $*" >&2; fail=1; }

# The front matter of a markdown file: the lines between its first two `---` lines.
front() { awk 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { exit } NR > 1 { print }' "$1"; }
# The value of one front matter key, quotes and surrounding spaces removed.
field() { front "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1 | sed -e 's/[[:space:]]*$//' -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'\$/\1/"; }

# I5: every style says, in this exact sentence, which texts its rules cover.
scope="These rules apply to every text written for the person to read: the chat, reports, questions, notifications, chapter titles, study pages, signals and the reasoning in log notes. Code, commits, plans and \`.plans/\` files, prompts for agents, and drafts for other people follow the repository's rules and their own language."
# I6: a style holds form rules only; these phrases belong to the kit's content rules (D7, D15).
content_phrases=("why before" "before the what" "concrete case" "translate" "untranslated" "as they are" "question format" "Pro/Contro"
  "first sentence gives the answer" "answer first" "define a concept term")

styles=("$mod"/output-styles/*.md)
[[ -e "${styles[0]}" ]] || bad "no style in $mod/output-styles"

for f in "${styles[@]}"; do
  [[ -e "$f" ]] || continue
  stem="$(basename "$f" .md)"
  # A name that differs from the file stem would select the Default style silently.
  [[ "$(field "$f" name)" == "$stem" ]] || bad "$stem.md: front matter name is not \"$stem\""
  [[ -n "$(field "$f" description)" ]] || bad "$stem.md: no description"
  [[ "$(field "$f" keep-coding-instructions)" == "true" ]] || bad "$stem.md: keep-coding-instructions is not true"
  front "$f" | grep -q '^force-for-plugin:' && bad "$stem.md: sets force-for-plugin"
  grep -qF -- "$scope" "$f" || bad "$stem.md: no scope sentence (I5)"
  for p in "${content_phrases[@]}"; do
    grep -qiF -- "$p" "$f" && bad "$stem.md: holds a content-rule phrase (I6): \"$p\""
  done
done

# I7: STE says, in this exact text, that it is not the official standard, and THIRD-PARTY.md carries
# AminBlg's source and MIT notice.
notice="This style follows the spirit of ASD-STE100 Simplified Technical English. It is not the official standard, and ASD did not certify it."
grep -qF -- "$notice" "$mod/output-styles/STE.md" 2>/dev/null || bad "STE.md: no \"not the official standard\" notice (I7)"
# STE's strict mode adds words only: the check/verify/confirm rule is in its Words section already.
strict="$(awk '/^## Strict mode/ { on = 1; next } /^## / { on = 0 } on' "$mod/output-styles/STE.md" 2>/dev/null)"
[[ -n "$strict" ]] || bad "STE.md: no \"## Strict mode\" section"
grep -qiF "make sure that" <<<"$strict" && bad "STE.md: strict mode repeats the \"make sure that\" rule"
third="$mod/THIRD-PARTY.md"
if [[ -f "$third" ]]; then
  grep -qF "https://github.com/AminBlg/SimpleEnglish" "$third" || bad "THIRD-PARTY.md: no source URL (I7)"
  grep -qE '(^|[^0-9a-f])[0-9a-f]{40}([^0-9a-f]|$)' "$third" || bad "THIRD-PARTY.md: no 40-hex source commit (I7)"
  grep -qF "MIT License" "$third" || bad "THIRD-PARTY.md: no \"MIT License\" (I7)"
  grep -qF "Copyright (c)" "$third" || bad "THIRD-PARTY.md: no copyright line (I7)"
  grep -qF "ASD-STE100 is a registered trademark of ASD" "$third" || bad "THIRD-PARTY.md: no trademark line (I7)"
else
  bad "no THIRD-PARTY.md in $mod (I7)"
fi

# I8: each eval case in the kit's evals/language/ carries its style's body, exactly, as append_system_prompt.
# The case folder names the style: `<style in lowercase>-<what>`. A copy of the mod with no evals/ beside it
# skips this check.
# The body of a style: the text after its front matter, leading and trailing blank lines removed.
body() { awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; next } fm { next }
  !seen && $0 ~ /^[[:space:]]*$/ { next } { seen = 1; print }' "$1"; }
# append_system_prompt as a `|` block scalar, dedented: in a prompt.md front matter, or under a case.yaml's
# execution key. Any other form prints nothing, so the comparison fails.
appended() { awk -v yaml="$([[ "$1" == *.yaml ]] && echo 1)" '
  !yaml && NR == 1 { if ($0 != "---") exit; next }
  !yaml && $0 == "---" { exit }
  { match($0, /^ */); lead = RLENGTH }
  inblk && $0 ~ /[^ ]/ && lead <= keyind { inblk = 0 }
  inblk { if (ind == "" && $0 ~ /[^ ]/) ind = lead; print (ind == "" ? "" : substr($0, ind + 1)); next }
  yaml && $0 ~ /^[^ #]/ { top = $0 }
  /^ *append_system_prompt:[ ]*\|[-+]?[ ]*$/ && (yaml ? (lead > 0 && top ~ /^execution:[ ]*$/) : lead == 0) {
    inblk = 1; keyind = lead }' "$1"; }
kit_evals="$mod/../../evals"
if [[ -d "$kit_evals" ]]; then
  shopt -s nullglob
  cases=("$kit_evals"/language/*/prompt.md "$kit_evals"/language/*/case.yaml)
  shopt -u nullglob
  [[ ${#cases[@]} -gt 0 ]] || bad "no eval case in evals/language/ (I8)"
  for c in "${cases[@]}"; do
    name="$(basename "$(dirname "$c")")"
    style="$(tr '[:lower:]' '[:upper:]' <<<"${name%%-*}")"
    if [[ ! -f "$mod/output-styles/$style.md" ]]; then
      bad "evals/language/$name: no style $style.md for this case (I8)"
    elif [[ "$(appended "$c")" != "$(body "$mod/output-styles/$style.md")" ]]; then
      bad "evals/language/$name: append_system_prompt differs from the body of $style.md (I8)"
    fi
  done
fi

# I4: the mod validates, and its hooks are only session.start and command.run (no prompt event).
out="$(claude plugin validate "$mod" --strict 2>&1)" || bad "claude plugin validate --strict failed:"$'\n'"$out"
# One line per hooks module: "❯ ./register.ts hooks: session.start, command.run{command=language}".
hooks="$(sed -n 's/^[[:space:]]*❯ [^[:space:]]* hooks: //p' <<<"$out")"
if [[ -z "$hooks" ]]; then
  bad "validate printed no hooks line"
else
  events="$(sed 's/{[^}]*}//g' <<<"$hooks" | tr ',\n' '\n\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | sort -u)"
  others="$(grep -v -x -e session.start -e command.run <<<"$events")"
  [[ -z "$others" ]] || bad "the mod hooks more than session.start and command.run: $(paste -sd ' ' - <<<"$others")"
fi

[[ $fail -eq 0 ]] && echo "packs.test.sh: OK"
exit $fail
