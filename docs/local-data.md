# Local data

Personal and employer-specific material lives outside this repository, in `~/.my-agent-kit/`. Skills create missing folders on first use. It is deliberately not under `~/.claude/`: Claude Code treats that folder as protected configuration, so every write there needs approval, and headless runs refuse it.

```
~/.my-agent-kit/
  deny-words.txt          words that must never enter this repository (read by scripts/check.sh)
  suite-log.md            problems with the kit, written by /my:improve note and digest
  signals/<owner-name>-<branch>.md  raw signals collected during the work, until /my:improve digest turns them into notes
  projects/<repo>.md      one profile per repository
  reviewers/<handle>.md   how a reviewer thinks, written by /my:pr:study, read by /my:pr:review
  reads/                  PR readings written by /my:pr:learn (header records the head commit)
  study/                  study pages, glossary.md and README.md (the index, with the comment ids studied)
  reviews/                review drafts written by /my:pr:review
  plans/                  plans written by /my:plan:scope --dry-run
  retros/                 one-page retrospective per finished change
  state/<owner-name>-<branch>.json  where a change stands, written by /my:plan:scope, /my:plan:round and /my:plan:run, read by the status mod
```

## Project profile

Template: [templates/project-profile.md](../templates/project-profile.md). `<repo>` is the GitHub `owner-name` slug, for example `acme-web`.

`/my:plan:scope` creates the profile on first use. It reads the repository's agent instructions (`CLAUDE.md`, `AGENTS.md`), contributing guides, CI workflows and skills, then asks the user to confirm it. A skill that finds a profile wrong records a signal, and `/my:improve run` can correct it.

## Reviewer profile

Template: [templates/reviewer-profile.md](../templates/reviewer-profile.md). It holds a reviewer's recurring lenses, their typical questions, and what they let pass. It is built from study pages, never from guesses.

## Suite log

One entry per problem, in the format of [templates/log-entry.md](../templates/log-entry.md). Entries are appended and never deleted. A fixed entry keeps its text and gains a `fixed <version>` status. The digest may append `Evidence:` lines to an open entry, never change its other lines. Labels are in English; the reasoning is in the user's language.

## State file

One file per change, `state/<owner-name>-<branch>.json` (`/` in the branch becomes `-`), rewritten whole through a temp file and a rename. `/my:plan:scope` (on approval), `/my:plan:round` and `/my:plan:run` write it; the optional status mod reads it. A run resuming after compaction reads it too.

```json
{
  "repo": "owner/name",
  "branch": "feature",
  "worktree": "/abs/path",
  "session": "<session id or unknown>",
  "updatedAt": "2026-01-10T09:40:00Z",
  "mode": "run",
  "plan": { "title": "…", "path": "/abs/path/.plans/plan.md" },
  "parts": [ { "title": "Part A: …", "status": "done", "done": 3, "total": 3 } ],
  "round": 3,
  "step": "execute",
  "items": { "done": 3, "total": 6 },
  "state": "running",
  "reason": null,
  "rounds": [ { "n": 1, "startedAt": "…", "endedAt": "…", "verdict": "block 1" } ],
  "pr": 456,
  "commentsReadUntil": "2026-01-10T09:00:00Z"
}
```

- `step`: `triage`, `check`, `execute`, `verify`, `review`, `push`, `report`.
- `state`: `ready` (the plan is approved, or a round ended and the next one can start), `running`, `needs_you` (a gate is waiting, `reason` says which), `stopped` (failed or capped, `reason` says why), `done` (the bar is met).
- `parts[].status`: `todo`, `running`, `done`; a plan without parts has one part, the plan itself.
