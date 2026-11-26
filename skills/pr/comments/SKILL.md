---
name: comments
description: "Make sense of PR comments from bots or colleagues: two lines each, real / duplicate / not a bug / out of scope checked against the code, weight, a proportional action and a reply draft (short for a bot, one explaining reply for a colleague's review); posts only after you say yes."
argument-hint: "[PR number or URL] [comment URL | new | all]"
disable-model-invocation: true
when: "\"/my:comments\", \"cosa vuol dire questo commento\", \"explain these bot comments\", \"is this Bugbot finding real\", \"help me answer this review\""
reads: [rules/core.md, rules/plan-contract.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/files.md, rules/review-lenses.md]
---

# /my:comments — what each comment means, and what to do about it

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md`, `${CLAUDE_PLUGIN_ROOT}/rules/files.md` and `${CLAUDE_PLUGIN_ROOT}/rules/review-lenses.md`.

**Activity:** follow `${CLAUDE_PLUGIN_ROOT}/rules/local-data.md` § The activity file.

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
   - Classify the group as **real** (a claimed bug, above all one a bot marks uncertain, only once reproduced through the production caller: `rules/verifying.md`, verify), **not verified** (with the command that would decide it: a check-only item, and no reply until it is decided), **duplicate** (of which group), **not a bug** (with evidence), **already fixed** (with the commit), or **out of scope** (outside the PR's plan or diff).
   - A real group that the plan, the research or a round's review should have caught is a signal (`rules/learning.md`: closing step). Read the plan (`.plans/plan.md`, or the one the user names) to judge it.
4. **Weigh and act.** Weight each group by `rules/review-lenses.md` § Grading a finding. Pick a proportional action: fix, document, ticket, or reply only. A low-value style point on a local tool does not get an elaborate fix.
5. **Draft the replies,** in English.
   - **A person's review** (a colleague, not a bot): one reply for the whole review, as a PR comment that names the points it answers, never one per point; a point already fixed takes its "Addressed in `<sha>`" line inside it. For each other point, where the behaviour comes from and what the alternative would cost, so they can judge (`rules/core.md`: text addressed to a colleague). As long as the points need.
   - **A bot:** at most 3 sentences, factual.
     - Fixed: "Addressed in `<sha>`: <how>."
     - Not a bug: the evidence, with `file:line`.
     - Ticket: "Out of scope for this PR; tracked in <ticket>."
6. **Output.**
   - **Chat:** for each group, its comment(s), explanation (2 lines), class, weight and action.
   - **File:** `<worktree>/.plans/comments-<date>.md` (or the scratchpad), holding a table with one row per group and those columns, the evidence and the reply drafts. Items marked "fix" are written as `### <k>. <claim>` entries, so `/my:round` and `/my:run` can take the file as their input.
   - **State file:** update it.
7. **Gate.** Paste the reply drafts in chat, and ask which to post (all, a selection, or none) and whether to resolve the answered threads, never those of a person's review answered with an explanation: they resolve them. Post with `gh api repos/<o>/<r>/pulls/<n>/comments -X POST -f body=… -F in_reply_to=<id>` (a person's review: `gh api repos/<o>/<r>/issues/<n>/comments -X POST -f body=…`), and resolve with the GraphQL `resolveReviewThread` mutation, only for what the user approved. Never resolve a thread whose fix is not yet pushed.
8. **Suggest the next step:**
   - `/my:run <comments file>` when fixes are pending (on the user's yes, read `${CLAUDE_PLUGIN_ROOT}/skills/plan/run/SKILL.md` and follow it with `<comments file>`);
   - the repository's own comment resolver, when the project profile names one, as an alternative.
9. **Closing step** from `rules/learning.md`.
