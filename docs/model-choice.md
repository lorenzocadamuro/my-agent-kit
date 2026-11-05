# Which model an agent runs on

An agent the kit starts runs on the session's model unless this table names another. The kit names one only where a cheaper model was tested in that role; everywhere else the user controls the cost by choosing the session's model. No skill names a model itself: each sentence that starts an agent points here.

| Role | Started at | Model | Why | Tested |
| ---- | ---------- | ----- | --- | ------ |
| Research search agent | `plan:scope` step 3, phase 1 | `sonnet` | it only searches and decides nothing; each answer cites `file:line` or says `unknown`, and the coordinator checks what it uses | claude-sonnet-5-5, 2026-11-05 |
| Research analysis agents | `plan:scope` step 3, phase 2 | session model | they judge how the code works and what the change does to it | — |
| Plan review | `plan:scope` step 6 | session model | a guard: what it misses reaches every round | — |
| Triage check | `plan:round` step 4 | session model, A/B pending on captured rounds | a guard: what it misses reaches the executor silently | — |
| Executor, and its `SendMessage` continuation | `plan:round` step 5 | session model | it writes the code | — |
| Round review | `plan:round` step 7 | session model | a guard: it moves only after an A/B on real rounds | — |
| Deep review (the outer agent) | `plan:round` step 7 | session model | the repository's own tool picks the models of the agents it starts; the kit does not set them | — |
| `pr:review` agents | `pr:review` step 3 | session model | they judge the PR | — |
| `improve run` review | `improve` § Run, step 6 | session model | it judges a change to the kit | — |
| Any other agent the coordinator starts | — | session model | the default | — |

## Rules

- A Sonnet row passes `model: "sonnet"` to the Agent tool, except when the session's model is cheaper (Haiku): then it passes none, so the kit never raises the cost above the session the user chose.
- A session-model row passes no `model`: the agent inherits the session's.

## Fallback

- A Sonnet agent whose result omits an item of its list, or gives a claim without `file:line` evidence, runs once more with no `model`, on the session's model.
- An item answered `unknown: <what could not be read>` (no `gh`, no git, no access) is not a reason to rerun.

## Tested

- The Tested column names the model the `sonnet` alias gave when the row was tested. When the alias moves to another model, the A/B behind the row runs again before the row is trusted.

## Pending

- The triage check's A/B waits for at least 3 rounds saved under `<data root>/trials/triage-before-check/` (`plan:round` step 4).
