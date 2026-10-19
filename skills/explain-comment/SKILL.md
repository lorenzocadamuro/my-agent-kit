---
name: explain-comment
description: Make sense of PR comments fast, from bots (Bugbot, review bots, CI reviewers) or colleagues. For each comment, gives two plain lines in the user's language, whether it is real / a duplicate / not a bug / out of scope (checked against the code at HEAD), its weight, a proportional action (fix, document, ticket, reply only), and a reply draft in English of 3 sentences or fewer. Saves the triage for /my:pr-round, and posts replies or resolves threads only after the user says yes. Use for "/my:explain-comment", "cosa vuol dire questo commento", "explain these bot comments", "is this Bugbot finding real", "help me answer this review".
argument-hint: "[PR number or URL] [comment URL | new | all]"
---

# /my:explain-comment — what each comment means, and what to do about it

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, and `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md` (the grading rules).

Talk to the user in their language. Reply drafts are in English.

**Data root:** `$MY_AGENT_KIT_HOME`, or a root the user names; otherwise `~/.my-agent-kit`.

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
4. **Weigh and act.** Weight is block, ticket or note, as in the lenses doc. Pick a proportional action: fix, document, ticket, or reply only. A low-value style point on a local tool does not get an elaborate fix.
5. **Draft the replies:** at most 3 sentences, factual, in English.
   - Fixed: "Addressed in `<sha>`: <how>."
   - Not a bug: the evidence, with `file:line`.
   - Ticket: "Out of scope for this PR; tracked in <ticket>."
6. **Output.**
   - **Chat:** a table with one row per group: comment(s), plain explanation (2 lines), class, weight, action.
   - **File:** `<worktree>/.plans/comments-<date>.md` (or the scratchpad), holding the table, the evidence and the reply drafts. Items marked "fix" are written as `### <k>. <claim>` entries, so `/my:pr-round` can take the file as its input.
   - **State file:** update it.
7. **Gate.** Ask which replies to post (all, a selection, or none) and whether to resolve the answered threads. Post with `gh api repos/<o>/<r>/pulls/<n>/comments -X POST -f body=… -F in_reply_to=<id>`, and resolve with the GraphQL `resolveReviewThread` mutation, only for what the user approved. Never resolve a thread whose fix is not yet pushed.
8. **Suggest the next step:**
   - `/my:pr-round <comments file>` when fixes are pending;
   - the repository's own comment resolver, when the project profile names one, as an alternative.
9. **Closing step** from the principles.
