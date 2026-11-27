#!/usr/bin/env bash
# Writes the state file (rules/kit-data.md § State file): every write by /my:scope and /my:run goes
# through here. It keeps every field it is not told to change, sets updatedAt, and rewrites the file
# whole through a temp file and a rename. With --plan it ends with scripts/state-steps.sh, the only
# writer of steps, on the same temp file, passing it the step flags, so the file is renamed once.
# Usage: state.sh <state.json> [--set key=value]... [--json key=<json>]... [--started <time|now>]
#                 [--new-round <n>] [--end-round <verdict>]
#                 [--plan <plan.md> [--running A2,B1] [--failed A2] [--labels A=<label>,…]... [--short A=<short>]...]
#   --set        a string field (`--set state=needs_you --set "reason=Plan approval"`)
#   --json       a field given as JSON (`--json round=3`, `--json 'items={"done":1,"total":3}'`, `--json reason=null`)
#   --started    startedAt, only when the file has none or its state is done (a finished plan's file)
#   --new-round  appends { n, startedAt } to rounds unless round n has an entry; only then are failed marks cleared
#   --end-round  sets endedAt and verdict on the open round (the last one without endedAt)
#   --short      a part's short title (`plan=` in a plan without parts); --running, --failed, --labels: state-steps.sh
set -euo pipefail

if [[ $# -lt 1 || "$1" == -* ]]; then
  sed -n '6,14p' "$0" >&2
  exit 2
fi
here="$(cd "$(dirname "$0")" && pwd)"
python3 - "$here/state-steps.sh" "$@" <<'PY'
import json, os, subprocess, sys, tempfile
from datetime import datetime, timezone

steps_script, path, args = sys.argv[1], sys.argv[2], sys.argv[3:]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
def die(msg):
    print(f"state.sh: {msg}", file=sys.stderr)
    sys.exit(2)

sets, started, new_round, end_round, plan, shorts, passed = [], None, None, None, None, [], []
while args:
    a = args.pop(0)
    if a in ("--set", "--json", "--started", "--new-round", "--end-round", "--plan", "--short", "--running", "--failed", "--labels") and not args:
        die(f"{a} needs a value")
    if a in ("--set", "--json"):
        key, eq, value = args.pop(0).partition("=")
        if not eq or not key:
            die(f"{a} takes key=value")
        if a == "--json":
            try:
                value = json.loads(value)
            except ValueError:
                die(f"--json {key}: not JSON")
        sets.append((key, value))
    elif a == "--started":
        started = args.pop(0)
    elif a == "--new-round":
        try:
            new_round = int(args.pop(0))
        except ValueError:
            die("--new-round takes a round number")
    elif a == "--end-round":
        end_round = args.pop(0)
    elif a == "--plan":
        plan = args.pop(0)
    elif a == "--short":
        part, eq, value = args.pop(0).partition("=")
        if not eq:
            die("--short takes <part>=<short>")
        shorts.append(("" if part.strip().upper() in ("", "PLAN") else part.strip().upper(), value.strip()))
    elif a in ("--running", "--failed", "--labels"):
        passed += [a, args.pop(0)]
    else:
        die(f"unknown argument {a}")
if (passed or shorts) and not plan:
    die("--running, --failed, --labels and --short need --plan")
if plan and not os.path.isfile(plan):
    die(f"no plan at {plan}")

state = json.load(open(path, encoding="utf-8")) if os.path.exists(path) else {}
if started is not None and (not state.get("startedAt") or state.get("state") == "done"):
    state["startedAt"] = now if started == "now" else started
for key, value in sets:
    state[key] = value
appended = False
if new_round is not None:
    rounds = state.setdefault("rounds", [])
    if not any(r.get("n") == new_round for r in rounds):
        rounds.append({"n": new_round, "startedAt": now})
        appended = True
if end_round is not None:
    open_rounds = [r for r in state.get("rounds") or [] if not r.get("endedAt")]
    if open_rounds:
        open_rounds[-1].update({"endedAt": now, "verdict": end_round})
    else:
        print("state.sh: --end-round: no open round", file=sys.stderr)
for letter, short in shorts:
    parts = state.setdefault("parts", [])
    title = f"Part {letter}" if letter else ""
    match = [p for p in parts if (p.get("title", "").startswith(title + ":") or p.get("title", "") == title) and (letter or not p.get("title"))]
    if match:
        match[0]["short"] = short
    else:
        parts.append({"title": title, "short": short})
state["updatedAt"] = now

folder = os.path.dirname(os.path.abspath(path))
os.makedirs(folder, exist_ok=True)
fd, tmp = tempfile.mkstemp(dir=folder, prefix=".state-", suffix=".json")
try:
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)
        f.write("\n")
    if plan:
        cmd = ["bash", steps_script, tmp, plan] + passed + (["--new-round"] if appended else [])
        if subprocess.run(cmd).returncode != 0:
            die("state-steps.sh failed; the state file is unchanged")
    os.replace(tmp, path)
finally:
    if os.path.exists(tmp):
        os.unlink(tmp)
PY
