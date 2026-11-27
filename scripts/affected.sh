#!/usr/bin/env bash
# Lists the eval cases a change reaches, one `evals/<skill>/<case>` per line, from the changed files:
# - the cases of each skill whose folder holds a changed file;
# - whose `reads` lists one, in the working tree or, with --base <rev>, in that version;
# - or whose folder text names one by its path or its basename (`<folder>/SKILL.md` for a SKILL.md);
# - a rule file (rules/*.md) whose text names a changed file passes its own readers on, and so on;
# - a changed file inside a case lists that case.
# It only reports (C18): it never decides which cases a gate runs.
# Usage: affected.sh [--root <kit>] [--base <rev>] <changed file>...
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"; base=""; changed=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) root="$(cd "$2" && pwd)"; shift 2 ;;
    --base) base="$2"; shift 2 ;;
    -*) echo "unknown argument: $1" >&2; exit 2 ;;
    *) changed+=("$1"); shift ;;
  esac
done
[[ ${#changed[@]} -eq 0 ]] && { echo "usage: affected.sh [--root <kit>] [--base <rev>] <changed file>..." >&2; exit 2; }
cd "$root"

python3 - "$root" "$base" "${changed[@]}" <<'PY'
import os, re, subprocess, sys
root, base, changed = sys.argv[1], sys.argv[2], sys.argv[3:]

def rel(p):
    p = os.path.relpath(os.path.abspath(p), root) if os.path.isabs(p) else os.path.normpath(p)
    return p[2:] if p.startswith("./") else p

def read(p):
    try:
        with open(p, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""

def frontmatter(text, key):
    lines = text.split("\n")
    if not lines or lines[0] != "---":
        return ""
    for line in lines[1:]:
        if line == "---":
            break
        if line.startswith(key + ":"):
            return line[len(key) + 1:].strip().strip('"')
    return ""

def reads_of(text):
    return {r.strip() for r in frontmatter(text, "reads").strip("[]").split(",") if r.strip()}

def at_base(path):
    if not base:
        return ""
    r = subprocess.run(["git", "-C", root, "show", f"{base}:{path}"], capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else ""

def names(p):
    b = os.path.basename(p)
    if b == "SKILL.md":
        b = os.path.basename(os.path.dirname(p)) + "/SKILL.md"
    return {p, b}

def mentions(text, paths):
    return any(n in text for p in paths for n in names(p))

cases, files = set(), set()
for c in map(rel, changed):
    m = re.match(r"evals/([^/]+)/([^/]+)/", c)
    if m and m.group(1) != "results":
        cases.add(f"evals/{m.group(1)}/{m.group(2)}")
    elif not c.startswith("evals/"):
        files.add(c)

# A rule file that names a changed file passes its readers on, to a fixed point.
rules = sorted(f"rules/{f}" for f in os.listdir("rules") if f.endswith(".md")) if os.path.isdir("rules") else []
grew = True
while grew:
    grew = False
    for r in rules:
        if r not in files and mentions(read(r), files):
            files.add(r); grew = True

skills = []
for d, _, fs in os.walk("skills"):
    if "SKILL.md" in fs:
        skills.append(rel(d))
hit = []
for d in sorted(skills):
    text = read(f"{d}/SKILL.md")
    name = frontmatter(text, "name") or os.path.basename(d)
    reads = reads_of(text) | reads_of(at_base(f"{d}/SKILL.md"))
    folder = "".join(read(os.path.join(w, f)) for w, _, fs in os.walk(d) for f in fs)
    if any(f.startswith(d + "/") for f in files) or reads & files or mentions(folder, files):
        hit.append(name)
        ev = f"evals/{name}"
        if os.path.isdir(ev):
            cases.update(f"{ev}/{c}" for c in os.listdir(ev) if os.path.isdir(f"{ev}/{c}") and c != "results")
print("affected skills: " + (" ".join(hit) or "none"), file=sys.stderr)
for c in sorted(cases):
    print(c)
PY
