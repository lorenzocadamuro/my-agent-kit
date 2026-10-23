# /my:pr:review — the judgement first, the drafts after

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md`, `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md`.

## Arguments and output mode

- **PR:** a number or URL, or else the PR of the current branch.
- **Instructions:** free text. Read them for:
  - **output mode:**
    - `pending` (default on a colleague's PR): a pending GitHub review with inline comments;
    - `summary`: one review comment with no inline comments;
    - `local`: nothing touches GitHub, and drafts come back in chat and in a file;
  - **focus areas;**
  - **tone.**
- **Own PR** (the author is the authenticated `gh` user): the default mode is `local`. Findings feed `/my:plan:round` and `/my:plan:run`; you cannot review your own PR on GitHub.

## Steps

1. **Collect:**
   - `gh pr view <n> --json title,body,author,files,headRefOid,baseRefName,url,reviewRequests`;
   - `gh pr diff <n>`;
   - linked tickets;
   - existing reviews and comments (review bodies, inline and general comments), each with its commit and whether its thread is resolved: `gh api graphql -f query='query{repository(owner:"<owner>",name:"<repo>"){pullRequest(number:<n>){reviewThreads(first:100){totalCount nodes{isResolved path line comments(first:1){nodes{author{login} body originalCommit{oid}}}}}}}}'` (read-only, about a second; a `totalCount` over 100 needs more pages).

   On the user's own PR, also find the plan: `git worktree list`, the branch's worktree, then `.plans/plan.md`. With a plan, its promise, boundary, invariants, out-of-scope list and bar are the yardstick. Without one, the PR description is.

   When `gh` is unavailable and the user pasted the diff and description, work from those.

2. **Load the context:**
   - the project profile (`<data root>/projects/<owner>-<repo>.md`) and the guides it maps to the changed paths;
   - reviewer profiles in `<data root>/reviewers/`, for the requested reviewers when the PR is the user's (to anticipate them), or as extra lenses on a colleague's PR;
   - an earlier analysis of this PR in `<data root>/reviews/`, with the head it was written at;
   - the reading from `/my:pr:learn`, if one exists (`<data root>/reads/<repo>-pr<n>.md`, written at the current head). Use its promise and its before → after map as the yardstick, and its "questions to keep in mind" as your starting hypotheses. Do not repeat its explanations in the review. If the reading is for an older head, use it only for what the newer commits did not change.
3. **Review, starting from the promise:** follow the PR's main scenario end to end through every piece it touches, then use the other lenses that fit (lenses doc).
   - **Up to about 800 changed lines, on a colleague's PR:** review it yourself.
   - **Larger, or the user's own PR at any size:** split by area across up to 3 fresh read-only agents (one for a small PR). Give each the lenses, the rules, the promise, its paths and, when the PR was reviewed before, the earlier analysis and the open threads. Each returns findings with `file:line` evidence. On the user's own PR they also verify and grade them (steps 4–5); you write the analysis from their findings and drop none.

   Never truncate a caller audit.

4. **Verify every finding** against the code at the head commit before keeping it: read the lines, the callers, and the tests. Before calling a shape wrong or proposing a refactor, find why the code is shaped this way (a comment, a commit, a contract); a deliberate design is not a finding. Drop what does not hold, or turn it into a question when it is plausible but unproven.
5. **Grade each finding** as **block**, **ticket** or **note**, by the lenses doc § Grading a finding, weighing who can trigger it and what it costs.
6. **The analysis, first:** private, in chat, in the user's language. No text for GitHub yet.
   - **The verdict:** ready to merge or not, and why, in two lines.
   - **Since the last review,** when the PR was already reviewed (an earlier analysis, or reviews by others), before anything new: each point raised then, and whether the head fixes it (with the commit or line), leaves it open, or the author answered it.
   - **The main scenario,** followed end to end: where it holds, and where it breaks.
   - **One section per question that matters,** each with its answer and its nature (architecture or design, lines to fix, a nit); each finding with its label, `file:line` and evidence. A point already raised in an open thread is not a new finding: name the thread and its author, and add only what is new.
   - **"Nothing worth adding" is a valid outcome.** There is no quota of questions or findings: a PR with only nits says so, and that it is ready.

   Save it to `<data root>/reviews/<owner-name>-pr<n>-<date>.md` (or the file the user names), with the head commit in its header, present the file (principles: where files go), and ask whether the analysis holds. A correction continues the conversation, and is a signal (principles: closing step). The drafts wait for the user's agreement, in chat or already in the instructions ("write the drafts too"); without either, and with no way to ask, stop here.
7. **The drafts, once the user agrees with the analysis:**
   - the questions to ask the author, only those worth asking, the most important first;
   - an inline comment of at most 4 sentences per kept finding, phrased as a question when uncertain, with a concrete suggestion when there is one; for a point with an open thread, at most a reply in it with something new, which the user posts there (the review payload of step 8 cannot carry a thread reply);
   - a review summary of at most 6 lines.

   Add them to the file and paste them in chat, in every mode (principles: present a file). In `local` mode they are for the user only, with no gate. Otherwise the gate: ask whether to create the pending review as drafted, switch the mode, or edit first.

8. **Publish only after a yes.**
   - **`pending`:** `gh api repos/<o>/<r>/pulls/<n>/reviews -X POST --input <payload.json>`, with `commit_id` set to the head, `body` set to the summary, and `comments` as a list of `{path, line, side: "RIGHT", body}`. **Omit `event`, so the review stays pending.** Check first that every line is inside the diff; move any comment that is not into the body. Give the user the link: they submit it from GitHub.
   - **`summary`:** the same call with no `comments`. Still pending.
   - **`local`:** nothing to publish.
9. **Closing step** from the principles.
