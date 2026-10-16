# Changelog

All notable changes to this kit are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
