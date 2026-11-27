#!/usr/bin/env python3
"""Decides whether /my:run stops after a round, from the round's facts (skills/plan/run/SKILL.md § Run).

Input: a JSON object of facts, from a file or `-` for stdin. A fact left out did not happen.
  gate               a gate the plan or rules/core.md names, reached (its name: "Plan approval")
  gateAnswer         "go on" or "end": the user's answer to that gate
  driftOverBudget    step 2's drift gate
  decisions          [{"kind": "K7", "flag": "boundary", "handedOver": false}], decisions for the user
  verificationFailed, conflictsWithMain, laneConflict, redCiAtStart, readyForReview,
  pushRejected, pushDisabled, executorStopped, laneMergeFailed   true or false
  newComments        PR comments not covered by the source;  openQuestions  questions still open
  toPublish          what waits to be published (the draft-PR question, replies, ticket changes)
  consecutiveRounds  rounds this run has done in a row
Output: `stop: <reason>` at the first entry of the stop list that holds, else `go: round succeeded`
(with the decisions taken alone). Exit 2 on an unknown fact or a wrong type.
Usage: stop-policy.py <facts.json | ->
"""
import json, sys

BOOLS = {"driftOverBudget", "verificationFailed", "conflictsWithMain", "laneConflict", "redCiAtStart",
         "readyForReview", "pushRejected", "pushDisabled", "executorStopped", "laneMergeFailed"}
INTS = {"newComments", "openQuestions", "consecutiveRounds"}
OTHER = {"gate", "gateAnswer", "decisions", "toPublish"}
ROUND_CAP = 5


def decide(f):
    """The stop list of /my:run § Run, in its order; the first that holds wins."""
    answered = f.get("gateAnswer")
    if answered == "end":
        return "stop: Run ended by the answer"
    # 1. A gate the plan or rules/core.md names (drift over budget is step 2's), and any decision for the
    #    user, unless the method lets the run decide its kind alone: then it is decided and listed.
    if f.get("gate") and answered != "go on":
        return f"stop: {f['gate']}"
    if f.get("driftOverBudget") and answered != "go on":
        return "stop: Drift over budget"
    alone = []
    for d in f.get("decisions") or []:
        if d.get("handedOver"):
            alone.append(f"decided alone (handed over: {d.get('kind', '?')})")
        else:
            return f"stop: Decision needed ({d.get('flag') or d.get('kind') or 'user'})"
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
    if f.get("pushRejected") and not f.get("pushDisabled"):
        return "stop: Push rejected"
    if f.get("executorStopped"):
        return "stop: Executor stopped"
    if f.get("laneMergeFailed"):  # lane-merge.sh "merge failed": no conflict, yet the lane did not merge
        return "stop: Executor stopped (lane merge failed)"
    if f.get("openQuestions", 0) > 0:
        return "stop: Open question"
    return "go: round succeeded" + "".join(f"; {a}" for a in alone)


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
        if k == "gate" and v is not None and not isinstance(v, str):
            return "gate must be a gate's name"
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
