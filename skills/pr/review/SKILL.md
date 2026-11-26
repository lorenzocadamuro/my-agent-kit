---
name: review
description: "Review a PR the way a senior colleague would, yours before human review or a colleague's: first a private analysis (ready to merge or not, the main scenario end to end, verified findings weighed by reach and impact; nothing worth adding is a valid answer), then, once you agree, questions and comment drafts in English; by default a GitHub review submitted with the event you choose at the gate."
argument-hint: "<PR number or URL> [instructions in plain words]"
disable-model-invocation: true
when: "\"/my:review\", \"review this PR\", \"fammi la review\", \"what would a senior ask here\""
reads: [rules/core.md, rules/plan-contract.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/files.md, rules/review-lenses.md, rules/question-format.md, rules/model-choice.md]
---

# /my:review — the judgement first, the drafts after

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md`, `${CLAUDE_PLUGIN_ROOT}/rules/files.md`, `${CLAUDE_PLUGIN_ROOT}/rules/review-lenses.md`, `${CLAUDE_PLUGIN_ROOT}/rules/question-format.md` and `${CLAUDE_PLUGIN_ROOT}/rules/model-choice.md`.

**Activity:** follow `${CLAUDE_PLUGIN_ROOT}/rules/local-data.md` § The activity file.

## Arguments and output mode

- **PR:** a number or URL, or else the PR of the current branch.
- **Instructions:** free text. Read them for:
  - **output mode:**
    - `submit` (default on a colleague's PR): a GitHub review with inline comments, submitted with the event chosen at the gate (step 7);
    - `pending`: the same review, left pending for the user to submit from GitHub;
    - `summary`: one review comment with no inline comments, submitted like `submit`;
    - `local`: nothing touches GitHub, and drafts come back in chat and in a file;
  - **focus areas;**
  - **tone.**
- **Own PR** (the author is the authenticated `gh` user): the default mode is `local`. Findings feed `/my:run`; you cannot review your own PR on GitHub.

## Steps

1. **Collect:**
   - `gh pr view <n> --json title,body,author,files,headRefOid,baseRefName,url,reviewRequests`; its `headRefOid` is the reviewed head;
   - `gh pr diff <n>`;
   - linked tickets;
   - existing reviews and comments (review bodies, inline and general comments), each with its commit and whether its thread is resolved: `gh api graphql -f query='query{repository(owner:"<owner>",name:"<repo>"){pullRequest(number:<n>){reviewThreads(first:100){totalCount nodes{isResolved path line comments(first:1){nodes{author{login} body originalCommit{oid}}}}}}}}'` (read-only, about a second; a `totalCount` over 100 needs more pages).

   On the user's own PR, also find the plan: `git worktree list`, the branch's worktree, then `.plans/plan.md`. With a plan, its promise, boundary, invariants, out-of-scope list and bar are the yardstick. Without one, the PR description is.

   When `gh` is unavailable and the user pasted the diff and description, work from those.

2. **Load the context:**
   - the project profile (`<data root>/projects/<owner>-<repo>.md`), the guides it maps to the changed paths, and the repository rules that apply to what the change does (`rules/repository.md`: repository rules are inputs);
   - reviewer profiles in `<data root>/reviewers/`, for the requested reviewers when the PR is the user's (to anticipate them), or as extra lenses on a colleague's PR;
   - an earlier analysis of this PR in `<data root>/reviews/`, with the head it was written at;
   - the reading from `/my:learn`, if one exists (`<data root>/reads/<repo>-pr<n>.md`, written at the current head). Use its promise and its before → after map as the yardstick, and its "questions to keep in mind" as your starting hypotheses. Do not repeat its explanations in the review. If the reading is for an older head, use it only for what the newer commits did not change.
3. **Review, starting from the promise:** follow the PR's main scenario end to end through every piece it touches, then use the other lenses that fit (`rules/review-lenses.md`).
   - **Up to about 800 changed lines, on a colleague's PR:** review it yourself.
   - **Larger, or the user's own PR at any size:** split by area across up to 3 fresh read-only agents (one for a small PR; model: `rules/model-choice.md`). Give each the lenses, the rules, the promise, its paths and, when the PR was reviewed before, the earlier analysis and the open threads. Each returns findings with `file:line` evidence. On the user's own PR they also verify and grade them (steps 4–5); you write the analysis from their findings and drop none.

   Never truncate a caller audit.

4. **Verify every finding** against the code at the head commit before keeping it: read the lines, the callers, and the tests. Before calling a shape wrong or proposing a refactor, find why the code is shaped this way (a comment, a commit, a contract); a deliberate design is not a finding. Drop what does not hold, or turn it into a question when it is plausible but unproven.
5. **Grade each finding** as **block**, **ticket** or **note**, by `rules/review-lenses.md` § Grading a finding, weighing who can trigger it and what it costs.
6. **The analysis, first:** private, in chat. No text for GitHub yet.
   - **What the PR does,** on a colleague's PR when no reading of it exists at the current head (step 2): about five lines, what it changes and why, before → after, so the verdict lands on a PR the user already understands. With a reading, a link to it instead.
   - **The verdict:** ready to merge or not, and why, in two lines, judged on the PR as it is at its head: facts about its base (another open PR, the merge order, a rebase) are information for the author, not conditions, unless they break the PR's promise. When others already reviewed the PR, it counts the findings no one raised apart from those already raised, and names the new ones first.
   - **Since the last review,** when the PR was already reviewed (an earlier analysis, or reviews by others), before anything new: each point raised then, and whether the head fixes it (with the commit or line), leaves it open, or the author answered it.
   - **The main scenario,** followed end to end: where it holds, and where it breaks.
   - **One section per question that matters,** each with its answer and its nature (architecture or design, lines to fix, a nit); each finding with its label, `file:line` and evidence. A point already raised in an open thread is not a new finding: name the thread and its author, and add only what is new.
   - **"Nothing worth adding" is a valid outcome.** There is no quota of questions or findings: a PR with only nits says so, and that it is ready.

   Save it to `<data root>/reviews/<owner-name>-pr<n>-<date>.md` (or the file the user names), with the head commit in its header, present the file (`rules/files.md`: where files go), and ask whether the analysis holds. A correction continues the conversation, and is a signal (`rules/learning.md`: closing step). The drafts wait for the user's agreement, in chat or already in the instructions ("write the drafts too"); without either, and with no way to ask, stop here.
7. **The drafts, once the user agrees with the analysis.** First read the head again (`gh pr view <n> --json headRefOid`): when it moved since the reviewed head, read the new commits and any new review, update the analysis, say what changed, and take the new head as the reviewed head.
   - the questions to ask the author, only those worth asking, the most important first;
   - an inline comment of at most 4 sentences per kept finding, phrased as a question when uncertain, with a concrete suggestion when there is one; for a point with an open thread, at most a reply in it with something new, which the user posts there (the review payload of step 8 cannot carry a thread reply);
   - a review summary of at most 6 lines.

   They state the PR's current state at its head, facts and requests, and leave the decisions to the author (`rules/core.md`: text addressed to a colleague): no thanks for fixes, no courtesy praise; a point a newer commit fixed leaves the drafts without mention.

   Add them to the file and paste them in chat, in every mode (`rules/files.md`: present a file). In `local` mode they are for the user only, with no gate. Otherwise the gate: recommend the review's event from the verdict, then ask whether to post as drafted with that event, another event, or pending, or to edit first. The recommendation: `COMMENT` by default; `APPROVE` when the findings are only notes, or blocks small enough that another round trip costs more than they do (the summary then names them as follow-ups); `REQUEST_CHANGES` only for a serious problem, such as a broken promise, lost data or a security hole. On a colleague's PR, when the chosen event submits the review, also offer the watch of step 10, and ask whether a follow-up that finds every block fixed may submit `APPROVE` on its own.

8. **Publish only after a yes.**
   - **Right before posting,** read the head again: when it moved since the drafts, post nothing, read the new commits, update the drafts, and ask again with what changed.
   - **`submit`:** `gh api repos/<o>/<r>/pulls/<n>/reviews -X POST --input <payload.json>`, with `commit_id` set to the reviewed head, `event` set to the chosen event, `body` set to the summary, and `comments` as a list of `{path, line, side: "RIGHT", body}`. Check first that every line is inside the diff; move any comment that is not into the body. Give the user the link.
   - **`pending`:** the same call without `event`, so the review stays pending; the user submits it from GitHub.
   - **`summary`:** the `submit` call with no `comments`.
   - **`local`:** nothing to publish.
9. **Closing step** from `rules/learning.md`, before any watch starts.
10. **Watch, when the user said yes at the gate** to a submitted review. A background command polls the PR's comments, reviews and review requests (never its CI), and ends when the author tags the user, requests the user's review again, or the PR closes. On the first two, run a follow-up review from the saved analysis: the commits after the reviewed head, every open thread, and all new code at the same depth (steps 3–6). When every block is fixed and no new one appears, submit `APPROVE` with a short summary only when the user allowed it at the gate; otherwise bring back the analysis and the drafts, and decide the event with the user as in step 7. After each follow-up, the watch starts again, until the PR closes or the user stops it.
