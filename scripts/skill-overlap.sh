#!/usr/bin/env bash
# Ranks the kit's skills by the trigger words they share with a candidate skill: the words of four
# letters or more in each skill's `description` and `when`, against the candidate's own `description`
# and `when` (its whole text when it has no frontmatter). Highest first; skills that share none are left
# out. One line per skill: `<shared count> <name> <file>: <shared words>`. It only reports.
# Usage: skill-overlap.sh [--root <kit>] <candidate file | ->
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"; cand=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) root="$(cd "$2" && pwd)"; shift 2 ;;
    -) cand="-"; shift ;;
    -*) echo "unknown argument: $1" >&2; exit 2 ;;
    *) cand="$1"; shift ;;
  esac
done
[[ -z "$cand" ]] && { echo "usage: skill-overlap.sh [--root <kit>] <candidate file | ->" >&2; exit 2; }
text="$(if [[ "$cand" == "-" ]]; then cat; else cat "$cand"; fi)"

cd "$root"
CANDIDATE="$text" python3 - <<'PY'
import os, re
STOP = set("""about after again also another before being both does doing done each even every from have here
into just like more most much must need never only other over same should some such than that their them
then there these they this those through under until very want what when where which while will with without
would your yours skill skills kit""".split())

def triggers(text, whole_if_no_frontmatter):
    lines = text.split("\n")
    if lines and lines[0].strip() == "---" and "---" in [l.strip() for l in lines[1:]]:
        fm = lines[1:[l.strip() for l in lines[1:]].index("---") + 1]
        text = " ".join(l.split(":", 1)[1] for l in fm if re.match(r"(description|when):", l))
    elif not whole_if_no_frontmatter:
        return set()
    words = set()
    for w in re.findall(r"[a-z][a-z'-]{3,}", text.lower()):
        w = w.strip("'-")
        if w.endswith("s") and len(w) > 4 and not w.endswith("ss"):
            w = w[:-1]
        if len(w) >= 4 and w not in STOP:
            words.add(w)
    return words

cand = triggers(os.environ["CANDIDATE"], True)
rows = []
for d, _, fs in os.walk("skills"):
    if "SKILL.md" not in fs:
        continue
    path = os.path.join(d, "SKILL.md")
    with open(path, encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    m = re.search(r"^name:\s*\"?([^\"\n]+)", text, re.M)
    shared = cand & triggers(text, False)
    if shared:
        rows.append((len(shared), m.group(1).strip() if m else d, path, sorted(shared)))
if not rows:
    print("No overlap: no skill shares a trigger word with the candidate.")
for n, name, path, shared in sorted(rows, key=lambda r: (-r[0], r[1])):
    print(f"{n:4d} {name} {path}: {', '.join(shared)}")
PY
