---
name: improve
description: Grow the `my` kit from real use. `note <text>` logs a problem with any /my skill (or its principles, templates, or a project profile) from any session, without changing anything; no argument lists open notes; `run [skill|ids]` turns open notes into approved changes backed by eval cases, then updates README, CHANGELOG and version, commits, tags and pushes; `log` shows the history. Use when the user says "/my:improve", "annota", "note this problem with the kit", "the skill did X wrong", "improve the kit", "what's open on the kit".
argument-hint: "note <what happened> | run [skill|ids] | log [skill] | (none: list open)"
---

# /my:improve — the kit's improvement loop

The kit changes only through this skill, and only with the user's approval. A note never changes anything; a run changes only what the user approves.

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md` and `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md`.

## Paths

- **Data root:** `$MY_AGENT_KIT_HOME` if set, or a data root the user names in the request; otherwise `~/.my-agent-kit`. The log is `<data root>/suite-log.md`. Create it with a `# Suite log` heading if missing.
- **Kit source:** the git repository behind `${CLAUDE_PLUGIN_ROOT}`. Resolve it with `git -C "${CLAUDE_PLUGIN_ROOT}" rev-parse --show-toplevel`. If that fails (the plugin was installed from a marketplace cache), ask for the clone path, defaulting to `~/Workspace/my-agent-kit`. Never edit the cache.

## Parse `$ARGUMENTS`

| First word    | Mode                                                   |
| ------------- | ------------------------------------------------------ |
| `note`        | Note: the rest is the user's description               |
| `run`         | Run: optional skill name or entry ids follow           |
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
   - Write it in English. If the user wrote in another language, keep a short quote of their words when the exact meaning matters.
   - The id is `YYYYMMDD-NN`, where NN counts today's entries starting at 01.
   - "What happened" and "Expected" are concrete: what was done or said, not an opinion.
   - "Suspected cause" names a step, principle, template or profile line when you can point to it; otherwise `unknown`. Do not investigate deeply here.
4. **Append** the entry to the log. Change nothing else: no skill, doc, template or profile.
5. **Confirm in exactly one line,** and nothing else: `Logged <id> · <skill> · <n> open`. Missing context goes in the entry as `unknown`; do not explain it in the reply.

## List (no argument)

Show the open entries grouped by skill, then by suspected cause, each with its id and one-line "what happened". End with the count, and one line saying whether a run looks worthwhile. Three or more notes on the same cause are a strong signal; a single vague note may need more evidence first.

## Run

1. **Preflight the kit source.** Clean tree, on `main`, `git pull --ff-only`. Stop if any of these fails.
2. **Select entries:** all open ones, or those matching the given skill or ids. Read each affected skill, the principles and templates, and any session or file an entry points to.
3. **Group by root cause.** Several notes often share one cause. For each group, decide where the fix belongs:
   - **Project profile** (`<data root>/projects/<repo>.md`): a fact about one repository. Edit the profile; no version bump.
   - **Principles or templates:** a rule that applies to several skills.
   - **One skill:** a step that only that skill has.
   - **No change:** the kit behaved as designed. Explain why, and propose closing the entry as `wontfix`.
4. **Propose,** following the question format: one question per group, with up to four options.
   - Give the concrete change, its pros and cons, and what it costs (skill length, extra steps).
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
9. **Tell the user** what changed, and that it takes effect from the next session.

## Log

Show every entry (or one skill's), newest first: id, state, and the version that fixed it. End with totals by state.

## Rules

- Never change a skill, doc or template outside `run`, and never without approval.
- Never write employer, project, ticket or colleague names into the kit source. The log and the project profiles may hold them, because they live outside the repository.
- Keep the conversation in the user's language. Files are in English.
