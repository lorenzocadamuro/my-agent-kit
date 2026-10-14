---
name: learn
description: Private learning mode for pull requests, in the user's language, with a ten-minute reading budget. `pr <n>` explains a PR before the user reviews it: what it does and why, the flow before and after, the order to read the files, what it promises, and the questions to keep in mind (on a re-run, only what changed since the last reading). `review <n> [reviewer]` turns review comments into a three-layer study page that ties each comment to the code and to the reviewer's reasoning (on a re-run, only comments not studied yet). Keeps a personal glossary and reviewer profiles. Use for "/my:learn", "spiegami la PR 456", "help me understand this PR", "studia questa review", "come ragiona il reviewer", "what does this reviewer mean". Output stays local and private, never published.
argument-hint: "pr <PR> | review <PR> [reviewer…] [all] | <pasted comments>"
---

# /my:learn — understand a PR, learn from its reviews

The goal is learning, not summarising. Every page connects words to the real code, makes the reasoning repeatable, and fits a reading budget.

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`. Use `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md` to name reasoning moves and the questions worth asking.

## Modes

| First word of `$ARGUMENTS` | Mode                                                                          | Steps                  |
| -------------------------- | ----------------------------------------------------------------------------- | ---------------------- |
| `pr`                       | Understand a PR before reviewing it                                           | [pr.md](pr.md)         |
| `review`                   | Study the comments of a review                                                | [review.md](review.md) |
| none, or pasted comments   | `review` if the text is review comments; otherwise ask which mode in one line |                        |

The sub-commands `/my:learn:pr` and `/my:learn:review` call this skill with the mode already set.

## Shared rules (both modes)

- **Data root:** `$MY_AGENT_KIT_HOME`, or a root the user names; otherwise `~/.my-agent-kit`.
  - Readings go in `<data root>/reads/`.
  - Study pages, `glossary.md` and the `README.md` index go in `<data root>/study/`.
  - Reviewer profiles go in `<data root>/reviewers/`.
  - Use the file name the user gives, when they give one.
- **Language:**
  - Pages, glossary entries and the chat reply are in the user's language (the one they write to you in).
  - Quotes and code stay in the original. File names are in English.
- **Private:**
  - write only under the data root, never inside a repository;
  - never publish (no artifacts, docs, gists, comments or messages);
  - never mention the study in PRs, commits or messages to colleagues.
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
- **Memory:** each mode records what it has covered, so a re-run covers only what is new (see the mode file).
- **Finish:**
  - Open the page with `open <file>`.
  - Reply in chat in at most 8 lines: the path, layer 0 in brief, and one question that checks the user understood.
  - Then offer the natural next step: after `pr`, `/my:review-lens <n>`; after `review`, `/my:explain-comment <n>` when replies are owed.
- **Closing step:** follow the principles.
