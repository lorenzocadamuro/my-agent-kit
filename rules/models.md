# Which model an agent runs on

An agent the kit starts runs on the session's model unless this table names another. The kit names one only where the role decides nothing and its answers are checked, or where a cheaper model matched the session's model in an A/B on that role; everywhere else the user controls the cost by choosing the session's model. No skill names a model itself: each sentence that starts an agent points here.

| Role | Started at | Model | Why | Tested |
| ---- | ---------- | ----- | --- | ------ |
| Research search agent | `plan:scope` step 3, phase 1 | `sonnet` | it only searches and decides nothing; each answer cites `file:line` or says `unknown`, and the coordinator checks what it uses | claude-sonnet-5-5, 2026-11-05: `plan/research-search-on-sonnet` (size M), 2 of 2; no A/B (it decides nothing) |
| Research analysis agents | `plan:scope` step 3, phase 2 | session model | they judge how the code works and what the change does to it | — |
| Plan review | `plan:scope` step 6 | session model | a guard: what it misses reaches every round | — |
| Triage check | `plan:run` step 4 | session model | a guard: what it misses reaches the executor silently | — |
| Executor, and its `SendMessage` continuation | `plan:run` step 5 | session model | it writes the code | — |
| Round review | `plan:run` step 7 | session model | a guard: what it misses is pushed silently | — |
| Deep review (the outer agent) | `plan:run` step 7 | session model | the repository's own tool picks the models of the agents it starts; the kit does not set them | — |
| `pr:review` agents | `pr:review` step 3 | session model | they judge the PR | — |
| `improve run` review | `improve` § Run, step 6 | session model | it judges a change to the kit | — |
| Any other agent the coordinator starts | — | session model | the default | — |

## Rules

- A Sonnet row passes `model: "sonnet"` to the Agent tool, except when the session's model is cheaper (Haiku): then it passes none, so the kit never raises the cost above the session the user chose.
- A session-model row passes no `model`: the agent inherits the session's.

## Fallback

- A Sonnet agent whose result omits an item of its list, or gives a claim without `file:line` evidence, runs once more with the same prompt and no `model`, on the session's model.
- An item answered `unknown: <what could not be read>` (no `gh`, no git, no access) is not a reason to rerun.

## Tested

- The Tested column names the model the `sonnet` alias gave when the row was tested. When the alias moves to another model, the tests or the A/B named in a row run again before the row is trusted.
