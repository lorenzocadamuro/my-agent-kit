## The method

- **The gate decisions of the `plan:*` modes and `pr:sync` are learned as kinds** in `<data root>/method.md` ([kit-data.md](kit-data.md) § Method); other modes neither cite nor update kinds when they decide, and only the coordinating session edits the file. Each such decision belongs to a kind; one that fits none gets the next `K<n>` (appended with `${CLAUDE_PLUGIN_ROOT}/scripts/append-entry.sh kind`, which numbers it under a lock), in generic words, starts `asked`, and its first answer counts like any other (match 1, mismatch 0). Two kinds are close when the same judgement would recommend the same option; merged, they keep the lower count and the less autonomous state, and are `kept` if either is.
- **A recommendation follows its kind's judgement** only when the decision clearly fits the kind's own case, and unless research says otherwise, and then says so; a decision that fits only a neighbouring case cites no kind, or names it as a weak fit. Only the user's choice counts: an assumption, like a decision taken `from the request` or `decided from research`, counts for no kind and creates none (its Kind cell may name the kind it fits), and a hand-over is never assumed. A match adds one; a mismatch rewrites the judgement to the user's choice, resets the count to 0 and sets a `proposed` or `handed over` kind back to `asked`. The plan's Decisions table records both options (plans with older columns stay valid).
- **At 5 matches a `work` kind becomes `proposed`,** and the next gate in any session proposes handing it over: yes makes it `handed over`; no sets it back to `asked`, count 0. `kept` kinds are recorded, so recommendations can cite them, and never proposed.
- **A handed-over kind is decided alone, by its judgement, only when the decision clearly fits it** and research does not point elsewhere; otherwise ask, and the answer counts. The report and the plan then say "decided alone (handed over: K<n>)".
- **The user takes a kind back by saying so in chat,** in any session: the coordinator sets it to `asked`, count 0, with the date.

## Closing step of every skill

The kit learns while it is used. Every skill collects signals during the work and lists them in its end report; only `/my:note`, `/my:improve` list, `/my:log`, `/my:method`, `/my:unslop` and `/my:wait-what` are exempt.

- **A signal is a sign that the kit's directives missed something:**
  - the user answers with a free answer ("Other") or dismisses a question. Record why: the question was unclear, the proposed method did not fit, or the user added an instruction of their own;
  - the user asks for a simpler explanation, or the reasoning in the chat shows a gap in the plan or the method;
  - a decision is reversed, a gate comes as a surprise, or a stop the plan did not foresee happens;
  - a review finding, or a real comment from a reviewer or a bot, that the plan, the research or the round's own review should have caught;
  - rework in a round.
- **Record each one when it happens, without interrupting the work.** Append one line to this session's signals file, `<data root>/signals/<owner-name>-<branch>.md` (`/` in the branch becomes `-`; without a branch, `<owner-name or "none">-<date>-<session id or time>.md`), creating it with a `# Signals: <repo> · <branch>` heading: `- <date time> · <kind> · <skill:mode> · <what happened> · <source> · kit <version>`, the version as in a log entry's `Kit:` line ([skills/improve/note/note-template.md](../skills/improve/note/note-template.md); older lines without it stay valid). Only the coordinating session writes signals.
- **At the end, list this session's pending signals in the end report,** one line each, and never turn them into notes alone: a note is saved only with the user's yes, when they question or correct the kit in the conversation (`rules/core.md`) or start `/my:note signals <this session's signals file>` from the report. When there were none, say nothing about it.
- **Never edit a skill on your own.**

## The kit's improvement loop

The kit changes only through an approved plan (`/my:scope` or `/my:run`) or `/my:improve run`, and only with the user's yes. A note never changes anything; a run changes only what the user approves.
