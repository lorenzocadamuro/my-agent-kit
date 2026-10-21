---
name: pr
description: Work on a pull request around its review. `learn` explains a PR before the user reviews it (private, in the user's language). `study` turns the review comments the user received into a private study page and reviewer profiles. `review` reviews a PR the way a senior colleague would, with verified, graded findings and comment drafts. `comments` makes sense of bot and colleague comments and drafts short replies. `sync` brings the branch up to date with main safely. Use for "/my:pr", "spiegami la PR 456", "help me understand this PR", "studia questa review", "review this PR", "fammi la review", "cosa vuol dire questo commento", "is this Bugbot finding real", "merge main", "allinea con main".
argument-hint: "learn <PR> | study <PR> [reviewer…] | review <PR> [instructions] | comments [PR] [new|all|url] | sync [context] [--no-push]"
---

# /my:pr — a pull request and its review

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`.

## Modes

| First word of `$ARGUMENTS` | Mode                                                   | Steps                                          |
| -------------------------- | ------------------------------------------------------ | ---------------------------------------------- |
| `learn`                    | Understand a PR before reviewing it (private)          | [learning.md](learning.md), then [learn.md](learn.md) |
| `study`                    | Study the comments of a review received (private)      | [learning.md](learning.md), then [study.md](study.md) |
| `review`                   | Review a PR as a senior colleague would                | [review.md](review.md)                         |
| `comments`                 | Explain PR comments, triage them, draft replies        | [comments.md](comments.md)                     |
| `sync`                     | Bring the branch up to date with main                  | [sync.md](sync.md)                             |
| none, or pasted comments   | `comments` if the text is comments to answer, `study` if the user wants to learn from them; otherwise ask which mode in one line |  |

The sub-commands `/my:pr:learn`, `/my:pr:study`, `/my:pr:review`, `/my:pr:comments` and `/my:pr:sync` call this skill with the mode already set. Follow the mode's file; with the principles, it holds every rule the mode needs, except the shared rule below. The rules of `learning.md` apply to `learn` and `study` only.

**Activity (every mode):** write the activity sidecar (`${CLAUDE_PLUGIN_ROOT}/docs/local-data.md` § State file) under the mode's data root: `running` as the first step and again when the user answers, `needs_you` while waiting for the user (a posting gate, a design conflict), `done` at every exit, stops included.
