# Learning rules — shared by /my:pr:learn and /my:pr:study

The goal is learning, not summarising. Every page connects words to the real code, makes the reasoning repeatable, and fits a reading budget. These rules apply to `learn` and `study` only.

Use `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md` to name reasoning moves and the questions worth asking.

## Shared rules (learn and study)

- **Data root:** `$MY_AGENT_KIT_HOME`, or a root the user names; otherwise `~/.my-agent-kit`.
  - Readings go in `<data root>/reads/`.
  - Study pages, `glossary.md` and the `README.md` index go in `<data root>/study/`.
  - Reviewer profiles go in `<data root>/reviewers/`.
  - Use the file name the user gives, when they give one.
- **Language:**
  - Pages, glossary entries and the chat reply are in the user's language (the one they write to you in).
  - Quotes and code stay in the original. File names are in English.
- **Budget:** layer 0 is at most 150 words; the whole page is at most about 1,800 words.
  - Before opening the page, count the words with `wc -w`, and cut until it fits.
  - Never cut code anchors or weights.
- **Three layers:**
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
- **Memory:** each of the two modes records what it has covered, so a re-run covers only what is new (see the mode file).
- **Finish:**
  - Open the page with `open <file>`.
  - Reply in chat in at most 8 lines: the path, layer 0 in brief, and one question that checks the user understood.
  - Then offer the natural next step: after `learn`, `/my:pr:review <n>`; after `study`, `/my:pr:comments <n>` when replies are owed.
- **Closing step:** follow the principles.
