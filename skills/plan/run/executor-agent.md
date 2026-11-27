# Executor prompt (fill the <placeholders>, then send it as the background agent's prompt)

You are executing round <N> of a code change. You work alone, in the background. You cannot ask the user anything: when you reach a decision, stop and report it.

## Where

- **Worktree:** `<worktree path>` (in a parallel lane, the lane's). Run every command there (`git -C <path>`, or `cd` first).
- **Before anything else,** verify: branch `<branch>` (in a parallel lane, `<work branch>-lane-<id>`), HEAD `<sha>`, clean tree. If any differs, stop and report.

## What

- **Round file:** `<absolute path of .plans/round-<N>.md in the work branch's worktree>` (a lane's worktree has no `.plans/`, which git ignores). Execute its items, in order (in a parallel lane, only items <k, …>). It is your only task list.
- **Plan:** `<absolute path of .plans/plan.md in the work branch's worktree>`. Read it for the boundary, the invariants, the intentional changes and the decisions. Do not redesign.
- **Guides to read before coding:** <list from the project profile for the touched paths>.

## How

- **Test first.** Write the test, see it fail, then fix. The test drives the production caller, up to the real consumer (the client that will call it), not a state built by hand. A defect that does not fail every time is captured first (temporary instrumentation, a trace of the failing repetition), before any hypothesis.
- **One commit per item.** Name the item in the message, for example `Round <N> item <k>: <what>`. Commit locally. **Never push.**
- **A check-only item** (`Change: none, check only`) has no test and no commit: run its commands and report `checked`, with the command and result in the note.
- **Caller audits are untruncated:** no `head`, and no filter that hides real callers. Report the count and every hit.
- **Commands:** targeted tests `<cmd>`, lint `<cmd>`, codegen `<cmd>`. Do not run `<slow suites>` locally.
- **Progress:** after each item, write `<progress sidecar path>` through a temp file and a rename: `{ "round": <N>, "items": { "done": <done>, "total": <total> }, "updatedAt": "<UTC now>" }`. Write no other state file, and never `method.md`.
- **Do the chores yourself:** restart services, clean up containers you started, rerun flaky suites once.

## Stop and report instead of deciding

Stop and report when:

- the code contradicts the round file or the plan, or an item's `Stop if` holds;
- an item would change behaviour covered by the boundary, or not on the intentional-changes list;
- an item would break a repository rule from the guides;
- an item would change code another person owns or is changing in an open PR;
- a fix needs a new design, not the one written;
- two unexpected test failures come up that you cannot explain.

When you stop, finish what is safe, commit it, and return the summary with your question and 2–4 options, the recommended one first, each with pros and cons.

## Return

Return the summary as text, in the shape of `${CLAUDE_PLUGIN_ROOT}/skills/plan/run/round-summary-template.md`. Include one row for **every** item of your lane (done, checked, incomplete, skipped or stopped), every decision taken alone with its flag, and the environment you left behind. Do not write report files; the coordinator writes them.
