# Changelog

All notable changes to this kit are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [4.1.0] - 2026-10-21

The kit asks when you can answer, shows you the files it wants you to read, tries what it relies on before relying on it, follows what a plan adds, keeps its own checks, and the status band shows only where the work stands. Minor: new behaviour, nothing you rely on changes incompatibly.

### Questions

- A free answer or a dismissal that holds a question or a doubt gets an answer in chat, and the turn ends there: no new question until you say it is clear.
- A longer explanation goes in chat and ends the turn, because the question window covers the text above it; the short question comes after, carrying its own essential context.
- A decision is asked only when the work needs it: `plan:scope` asks what the plan and its first part need, and a later part's choice becomes a gate or an open question of that part.

### Files you must read

- A file you must read opens in the app's file pane, by absolute path, after its folder is added to the session when it lies outside the working directory (the data root, a worktree entered later). When the pane cannot open it, the kit gives the absolute path as code and says why. A text you must approve before it is published is pasted in chat, always. `pr:learn`, `pr:study` and `pr:review` follow this instead of `open <file>` or a bare path.

### Verification

- Every tool, client or command a plan relies on, or the kit hands you, runs once for real first, and its prerequisites (access, environment) and measured duration go into the plan or the message.
- A test drives the real consumer (the client that will call the code), not only its handler; an intermittent defect is captured first (temporary instrumentation, a trace of the failing repetition); an audit's claim about behaviour is reproduced, or marked "text only" and fixed in text; the verification is sized to what changes. The executor prompt carries the consumer and capture clauses.
- A check or a stop condition (the plan's, the round's, the coordinator's own) is never skipped, run less often or turned into a ticket without telling you, and one that fires goes to you. In `plan:round` a decision that relaxes one is a gate, and the executor stops when an item's `Stop if` holds. A check with a noisy result (an LLM judge, a model's choice) runs 2–3 times before it is called passed or failed.

### Plans

- `plan:scope` research follows what the plan adds or changes: for each new or changed field, state, key or rule, who writes it and when, who reads it (data saved before the change included), its transitions (backwards too), and any other route it opens. The round triage, the triage check and the round template carry the same check for each item.

### Status

- The band shows no work name, plan title or PR label, which the chat and the branch already give: only the state, the tiles, the percent and the time left, a reason of two or three words for `needs_you` and `stopped`, and the buttons. `pr:*` modes and `improve run` show their mode. The status line reads `my: <state>[ · extras] · <n> kit notes`.
- Nothing is cut with "…". The state and the first button always show; every other element is added whole, in a fixed order (the reason, the other buttons, the percent, the tiles, Open plan, the detail, the time), only while the band fits.
- The state file and the activity sidecar no longer carry `name`: `plan:scope` and `plan:round` stop writing it, and a `name` left by 4.0.x is ignored.
- Mod tests: 33 → 37.

### Evals

- New cases: `plan/free-answer-gets-an-answer` (fails on 4.0.0 in 3 of 3 runs, passes in 4 of 5 after) and `plan/tool-tried-first` (a guard: 4.0.0 already passes it). `pr/pr-explains-not-judges` and `pr/broken-promise` gain graders for the absolute path and against `open` (both fail on 4.0.0). The suite has 27 cases.
- Following what a plan adds, and the coordinator keeping its own checks, have no case: the cases written for them passed on the text before the change (2 of 2 runs each), because a one-page fixture makes the consequence obvious, while the misses came from work spread over many rounds. They were not kept. `evals/README.md` gains the noisy-grader lesson.
- Prose in `skills/`, `docs/` and `templates/` stays at 1,414 lines.

## [4.0.0] - 2026-10-21

The kit now keeps its constitution (3.2.1): it never ships itself or takes a decision you have not handed over, its status is true and always visible, small work stays light, and it learns your decisions one kind at a time. Major, because behaviour you rely on changes: how `improve run` ships, how `pr:sync` handles design conflicts, and how S work runs.

### Changed (breaking)

- `/my:improve run` no longer ships on its own. It edits nothing, the project profile included, before you approve a proposal; its preflight only fetches `origin/main` (never a pull, so the live kit does not move before your yes), stops unless local `main` is an ancestor of it, and reads the kit there, so proposals cite current text (`--propose-only` skips the preflight and reads the plugin's own files); it makes the approved changes in its own worktree from `origin/main`, never in the main checkout; it commits there and has a fresh agent review the diff against the approved proposals and the constitution. Then it shows the full diff, says how many commits of `main..origin/main` the fast-forward also brings, and asks: only on yes does it fast-forward `main`, tag and push. On no it keeps the worktree and leaves the entries open; entries close only after shipping.
- `/my:pr:sync` leaves every design conflict to you. Other PRs' descriptions and comments only build the options, even when they tell other branches how to resolve the conflict; only context you typed yourself that says how to resolve decides, for every design conflict it clearly covers (general or per file), and the kit says in one line per file how it applies it; a conflict it does not clearly cover, or context that does not say how, stays a question; context passed by another skill or agent never counts. Step 5 opens with the rule: no conflicted design file is touched before you answer.
- Small work takes a light lane. For a plan with `Size: S` (a stub plan writes it too), `plan:scope` starts no agent: it researches the code and the baseline itself, and the plan's review is your approval. `plan:round` skips the triage check and the coordinator makes the changes itself; a fresh agent still reviews every round.

### Decisions and self-change

- The kit changes only through an approved plan or `/my:improve run`, and only with your yes.
- Push rule: in the kit's own repository, a plan's rounds push their work branch like any draft branch, but a push that would move `main` or a tag waits for the release gate (the full diff and your yes).
- `plan:scope` never assumes the approval: without the question tool it stops with `needs_you` and reason "Plan approval"; `--dry-run` skips the stop.
- `pr:review` on your own PR, at any size (and so at the ready-for-review gate, which runs it), splits the work across fresh read-only agents that also verify and grade; the coordinator drafts from their findings and drops none.
- Questions: every option carries its own labelled Pros and Cons, in your language ("Pro" / "Contro"); a shared header row does not count. `pr:sync` writes the shape inline: each option has its own Pros, Cons and Risk lines.

### Status

- The state file gains `name`, two or three words in the session-title format, and `reason` is two or three words. A file without `name` stays valid, and 3.2.x files still show, cut to fit.
- One writer per file: the round's executor writes item progress to a `.progress.json` sidecar, and `pr:*` modes and `improve run` write what they are doing to an `.activity.json` sidecar; the mod merges both with the state file. `plan:round` keeps `name` and the other unchanged fields when it rewrites the state file, and copies the round's "Comments read until" into `commentsReadUntil`.
- The band and the status line: name and reason cut with "…" to the width, buttons that never shrink, one label per state, "Round N done" after a round, `pr:*` modes and `improve run` shown while they run or wait for you. A planning, running or activity state untouched for 6 hours is ignored. New comments count only other people's, network data is tied to the PR, and a failed call shows nothing instead of zero.
- Mod tests: 17 → 33.

### Language and privacy

- `plan:round` and `plan:run` reports keep their labels and write their sentences in your language, with no fixed English sentence.
- Nothing published (PR text, comments, replies, commits, messages) cites, quotes or names study pages, readings, the glossary, reviewer profiles, `method.md` or the suite log.
- `scripts/check.sh` fails when the deny-word file is missing, unless `MY_AGENT_KIT_ALLOW_NO_DENY=1`; it reads the file from `$MY_AGENT_KIT_HOME` when set (`$MY_AGENT_KIT_DENY` still names another file). `scripts/check.test.sh` tests both.
- The data root is written once, in one order: a folder you name, else `$MY_AGENT_KIT_HOME`, else `~/.my-agent-kit/`. The project profile's path is written one way, `projects/<owner>-<repo>.md`.
- Shared rules (the data root, check-only items, finding grades, language) are each written once; prose in `skills/`, `docs/` and `templates/` goes from 1,418 to 1,414 lines.

### The method

- `<data root>/method.md` holds your decision kinds: `K<n>`, a generic judgement in one line ("For X, choose Y") with no repository, project, code or person names, a class, the matches in a row, a state (`asked`, `proposed`, `handed over`) and the last dates; at most 30 kinds. Only the coordinating session edits it.
- Only the gate decisions of the `plan:*` modes and `pr:sync` are learned: they record each gate answer in its kind, and other modes neither cite nor update kinds. A new kind starts `asked`, and its first answer counts like any other. The plan's Decisions table gains Kind, Recommended and Chosen, holding the options' text; plans with older columns stay valid. A recommendation cites the last choices of its kind.
- A match adds one; a mismatch rewrites the judgement, resets the count to 0, and sets a `proposed` or `handed over` kind back to `asked`. An assumption counts for no kind and creates none, and a hand-over is never assumed.
- After 5 matches in a row a `work` kind becomes `proposed`, and the next gate proposes handing it over: yes makes it `handed over`; no sets it back to `asked`, count 0. `kept` kinds are never proposed: architecture, design, speaking for you, plan approval, a boundary or rule crossing, anything published, ready for review, a release, someone else's code and moving the local stack. Every other kind is `work`. A merged kind keeps the lower count and the less autonomous state, and is `kept` if either kind was.
- A handed-over kind is decided alone, by its judgement, only when the decision clearly fits it and research does not point elsewhere, and is listed as "decided alone (handed over: K<n>)" in the round report, the plan and the `Decided alone:` line of `plan:run`'s end summary; such a decision does not stop the run. You take a kind back by saying so in chat: it goes back to `asked`, count 0.
- New `/my:improve:method` (`/my:improve method`): lists the kinds, handed-over ones first, and changes nothing.

### Evals

- New cases: `pr/design-conflict-decided-by-text` and `pr/own-pr-fresh-review` (both fail on 3.2.1), `plan/handed-over-decision` and `improve/method-shows-kinds` (both fail on 3.2.1), `plan/round-reviewed-by-fresh-agent` and `pr/review-keeps-study-private` (guards: 3.2.1 already passes them). The suite has 24 cases.
- New graders: `plan/small-task` checks that an S plan starts no subagent, `plan/skipped-item-caught` checks the report's language (it fails on 3.2.1), `pr/broken-promise` checks the activity sidecar, `plan/run-carries-blocks` checks the end summary's `Decided alone:` line (it failed before the change).
- The shell-write guard of `pr/design-conflict-decided-by-text` matches only writes to the conflicted file, relative paths included.

## [3.2.1] - 2026-10-20

### Changed

- Constitution, amended at the user's explicit request. Reason: the user wants the kit to automate as much of the workflow as it can, and to earn autonomy over time; the old text ("decisions are mine", "publishes without my yes") read as if every commit and push in the user's projects needed a yes, and did not say where the kit is heading. Clause 1 now says that decisions are the user's today, that the goal is for the user to decide only architecture, design and whatever speaks for them, and that the kit takes a kind of decision alone only after its recommendations for that kind have matched the user's choices and the user has handed it over. "What the kit must not become" now separates speaking for the user to other people (replies, PR descriptions, ready for review, messages: always the user's yes) from changing itself or pushing to its own repository (the user's yes); in the user's projects, committing and pushing are automation, not publishing.

## [3.2.0] - 2026-10-20

### Added

- `CONSTITUTION.md`: what the kit is for, nine clauses, what it must not become, and how it is amended. The user asked for it and approved the text in chat; it wins over every other rule, the principles included. It changes only by hand or at the user's explicit request, with the reason written down.
- `.githooks/commit-msg`: a commit that touches `CONSTITUTION.md` fails unless its message contains "Amend constitution"; merges pass. A guard against accidents, not a wall.
- `/my:improve run` reads the constitution before proposing: when a note asks for something it forbids, or a proposal would contradict it, the run names the clause and says that only the user can amend it, instead of proposing the change; for the cause behind such a note it proposes only what the constitution allows. It never edits the file.
- Pointers: `docs/principles.md` serves the constitution; `.claude/CLAUDE.md` states the amendment rule and that agents never write the phrase on their own; the README names it first among the principles.
- Eval `improve/run-respects-constitution` (it fails on 3.1.0).

## [3.1.0] - 2026-10-20

### Added

- The status is visible from the first step: `plan:scope` writes the state file as `planning`, with its step (research, interview, writing, review, approval), and the status line shows "Planning". `--dry-run` deletes it at the end.
- Principles, "the kit carries the plan it made": an approved plan runs only through `/my:plan:run` or `/my:plan:round`; a request to do part of it directly becomes a round with that part as its source; leaving the kit for a change is the user's call.
- Verification-only items: a round item can be "check only"; its summary row is `checked`, with no commit and the evidence in the note, and `verify-round.sh` accepts it.
- The plan's bar for done says what is checked every round and what once at the end, with the cost of each; rounds use the first, the ready-for-review gate the second.

### Changed

- One rule for the state file's name, from the session's folder and never from the project profile: `<owner>-<repo>-<branch>` from the git remote, or `none-<folder>`. The file follows the session into a worktree. The status mod also finds a state file by its `worktree` when the name differs.
- `plan:scope` research traces how the things the plan relies on really work: the callers of shared code, every field and rule of code or data it replaces, the order in which a measuring tool runs, each with `file:line` and checked against a scenario that runs today.
- Question format: explore in the chat on a mockup while a design takes shape, and ask with the tool once a real choice is left; show structural or visual cases as a small before/after; say which principle the recommended option rests on, and when it only keeps today's behaviour.
- At approval, `plan:scope` writes the worktree branch's state file (with `repo`, `branch` and `worktree`) and deletes the planning one, so the bar shows wherever the work continues; a cancelled plan deletes it, and an existing branch sets it to `needs_you`. The status mod ignores a `planning` state untouched for 6 hours.
- If the plan's end-of-work checks fail at the ready-for-review gate, their failures become the next round's items.
- Check-only items are exempt from "test first" and "one commit per item" in the round template, the executor and the triage check; the round report counts them.
- `plan:scope` lists the sections an S plan drops on one line, without headings.
- Eval `plan/small-task` checks that planning writes a state file (it fails on 3.0.0); mod tests cover the planning state, the fallback by worktree and stale planning states; the `pr/design-conflict-stops` options grader accepts Italian pros and cons.

## [3.0.0] - 2026-10-19

### Changed (breaking)

- Commands are grouped by object. `/my:scope-plan` is `/my:plan:scope`, `/my:pr-round` is `/my:plan:round`, `/my:learn:pr` is `/my:pr:learn`, `/my:learn:review` is `/my:pr:study`, `/my:review-lens` is `/my:pr:review`, `/my:explain-comment` is `/my:pr:comments`, `/my:merge-main` is `/my:pr:sync`. `/my:improve:*` is unchanged. Each mode keeps today's steps and outputs.
- Three skills with modes: `plan` (scope, round, run), `pr` (learn, study, review, comments, sync) and `improve`. Each command carries its own "Use for…" phrases; the private learning rules stay with `pr:learn` and `pr:study`.
- Log entries and signals name `skill:mode`. `improve` reads older entries and signals under the new names and shows only those.
- Eval cases moved to `evals/plan/` and `evals/pr/`.

### Added

- `/my:plan:run`: rounds one after another while each succeeds (verification passed, push done or disabled, no open question), across plan parts. It stops at a gate the plan or the principles name, failed verification, drift over budget, conflicts with main, new PR comments, red CI known at round start, anything to publish, the ready-for-review gate, or 5 consecutive rounds, with one notification and one summary at the end.
- Rounds write their review to `.plans/round-<N>-review.md`, so block findings reach the next round, and tick a plan part's checkboxes when its items are verified.
- The state file `<data root>/state/<owner-name>-<branch>.json`, written by `plan:scope` (ready), `plan:round` and `plan:run` at every step; its shape is in `docs/local-data.md`.
- A session chapter per round.
- `mods/my-status`, an optional mod installed from the repository's marketplace: one line above the prompt with the plan's parts as tiles that fill up, the percentage, the time left, what needs the user, and the next action as a button that fills the prompt; "Open plan" in a pane; a status line entry. It only reads (plus a `git fetch` at most every 10 minutes while a PR exists).
- Evals `plan/run-carries-blocks` and `plan/run-stops-before-publishing`; `improve/log-shows-problems` checks the new names. The suite has 17 cases.

### Fixed

- Eval graders that searched the trace for `git worktree add` and `git push` now check the commands actually run, not the instructions the agent read.
- `improve/run-finds-upstream-lesson` uses regex graders instead of an LLM judge on a long reply, and checks that only new names reach the user; `improve/digest-groups-signals` accepts the confirmation line in the user's language.
- `plan:scope`: a dropped plan section is one line with nothing under it.

## [2.4.1] - 2026-10-19

### Changed

- Principles, verify: "check every claim" now names the agent's own claims too: a ticket's premises, live state (flags, config, environment, a preview), the consequences written into an option, and "done", "it is live" or "it works". Each carries evidence or is marked unverified; the question format points option effects at this rule.
- Principles, worktree: the project profile can say how the user works in a repository (for example "work on `main`, no worktree"), and skills check what the profile names. `pr-round` preflight follows it. Building a profile now asks how the user works there and how the local stack runs; the profile template records the stack variant and the move and move-back commands.
- Question format: a term's plain meaning also covers ideas introduced earlier in the conversation; an answer that makes a pending question stale means dropping or rewriting it.
- Principles, links: the scratchpad is not openable from the app's file pane; a file the user must read goes in the working directory's `.plans/` or the data root.

## [2.4.0] - 2026-10-19

### Added

- The kit learns while it is used. Every skill records signals without interrupting: a free "Other" answer or a dismissed question (and why), a request for a simpler explanation, a reversed decision, a surprise gate or stop, a review finding or a reviewer or bot comment the plan should have caught, rework. They go to `<data root>/signals/`, so they survive the session and the worktree.
- `/my:improve digest` (and `/my:improve:digest`): turns pending signals into a few notes grouped by upstream cause. Withdrawn signals are marked dropped, and a cause that already has an open note gains `Evidence:` lines instead of a new note. Every skill runs it at the end.
- `pr-round` reads the PR comments that are new since the last round, without touching `explain-comment`'s state, and its report gains a `Lessons:` line. `explain-comment` records a real comment the plan should have caught as a signal.
- Log entries gain "Why it was a problem" and "Missing question". Their reasoning is in the user's language.
- `/my:improve run --propose-only` stops after the proposals.
- Evals `improve/note-explains-why`, `improve/digest-groups-signals` and `improve/run-finds-upstream-lesson`; `explain-comment/duplicates` also checks the signal. The suite has 15 cases.

### Changed

- `improve run` looks for the upstream lesson first: the missing question, and the existing rule that should have covered it and why it did not. It prefers refining, generalising or moving that rule to adding one.
- Principles, language: reasoning is in the user's language, in plain words. Repository and kit vocabulary is never translated, and a term gets a plain meaning the first time it appears. This replaces the "technical labels" rule; the question format keeps terms instead of paraphrasing them.
- The principles' closing step collects signals and runs the digest, instead of offering a note.

## [2.3.0] - 2026-10-16

### Added

- Principles: measure a check's baseline on `origin/main` before it enters the bar for done or a stop condition. When it already fails there, the bar reads "no new failures against the baseline". `scope-plan` records the baseline during research, the plan template's Verification asks for it, and `pr-round` keeps it in stop conditions.
- Principles: link only files the desktop app can open. Before linking a file under the data root, add the data root to the session with the directory-request tool; when the tool is missing, show the path as code.
- Principles: technical labels (states, ids, table headers) stay in English; explanations follow the user's language.
- Question format: one decision per question; every option has both pros and cons; for a rollout, say first what the deployed thing does and what users see when it is missing. A dismissed batch, or "I don't understand", means explain first and ask again with the tool, never options in plain text.
- `improve` list and log: each entry shows its problem in one line and a coloured state badge, with the detail on demand. Closed entries are folded away. Uses the app's visual widget when available, a Markdown table otherwise.
- Evals `scope-plan/baseline-and-callers` and `improve/log-shows-problems`; the suite has 12 cases.

### Changed

- `scope-plan` research lists every caller of each shared function or chokepoint the change extends, with what each reads, not only the entry points.
- `improve note` re-reads the log right before appending and takes the next free id, so two sessions cannot write the same one.
- The README and `improve` no longer hard-code the clone location.

### Fixed

- Eval `learn/pr-explains-not-judges`: the graders no longer fail on ordinary uses of "block" or on a question mark slightly further from "idempotency".

## [2.2.0] - 2026-10-15

### Added

- Principles: a skill that opens a fresh session renames it after the work with the app's session-title tool: `<ticket or PR id> <2-3 words>`, or two or three words naming the problem. It skips the rename when the tool is missing. Before, the title stayed the command name ("Scope plan <id>").

## [2.1.0] - 2026-10-14

### Added

- `scope-plan` moves the session into the new worktree with EnterWorktree, when the project profile says so. Worktrees can live in the editor's own folder (`<repo>/.claude/worktrees/`).
- Project profiles gain "Session follows the worktree" and "Manual testing". `pr-round` treats moving the local stack to the change's worktree as a gate.

## [2.0.0] - 2026-10-14

### Changed (breaking)

- `/my:study-review` is now `/my:learn review`. The skill has two modes and keeps the same study pages, glossary and index.

### Added

- `/my:learn pr <n>`: understand a PR before reviewing it. Gives what it does and why, the flow before and after, the reading order, its promise and the questions to keep in mind. A re-run covers only the commits since the last reading.
- Sub-commands for a navigable menu: `/my:learn:pr`, `/my:learn:review`, `/my:improve:note`, `/my:improve:run`, `/my:improve:log`.
- `/my:review-lens` reuses the `/my:learn pr` reading: its promise and map as the yardstick, its questions as starting hypotheses.
- Eval `learn/pr-explains-not-judges`; the suite has 10 cases, all passing.

## [1.0.0] - 2026-10-14

### Added

- `/my:pr-round` skill: plan-driven round with checked triage, background executor, verification against git, fresh conformance review with labelled findings, deep review at milestones, automatic draft push, five-line report and ready-for-review gate with a retrospective; evals for a silently skipped item and an out-of-scope finding.
- `/my:merge-main` skill: merge-tree preview, conflict classes, design-conflict gate informed by the conflicting PRs, pinned regeneration and post-merge checks; eval for a design conflict next to a lockfile conflict.
- `/my:explain-comment` skill: duplicate grouping, code-checked classification, proportional actions, reply drafts, and a triage file for the next round; eval for duplicates and a false positive.
- `/my:review-lens` skill: senior-style review with verified, graded findings, questions for the author, and pending-review, summary or local output; eval for a broken promise.
- `/my:scope-plan` skill: project profile setup, ticket reading, research, size-scaled interview, independent plan review, approval gate, worktree and ticket start; evals for a small task and a false premise.
- `/my:study-review` skill: three-layer Markdown study pages with a reading budget, cumulative glossary, reviewer profiles and index; eval for the budget and known terms.
- Shared foundation: principles extended (gates, push policy, review depth, notifications, project profiles, closing step), question format, review lenses, local data layout.
- Templates: plan, project profile, round, round summary, log entry, reviewer profile, study page.
- `/my:improve` skill: `note`, list, `run`, `log`, with its first eval case.
- Eval guide: how to run cases locally and which grader types to use.
- Scripts: `verify-round.sh` (summary versus git) and `drift.sh` (size, distance from main, conflict preview).

### Changed

- Local data root moved from `~/.claude/my` to `~/.my-agent-kit`: Claude Code protects `~/.claude`, so headless runs refused to write there (found in the real trials).
- README: gates updated (pushing a verified round to the draft branch is not a gate), end-to-end example, eval command.

### Verified

- 9 eval cases pass (`claude plugin eval`, local only, about $3.3 for the suite).
- Real read-only trials of all seven skills on a large private repository, including a full `pr-round` and `merge-main` on a scratch branch that was never pushed.

## [0.1.0] - 2026-10-14

### Added

- Repository base: plugin manifest (`my`), private marketplace manifest, README, shared principles, privacy check and pre-commit hook.
