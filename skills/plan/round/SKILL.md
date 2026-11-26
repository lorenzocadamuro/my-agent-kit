---
name: round
description: "Run one round of work on a change against its plan, autonomously, then report and stop: triage checked for items the plan did not specify and executed by background agents (except for size S), verification against git, fresh review, draft push."
argument-hint: "[source: plan part | file | list] [--triage-only] [--verify N] [--deep] [--no-push]"
disable-model-invocation: true
when: "\"/my:round\", \"run the next round\", \"esegui il giro\", \"fix these findings\", \"implement part B of the plan\""
reads: [rules/core.md, rules/plan-contract.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/files.md, rules/question-format.md, rules/review-lenses.md, rules/model-choice.md]
---

# /my:round

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md`, `${CLAUDE_PLUGIN_ROOT}/rules/files.md`, `${CLAUDE_PLUGIN_ROOT}/rules/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/rules/review-lenses.md` and `${CLAUDE_PLUGIN_ROOT}/rules/model-choice.md`.

Read `${CLAUDE_PLUGIN_ROOT}/skills/plan/run/SKILL.md` and follow it as `round`, with `$ARGUMENTS`: steps 1 to 11 once, then report and stop.
