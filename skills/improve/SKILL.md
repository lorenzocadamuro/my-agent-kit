---
name: improve
description: Grow the `my` kit from real use. `note <text>` logs a problem with any /my skill (or its principles, templates, or a project profile) from any session, without changing anything; `digest` turns the signals other skills collected during the work into a few clear notes; no argument lists open notes; `run [skill|ids]` finds the upstream lesson behind open notes and turns it into approved changes backed by eval cases, then updates README, CHANGELOG and version, and ships them after showing you the diff; `log` shows the history; `method` lists the decision kinds the kit has learned and which ones are handed over. Use when the user says "/my:improve", "annota", "note this problem with the kit", "the skill did X wrong", "improve the kit", "what's open on the kit".
argument-hint: "note <what happened> | digest [file] | run [skill|ids] [--propose-only] | log [skill] | method | (none: list open)"
---

# /my:improve — the kit's improvement loop

The kit changes only through an approved plan (`/my:plan:*`) or `run`, and only with the user's yes. A note never changes anything; a run changes only what the user approves.

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md` and `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md`.

## Paths

- **Log and signals:** the log is `<data root>/suite-log.md`. Create it with a `# Suite log` heading if missing. Signals live in `<data root>/signals/`.
- **Kit source:** the git repository behind `${CLAUDE_PLUGIN_ROOT}`. Resolve it with `git -C "${CLAUDE_PLUGIN_ROOT}" rev-parse --show-toplevel`. If that fails (the plugin was installed from a marketplace cache), ask for the path of the user's clone. Never edit the cache.

## Old names

Entries and signals written before 3.0.0 name skills that are now modes. Read them as their new names everywhere: in List and Log views, in Run selection, and in Digest. Show only the new names, in tables and in prose alike; the old ones never reach the user, not even to explain the rename. A filter on a skill (`log plan`) matches every mode of it.

| Old         | New           |
| ----------- | ------------- |
| `scope-plan` | `plan:scope` |
| `pr-round`  | `plan:round`  |
| `learn`     | `pr:learn` when the entry is about a PR reading, `pr:study` when it is about a review study |
| `review-lens` | `pr:review` |
| `explain-comment` | `pr:comments` |
| `merge-main` | `pr:sync`    |

## Parse `$ARGUMENTS`

| First word    | Mode                                                   |
| ------------- | ------------------------------------------------------ |
| `note`        | Note: the rest is the user's description               |
| `digest`      | Digest: an optional signals file follows               |
| `run`         | Run: optional skill name, entry ids, `--propose-only`  |
| `log`         | Log: optional skill name follows                       |
| `method`      | Method: list the decision kinds                        |
| none, `list`  | List open entries                                      |
| anything else | Treat the whole text as a note, and say so in one line |

## Note

Goal: under a minute, no questions unless the text is empty.

1. **Identify the skill and mode,** written `skill:mode` (`plan:scope`, `plan:run`, `pr:review`, `improve:run`): from the text, or else from the most recent `/my:` command used in this session, or else `general`. Use `principles`, `templates`, `scripts`, `mod` or `profile:<repo>` when the problem is there.
2. **Collect context without asking:**
   - date and time;
   - current repository (`git rev-parse --show-toplevel`, remote slug), branch, and PR number (`gh pr view --json number -q .number`, if any);
   - the session id if known.
3. **Fill the entry** from `${CLAUDE_PLUGIN_ROOT}/templates/log-entry.md`.
   - The reasoning fields are what happened, why it was a problem, missing question and expected (principles: language). Keep a short quote of the user's words when the exact meaning matters.
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

**Activity:** write the activity sidecar (`${CLAUDE_PLUGIN_ROOT}/docs/local-data.md` § State file), mode `improve:run`: `running` at the start and again when the user answers, `needs_you` while waiting at a proposal or the ship question, `done` at every exit, stops included.

1. **Preflight the kit source** (the main checkout; no worktree yet). Clean tree, on `main`, `git pull --ff-only`. Stop if any of these fails. With `--propose-only`, skip the preflight, and stop after step 4 without the closing step.
2. **Select entries:** all open ones, or those matching the given skill or ids. Read each affected skill, the principles and templates, and any session or file an entry points to.
3. **Find the upstream lesson.** Group the notes by upstream cause, not by surface event. For each group:
   - **Check it against the constitution first.** Read `${CLAUDE_PLUGIN_ROOT}/CONSTITUTION.md`, and check each note and each proposal against it. When a note asks for something the constitution forbids, or a proposal would contradict it, do not propose that change: say which clause it contradicts, and that only the user can amend the constitution, by hand or on explicit request. For the cause behind the note, propose only what the constitution allows.
   - **Name the missing question:** what should have been asked or checked at the start.
   - **Find the existing rule that should have covered it,** and say why it did not apply: not reached by the step where it happened, worded too narrowly, or worded for one case.
   - **Place the fix,** in this order of preference: refine, generalise or move that rule; merge it with a neighbour; add a new rule only when none covers the cause. Never word a fix around one case.
   - **Project profile** (`<data root>/projects/<repo>.md`) only for a fact about one repository: propose the change like any other, and apply it only after approval, with no version bump.
   - **No change** when the kit behaved as designed: explain why, and propose `wontfix`.
4. **Propose,** following the question format: one question per group, with up to four options.
   - Show the missing question and the rule first, then the concrete change, its pros and cons, and what it costs (skill length, extra steps).
   - Always offer "Defer" and "Won't fix".
   - **Prefer removing or merging a rule to adding one.** If the change makes a skill longer than about 200 lines, say so and propose what to cut.
5. **For each approved change.** At the first one, create the kit worktree from `origin/main`: `<kit source>/.claude/worktrees/improve-<date>-<time>`, on a branch of the same name. Make sure `.claude/worktrees/` is ignored (`git check-ignore`, else add it to `.git/info/exclude`), and run `git config core.hooksPath .githooks` in it. This is `<kit worktree>`: every later edit, eval and gate (5.1–5.3, 6) uses it, never the main checkout.
   1. **Eval first.** Add or extend a case in `evals/<skill>/<case>/`, following `evals/README.md`. The case reproduces the problem in generic terms, with no employer, project or person names. Run it on the current version with the command in `evals/README.md`, filtered with `--case '<case>'`. It should fail; if it cannot fail in an eval, say why and continue.
   2. **Make the change.**
   3. **Run the gates:**
      - `claude plugin validate "<kit worktree>" --strict`;
      - `"<kit worktree>/scripts/check.sh"`;
      - the touched skills' evals, with the command in `evals/README.md`.

      Report the spend.

6. **Record:**
   - **README:** update the skills table and any text the change makes untrue.
   - **CHANGELOG:** add an entry under the new version.
   - **Version** in `.claude-plugin/plugin.json`: patch for wording and fixes, minor for new behaviour or a new skill, major for incompatible command changes or behaviour the user relies on (README § Versioning).
   - The README must agree with the change before you go on.
   - **Commit** in `<kit worktree>` (`Improve <skill>: <what>`). Then a fresh agent that did not write the change reviews `git diff origin/main..HEAD` there against the approved proposals and the constitution. Fix its block findings in a new commit, then rerun the 5.3 gates.
7. **Ship:** show the full diff (`git diff origin/main..HEAD`) and ask. Only on yes: fast-forward `main` in the main checkout to the worktree's branch, tag `v<version>`, push with tags, then remove the worktree and delete its branch. On no, keep the worktree, say where it is, and leave the entries open.
8. **Close the entries,** only after shipping (or at once when no change was approved). Set each to `fixed <version> (<short sha>)`, `wontfix: <reason>` or `deferred: <reason>`. Never delete an entry.
9. **Tell the user** what changed, and that it takes effect from the next session. Then the closing step (principles).

## Method

Show `<data root>/method.md`, handed-over kinds first: id, judgement, class, state, matches and the last dates, labels as the principles say. Without the file, say that no kind is recorded yet. Change nothing; a take-back the user says afterwards in this session is applied as the principles' method says.

## Log

Show every entry (or one skill's), open ones first, newest first within each group, with the version that fixed each closed one. End with totals by state.

## Rules

- Never edit `CONSTITUTION.md`, and never write "Amend constitution" in a commit message unless the user asked for the amendment.
- Never write employer, project, ticket or colleague names into the kit source. The log and the project profiles may hold them, because they live outside the repository.
