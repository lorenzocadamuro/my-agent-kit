# Learning rules — /my:learn

The goal is learning, not summarising. Every page connects words to the real code, makes the reasoning repeatable, and fits a reading budget. These rules apply to `learn` only: to the reading of a PR and to the study of its review comments.

Use `${CLAUDE_PLUGIN_ROOT}/rules/reviewing.md` to name reasoning moves and the questions worth asking.

## Rules

- **Paths, under the data root:** readings in `reads/`; study pages, `glossary.md` and the `README.md` index in `study/`; reviewer profiles in `reviewers/`.
  - Use the file name the user gives, when they give one.
- **Language:** quotes and code stay in the original; file names are in English.
- **Budget:** layer 0 is at most 150 words; the whole page is at most about 1,800 words.
  - Before opening the page, count the words with `wc -w`, and cut until it fits.
  - Never cut code anchors or weights.
- **Three layers** (a reading then ends with the review comments overview: `skills/pr/learn/SKILL.md` step 4):
  - **layer 0:** what the user needs now, in one minute;
  - **layer 1:** the ten-minute read;
  - **layer 2:** optional depth, inside `<details>`.
- **Anchored to the code:**
  - Every claim about the code names a file and function, read at the PR's head commit.
  - Snippets are real, and at most 10 lines.
  - Anything you did not verify is written as "unverified: check `<path>`".
  - When `gh` is unavailable, work from pasted material, and say in one line that the anchors are unverified.
- **Glossary:**
  - A term already in `study/glossary.md` gets a link, never a second explanation; add only a "Seen in" line to it.
  - Add at most 5 new terms per page, as `### <Term> — <meaning>`, followed by "In general", "In the code", "Seen in".
- **Memory:** the reading and the study each record what they have covered, so a re-run covers only what is new (see `skills/pr/learn/SKILL.md`).
- **Finish:**
  - Present the page (`rules/kit-data.md`: where files go).
  - Reply in chat in at most 8 lines: the path, layer 0 in brief, and one question that checks the user understood.
  - Then offer the natural next step: after a reading, `/my:review <n>`; after a study of comments, `/my:comments <n>` when replies are owed. On the user's yes, read `${CLAUDE_PLUGIN_ROOT}/skills/pr/review/SKILL.md` or `${CLAUDE_PLUGIN_ROOT}/skills/pr/comments/SKILL.md` and follow it with `<n>`.
- **Closing step:** follow `rules/learning.md`.
