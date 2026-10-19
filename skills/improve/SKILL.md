---
name: improve
description: Grow the `my` kit from real use. `note <text>` logs a problem with any /my skill (or its principles, templates, or a project profile) from any session, without changing anything; `digest` turns the signals other skills collected during the work into a few clear notes; no argument lists open notes; `run [skill|ids]` finds the upstream lesson behind open notes and turns it into approved changes backed by eval cases, then updates README, CHANGELOG and version, commits, tags and pushes; `log` shows the history. Use when the user says "/my:improve", "annota", "note this problem with the kit", "the skill did X wrong", "improve the kit", "what's open on the kit".
argument-hint: "note <what happened> | digest [file] | run [skill|ids] [--propose-only] | log [skill] | (none: list open)"
---

# /my:improve — the kit's improvement loop

The kit changes only through this skill, and only with the user's approval. A note never changes anything; a run changes only what the user approves.

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md` and `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md`.

## Paths

- **Data root:** `$MY_AGENT_KIT_HOME` if set, or a data root the user names in the request; otherwise `~/.my-agent-kit`. The log is `<data root>/suite-log.md`. Create it with a `# Suite log` heading if missing. Signals live in `<data root>/signals/`.
- **Kit source:** the git repository behind `${CLAUDE_PLUGIN_ROOT}`. Resolve it with `git -C "${CLAUDE_PLUGIN_ROOT}" rev-parse --show-toplevel`. If that fails (the plugin was installed from a marketplace cache), ask for the path of the user's clone. Never edit the cache.

## Parse `$ARGUMENTS`

| First word    | Mode                                                   |
| ------------- | ------------------------------------------------------ |
| `note`        | Note: the rest is the user's description               |
| `digest`      | Digest: an optional signals file follows               |
| `run`         | Run: optional skill name, entry ids, `--propose-only`  |
| `log`         | Log: optional skill name follows                       |
| none, `list`  | List open entries                                      |
| anything else | Treat the whole text as a note, and say so in one line |

## Note

Goal: under a minute, no questions unless the text is empty.

1. **Identify the skill:** from the text, or else from the most recent `/my:` skill used in this session, or else `general`. Use `principles`, `templates`, `scripts` or `profile:<repo>` when the problem is there.
2. **Collect context without asking:**
   - date and time;
   - current repository (`git rev-parse --show-toplevel`, remote slug), branch, and PR number (`gh pr view --json number -q .number`, if any);
   - the session id if known.
3. **Fill the entry** from `${CLAUDE_PLUGIN_ROOT}/templates/log-entry.md`.
   - The reasoning fields (what happened, why it was a problem, missing question, expected) are in the user's language; labels, ids, states and repository terms stay as they are (principles: language). Keep a short quote of the user's words when the exact meaning matters.
   - The id is `YYYYMMDD-NN`: re-read the log right before appending, and take the next number after today's highest, starting at 01. Another session may have written since you last read it.
   - "What happened" and "Expected" are concrete: what was done or said, not an opinion. "Why it was a problem" says what it cost the user, in plain words. "Missing question" is a question someone should have asked at the start, not a fix; `unknown` when it is not clear.
   - "Suspected cause" names a step, principle, template or profile line when you can point to it; otherwise `unknown`. Do not investigate deeply here.
4. **Append** the entry to the log. Change nothing else: no skill, doc, template or profile.
5. **Confirm in exactly one line,** and nothing else: `Logged <id> · <skill> · <n> open`. Missing context goes in the entry as `unknown`; do not explain it in the reply.

## Digest

Run at the end of every other skill (principles: closing step), or by the user. Goal: a few clear notes, no noise, no questions.

1. **Read the pending signals:** lines without a mark, in the given file. Without a file (the user runs it by hand), every file under `<data root>/signals/`, so leftovers from sessions that ended early are picked up.
2. **Drop what a later signal contradicts or withdraws.** Mark both the withdrawn and the withdrawing signal `→ dropped: <why>`; never delete a line.
3. **Group by upstream cause:** the missing question or directive behind the signals, not the surface event. A session usually yields one to three groups.
4. **For each group,** re-read the log first.
   - If an open entry has the same cause, append one `- Evidence: <date> · <skill> · <what happened> · <source>` line per signal at its end. Never change its other lines.
   - Otherwise write a new entry as in Note, with the signals as Evidence lines. Its "Where" comes from the signals file's heading.
5. **Mark each digested signal** `→ <entry id>`.
6. **Reply in one line:** `Digested <k> signals → <ids>`. With no pending signals, reply nothing.

Never change a skill, doc, template or profile.

## Showing entries

List and Log share one view. Each entry shows its id, skill, state as a coloured badge, and the problem in one line, written in the user's language from "Why it was a problem" (or "What happened" in older entries). Its detail (what happened, why it was a problem, missing question, expected, suspected cause, where, evidence) opens on demand. Labels follow the principles: states, ids and headers in English, the problem and the detail in the user's language.

- **With the app's visual widget tool** (`show_widget`, after its `read_me` with the `interactive` module): render one widget. Each entry is a collapsible row; badges are green for `open`, grey for `fixed` and `wontfix`, amber for `deferred`. Closed entries sit in one more collapsible section, closed by default.
- **Without it:** a Markdown table with the columns `Id · Skill · State · Problem`, states as `🟢 open`, `✅ fixed`, `⏸ deferred`, `⚪ wontfix`. Closed entries follow the open ones in a separate table under `Closed (<n>)`.

## List (no argument)

Show the open entries, grouped by skill and then by suspected cause. End with the count, and one line saying whether a run looks worthwhile. Three or more notes on the same cause are a strong signal; a single vague note may need more evidence first.

## Run

1. **Preflight the kit source.** Clean tree, on `main`, `git pull --ff-only`. Stop if any of these fails. With `--propose-only`, skip the preflight, and stop after step 4 without the closing step.
2. **Select entries:** all open ones, or those matching the given skill or ids. Read each affected skill, the principles and templates, and any session or file an entry points to.
3. **Find the upstream lesson.** Group the notes by upstream cause, not by surface event. For each group:
   - **Name the missing question:** what should have been asked or checked at the start.
   - **Find the existing rule that should have covered it,** and say why it did not apply: not reached by the step where it happened, worded too narrowly, or worded for one case.
   - **Place the fix,** in this order of preference: refine, generalise or move that rule; merge it with a neighbour; add a new rule only when none covers the cause. Never word a fix around one case.
   - **Project profile** (`<data root>/projects/<repo>.md`) only for a fact about one repository: edit it, no version bump.
   - **No change** when the kit behaved as designed: explain why, and propose `wontfix`.
4. **Propose,** following the question format: one question per group, with up to four options, in the user's language.
   - Show the missing question and the rule first, then the concrete change, its pros and cons, and what it costs (skill length, extra steps).
   - Always offer "Defer" and "Won't fix".
   - **Prefer removing or merging a rule to adding one.** If the change makes a skill longer than about 200 lines, say so and propose what to cut.
5. **For each approved change:**
   1. **Eval first.** Add or extend a case in `evals/<skill>/<case>/`, following `evals/README.md`. The case reproduces the problem in generic terms, with no employer, project or person names. Run it on the current version with the command in `evals/README.md`, filtered with `--case '<case>'`. It should fail; if it cannot fail in an eval, say why and continue.
   2. **Make the change.**
   3. **Run the gates:**
      - `claude plugin validate "<kit source>" --strict`;
      - `"<kit source>/scripts/check.sh"`;
      - the touched skills' evals, with the command in `evals/README.md`.

      Report the spend.

6. **Record:**
   - **README:** update the skills table and any text the change makes untrue.
   - **CHANGELOG:** add an entry under the new version.
   - **Version** in `.claude-plugin/plugin.json`: patch for wording and fixes, minor for new behaviour or a new skill, major for incompatible command changes.
   - The README must agree with the change before you go on.
7. **Ship:** show the changed files with one line each, then commit (`Improve <skill>: <what>`), tag `v<version>`, and push with tags.
8. **Close the entries.** Set each to `fixed <version> (<short sha>)`, `wontfix: <reason>` or `deferred: <reason>`. Never delete an entry.
9. **Tell the user** what changed, and that it takes effect from the next session. Then the closing step (principles).

## Log

Show every entry (or one skill's), open ones first, newest first within each group, with the version that fixed each closed one. End with totals by state.

## Rules

- Never change a skill, doc or template outside `run`, and never without approval.
- Never write employer, project, ticket or colleague names into the kit source. The log and the project profiles may hold them, because they live outside the repository.
- Language follows the principles: kit source in English; conversation, signals and the reasoning in log entries in the user's language; terms never translated.
