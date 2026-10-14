---
name: pr-round
description: Run one round of work on a change, autonomously, against its plan. Builds and independently checks the round's triage (from a plan part, an explain-comment file, review findings, or a list), executes it with a background agent in the change's worktree (test first, one commit per item), verifies the summary against git, runs a fresh conformance review against the plan (deep review at milestones), pushes the draft branch, and reports in five lines with a drift signal. Stops only at the agreed gates and notifies the user. Use for "/my:pr-round", "run the next round", "esegui il giro", "fix these findings", "implement part B of the plan".
argument-hint: "[source: plan part | file | list] [--triage-only] [--verify N] [--deep] [--no-push]"
---

# /my:pr-round — one round, no babysitting

You are the coordinator. You stay in the user's session; all the work happens in background agents. The user hears from you at the start, at gates, and at the end.

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md`.

**Data root:** `$MY_AGENT_KIT_HOME`, or a root the user names; otherwise `~/.my-agent-kit`.

## Arguments

| Argument        | Effect                                                                                                                                                                                          |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| source          | `part B` of the plan; a file (`.plans/comments-<date>.md`, a review file); or a list in plain words. By default, the next unfinished plan part, or the open block findings from the last review |
| `--triage-only` | Build and check the triage, then stop and show it                                                                                                                                               |
| `--verify N`    | Skip to step 6 for round N, when its executor has already finished                                                                                                                              |
| `--deep`        | Also run the deep review this round                                                                                                                                                             |
| `--no-push`     | Do not push                                                                                                                                                                                     |

## Steps

### 1. Load

- **The plan:** `<worktree>/.plans/plan.md`. If it is missing, offer `/my:scope-plan --adopt`. For a tiny task, the user may prefer three questions (goal, boundary, bar) and a stub plan instead.
- **The project profile:** commands, the guides to load for the touched paths, the deep review tool.

### 2. Preflight

- A linked worktree, on the change's branch, with a clean tree.
- Record HEAD, and whether it equals its upstream.
- Run `${CLAUDE_PLUGIN_ROOT}/scripts/drift.sh --lines <budget> --files <budget>`, with the budgets taken from the plan.
- **If main moved and the preview shows conflicts,** ask whether to run `/my:merge-main` first.
- **If drift is over budget,** that is a gate: split, accept with a reason, or cut scope.

### 3. Triage

Write `.plans/round-<N>.md` from `${CLAUDE_PLUGIN_ROOT}/templates/round.md`, where N is the next unused number. For every item:

- **Verify the claim against the code at HEAD,** and drop or rewrite what does not hold.
- **List the callers covered, by path,** with the untruncated count.
- **Name the owning code point,** and a test that fails without the fix and drives the production caller.
- **Write the stop conditions.**

Items outside the plan's scope, and findings labelled "ticket", go to "Not this round", with ticket text and no fix.

### 4. Independent triage check

Run a fresh agent with [triage-check.md](triage-check.md). Fix what it finds. Anything that needs the user becomes a gate question. With `--triage-only`, stop here and show the triage.

### 5. Execute

- Launch a **background** general-purpose agent with [executor.md](executor.md), filled in: the worktree path, the round file, the guides, the commands.
- Tell the user in one line: `Round N started: k items. I'll notify you at a gate or when it ends.`
- **When the agent stops with questions,** ask the user (gate, with a notification), then continue the same agent with `SendMessage`.
- **When it finishes,** write its returned summary to `.plans/round-<N>-summary.md`.

### 6. Verify

- Run `${CLAUDE_PLUGIN_ROOT}/scripts/verify-round.sh .plans <N>`. A missing item, a fake commit or a dirty tree fails the round: report it, and never paper over it.
- **Check the summary's claims yourself:** audit counts, test results, and every decision taken alone.
  - A decision flagged boundary, rule or someone else's code is a gate.
  - Any other decision is listed in the report.

### 7. Review

- **Every round,** a fresh agent runs [reviewer.md](reviewer.md) on `<round start>..HEAD`, against the plan.
- **At milestones,** also run the profile's deep review tool through a background agent, with the plan's bar as the stop criterion. The milestones are `--deep`, the ready-for-review gate, and drift over budget.
- **Sort the findings:**
  - **block** → next round's items;
  - **ticket** → append to `.plans/tickets.md`;
  - **note** → listed in the report.

### 8. Push

- If verification passed and `--no-push` is not set, run `git push`, fast-forward only.
- **No PR yet:** the first push asks once whether to open a **draft** PR, because that is published text. Build its body with the profile's PR description tool when there is one.
- Read CI through the app's PR status tool when one is available. Never poll.

### 9. Report

Five lines, and a desktop notification when the round ran long:

```
Round N: <k done / m stopped / s skipped>  ·  HEAD <sha> (pushed | not pushed: why)
Review: <verdict against the bar>; block <b>, ticket <t>, note <n>
Drift: <lines>/<budget> lines, <files>/<budget> files; main <ahead/behind>
Decisions taken alone: <count, or the flagged ones>
Next: <next round with b items | ready-for-review gate | a question>
```

### 10. Ready-for-review gate

When the review says the bar is met and no block finding remains:

1. Run `/my:review-lens` on the PR in `local` mode, and the deep review, if this round did not already.
2. Write a one-page retrospective to `<data root>/retros/<repo>-<branch>.md`: rounds, rework and its causes, decision reversals, drift, and what the reviewers asked.
3. Ask the user, one question each: mark the PR ready, update the description, notify the reviewers (all of these are publishing).

### 11. Closing step

Follow the principles. A round with rework, a surprise gate or a decision reversal is worth a `/my:improve note`.
