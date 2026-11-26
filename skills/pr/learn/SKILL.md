# /my:pr:learn — understand a PR, or the review it received

**Activity:** follow `${CLAUDE_PLUGIN_ROOT}/rules/local-data.md` § The activity file.

Input:

- a PR number or URL (by default, the PR of the current branch);
- optionally, a focus:
  - an area, in plain words: the reading below goes deeper there;
  - **review comments:** a comment id or URL, reviewer handles (a word naming one of the PR's reviewers), `comments` (every human comment), or pasted comment text, each followed by `all` to take comments already studied again. Then follow § Studying review comments instead of the reading.

This mode explains; it does not judge. Write hypotheses as questions, never as findings. Judging is `/my:pr:review`, which reuses this reading.

## Reading the PR

1. **Check for an earlier reading:** `reads/<repo>-pr<n>.md`. Its header records the head commit it was written at.
   - If it exists and the head is unchanged, rewrite only its review comments overview (step 2's comments, step 4's format), link it and stop.
   - If the head moved, read only the commits since that SHA (`gh api repos/<o>/<r>/compare/<old>...<new>`). Add a "What changed since <date>" section at the top of the same file, and update the header and the review comments overview.
2. **Collect:**
   - `gh pr view <n> --json title,body,author,files,headRefOid,baseRefName,url,reviewRequests`;
   - `gh pr diff <n>`;
   - linked tickets;
   - the existing reviews and their comments, with each thread's state (the query in `review.md` step 1), for the overview at the end, not to study them;
   - the project profile, for the guides to load.

   When the profile names a repository tool that explains PRs, you may use its output as a source. Never use its publish options.

3. **Find the shape of the change.**
   - Find the entry points.
   - Find the data or state that changes, and who owns it.
   - Split the diff into mainline code, tests, generated files and mechanical fallout. Only mainline counts for understanding.
4. **Write the reading** from `${CLAUDE_PLUGIN_ROOT}/skills/pr/learn/read-page-template.md`, at `reads/<repo>-pr<n>.md`. The header records the PR, the head SHA and the date.
   - **Layer 0** (at most 150 words):
     - what the PR does, and why (the problem it solves);
     - its size in mainline lines;
     - the areas it touches;
     - **the promise:** what it guarantees, in one sentence.
   - **Layer 1:**
     - **Before → after:** the flow in at most 6 steps, marking the steps that change.
     - **Reading order:** at most 5 files, each with why to read it and what to look for.
     - **Key terms:** new ones explained briefly, known ones linked to the glossary.
   - **Layer 2,** collapsed:
     - details per area, with one snippet each;
     - what the PR deliberately does not do (from the description or the code);
     - how it is tested.
   - **Questions to keep in mind:** 3–6 questions from the lenses that this PR makes relevant, for example "who else writes this record?" or "what happens on a restart between X and Y?". These are open questions, not verdicts.
   - **Review comments so far,** last, after layer 2, when the PR has any: who said what, one line per reviewer (at most 5 lines), which threads are still open, and `/my:pr:learn <n> comments` to study them.
5. **Update the glossary.** Readings do not touch reviewer profiles.
6. **Ask in chat:** "Do you want me to go deeper into a part, or start `/my:pr:review <n>`?"

## Studying review comments

1. **Choose the comments.**
   - Take the human reviews and inline comments on the current head **that are not in the index yet** (`study/README.md`, column "comments studied"); `all` takes them again.
   - Reviewer handles narrow them to theirs; a comment id or URL takes only that comment and its thread.
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
6. **Write the page** from `${CLAUDE_PLUGIN_ROOT}/skills/pr/learn/study-page-template.md`, at `study/<yyyy-mm-dd>-<repo>-pr<n>-<reviewer>.md`.
   - **Layer 0:** verdict and weights, what the user owes (at most 3 items), one move worth learning.
   - **Layer 1:** for each in-depth comment, "in short" (at most 40 words) and "how they reason" (at most 30 words, named after a lens), with the code in `<details>`.
   - **Layer 2:** new terms, at most 2 new reasoning moves, at most 3 check questions. Add a flow map (at most 6 steps) only when 3 or more comments touch the same flow.
   - **Mark what is negotiable:** where a request widens the scope, or the criticism is debatable, say how to argue for a follow-up.
7. **Update the cumulative files:**
   - the glossary;
   - `reviewers/<handle>.md`, following `${CLAUDE_PLUGIN_ROOT}/skills/pr/learn/reviewer-profile-template.md`, where each line cites this page and states only what the comments show;
   - the index row: date, PR, reviewer, file, moves learned, **comment ids studied**.
