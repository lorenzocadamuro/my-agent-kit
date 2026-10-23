# Changelog

All notable changes to this kit are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [5.2.0] - 2026-10-23

A note now records the kit version it was written with, and `/my:improve run` checks a note from an older version against what changed since, so it no longer "fixes" a rule a later release already fixed or rewrote. Minor: new behaviour, nothing you rely on changes incompatibly.

### Improve

- A log entry gains a `Kit:` line: the `version` in the plugin's `plugin.json`, read when the writing skill starts, so it is the version the session follows (a chat keeps the version it started with while the kit moves on). Note fills it; Digest fills it from the newest version its signals carry. A signal line ends with `kit <version>`. Entries and signals written before have none and stay valid.
- List and Log mark an open entry from a version older than the current one with `from <version>` next to its state. Its version is its `Kit:` line, or else, approximately (`from ~<version>`), the latest release dated before its `When`: release tags with their dates, or without git the CHANGELOG's release dates.
- `run` step 2 flags each selected entry from an older version, reads what changed since that version where its suspected cause points (CHANGELOG, `git log v<version>..origin/main`), and classifies it: still valid, already fixed (by which version) or obsolete (that part was rewritten). Only still-valid entries go on to the upstream lesson; each other one is shown in one line with its reason and a proposed closing, `fixed <version> (already)` or `wontfix: obsolete since <version>`, applied only on your yes, and without waiting for a ship. `--propose-only` shows the same, reading what changed from the CHANGELOG alone.

### Evals

- New case `improve/run-flags-old-notes` (two open notes: one written with 4.0.0 whose cause 5.1.0 fixed, one current and still valid; no git in the sandbox, so the run falls back to the plugin's own CHANGELOG): on 5.1.0 the run already called the old note fixed, but without the version marker and proposing a plain `fixed 5.1.0`, so it fails its two version graders (1 run, re-graded on its saved reply after the final graders). After: 3 of 3 runs pass. An intermediate text gave the run its own `from <version>, now <current>` form beside the views' marker: 3 of 5 runs missed a grader on that form, the two kept ones having shown `from 4.0.0` in the table and the versions in prose; the run now uses the views' marker, kept in English like the states, and the grader checks it. An LLM grader on the proposals was dropped: its judge failed 5.1.0's reasonable reply 3 of 3 with no reason given.
- `note-logs-without-changing` gains a grader that the entry has a `Kit:` line: it fails on 5.1.0 (1 run) and passes after. `note-explains-why`, `digest-groups-signals`, `run-finds-upstream-lesson`, `run-respects-constitution` and `log-shows-problems` pass (1 run each). The suite has 34 cases.
- Prose in `skills/`, `docs/` and `templates/`: 1,425 → 1,427 lines.

## [5.1.0] - 2026-10-23

The size budget and its split trigger count production code, not tests, so the guard tests a plan asks for no longer stop a run at "drift over budget". Minor: new behaviour, nothing you rely on changes incompatibly.

### Plans

- `scripts/drift.sh` splits the change's size into production and tests and prints both, after the total `size:` line, which stays. The `--lines` and `--files` budgets compare production only; test lines and files are reported and never put a change over budget. Test files by default: paths with a `test`, `tests`, `__tests__`, `spec` or `specs` folder, and files named `*_test.*`, `*.test.*`, `*.spec.*`, `test_*.*`, `*_spec.*` or `conftest.py`; a file moved across is classed by its new path. `--tests <pathspec>…` replaces the default, and the `--` excludes work as before.
- The principles, `plan:scope` (the S and L size classes, the interview's budget topic), the plan template and `plan:round` (the `drift.sh` call and the report's Drift line, with test lines apart) state the budget in production lines and files; tests are estimated and reported apart. A plan written before reads its numbers as production lines.
- The project profile gains an optional "Test paths" line, passed to `drift.sh` as `--tests`.

### Tests and evals

- New `scripts/drift.test.sh`, in a temporary repository: fails on 5.0.0's `drift.sh` in 9 of 11 checks (test lines push a change over a budget its production code meets; `--tests` is unknown), passes 11 of 11 after. It replaces an eval case: evals have no working git.
- `plan/round-reviewed-by-fresh-agent`'s fixture shows the new `production:` and `tests:` lines in its `drift.sh` output; it passes 2 of 2 (one run before the fixture change, one after). `plan/run-carries-blocks` passes 1 of 1. `plan/small-task` passes 1 of 2: the failed run lost the plan judge and did not write the planning state; the second passed both. `plan/skipped-item-caught` passes 1 of 3 on its language graders (its catch grader 3 of 3): one run wrote `report.md` in English, one fully Italian run drew FAIL votes; 5.0.0's prose, run once for comparison, passed. The language judge is noisy here, and the one text change these cases read is the report's Drift line.
- Prose in `skills/`, `docs/` and `templates/`: 1,424 → 1,425 lines.

## [5.0.0] - 2026-10-22

A review gives its judgement first and writes for GitHub only once you agree with it; one command explains a PR or the review it received; planning research checks the premises of its recommendations. Major: `/my:pr:study` is removed.

### Breaking

- `pr:review` in `local` mode pastes the drafts in chat too, as in the other modes (the skill said both yes and no).
- `/my:pr:study` is removed: use `/my:pr:learn <PR> <comment id or URL | reviewer | comments [all]>`, or paste the comments after it. It studies the review comments as before (study page, glossary, reviewer profiles, only comments not studied yet). Without a focus, `/my:pr:learn` explains the whole PR as before. `/my:improve` reads `pr:study` in old log entries as `pr:learn`.

### Review

- `pr:review` first shows a private analysis in chat, in your language: ready to merge or not and why; the PR's main scenario followed end to end through every piece; one section per question that matters, each with its answer and nature (architecture or design, lines to fix, a nit). "Nothing worth adding" is a valid outcome: no quota of questions or findings. The questions to the author, the inline comments and the summary come only once you agree with the analysis (in chat, or already in your instructions), then the publishing gate as before. Without your agreement and with no way to ask, it stops after the analysis.
- Without a focus, `/my:pr:learn` ends the reading with a short overview of the PR's review comments (who said what, one line per reviewer, which threads are still open) pointing to `/my:pr:learn <PR> comments`; a re-run refreshes it.
- On a PR already reviewed (an earlier analysis in the data root, or reviews by others), the analysis first says, after the verdict, what the head fixed since then, what is still open and what the author answered. A point already raised in an open thread is not a new finding: the review names the thread and its author, and a draft adds to it only something new, as a reply you post in that thread.
- Before calling a shape wrong or proposing a refactor, the review finds why the code is shaped that way; a deliberate design is not a finding. Collection reads review bodies and general comments as well as inline ones.
- The review lenses start from the promise (its main scenario, end to end, before the other lenses) and gain a Coherence lens: one value computed from different inputs, texts a model reads that disagree, a condition wider than its intent. Evidence asks whether the description is still true at the head. Severity weighs reach and impact (who can trigger it, what it costs); "the main branch has the same problem" is still no reason to downgrade a broken promise. The questions for the author have no fixed count. The round reviewer starts from the plan's main scenario too.

### Plans

- A recommendation's premise is checked like any other claim: a production volume or frequency it depends on is measured with a read-only query before the interview, or the recommendation says it is unverified and which measure would decide it.
- For shared code the change extends, `plan:scope` research reports the rule each caller applies (tolerances, exceptions, what it skips), not only what it reads, and checks each rule against the change.
- An out-of-scope item you accept as it is can carry its reason in the plan with no ticket ("none: accepted (D<n> or A<n>), <reason>" in the Ticket column; a review grading a finding `ticket` offers the same), the recommended option when it concerns only a non-production environment. A ticket is one option, not the rule.

### Evals

- New case `pr/nothing-worth-adding` (a pure rename with nothing to raise): fails on 4.2.0 in 3 of 3 runs (questions and findings to fill the review), passes after on the chat verdict, 2 of 2 on an earlier fixture (whose formatting bug drew an out-of-scope ticket) and 2 of 2 on the final one. A grader on the review file's question count was dropped: its judge passed a three-question file on 4.2.0 and failed a zero-question file after.
- New case `pr/drafts-wait-for-agreement` (the broken-promise PR, with no agreement in the prompt): `review.md` holds English draft sections on 4.2.0 (1 of 1 run) and none after (2 of 2). An LLM grader on the reply was dropped: it passed 4.2.0's reply and failed two correct replies that asked whether the analysis holds.
- New case `plan/research-checks-premises`: its staging-only item gets a ticket on 4.2.0 in 2 of 2 runs and "none: accepted" after in 2 of 2. Its volume and caller-rule graders already pass on 4.2.0 (the prose principle and the fixture's profile were enough): they guard the new text.
- New case `pr/later-round-confirms-fixes` (a PR already reviewed: an earlier analysis in the data root whose block the head fixed, and a colleague's open thread): before this change it fails in 4 of 4 runs (the fix is confirmed only inside the scenario or later, and twice a new inline comment repeats the colleague's point instead of replying in her thread); after, 5 of 5 pass. These counts apply its final regex graders to the saved outputs, plus one live run after: an LLM grader was dropped, its judge having failed three correct files after the change. `pr/broken-promise` (2 of 2) and `pr/drafts-wait-for-agreement` (1 of 1) still pass; `pr/own-pr-fresh-review` passes 1 of 2, the failure a judge vote against a file with the block, the questions and the drafts (its fixture has no earlier review).
- New case `pr/learn-overviews-comments` (a PR with one open and two resolved review threads): before this change both runs mention the comments only inside layer 0 or the collapsed layer 2 (one with no `/my:pr:learn … comments` pointer at all), so neither reading ends with the overview; after, 2 of 2 pass. `pr/pr-explains-not-judges` (a PR with no comments, 1 of 1) and `pr/budget-and-known-term` (2 of 2) still pass.
- `pr/broken-promise`, `pr/own-pr-fresh-review` and `pr/review-keeps-study-private` now say in the prompt that the drafts need not wait for agreement, since evals cannot answer. `pr/budget-and-known-term` runs through `/my:pr:learn acme/orders#42 comments`; it already passes on 4.2.0 (3 of 3 runs), where the model adapted, so it guards the merge rather than proving it; after, 5 of 7 runs pass (3 of 4 on the final text), the two failures being split judge votes on the glossary and the page. The suite has 33 cases.
- Prose in `skills/`, `docs/` and `templates/`: 1,418 → 1,424 lines (17,556 → 18,334 words).

## [4.2.0] - 2026-10-22

The kit speaks your language even when everything it read is in English, introduces its questions in chat before asking them, plans in the change's worktree from the start, puts in the bar only checks that can fail, and its release updates the plugins you have installed. Minor: new behaviour, nothing you rely on changes incompatibly.

### Language and what you see

- The chat is in your language even when the skills, plans and agents' reports it read are in English; an agent's report reaches you translated and summarised, never forwarded as it is.
- When you say what you see (the chat's language, a missing explanation, a screen), the kit checks it against the session record (transcript, files, screenshots) before answering, and never contradicts you from memory.

### Questions

- Right before a batch of questions, in the same message and in your language, the chat introduces them: the situation, what the kit prescribes and why it asks, and what the choice changes. The questions and each option's Effect, Today, Pros, Cons and Severity then stay short, a few words each. This replaces the 4.1.0 rule that a longer explanation goes in chat and ends the turn: the separate turn stays only when you dismiss the questions or ask back.

### Plans

- `plan:scope` opens the change's worktree from `origin/main` as soon as the ticket or request is read (the branch name known), moves the session there when the profile says so, writes the plan in its `.plans/`, and plans in the branch's state file once the session works there (the session file stays for a dry run, or a session that stays outside the worktree). The profile's setup command starts there in the background, so the baseline runs on a ready worktree. At approval only the ready state and the ticket move are left; on cancel it offers to remove the worktree. `--dry-run` still creates nothing, and neither does a profile where you work without a worktree.
- Since an unapproved plan now sits in the worktree, `plan:round` and `plan:run` refuse a plan whose state file is still `planning` (or `needs_you` for "Plan approval"), and offer to finish `plan:scope` instead.
- A check enters the bar for done only after it was seen failing on the change's likeliest wrong input (or its code shows it checks that); otherwise the plan says it cannot fail and looks for one that can. `plan:scope` tries each bar check that way in its baseline.
- A condition that happens only after the merge (a deploy, a sync, a rollout) is proposed as a separate verification ticket, its text in the plan: the interview's bar topic and the template's "After the merge" line, written only when there is one. Each bar check in the template names the wrong input it was seen failing on, in its own line, so a small plan stays short.

### Release

- `improve run` bumps the version of every plugin of the repository whose files changed, and after the yes and the push updates the installed copies (`claude plugin marketplace update`, then `claude plugin update`), checks they hold the new code, and tells you to restart. The principles' release gate says the same. Reviewed only: the eval sandbox has no installed plugins.

### Evals

- New case `plan/post-merge-check-ticket`: fails on 4.1.1 (2 of 2 runs: the sync stays on the ticket as "the user confirms after the deploy"), passes 3 of 3 after. The suite has 28 cases.
- The introduction before questions has no case: a grader for it on `plan/run-stops-before-publishing` failed 1 of 4 runs on 4.1.1 and 1 of 5 after, because without the question tool (headless evals cannot open it, even when allowed) the context already lands in chat; the noise was not kept in a gate case.
- `plan/skipped-item-caught` gains `chat-language` (the last message is in Italian, the executor's English summary not pasted): a guard, since 4.1.1 already speaks Italian in this one-round case (one judge failure was on a fully Italian message). Both language graders now allow item titles and tool output quoted from the files.
- The check that a bar check can fail has no case: on a one-file fixture 4.1.1 already said, in 2 of 2 runs, that the validation script could not catch a wrong name; the miss came from a hook whose code was not read. Opening the worktree at the start has none either: evals have no working git, and the dry-run cases guard that `--dry-run` creates nothing.
- Prose in `skills/`, `docs/` and `templates/`: 1,414 → 1,418 lines.

## [4.1.1] - 2026-10-22

While planning, the state belongs to the chat, not the folder: two chats planning in the same folder no longer overwrite each other, and a third chat there no longer shows their plan. Patch: a fix, nothing you rely on changes.

### Status

- `plan:scope` writes its planning state to `state/session-<session id>.json` (the id from `$CLAUDE_CODE_SESSION_ID`) and deletes it at approval, when it writes the worktree branch's file as before. The activity sidecar of `pr:*` modes and `improve run` is `state/session-<session id>.activity.json`. Without a session id, the folder's name stays.
- `my-status` reads the chat's own session file (`$.session.id()`) and the folder and branch file, and shows the newer of the two (a missing date counts as oldest), so a leftover planning file never hides a live run; its fallback by worktree skips session files. A chat never shows another chat's planning or activity when both have a session id; folder-named files (written by 4.1.0, or by a chat without an id) still show in every chat of that folder, as the README says. The 6-hour rule covers session files.
- Mod tests: 37 → 42 (four fail on 4.1.0; the stale guard passes already).
- `my-status` is versioned 0.2.1, so installed copies update.

### Evals

- `plan/small-task` (`planning-state`) and `pr/broken-promise` (`activity`) now require the session name, with an id of at least one character and no unexpanded variable: both fail on 4.1.0 (1 of 1 run each); after, `activity` passes 3 of 3 runs and `planning-state` 2 of 3 (the third run showed the name only as `session-$CLAUDE_CODE_SESSION_ID.json`).
- Prose in `skills/`, `docs/` and `templates/` stays at 1,414 lines.

## [4.1.0] - 2026-10-21

The kit asks when you can answer, shows you the files it wants you to read, tries what it relies on before relying on it, follows what a plan adds, keeps its own checks, and the status band shows only where the work stands. Minor: new behaviour, nothing you rely on changes incompatibly.

### Questions

- A free answer or a dismissal that holds a question or a doubt gets an answer in chat, and the turn ends there: no new question until you say it is clear.
- A longer explanation goes in chat and ends the turn, because the question window covers the text above it; the short question comes after, carrying its own essential context.
- A decision is asked only when the work needs it: `plan:scope` asks what the plan and its first part need, and a later part's choice becomes a gate or an open question of that part.

### Files you must read

- A file you must read opens in the app's file pane, by absolute path, after its folder is added to the session when it lies outside the working directory (the data root, a worktree entered later). When the pane cannot open it, the kit gives the absolute path as code and says why. A text you must approve before it is published is pasted in chat, always. `pr:learn`, `pr:study` and `pr:review` follow this instead of `open <file>` or a bare path; `pr:comments` pastes its reply drafts, and `plan:round` the draft-PR body and the description update, with the question.

### Verification

- Every tool, client or command a plan relies on, or the kit hands you, runs once for real first, and its prerequisites (access, environment) and measured duration go into the plan or the message. A command that changes shared state (production config, deploys, data, anything published) is tried only as a dry run or its read-only part, or else marked "not tried" and you are told.
- A test drives the real consumer (the client that will call the code), not only its handler; an intermittent defect is captured first (temporary instrumentation, a trace of the failing repetition); an audit's claim about behaviour is reproduced, or marked "text only" and fixed in text; the verification is sized to what changes. The executor prompt carries the consumer and capture clauses.
- A check or a stop condition (the plan's, the round's, the coordinator's own) is never skipped, run less often or turned into a ticket without your yes (a gate), and one that fires goes to you. In `plan:round` a decision that relaxes one is a gate, and the executor stops when an item's `Stop if` holds. A check with a noisy result (an LLM judge, a model's choice) runs 2–3 times before it is called passed or failed.

### Plans

- `plan:scope` research follows what the plan adds or changes: for each new or changed field, state, key or rule, who writes it and when, who reads it (data saved before the change included), its transitions (backwards too), and any other route it opens. The round triage, the triage check and the round template carry the same check for each item.

### Status

- The band shows no work name, plan title or PR label, which the chat and the branch already give: only the state, the tiles, the percent and the time left, a reason of two or three words for `needs_you` and `stopped`, and the buttons. `pr:*` modes and `improve run` show their mode. The status line reads `my: <state>[ · extras] · <n> kit notes`.
- Nothing is cut with "…". The state and the first button always show; every other element is added whole, in a fixed order (the reason, the other buttons, the percent, the tiles, Open plan, the detail, the time), only while the band fits.
- The state file and the activity sidecar no longer carry `name`: `plan:scope` and `plan:round` stop writing it, and a `name` left by 4.0.x is ignored.
- Mod tests: 33 → 37.
- `my-status` is versioned 0.2.0 (it stayed 0.1.0 through 4.0.0): the installed mod is a copy kept by version, so without the bump an installed copy never received the 4.0.0 and 4.1.0 band. The README says how to update it.

### Evals

- New cases: `plan/free-answer-gets-an-answer` (fails on 4.0.0 in 3 of 3 runs, passes in 4 of 5 after) and `plan/tool-tried-first` (a guard: 4.0.0 already passes it). `pr/pr-explains-not-judges` and `pr/broken-promise` gain a grader for the absolute path (both fail on 4.0.0); `pr/pr-explains-not-judges` also gains two guards against `open` (4.0.0 already passes them). The suite has 27 cases.
- Following what a plan adds, and the coordinator keeping its own checks, have no case: the cases written for them passed on the text before the change (2 of 2 runs each), because a one-page fixture makes the consequence obvious, while the misses came from work spread over many rounds. They were not kept. `evals/README.md` says how many runs a noisy grader needs.
- `pr/sync-context-covers-one`: `pricing-decided` fails only on a gating word on the `pricing.py` line (it failed a correct run that wrote "user decision"), and `orders-gate` no longer takes "decided by" as a gate. 3 of 3 runs pass.
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
