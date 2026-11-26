---
name: improve
description: "Grow the `my` kit from real use: no argument lists open notes; `run [skill|ids]` finds the upstream lesson behind open notes and turns it into approved changes backed by eval cases, then updates README, CHANGELOG and version, and ships them after showing you the diff."
argument-hint: "note <what happened> | digest [file] | run [skill|ids] [--propose-only] | log [skill] | method | (none: list open)"
disable-model-invocation: true
when: "\"/my:improve\", \"improve the kit\", \"what's open on the kit\""
reads: [rules/core.md, rules/plan-contract.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/files.md, rules/question-format.md, rules/model-choice.md, rules/local-data.md]
---

# /my:improve — the kit's improvement loop

How the kit changes: `${CLAUDE_PLUGIN_ROOT}/rules/learning.md` § The kit's improvement loop.

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md`, `${CLAUDE_PLUGIN_ROOT}/rules/files.md`, `${CLAUDE_PLUGIN_ROOT}/rules/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/rules/model-choice.md` and `${CLAUDE_PLUGIN_ROOT}/rules/local-data.md`.

## Parse `$ARGUMENTS`

| First word    | Mode                                                   |
| ------------- | ------------------------------------------------------ |
| `note`        | Note: read `${CLAUDE_PLUGIN_ROOT}/skills/improve/note/SKILL.md` and follow it with the rest, the user's description |
| `digest`      | Digest: read `${CLAUDE_PLUGIN_ROOT}/skills/improve/digest/SKILL.md` and follow it with the optional signals file that follows |
| `run`         | Run: optional skill name, entry ids, `--propose-only`  |
| `log`         | Log: read `${CLAUDE_PLUGIN_ROOT}/skills/improve/log/SKILL.md` and follow it with the optional skill name that follows |
| `method`      | Method: read `${CLAUDE_PLUGIN_ROOT}/skills/improve/method/SKILL.md` and follow it, to list the decision kinds |
| none, `list`  | List open entries                                      |
| anything else | Treat the whole text as a note: read `${CLAUDE_PLUGIN_ROOT}/skills/improve/note/SKILL.md` and follow it with the whole text, and say so in one line |

## List (no argument)

First run `${CLAUDE_PLUGIN_ROOT}/scripts/append-entry.sh check` on the log and on `<data root>/method.md`: ids held twice are listed in one line before the entries, with the offer to renumber the later ones.

Show the open entries, grouped by skill and then by suspected cause. End with the count, and one line saying whether a run looks worthwhile. Three or more notes on the same cause are a strong signal; a single vague note may need more evidence first.

## Run

**Activity:** write the activity sidecar (`${CLAUDE_PLUGIN_ROOT}/rules/local-data.md` § State file), mode `improve:run`: `running` at the start and again when the user answers, `needs_you` while waiting at a proposal or the ship question, `done` at every exit, stops included.

1. **Preflight the kit source.** With `--propose-only`, skip it: steps 2–4 read the files under `${CLAUDE_PLUGIN_ROOT}`, and the run stops after step 4 without the closing step. Otherwise, in the main checkout (no worktree yet): clean tree, on `main`, `git fetch origin main` (never a pull: the live kit does not move before a yes). Stop if any of these fails, or if local `main` is not an ancestor of `origin/main` (`git merge-base --is-ancestor main origin/main`). Steps 2–4 then read the kit at `origin/main` (`git show origin/main:<path>`), so proposals cite current text.
2. **Select entries:** all open ones, or those matching the given skill or ids. Read each affected skill, the `rules/` files and templates, and any session or file an entry points to.
   - **Entries from an older version** (`rules/local-data.md` § Showing entries; the current version is where steps 2–4 read the kit): flag each one with its marker and the current version, read what changed since that version where its suspected cause points (the CHANGELOG entries, `git -C <kit source> log v<version>..origin/main -- <paths>`; with `--propose-only` or without git, the CHANGELOG alone), and classify it: still valid, already fixed (by which version), or obsolete (that part was rewritten). Only still-valid entries go on to step 3. Each other one gets one line with its reason and a proposed closing, `fixed <version> (already)` or `wontfix: obsolete since <version>`, asked in step 4 and applied in step 8 only on the user's yes.
3. **Find the upstream lesson.** Group the notes by upstream cause, not by surface event. For each group:
   - **Check it against the constitution first.** Read `CONSTITUTION.md` where steps 2–4 read the kit (at `origin/main`, or the plugin files with `--propose-only`), and check each note and each proposal against it. When a note asks for something the constitution forbids, or a proposal would contradict it, do not propose that change: say which clause it contradicts, and that only the user can amend the constitution, by hand or on explicit request. When the user wants that amendment, ask it as its own question (question-format § Shape). For the cause behind the note, propose only what the constitution allows.
   - **Name the missing question:** what should have been asked or checked at the start.
   - **Find the existing rule that should have covered it,** and say why it did not apply: not reached by the step where it happened, worded too narrowly, or worded for one case.
   - **Place the fix,** in this order of preference: refine, generalise or move that rule; merge it with a neighbour; add a new rule only when none covers the cause. Never word a fix around one case.
   - **Project profile** (`<data root>/projects/<owner>-<repo>.md`) only for a fact about one repository: propose the change like any other, and apply it only after approval, with no version bump.
   - **No change** when the kit behaved as designed: explain why, and propose `wontfix`.
4. **Propose,** following the question format: one question per group, with up to four options.
   - **Write for a reader who never saw the notes,** in the whole report, step 2's classification included: the explanation first, file paths, line numbers and rule names only after it, never in its place. It goes in chat, right before the questions; a report file is extra detail, never the explanation.
   - Open each group with one concrete case of what went wrong, from its notes, and say which notes it joins because they share one cause; then what will change for the user and what it costs in time; then the missing question, the rule quoted in its own words (kit terms are never translated), and the change in the kit, every term explained. Each option says its pros, its cons and its cost in the user's time first (minutes per round, a step more, none), and only then in skill length.
   - Always offer "Defer" and "Won't fix".
   - **Prefer removing or merging a rule to adding one.** If the change makes a skill longer than about 200 lines, say so and propose what to cut.
5. **For each approved change.** At the first one, create the kit worktree from `origin/main`: `<kit source>/.claude/worktrees/improve-<date>-<time>`, on a branch of the same name. Make sure `.claude/worktrees/` is ignored (`git check-ignore`, else add it to `.git/info/exclude`), and run `git config core.hooksPath .githooks` in it. This is `<kit worktree>`, used by absolute path: the session is not moved into it, since it may belong to another project: every later edit, eval and gate (5.1–5.3, 6) uses it, never the main checkout.
   1. **Eval first.** Add or extend a case in `evals/<skill>/<case>/`, following `evals/README.md`. The case reproduces the problem in generic terms, with no employer, project or person names. Run it on the current version with the command in `evals/README.md`, filtered with `--case '<case>'`. It should fail; if it cannot fail in an eval, say why and continue. Each grader counts only after it was tried on both sides, on samples its author did not choose alone: it fails the note's own wrong answer (its "What happened" and Evidence lines, and the old version's kept run when the case failed there) and passes correct answers in other words from kept runs (`--keep-temp`) of the new version, and of the old one where it already behaved; a hand-written sample only adds to these.
   2. **Make the change.**
   3. **Run the gates:**
      - `claude plugin validate "<kit worktree>" --strict`;
      - `"<kit worktree>/scripts/check.sh"`;
      - the touched skills' evals, with the command in `evals/README.md`.

      Report the spend; there is no spend cap.

6. **Record:**
   - **README:** update the skills table and any text the change makes untrue.
   - **CHANGELOG:** add an entry under the new version.
   - **Version** in `.claude-plugin/plugin.json`: patch for wording and fixes, minor for new behaviour or a new skill, major when a command or its arguments, or behaviour the user relies on, change incompatibly (README § Versioning). Every other plugin of the repository whose files changed (`mods/<name>/`) gets its own bump too: installed copies are kept by version.
   - The README must agree with the change before you go on.
   - **Commit** in `<kit worktree>` (`Improve <skill>: <what>`). Then a fresh agent that did not write the change (model: `rules/model-choice.md`) reviews `git diff origin/main..HEAD` there against the approved proposals and the constitution, and runs each new or changed grader on one near miss and one correct answer it writes itself. Fix its block findings in a new commit, then rerun the 5.3 gates.
7. **Ship:** first `git fetch origin main`. When `origin/main` moved past the worktree's base, list what changed in the files the new or changed cases and graders read (`git diff <base>..origin/main -- <paths>`), merge it into the worktree's branch (never a rebase), and rerun only the cases those changes touch, or none, with a CHANGELOG line saying where the numbers were measured. Then show the full diff (`git diff origin/main..HEAD`) and ask, saying how many commits of `main..origin/main` the fast-forward also brings. Only on yes: fast-forward `main` in the main checkout to the worktree's branch, tag `v<version>`, push with tags, then remove the worktree and delete its branch. Then update each installed copy of a plugin whose version changed (`claude plugin list` shows them): `claude plugin marketplace update <marketplace>`, then `claude plugin update <plugin>@<marketplace>`; check that the installed copy holds the new version's code, and tell the user to restart. On no, keep the worktree, say where it is, and leave the entries open.
8. **Close the entries,** only after shipping (or at once when no change was approved; a closing approved from step 2 never waits for the ship). Set each to `fixed <version> (<short sha>)`, `fixed <version> (already)`, `wontfix: <reason>` or `deferred: <reason>`. Never delete an entry.
9. **Tell the user** what changed, and that it takes effect from the next session. Then the closing step (`rules/learning.md`).

## Rules

- Never edit `CONSTITUTION.md`, and never write "Amend constitution" in a commit message unless the user asked for the amendment.
- Never write employer, project, ticket or colleague names into the kit source. The log and the project profiles may hold them, because they live outside the repository.
