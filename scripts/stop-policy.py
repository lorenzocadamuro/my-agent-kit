#!/usr/bin/env python3
"""Decides whether /my:run stops after a round, from the round's facts (skills/plan/run/SKILL.md § Run).

Input: a JSON object of facts, from a file or `-` for stdin. A fact left out did not happen.
  gate               a gate the plan or rules/core.md names, reached: its name ("Plan approval"), or
                     {"name": …, "kind": "K12", "handedOver": true} when the method may decide its kind
  gateAnswer         "go on" or "end": the user's answer to that gate
  driftOverBudget    step 2's drift gate: true, or {"kind": "K127", "handedOver": true}
  decisions          every decision taken alone in the round, from the summary:
                     [{"kind": "K7", "flag": "none", "handedOver": false, "answered": false}];
                     flag is none, boundary, rule, other's code or relaxed check (a relaxed check or
                     stop condition); answered: the user already answered it
  verificationFailed, conflictsWithMain, laneConflict, redCiAtStart, readyForReview,
  pushRejected, pushDisabled, executorStopped, laneMergeFailed   true or false
  newComments        PR comments not covered by the source;  openQuestions  questions still open
  toPublish          what waits to be published (the draft-PR question, replies, ticket changes)
  consecutiveRounds  rounds this run has done in a row
Output: `stop: <reason>` at the first entry of the stop list that holds, else `go: round succeeded`,
each followed by the decisions taken alone. A decision stops only when it is flagged and its kind is
not handed over; boundary, rule and other's code never go on through a hand-over (README § The method).
Exit 2 on an unknown fact, an unknown flag or a wrong type.
Usage: stop-policy.py <facts.json | ->
"""
import json, sys

BOOLS = {"verificationFailed", "conflictsWithMain", "laneConflict", "redCiAtStart",
         "readyForReview", "pushRejected", "pushDisabled", "executorStopped", "laneMergeFailed"}
INTS = {"newComments", "openQuestions", "consecutiveRounds"}
OTHER = {"gate", "gateAnswer", "driftOverBudget", "decisions", "toPublish"}
FLAGS = {"none", "boundary", "rule", "other's code", "relaxed check"}
NEVER_HANDED_OVER = {"boundary", "rule", "other's code"}
ROUND_CAP = 5


def decide(f):
    """The stop list of /my:run § Run, in its order; the first that holds wins."""
    alone, needed = [], None
    for d in f.get("decisions") or []:
        flag = d.get("flag") or "none"
        if d.get("answered"):
            continue
        if d.get("handedOver") and flag not in NEVER_HANDED_OVER:
            alone.append(f"decided alone (handed over: {d.get('kind', '?')})")
        elif flag != "none":
            needed = needed or f"stop: Decision needed ({flag})"
        else:
            alone.append(f"decided alone ({d.get('kind', '?')}, flag none)")
    gate, drift = f.get("gate"), f.get("driftOverBudget")
    for g in (gate, drift):
        if isinstance(g, dict) and g.get("handedOver"):
            alone.append(f"decided alone (handed over: {g.get('kind', '?')})")
    return reason(f, gate, drift, needed) + "".join(f"; {a}" for a in alone)


def reason(f, gate, drift, needed):
    answered = f.get("gateAnswer")
    if answered == "end":
        return "stop: Run ended by the answer"
    # 1. A gate the plan or rules/core.md names (drift over budget is step 2's), and any decision for the
    #    user, unless the method lets the run decide its kind alone: then it is decided and listed.
    if gate and answered != "go on" and not (isinstance(gate, dict) and gate.get("handedOver")):
        return f"stop: {gate['name'] if isinstance(gate, dict) else gate}"
    if drift and answered != "go on" and not (isinstance(drift, dict) and drift.get("handedOver")):
        return "stop: Drift over budget"
    if needed:
        return needed
    # 2. Failed verification.
    if f.get("verificationFailed"):
        return "stop: Verification failed"
    # 3. Conflicts with main, or between lanes (rules/parallel.md).
    if f.get("conflictsWithMain"):
        return "stop: Conflicts with main"
    if f.get("laneConflict"):
        return "stop: Lane conflict"
    # 4. New PR comments not covered by the source.
    if f.get("newComments", 0) > 0:
        return "stop: New PR comments (suggest Review comments)"
    # 5. Red CI known at round start.
    if f.get("redCiAtStart"):
        return "stop: Red CI"
    # 6. Anything to publish.
    if f.get("toPublish"):
        what = f["toPublish"]
        return "stop: To publish" + (f" ({', '.join(what)})" if isinstance(what, list) else "")
    # 7. The ready-for-review gate.
    if f.get("readyForReview"):
        return "stop: Ready for review"
    # 8. 5 consecutive rounds.
    if f.get("consecutiveRounds", 0) >= ROUND_CAP:
        return "stop: Round cap"
    # 9. Any other round that does not succeed: a round succeeds when verification passed, the push is
    #    done or disabled, and no question is open.
    if f.get("pushRejected"):
        return "stop: Push rejected"
    if f.get("executorStopped"):
        return "stop: Executor stopped"
    if f.get("laneMergeFailed"):  # lane-merge.sh "merge failed": no conflict, yet the lane did not merge
        return "stop: Executor stopped (lane merge failed)"
    if f.get("openQuestions", 0) > 0:
        return "stop: Open question"
    return "go: round succeeded"


def check(f):
    if not isinstance(f, dict):
        return "the facts must be a JSON object"
    for k, v in f.items():
        if k in BOOLS and not isinstance(v, bool):
            return f"{k} must be true or false"
        if k in INTS and (isinstance(v, bool) or not isinstance(v, int)):
            return f"{k} must be a number"
        if k == "gateAnswer" and v not in ("go on", "end"):
            return "gateAnswer must be \"go on\" or \"end\""
        if k == "decisions" and not (isinstance(v, list) and all(isinstance(d, dict) for d in v)):
            return "decisions must be a list of objects"
        if k == "decisions":
            for d in v:
                if (d.get("flag") or "none") not in FLAGS:
                    return f"unknown flag {d.get('flag')!r}: flags are " + ", ".join(sorted(FLAGS))
        if k == "gate" and v is not None and not (isinstance(v, str) or isinstance(v, dict) and isinstance(v.get("name"), str)):
            return "gate must be a gate's name, or an object with its name"
        if k == "driftOverBudget" and not isinstance(v, (bool, dict)):
            return "driftOverBudget must be true, false or an object"
        if k not in BOOLS | INTS | OTHER:
            return f"unknown fact {k}"
    return None


def main(argv):
    if len(argv) != 2:
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    try:
        facts = json.load(sys.stdin if argv[1] == "-" else open(argv[1], encoding="utf-8"))
    except (OSError, ValueError) as e:
        print(f"stop-policy.py: {e}", file=sys.stderr)
        return 2
    err = check(facts)
    if err:
        print(f"stop-policy.py: {err}", file=sys.stderr)
        return 2
    print(decide(facts))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
