#!/usr/bin/env bash
# Derives the state file's parts from plan.md's boxes (docs/local-data.md § State file, parts[].steps),
# so no status is ever set by hand: each step is failed (already failed and unticked), running (named
# by --running), done (ticked) or todo, in that order; each part's done, total and status follow.
# Labels and short titles the coordinator wrote are kept; a step the plan added gets its first words
# until one is written. Every other field is kept. The file is rewritten through a temp file and a rename.
# Usage: state-steps.sh <state.json> <plan.md> [--running A2,B1] [--new-round]
#   --running    the steps the open round's items implement or rework: part letter and step number
#   --new-round  a round entry was just added to rounds: failed marks are cleared
set -euo pipefail

if [[ $# -lt 2 || ! -f "$2" ]]; then
  sed -n '7,9p' "$0" >&2
  exit 2
fi

python3 - "$@" <<'PY'
import json, os, re, sys, tempfile

state_path, plan_path = sys.argv[1], sys.argv[2]
args = sys.argv[3:]
running, new_round = set(), False
while args:
    a = args.pop(0)
    if a == "--running" and args:
        running = {s.strip().upper() for s in args.pop(0).split(",") if s.strip()}
    elif a == "--new-round":
        new_round = True
    else:
        sys.exit(f"state-steps.sh: unknown argument {a}")

# The plan's parts: "Part X: title" headings, each with its top-level boxes in order. Without parts,
# the plan is one part, its boxes outside the bar for done.
parts, cur, section = [], None, ""
for line in open(plan_path, encoding="utf-8"):
    head = re.match(r"^#{2,4}\s+(.*?)\s*$", line)
    if head:
        section = head.group(1)
        m = re.match(r"Part ([A-Z]):\s*(.*)", section)
        if m:
            cur = {"letter": m.group(1), "title": f"Part {m.group(1)}: {m.group(2)}", "boxes": []}
            parts.append(cur)
        elif parts:
            cur = None
        continue
    box = re.match(r"^- \[( |x|X)\]\s+(.*)", line)
    if not box:
        continue
    if cur is None and not parts and not section.lower().startswith("bar for done"):
        cur = {"letter": "", "title": "", "boxes": [], "whole": True}
        parts.append(cur)
    if cur is not None:
        cur["boxes"].append((box.group(1) != " ", box.group(2)))

def first_words(text):
    text = re.sub(r"^\*\*[^*]+\*\*\s*", "", text)
    text = re.sub(r"[`*_]", "", text)
    return " ".join(re.findall(r"[\w'’-]+", text)[:3]) or "Step"

state = json.load(open(state_path, encoding="utf-8")) if os.path.exists(state_path) else {}
old = {}
for p in state.get("parts") or []:
    m = re.match(r"Part ([A-Z])", p.get("title", ""))
    old[m.group(1) if m else ""] = p

out, unlabelled = [], []
for part in parts:
    prev = old.get(part["letter"], {})
    prev_steps = prev.get("steps") or []
    steps = []
    for i, (ticked, text) in enumerate(part["boxes"]):
        was = prev_steps[i] if i < len(prev_steps) and len(prev_steps) == len(part["boxes"]) else {}
        label = was.get("label")
        if not label:
            label = first_words(text)
            unlabelled.append(f"{part['letter'] or 'plan'}{i + 1}")
        if was.get("status") == "failed" and not ticked and not new_round:
            status = "failed"
        elif f"{part['letter']}{i + 1}" in running:
            status = "running"
        elif ticked:
            status = "done"
        else:
            status = "todo"
        steps.append({"label": label, "status": status})
    done = sum(1 for t, _ in part["boxes"] if t)
    total = len(part["boxes"])
    if total and done == total:
        pstatus = "done"
    elif done or any(s["status"] == "running" for s in steps):
        pstatus = "running"
    else:
        pstatus = "todo"
    entry = dict(prev)
    entry.update({"title": part["title"] or prev.get("title", ""), "status": pstatus, "done": done, "total": total, "steps": steps})
    entry.pop("left", None)
    out.append(entry)

state["parts"] = out
folder = os.path.dirname(os.path.abspath(state_path))
fd, tmp = tempfile.mkstemp(dir=folder, prefix=".state-", suffix=".json")
with os.fdopen(fd, "w", encoding="utf-8") as f:
    json.dump(state, f, indent=2, ensure_ascii=False)
    f.write("\n")
os.replace(tmp, state_path)
if unlabelled:
    print("state-steps.sh: steps without a label, given their first words: " + ", ".join(unlabelled), file=sys.stderr)
for p in out:
    print(f"{p['title'].split(':')[0] or 'Plan'}: {p['done']}/{p['total']} {p['status']} · " + ", ".join(f"{s['label']} {s['status']}" for s in p["steps"]))
PY
