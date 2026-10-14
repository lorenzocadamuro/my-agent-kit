---
name: study-review
description: Private study mode for code-review comments. Turns a PR review (the user's own PR or a colleague's), or pasted comments, into a short Markdown study page in the user's language, in three layers (one minute, ten minutes, optional depth). Each comment is tied to the real code and to the reviewer's reasoning, and the skill keeps a personal glossary and reviewer profiles up to date. Use for "/my:study-review", "studia questa review", "help me understand this review", "spiegami come ragiona il reviewer", "what does this reviewer mean". Output stays local and private, never published.
argument-hint: "[PR number or URL] [reviewer…] | <pasted comments>"
---

# /my:study-review — learn how a reviewer thinks, in ten minutes

The goal is learning, not summarising. The page connects the reviewer's words to the code and makes their reasoning repeatable, within a reading budget.

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`. Use `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md` to name each reasoning move.

## Paths and privacy

- **Data root:** `$MY_AGENT_KIT_HOME`, or a root the user names; otherwise `~/.my-agent-kit`. Study files go in `<data root>/study/`; reviewer profiles in `<data root>/reviewers/`.
- **Language:** write the page, the glossary and the chat reply in the user's language (the language they write to you in). Quotes stay in the original. File names stay in English.
- **Private:**
  - write only under the data root, never inside a repository;
  - never publish (no artifacts, docs, gists, comments or messages);
  - never mention the study in PRs, commits or messages to colleagues.

## Input

`$ARGUMENTS` can hold any of these:

- a PR number or URL (by default, the PR of the current branch);
- reviewer handles to focus on;
- pasted comment text.

When it is unclear which comments to study, take the latest human reviews on the current head. Include bot comments only when a human cites them.

## Steps

1. **Collect** into the scratchpad:
   - `gh pr view <n> --json title,body,headRefOid,files,url`;
   - `gh api "repos/<o>/<r>/pulls/<n>/reviews?per_page=100"` and `.../pulls/<n>/comments?per_page=100`;
   - the PR author's replies in the threads, because reviewers often answer them without quoting.

   If `gh` is unavailable, work from the pasted text, and say in one line that code anchors are unverified.

2. **Skip what is already studied.** Read `study/README.md` (the index). Comment ids already listed there are not studied again; refer to their page instead.
3. **Load what the user already knows:**
   - `study/glossary.md`: a known term gets a link, never a second explanation;
   - `reviewers/<handle>.md`: reuse that reviewer's known lenses.
4. **Weigh every comment:** blocking, request, suggestion or praise. Pick at most **5** for depth: blocking first, then those that teach a new move. Every other comment becomes one table row.
5. **Anchor each in-depth comment to the code.**
   - Find the file and function, read it, and read who calls it and what happens when it fails.
   - Quote one snippet of at most 10 real lines.
   - When a reading is not verified, write "unverified: check `<path>`".
6. **Write the page** from `${CLAUDE_PLUGIN_ROOT}/templates/study-page.md`, at `study/<yyyy-mm-dd>-<repo>-pr<n>-<reviewer>.md`, or at the file name the user gives.
   - **Layer 0:** at most 150 words. Verdict and weights, what the user owes (at most 3 items), one move worth learning.
   - **Layer 1:** for each in-depth comment, "in plain words" (at most 40 words) and "how they reason" (at most 30 words, named after a lens), with the code inside `<details>`.
   - **Layer 2,** collapsed: at most 5 new terms, at most 2 new reasoning moves, at most 3 check questions. Add a flow map (at most 6 steps) only when 3 or more comments touch the same flow.
   - **Mark what is negotiable:** where a request widens the scope, or the criticism is debatable, say how to argue for a follow-up.
7. **Check the budget.** Count words with `wc -w`. If layer 0 is over 150 words, or the page is over about 1,800, cut until it fits. Never cut the weights or the code anchors.
8. **Update the cumulative files:**
   - **glossary.md:** add the new terms (`### <Term> — <meaning>`, then "In general", "In the code", "Seen in"). For a known term, add only a "Seen in" line.
   - **reviewers/<handle>.md:** follow `${CLAUDE_PLUGIN_ROOT}/templates/reviewer-profile.md`, citing this page for every line. Write only what the comments show.
   - **study/README.md:** one row per page, with date, PR, reviewer, file, the moves learned, and the comment ids studied.
9. **Open the page** with `open <file>`. Then reply in chat, in at most 8 lines: the path, the 2–3 key ideas, and one question that checks the user understood.

## Rules

- Explain the "why" (why the reviewer looks there), not only the "what".
- No flattery and no drama: this is study material.
- Closing step from the principles.
