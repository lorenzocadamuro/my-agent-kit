# Changelog

All notable changes to this kit are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
