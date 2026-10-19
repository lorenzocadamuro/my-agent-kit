# /my:pr:study — learn how a reviewer thinks

Input:

- a PR number or URL (by default, the PR of the current branch);
- optional reviewer handles;
- optional `all`;
- or pasted comment text.

## Steps

1. **Choose the comments.**
   - By default, take the human reviews and inline comments on the current head **that are not in the index yet** (`study/README.md`, column "comments studied").
   - With `all`, take every human comment again.
   - With reviewer handles, take only theirs.
   - Include bot comments only when a human cites them.
   - If nothing new is left, say so, link the existing pages, and stop.
2. **Collect** into the scratchpad:
   - `gh pr view <n> --json title,body,headRefOid,files,url`;
   - `gh api "repos/<o>/<r>/pulls/<n>/reviews?per_page=100"` and `.../pulls/<n>/comments?per_page=100`;
   - the PR author's replies in the threads, because reviewers often answer them without quoting.
3. **Load what the user already knows:**
   - the glossary;
   - `reviewers/<handle>.md`, to reuse that reviewer's known lenses;
   - the reading in `reads/` for this PR, if there is one: its map and terms save work.
4. **Weigh every comment:** blocking, request, suggestion or praise. Pick at most **5** for depth: blocking first, then those that teach a new move. Every other comment becomes one table row.
5. **Anchor each in-depth comment.** Find the file and function, read it, and read who calls it and what happens when it fails.
6. **Write the page** from `${CLAUDE_PLUGIN_ROOT}/templates/study-page.md`, at `study/<yyyy-mm-dd>-<repo>-pr<n>-<reviewer>.md`.
   - **Layer 0:** verdict and weights, what the user owes (at most 3 items), one move worth learning.
   - **Layer 1:** for each in-depth comment, "in plain words" (at most 40 words) and "how they reason" (at most 30 words, named after a lens), with the code in `<details>`.
   - **Layer 2:** new terms, at most 2 new reasoning moves, at most 3 check questions. Add a flow map (at most 6 steps) only when 3 or more comments touch the same flow.
   - **Mark what is negotiable:** where a request widens the scope, or the criticism is debatable, say how to argue for a follow-up.
7. **Update the cumulative files:**
   - the glossary;
   - `reviewers/<handle>.md`, following `${CLAUDE_PLUGIN_ROOT}/templates/reviewer-profile.md`, where each line cites this page and states only what the comments show;
   - the index row: date, PR, reviewer, file, moves learned, **comment ids studied**.
