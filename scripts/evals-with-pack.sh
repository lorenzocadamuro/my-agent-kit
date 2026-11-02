#!/usr/bin/env bash
# Builds evals-<style>/ at the kit's root: a git-ignored copy of the eval suite with the style's body added to
# every case as append_system_prompt (prompt.md front matter, case.yaml execution), after any text the case
# already has there. It approximates a session with that output style (plan D14). evals/language/ carries its
# own style and results/ hold old runs: neither is copied.
# Usage: scripts/evals-with-pack.sh <style> [kit folder]; then run the suite with --eval-dir evals-<style>.
set -euo pipefail

style="${1:?usage: evals-with-pack.sh <style> [kit folder]}"
root="$(cd "${2:-$(dirname "$0")/..}" && pwd)"
file="$root/mods/my-language/output-styles/$style.md"
[[ -f "$file" ]] || { echo "evals-with-pack: no style \"$style\" in $root/mods/my-language/output-styles/" >&2; exit 1; }
out="$root/evals-$style"
rm -rf "$out"
cp -R "$root/evals" "$out"
rm -rf "$out/language"
find "$out" -type d -name results -prune -exec rm -rf {} +

python3 - "$file" "$out" <<'PY'
import json, pathlib, sys

def indent_of(line):
    return len(line) - len(line.lstrip(" "))

def add(lines, start, stop, at, indent, text):
    """Sets append_system_prompt among the keys at `indent` in lines[start:stop], after any value it has."""
    key = " " * indent + "append_system_prompt:"
    for i in range(start, stop):
        if lines[i].startswith(key):
            value, j = lines[i][len(key):].strip(), i + 1
            if value in ("|", "|-", "|+"):
                while j < stop and (not lines[j].strip() or indent_of(lines[j]) > indent):
                    j += 1
                deep = min(indent_of(l) for l in lines[i + 1:j] if l.strip())
                old = "\n".join(l[deep:] for l in lines[i + 1:j])
            elif value[:1] in ('"', "'"):
                old = json.loads(value) if value[0] == '"' else value[1:-1].replace("''", "'")
            elif value and value[0] not in ">&*!":
                old = value
            else:
                raise SystemExit(f"evals-with-pack: append_system_prompt: unsupported value {value!r}")
            text, at = old.strip("\n") + "\n\n" + text, i
            del lines[i:j]
            break
    pad = " " * (indent + 2)
    lines[at:at] = [key + " |"] + [pad + l if l.strip() else "" for l in text.split("\n")]

style = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8").split("\n")
body = "\n".join(style[style.index("---", 1) + 1:] if style[0] == "---" else style).strip("\n")
count = 0
for case in sorted(pathlib.Path(sys.argv[2]).rglob("*")):
    if case.name not in ("prompt.md", "case.yaml"):
        continue
    lines = case.read_text(encoding="utf-8").split("\n")
    if case.name == "prompt.md":
        if lines[0] != "---":
            lines[0:0] = ["---", "---", ""]
        end = lines.index("---", 1)
        add(lines, 1, end, end, 0, body)
    else:
        top = [i for i, l in enumerate(lines) if l.strip() and not l.startswith((" ", "#"))]
        e = next((i for i in top if lines[i].rstrip() == "execution:"), None)
        if e is None:
            raise SystemExit(f"evals-with-pack: {case}: no execution key")
        stop = next((i for i in top if i > e), len(lines))
        child = next((indent_of(l) for l in lines[e + 1:stop] if l.strip()), 2)
        add(lines, e + 1, stop, e + 1, child, body)
    case.write_text("\n".join(lines), encoding="utf-8")
    count += 1
print(f"evals-with-pack: {count} cases in {sys.argv[2]}; run them with --eval-dir {pathlib.Path(sys.argv[2]).name}")
PY
