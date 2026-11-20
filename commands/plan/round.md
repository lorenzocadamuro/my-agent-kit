---
description: "Run one round of work on a change against its plan, autonomously, then report and stop: triage checked for items the plan did not specify and executed by background agents (except for size S), verification against git, fresh review, draft push. Use for \"/my:plan:round\", \"run the next round\", \"esegui il giro\", \"fix these findings\", \"implement part B of the plan\"."
argument-hint: "[source: plan part | file | list] [--triage-only] [--verify N] [--deep] [--no-push]"
---

Invoke the `my:plan` skill with the Skill tool, passing the arguments `round $ARGUMENTS`. Then, before any other step, read `round.md` in the skill's base directory (the one the Skill tool names) and follow it.
