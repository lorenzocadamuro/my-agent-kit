# /my:pr:review — questions a senior would ask

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
   - existing reviews and comments, so you do not repeat points already raised.

   On the user's own PR, also find the plan: `git worktree list`, the branch's worktree, then `.plans/plan.md`. With a plan, its promise, boundary, invariants, out-of-scope list and bar are the yardstick. Without one, the PR description is.

   When `gh` is unavailable and the user pasted the diff and description, work from those.

2. **Load the context:**
   - the project profile (`<data root>/projects/<owner>-<repo>.md`) and the guides it maps to the changed paths;
   - reviewer profiles in `<data root>/reviewers/`, for the requested reviewers when the PR is the user's (to anticipate them), or as extra lenses on a colleague's PR;
   - the reading from `/my:pr:learn`, if one exists (`<data root>/reads/<repo>-pr<n>.md`, written at the current head). Use its promise and its before → after map as the yardstick, and its "questions to keep in mind" as your starting hypotheses. Do not repeat its explanations in the review. If the reading is for an older head, use it only for what the newer commits did not change.
3. **Review.**
   - **Up to about 800 changed lines, on a colleague's PR:** review it yourself.
   - **Larger, or the user's own PR at any size:** split by area across up to 3 fresh read-only agents (one for a small PR). Give each the lenses, the rules, the promise and its paths. Each returns findings with `file:line` evidence. On the user's own PR they also verify and grade them (steps 4–5); you draft from their findings and drop none.

   Use only the lenses that fit the change. Never truncate a caller audit.

4. **Verify every finding** against the code at the head commit before keeping it: read the lines, the callers, and the tests. Drop what does not hold, or turn it into a question when it is plausible but unproven.
5. **Grade each finding** as **block**, **ticket** or **note**, by the lenses doc § Grading a finding.
6. **Draft:**
   - 5–8 questions to ask the author, the most important first;
   - the findings, each with its label, `file:line`, one line of explanation and the evidence;
   - an inline comment of at most 4 sentences per kept finding, phrased as a question when uncertain, with a concrete suggestion when there is one;
   - a review summary of at most 6 lines.

   Save it all to `<data root>/reviews/<owner-name>-pr<n>-<date>.md`, or to the file the user names.

7. **Show the user:**
   - the verdict in two lines;
   - the questions;
   - the findings table;
   - the file, presented (principles: where files go); unless the mode is `local`, the summary and the comments to publish, pasted in chat.

   Then the gate: ask whether to create the pending review as drafted, switch the mode, or edit first.

8. **Publish only after a yes.**
   - **`pending`:** `gh api repos/<o>/<r>/pulls/<n>/reviews -X POST --input <payload.json>`, with `commit_id` set to the head, `body` set to the summary, and `comments` as a list of `{path, line, side: "RIGHT", body}`. **Omit `event`, so the review stays pending.** Check first that every line is inside the diff; move any comment that is not into the body. Give the user the link: they submit it from GitHub.
   - **`summary`:** the same call with no `comments`. Still pending.
   - **`local`:** nothing to publish.
9. **Closing step** from the principles.
