#!/usr/bin/env bash
# Reports the sentences and lines, at least --min words long, that two or more kit files repeat
# (skills/, rules/ and CONSTITUTION.md, or the paths given), with each file and line that holds one.
# Case, markdown emphasis, spacing, frontmatter and the generated skills/go/index.md are ignored.
# It only reports: the exit code stays 0 (C18).
# Usage: single-source.sh [--root <kit>] [--min <words>] [path…]
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"; min=10; paths=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) root="$(cd "$2" && pwd)"; shift 2 ;;
    --min) min="$2"; shift 2 ;;
    -*) echo "unknown argument: $1" >&2; exit 2 ;;
    *) paths+=("$1"); shift ;;
  esac
done
cd "$root"
[[ ${#paths[@]} -eq 0 ]] && paths=(skills rules CONSTITUTION.md)

files=()
while IFS= read -r f; do files+=("$f"); done < <(
  for p in "${paths[@]}"; do [[ -e "$p" ]] && find "$p" -type f -name '*.md'; done | sort -u)
[[ ${#files[@]} -eq 0 ]] && { echo "No repeats of $min words or more (no files)."; exit 0; }

python3 - "$min" "${files[@]}" <<'PY'
import re, sys
min_words, files = int(sys.argv[1]), sys.argv[2:]
seen = {}  # normalized sentence -> {"text": first form, "where": {file: first line}}
split = re.compile(r'(?<=[.!?;])\s+|\s+\|\s+')
for f in files:
    if f.endswith("skills/go/index.md"):
        continue
    with open(f, encoding="utf-8", errors="replace") as fh:
        lines = fh.read().split("\n")
    end = lines.index("---", 1) if lines and lines[0] == "---" and "---" in lines[1:] else 0
    for no, line in enumerate(lines, 1):
        if end and no <= end + 1:
            continue
        line = re.sub(r'\*\*|__|^\s*(#+|[-*]|\d+\.)\s+', '', line.strip())
        for s in split.split(line):
            words = re.findall(r"[\w'`./-]+", s.lower())
            if len(words) < min_words:
                continue
            key = " ".join(w.strip(".`") for w in words)
            e = seen.setdefault(key, {"text": s.strip(), "where": {}})
            e["where"].setdefault(f, no)
repeats = [(k, e) for k, e in seen.items() if len(e["where"]) > 1]
if not repeats:
    print(f"No repeats of {min_words} words or more.")
for k, e in sorted(repeats, key=lambda x: (-len(x[1]["where"]), -len(x[0].split()))):
    print(f"{len(k.split())} words, {len(e['where'])} files: {e['text']}")
    for f, no in sorted(e["where"].items()):
        print(f"  {f}:{no}")
PY
