# /my:plan:round and /my:plan:run — rounds, no babysitting

You are the coordinator. You stay in the user's session and hand the work to background agents, except in the S lane: a plan whose header says `Size: S` skips the triage check, and you make its changes yourself (steps 4–5); a plan without a Size header takes the full lane. The user hears from you at the start, at gates, and at the end.

- **`round`** runs one round (steps 1–11), reports, and stops.
- **`run`** runs rounds one after another, as § Run says, until something needs the user.
- **Every gate follows the principles' method:** you decide a handed-over kind alone and list it in the report, record the other answers in `<data root>/method.md`, and propose due hand-overs; the executor only reports.

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md`.

## Arguments

| Argument        | Effect                                                                                                                                                                                          |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| source          | `part B` of the plan; a file (`.plans/comments-<date>.md`, a review file); or a list in plain words. By default, the open block findings of the last review (`.plans/round-<N>-review.md`), or else the next unfinished plan part. In `run`, the first round starts there and the next ones follow the plan |
| `--triage-only` | Build (and, above S, check) the triage, then stop and show it. Refused with `run`                                                                                                             |
| `--verify N`    | Skip to step 6 for round N, when its executor has already finished. In `run`, resume there and then loop                                                                                       |
| `--deep`        | Also run the deep review: this round; in `run`, when a part finishes and at the ready-for-review gate                                                                                         |
| `--no-push`     | Do not push                                                                                                                                                                                     |

## The state file

Write the state file (name and shape in `${CLAUDE_PLUGIN_ROOT}/docs/local-data.md` § State file) at the start of each round, at each step below, at each gate and its answer, and at the end. Rewrite it whole, keeping `name` and every field you do not change, through a temp file and a rename, so a reader never sees half a file. It feeds the optional status mod, and a resuming run reads it. A `reason` is two or three words (`Tests failing`).

At the end of a round or a run, set `state`: `done` when the bar is met (the ready-for-review gate); `needs_you` with a `reason` when a gate or a question waits for the user; `stopped` with a `reason` when verification failed or the run hit its cap; otherwise `ready`, waiting for the next round.

## Steps

### 1. Load

- **The plan:** `<worktree>/.plans/plan.md`. If it is missing, offer `/my:plan:scope --adopt`. For a tiny task, the user may prefer three questions (goal, boundary, bar) and a stub plan instead; a stub plan writes `Size: S` and takes the S lane.
- **The project profile:** commands, the guides to load for the touched paths, the deep review tool.
- **New PR comments:** those created since the previous round (its `Comments read until` line), read with the query of `pr:comments` step 1 but without touching its state file. A real comment that the plan, the research or the last review should have caught is a signal (principles: closing step). When comments need work, suggest `/my:pr:comments` to turn them into this round's source. Comments a `pr:comments` file covers count as read when that file is the source: move `Comments read until` past them.
- **CI:** read it through the app's PR status tool when one is available. Never poll.

### 2. Preflight

- A linked worktree on the change's branch, or what the profile names instead (principles: always in a worktree), with a clean tree.
- Record HEAD, and whether it equals its upstream.
- Run `${CLAUDE_PLUGIN_ROOT}/scripts/drift.sh --lines <budget> --files <budget>`, with the budgets taken from the plan.
- **If main moved and the preview shows conflicts,** ask whether to run `/my:pr:sync` first.
- **If drift is over budget,** that is a gate: split, accept with a reason, or cut scope.

### 3. Triage

Write `.plans/round-<N>.md` from `${CLAUDE_PLUGIN_ROOT}/templates/round.md`, where N is the next unused number, and copy its `Comments read until` time into the state file's `commentsReadUntil` (`none` leaves the field as it was). For every item:

- **Verify the claim against the code at HEAD,** and drop or rewrite what does not hold.
- **List the callers covered, by path,** with the untruncated count.
- **Name the owning code point,** and a test that fails without the fix and drives the production caller. A check-only item names instead the commands it runs and the result that counts as passing.
- **Write the stop conditions.** They use the plan's "every round" checks; the "once, at the end" proof belongs to the ready-for-review gate. A check copied from the plan or the profile keeps its baseline (principles: measure the baseline).

Items outside the plan's scope, and findings labelled "ticket", go to "Not this round", with ticket text and no fix. An item whose only fix crosses the boundary or a repository rule is a gate: ask before executing.

### 4. Independent triage check

In the S lane, skip this check and write `Triage check: skipped (size S)` in the round file. Otherwise, run a fresh agent with [triage-check.md](triage-check.md) and fix what it finds. Anything that needs the user becomes a gate question. In both lanes, `--triage-only` stops here and shows the triage.

### 5. Execute

- Mark a session chapter `Round N · <goal>` with the app's chapter tool; skip it when the tool is missing.
- Tell the user in one line, in their language, that round N started with k items and that they will hear from you at a gate or at the end. In `run`, say it for the first round only.
- **S lane:** make the changes yourself, following [executor.md](executor.md) § How, except its Progress line, and § Stop and report, except that you ask the user (a gate) where it says to stop. After each item, update `items` in the state file (no progress sidecar); at the end, write `.plans/round-<N>-summary.md` in the shape of `${CLAUDE_PLUGIN_ROOT}/templates/round-summary.md`.
- **Full lane:** launch a **background** general-purpose agent with [executor.md](executor.md), filled in: the worktree path, the round file, the guides, the commands, and the absolute path of the progress sidecar (the state file's path, `.json` becoming `.progress.json`).
  - **When the agent stops with questions,** ask the user (gate, with a notification), then continue the same agent with `SendMessage`.
  - **When it finishes,** write its returned summary to `.plans/round-<N>-summary.md`.

### 6. Verify

When the round's verification needs a manual check in the browser, follow the profile's "Manual testing" rule. Moving the local stack to this worktree is a gate: ask, then move it back afterwards.

- Run `${CLAUDE_PLUGIN_ROOT}/scripts/verify-round.sh .plans <N>`. A missing item, a fake commit or a dirty tree fails the round: report it, and never paper over it.
- **Check the summary's claims yourself:** audit counts, test results, and every decision taken alone.
  - A decision flagged boundary, rule or someone else's code is a gate.
  - Any other decision is listed in the report.
- **Tick the plan:** for each verified item that implements a step of a plan part, tick its checkbox in `plan.md`. A part is done when all its boxes are ticked; a plan without parts counts as one part.
- **Record signals** (principles: closing step) for rework, stopped items, and reversed decisions.

### 7. Review

- **Every round,** a fresh agent runs [reviewer.md](reviewer.md) on `<round start>..HEAD`, against the plan.
- **At milestones,** also run the profile's deep review tool through a background agent, with the plan's bar as the stop criterion. The milestones are `--deep`, the ready-for-review gate, and drift over budget.
- **Write `.plans/round-<N>-review.md`:** the verdict against the bar, then the findings under **Block**, **Ticket** and **Note**. The next round reads its block findings from there.
- **Sort the findings:**
  - **block** → next round's items;
  - **ticket** → append to `.plans/tickets.md`;
  - **note** → listed in the report.
- A block finding the plan did not foresee is a signal.

### 8. Push

- If verification passed and `--no-push` is not set, run `git push`, fast-forward only.
- **No PR yet:** the first push asks once whether to open a **draft** PR, because that is published text. Build its body with the profile's PR description tool when there is one.

### 9. Report

In `round`, first run `/my:improve digest` on this session's signals file (principles: closing step). In `run`, the digest waits for the end of the run.

Six lines, labels as shown and sentences in the user's language, and a desktop notification when the round ran long (in `run`, the notification waits for the end):

```
Round N: <k done / c checked / m stopped / s skipped>  ·  HEAD <sha> (pushed | not pushed: why)
Review: <verdict against the bar>; block <b>, ticket <t>, note <n>
Drift: <lines>/<budget> lines, <files>/<budget> files; main <ahead/behind>
Decisions taken alone: <count, or the flagged ones>; handed over: <K<n> decided alone, or none>
Lessons: <note ids from the digest | none | at the end of the run>
Next: <Run plan | One round | Review comments | Merge main | a question | ready-for-review gate>
```

### 10. Ready-for-review gate

When the review says the bar is met and no block finding remains:

1. Run the plan's "once, at the end" checks. If one fails, the bar is not met: its failures become the next round's items, and the state stays `ready` (or `needs_you` when the fix is a decision). Then run `/my:pr:review` on the PR in `local` mode and the deep review, if this round did not already.
2. Write a one-page retrospective to `<data root>/retros/<repo>-<branch>.md`: rounds, rework and its causes, decision reversals, drift, and what the reviewers asked.
3. Ask the user, one question each: mark the PR ready, update the description, notify the reviewers (all of these are publishing).

### 11. Closing step

Follow the principles. In `round`, the digest already ran in step 9; run it again only for signals recorded after the report.

## Run

`run` repeats steps 1–9 without the user, round after round. Each round reports one line (`Round N: k done · verdict · next`) instead of the six-line report; the full summary comes at the end.

- **A round succeeds** when verification passed, the push is done or disabled, and no question is open.
- **After a round that succeeds,** start the next one at once: the block findings in `.plans/round-<N>-review.md` first, then the next unfinished part. Finishing a part does not stop the run, unless the plan puts a gate there.
- **Stop the run** at the first of:
  - a gate the plan or the principles name, and any decision for the user (boundary, a repository rule, someone else's code);
  - failed verification;
  - drift over budget;
  - conflicts with main;
  - new PR comments not covered by the source (suggest "Review comments");
  - red CI known at round start;
  - anything to publish: the first push's draft-PR question, replies, ticket changes;
  - the ready-for-review gate (step 10 runs, its questions are the stop);
  - 5 consecutive rounds;
  - any other round that does not succeed (a rejected push, an executor that stopped).
- **After the user answers a gate,** the run goes on under the same rules, unless the answer ends it.
- **At each round start,** re-read this section, the plan and the state file, so a compacted session resumes where it was.
- **At the end:** run `/my:improve digest` once, send one desktop notification, set the state file to `needs_you`, `stopped` or `done`, and give one summary, labels as shown and sentences in the user's language:

```
Run: <r> rounds · <parts done>/<parts> parts · <elapsed>
Rounds: <one line each: N, items done, verdict>
Stopped: <why, in one plain phrase, and what is needed from the user>
Lessons: <note ids from the digest | none>
Next: <the action that unblocks it>
```
