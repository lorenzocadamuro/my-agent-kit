# /my:plan:round and /my:plan:run — rounds, no babysitting

You are the coordinator. You stay in the user's session and hand the work to background agents, except in the S lane: a plan whose header says `Size: S` skips the triage check, and you make its changes yourself (steps 4–5); in other lanes the check runs only for items step 3 triaged in full; a plan without a Size header takes the full lane. The user hears from you at the start, at gates, and at the end.

- **`round`** runs one round (steps 1–11), reports, and stops.
- **`run`** runs rounds one after another, as § Run says, until something needs the user.
- **Every gate follows the principles' method:** you decide a handed-over kind alone and list it in the report, record the other answers in the plan (question format § After the answer) and in `<data root>/method.md`, and propose due hand-overs; the executor only reports.

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md`, `${CLAUDE_PLUGIN_ROOT}/docs/model-choice.md`.

## Arguments

| Argument        | Effect                                                                                                                                                                                          |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| source          | `part B` of the plan; a file (`.plans/comments-<date>.md`, a review file); or a list in plain words. By default, the open block findings of the last review (`.plans/round-<N>-review.md`), then the next unfinished part in plan order. In `run`, the first round starts there and the next ones follow the plan |
| `--triage-only` | Build (and, above S, check for items triaged in full) the triage, then stop and show it. Refused with `run`                                                                                   |
| `--verify N`    | Skip to step 6 for round N, when its executor has already finished. In `run`, resume there and then loop                                                                                       |
| `--deep`        | Also run the deep review: this round; in `run`, when a part finishes and at the ready-for-review gate                                                                                         |
| `--no-push`     | Do not push                                                                                                                                                                                     |

## The state file

Write the state file (name and shape in `${CLAUDE_PLUGIN_ROOT}/docs/local-data.md` § State file) at the start of each round, at each step below, at each gate and its answer, and at the end. Rewrite it whole, keeping every field you do not change, through a temp file and a rename, so a reader never sees half a file. It feeds the optional status mod, and a resuming run reads it. A gate's answer is a write too: the state leaves `needs_you` for `running` before you act on the answer. A `reason` is two or three words (`Tests failing`).

**Rounds and steps.** At a round's start, `--verify N` included, append `{ n, startedAt }` to `rounds` (with `--verify N`, only when round N has no entry), and when a part has no `short` or `steps` (a file an older version wrote), fill them from the plan first (`short` at most 16 characters, as local-data.md says). Every write ends with `${CLAUDE_PLUGIN_ROOT}/scripts/state-steps.sh <state file> <plan.md> --running <steps>` (adding `--new-round` right after appending a round's entry), which derives the steps' and parts' statuses from `plan.md`'s boxes, never by hand. Only what cannot be derived is yours: the `rounds` entries, the steps the open round's items implement or rework, passed as `--running` (part letter and step number, a bare number in a plan without parts, from the triage, step 3; a block item that fixes a step reworks it; the same at every write until the one that ends the round, the writes after the executor finishes and during the review and the push included; none at the write that ends the round), and the `failed` mark of step 6. A gate pauses the round and does not end it: the round ends at step 9's report, a round stopped by failed verification included, or when the user's answer to a gate stops the run, and only then set its `endedAt` and `verdict` (the review's verdict against the bar, or `failed: <reason>` when verification failed).

At the end of a round or a run, set `state`: `done` when the bar is met and the ready-for-review gate is answered; `needs_you` with a `reason` when a gate or a question waits for the user; `stopped` with a `reason` when verification failed or the run hit its cap; otherwise `ready`, waiting for the next round.

## Steps

### 1. Load

- **The plan:** `<worktree>/.plans/plan.md`. If it is missing, offer `/my:plan:scope --adopt`; if it is not approved yet (its state file is `planning`, or `needs_you` for "Plan approval"), offer to finish `/my:plan:scope` instead, and run nothing. For a tiny task, the user may prefer three questions (goal, boundary, bar) and a stub plan instead; a stub plan writes `Size: S` and takes the S lane.
- **The project profile:** commands, the guides to load for the touched paths, the deep review tool.
- **New PR comments:** those created since the previous round (its `Comments read until` line), read with the query of `pr:comments` step 1 but without touching its state file. A real comment that the plan, the research or the last review should have caught is a signal (principles: closing step). When comments need work, suggest `/my:pr:comments` to turn them into this round's source. Comments a `pr:comments` file covers count as read when that file is the source: move `Comments read until` past them.
- **CI:** read it through the app's PR status tool when one is available. Never poll.

### 2. Preflight

- A linked worktree on the change's branch, or what the profile names instead (principles: always in a worktree), with a clean tree.
- Record HEAD, and whether it equals its upstream.
- Run `${CLAUDE_PLUGIN_ROOT}/scripts/drift.sh --lines <budget> --files <budget>`, with the budgets taken from the plan (production code: principles, size budget), and `--tests <pathspecs>` when the profile names test paths.
- **If main moved and the preview shows conflicts,** ask whether to run `/my:pr:sync` first.
- **If drift is over budget,** that is a gate: split, accept with a reason, or cut scope.

### 3. Triage

Write `.plans/round-<N>.md` from `${CLAUDE_PLUGIN_ROOT}/templates/round.md`, where N is the next unused number, and copy its `Comments read until` time into the state file's `commentsReadUntil` (`none` leaves the field as it was).

**Ready steps go in as written.** A plan step is unchanged when its bullet line and its label lines (up to the next `- [` or heading), with `[x]` and `[ ]` alike and whitespace ignored, appear as such under the same part letter in `.plans/plan-approved.md`. When that file is missing, or the plan's Boundary, Invariants, Intentional changes or Out of scope differ from it, no step is unchanged. Only `plan:scope` step 7 writes `plan-approved.md`; a round never refreshes it. A step whose six labels (`templates/plan.md` § Parts) are all filled and that is unchanged goes into the round file under its `### <k>.` heading with its labels as written: rerun each of its `Searches:` at HEAD, and mark it `Ready from plan`. A count that moved, a missing or different copy, a step with a label missing, a review block fix and an added item take the full triage.

**Full triage,** for every other item:

- **Verify the claim against the code at HEAD,** and drop or rewrite what does not hold.
- **List the callers covered, by path,** with the untruncated count, and for each field, state, key or rule the item adds, changes or reads to start its own work, its writers across the code base, readers (saved data included), transitions and opened routes (`plan:scope` step 3).
- **Name the owning code point,** and a test that fails without the fix and drives the production caller, in the shape users are told to write it (principles: a test or a check must be able to fail). A check-only item names instead the commands it runs and the result that counts as passing.
- **Pin each clause.** For each invariant or boundary clause the item touches, name the test that fails when that clause alone is broken (removed one at a time), and the tests of its other side: an input the clause must let through (for a check, such as a linter, a regex or a grader, the correct cases it must not flag), and each failure path (an error, a timeout) of a dependency the new work shares with existing code; a boundary like "flag off equals main" covers what runs (hooks, subscriptions, effects, requests), not only what renders. An item that copies an approved artefact diffs the copy against its frozen source and lists every difference the plan does not name. An item that rewrites a rule in prose lists every other sentence stating it, and what the new wording covers against the old.

**Every round,** ready steps included:

- **Verify every claim in "Not this round" and in rows carried from earlier rounds** against the code at HEAD; a claim about an outside source (a comment, a ticket, a doc) is quoted from it as read now, or marked unverified.
- **Plan order:** a round that takes a later part before the next unfinished one says why in its trigger; "next round" is not a reason.
- **Estimate the production lines** each item adds (tests apart; a ready step's `Estimate:`), and again for each item that step 4's check changes. When the drift so far plus the estimate passes the plan's split trigger, step 2's drift gate comes now, before executing, unless step 2 already asked it this round and the estimate has not grown since.
- **Write the stop conditions.** They use the plan's "every round" checks; the "once, at the end" proof belongs to the ready-for-review gate. A check copied from the plan or the profile keeps its baseline (principles: measure the baseline).

Items outside the plan's scope, and findings labelled "ticket", go to "Not this round", with ticket text and no fix. An item whose only fix crosses the boundary or a repository rule is a gate: ask before executing.

### 4. Independent triage check

The check runs on the items step 3 triaged in full, and the round file says `Triage check: run`. The S lane skips it and writes `Triage check: skipped (size S)`; a round whose items are all `Ready from plan` writes `Triage check: skipped (ready steps)` and starts no agent here. A round of an M or L plan that looks small still gets it for its other items. An item added to a round in progress (the user's request, a finding, a message to the executor) goes into the round file first and, outside the S lane, passes this check before it runs. Outside the S lane, first save the triage as it is before its check, for the check's later A/B (`docs/model-choice.md` § Pending): copy `.plans/round-<N>.md` with `cp` to `<data root>/trials/triage-before-check/<owner>-<repo>-<branch>-round-<N>.md` (names as in `local-data.md` § State file); when that file exists (a later check of the same round), use the first free name, `-2`, `-3`, … before `.md`. Then run a fresh agent with [triage-check.md](triage-check.md) (model: `docs/model-choice.md`), its prompt naming the items to check and saying to skip those marked `Ready from plan`; save its report next to the copy, under the copy's name with `-check.md` in place of `.md`, and fix what it finds. Anything that needs the user becomes a gate question. In both lanes, `--triage-only` stops here and shows the triage.

### 5. Execute

- Mark a session chapter `Round N · <goal>` with the app's chapter tool; skip it when the tool is missing.
- Tell the user in one line that round N started with k items and that they will hear from you at a gate or at the end. In `run`, say it for the first round only.
- **S lane:** once step 3's round file is written, make the changes yourself, following [executor.md](executor.md) § How, except its Progress line, and § Stop and report, except that you ask the user (a gate) where it says to stop. After each item, update `items` in the state file (no progress sidecar); at the end, write `.plans/round-<N>-summary.md` in the shape of `${CLAUDE_PLUGIN_ROOT}/templates/round-summary.md`. Steps 6–8 follow as in the full lane: a change you make yourself, however small or directly asked, gets step 7's fresh review before the push.
- **Full lane:** launch a **background** general-purpose agent with [executor.md](executor.md) (model: `docs/model-choice.md`), filled in: the worktree path, the round file, the guides, the commands, and the absolute path of the progress sidecar (the state file's path, `.json` becoming `.progress.json`).
  - **When the agent stops with questions,** ask the user (gate, with a notification), then continue the same agent with `SendMessage`.
  - **When it finishes,** write its returned summary to `.plans/round-<N>-summary.md`.

### 6. Verify

When the round's verification needs a manual check in the browser, follow the profile's "Manual testing" rule. Moving the local stack to this worktree is a gate: ask, then move it back afterwards.

- Run `${CLAUDE_PLUGIN_ROOT}/scripts/verify-round.sh .plans <N>`. A missing item, a fake commit or a dirty tree fails the round: report it, and never paper over it.
- **Check the summary's claims yourself:** audit counts, test results, and every decision taken alone.
  - A decision flagged boundary, rule or someone else's code, or one that relaxes a check or a stop condition, is a gate.
  - Any other decision is listed in the report.
- **Tick the plan:** for each verified item that implements or reworks a step of a plan part and is not to blame (below), tick its checkbox in `plan.md`, in a failed round too. A part is done when all its boxes are ticked; a plan without parts counts as one part. When the plan's steps change, rewrite the part's `steps` from the plan. Then write the state file, which derives the statuses again.
- **When verification fails,** set `state: "stopped"` with a two-or-three-word `reason` (`Tests failing`), and when an item is to blame (its tests fail, its commit is missing), mark its step `failed` and untick its box in `plan.md`, whoever ticked it and in whichever round; blame wins over another item's tick of the same step.
- **Record signals** (principles: closing step) for rework, stopped items, and reversed decisions.

### 7. Review

- **First save the review's inputs** as they are now, for the review's later A/B (`docs/model-choice.md` § Pending): copy `.plans/plan.md`, `.plans/round-<N>.md` and `.plans/round-<N>-summary.md` with `cp` into `<data root>/trials/review-before-check/<owner>-<repo>-<branch>-round-<N>/` (names as in `local-data.md` § State file), and write there `round-<N>.diff`, the diff the review is given (`git diff <round start>..HEAD`); when that folder exists (a later review of the same round), use the first free name, `-2`, `-3`, … after it.
- **Every round,** a fresh agent then runs [reviewer.md](reviewer.md) on `<round start>..HEAD`, against the round's items and the plan (model: `docs/model-choice.md`). When a part that `state-steps.sh` shows done after step 6 was not done at the round's start, the prompt adds: `This round closes Part <X>: also follow its main scenario end to end, with the lenses that fit.` Other rounds' prompts name neither.
- **At milestones,** also run the profile's deep review tool through a background agent (model: `docs/model-choice.md`), with the plan's bar as the stop criterion. The milestones are `--deep`, the ready-for-review gate, and drift over budget.
- **Write `.plans/round-<N>-review.md`:** the verdict against the bar, the line per round item, then the findings under **Block**, **Ticket** and **Note**. The next round reads its block findings from there. Then copy it into the review's `review-before-check/` folder.
- **Sort the findings:**
  - **block** → next round's items;
  - **ticket** → append to `.plans/tickets.md`;
  - **note** → listed in the report; a note on a text the next round rewrites goes with that item.
- A block finding the plan did not foresee is a signal.

### 8. Push

- If verification passed, step 7's review ran, and `--no-push` is not set, run `git push`, fast-forward only.
- **No PR yet:** the first push asks once whether to open a **draft** PR, because that is published text. Build its body with the profile's PR description tool when there is one, and paste it in chat with the question.

### 9. Report

In `round`, first run `/my:improve digest` on this session's signals file (principles: closing step). In `run`, the digest waits for the end of the run.

Six lines, labels as shown, and a desktop notification when the round ran long (in `run`, the notification waits for the end):

```
Round N: <k done / c checked / m stopped / s skipped>  ·  HEAD <sha> (pushed | not pushed: why)
Review: <verdict against the bar>; block <b>, ticket <t>, note <n>
Drift: production <lines>/<budget> lines, <files>/<budget> files; tests <lines> lines apart; main <ahead/behind>
Decisions taken alone: <each unflagged one (a flagged one is a gate), and each handed-over one as "decided alone (handed over: K<n>)"; or none>
Lessons: <note ids from the digest | none | at the end of the run>
Next: <Run plan | One round | Review comments | Merge main | a question | ready-for-review gate>
```

### 10. Ready-for-review gate

When the review says the bar is met and no block finding remains:

1. Run the plan's "once, at the end" checks. If one fails, the bar is not met: its failures become the next round's items, and the state stays `ready` (or `needs_you` when the fix is a decision). Then run `/my:pr:review` on the PR in `local` mode and the deep review, if this round did not already.
2. Write a one-page retrospective to `<data root>/retros/<repo>-<branch>.md`: rounds, rework and its causes, decision reversals, drift, and what the reviewers asked.
3. Ask the user, one question each: mark the PR ready, update the description (the new text pasted in chat), notify the reviewers (all of these are publishing). After the last answer, the state is `done`.

### 11. Closing step

Follow the principles. In `round`, the digest already ran in step 9; run it again only for signals recorded after the report.

## Run

`run` repeats steps 1–9 without the user, round after round. Each round reports one line (`Round N: k done · verdict · next`) instead of the six-line report; the full summary comes at the end.

- **A round succeeds** when verification passed, the push is done or disabled, and no question is open.
- **After a round that succeeds,** start the next one at once: the block findings in `.plans/round-<N>-review.md` first, then the next unfinished part in plan order. Finishing a part does not stop the run, unless the plan puts a gate there.
- **Stop the run** at the first of:
  - a gate the plan or the principles name, and any decision for the user (boundary, a repository rule, someone else's code), unless the method lets you decide it alone (principles: the method): then decide it and list it;
  - failed verification;
  - conflicts with main;
  - new PR comments not covered by the source (suggest "Review comments");
  - red CI known at round start;
  - anything to publish: the first push's draft-PR question, replies, ticket changes;
  - the ready-for-review gate (step 10 runs, its questions are the stop);
  - 5 consecutive rounds;
  - any other round that does not succeed (a rejected push, an executor that stopped).
- **After the user answers a gate,** the run goes on under the same rules, unless the answer ends it.
- **At each round start,** re-read this section, the plan and the state file, so a compacted session resumes where it was.
- **At the end:** run `/my:improve digest` once, send one desktop notification, set the state file to `needs_you`, `stopped` or `done`, and give one summary, labels as shown:

```
Run: <r> rounds · <parts done>/<parts> parts · <elapsed>
Rounds: <one line each: N, items done, verdict>
Decided alone: <as the round report's "Decisions taken alone" line, for the whole run>
Stopped: <why, in one phrase, and what is needed from the user>
Lessons: <note ids from the digest | none>
Next: <the action that unblocks it>
```

When it stops on a decision, introduce it after the summary as question-format § Shape says, so the user can answer it cold after a break: what its terms mean, why the plan needs it, and what each option changes.
