# /my:learn pr — understand a PR before judging it

Input:

- a PR number or URL (by default, the PR of the current branch);
- optionally, an area to focus on, in plain words.

This mode explains; it does not judge. Write hypotheses as questions, never as findings. Judging is `/my:review-lens`, which reuses this reading.

## Steps

1. **Check for an earlier reading:** `reads/<repo>-pr<n>.md`. Its header records the head commit it was written at.
   - If it exists and the head is unchanged, link it and stop.
   - If the head moved, read only the commits since that SHA (`gh api repos/<o>/<r>/compare/<old>...<new>`). Add a "What changed since <date>" section at the top of the same file, and update the header.
2. **Collect:**
   - `gh pr view <n> --json title,body,author,files,headRefOid,baseRefName,url,reviewRequests`;
   - `gh pr diff <n>`;
   - linked tickets;
   - the existing reviews, only for their state, not to study them;
   - the project profile, for the guides to load.

   When the profile names a repository tool that explains PRs, you may use its output as a source. Never use its publish options.

3. **Find the shape of the change.**
   - Find the entry points.
   - Find the data or state that changes, and who owns it.
   - Split the diff into mainline code, tests, generated files and mechanical fallout. Only mainline counts for understanding.
4. **Write the reading** from `${CLAUDE_PLUGIN_ROOT}/templates/read-page.md`, at `reads/<repo>-pr<n>.md`. The header records the PR, the head SHA and the date.
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
5. **Update the glossary.** Readings do not touch reviewer profiles.
6. **Ask in chat:** "Do you want me to go deeper into a part, or start `/my:review-lens <n>`?"
