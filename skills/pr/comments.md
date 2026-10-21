# /my:pr:comments — what each comment means, and what to do about it

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, and `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md`.

## Arguments

| Argument        | What it selects                                                                     |
| --------------- | ----------------------------------------------------------------------------------- |
| PR              | A number or URL, or else the PR of the current branch                               |
| `new` (default) | Unresolved threads, plus comments created since the last run (the state file below) |
| `all`           | Every unresolved thread, plus review and issue comments                             |
| A comment URL   | Just that comment                                                                   |

Pasted comments work too, when `gh` is unavailable.

## Steps

1. **Collect.**
   - Review threads, with their resolved state, through GraphQL: `gh api graphql` over `pullRequest.reviewThreads(first:100){nodes{id isResolved comments(first:20){nodes{databaseId author{login} body path line originalCommit{oid} createdAt url}}}}`.
   - Review bodies, and issue comments (`gh api repos/<o>/<r>/issues/<n>/comments`).
   - The state file `<worktree>/.plans/comments-state.json` holds the last run's time and the ids already triaged. Outside a worktree, use the scratchpad.
2. **Group duplicates.** Several bots, or a bot and a human, often flag one root cause. Group by root cause, not by text, and keep one entry per group that lists every comment URL.
3. **Check each group against the code at HEAD:**
   - Is the issue still present? Has a later commit already fixed it? Compare the comment's commit with HEAD.
   - Read the code the comment points to, plus its callers and tests.
   - Classify the group as **real**, **duplicate** (of which group), **not a bug** (with evidence), **already fixed** (with the commit), or **out of scope** (outside the PR's plan or diff).
   - A real group that the plan, the research or a round's review should have caught is a signal (principles: closing step). Read the plan (`.plans/plan.md`, or the one the user names) to judge it.
4. **Weigh and act.** Weight each group by the lenses doc § Grading a finding. Pick a proportional action: fix, document, ticket, or reply only. A low-value style point on a local tool does not get an elaborate fix.
5. **Draft the replies:** at most 3 sentences, factual, in English.
   - Fixed: "Addressed in `<sha>`: <how>."
   - Not a bug: the evidence, with `file:line`.
   - Ticket: "Out of scope for this PR; tracked in <ticket>."
6. **Output.**
   - **Chat:** a table with one row per group: comment(s), plain explanation (2 lines), class, weight, action.
   - **File:** `<worktree>/.plans/comments-<date>.md` (or the scratchpad), holding the table, the evidence and the reply drafts. Items marked "fix" are written as `### <k>. <claim>` entries, so `/my:plan:round` and `/my:plan:run` can take the file as their input.
   - **State file:** update it.
7. **Gate.** Paste the reply drafts in chat, and ask which to post (all, a selection, or none) and whether to resolve the answered threads. Post with `gh api repos/<o>/<r>/pulls/<n>/comments -X POST -f body=… -F in_reply_to=<id>`, and resolve with the GraphQL `resolveReviewThread` mutation, only for what the user approved. Never resolve a thread whose fix is not yet pushed.
8. **Suggest the next step:**
   - `/my:plan:run <comments file>` when fixes are pending;
   - the repository's own comment resolver, when the project profile names one, as an alternative.
9. **Closing step** from the principles.
