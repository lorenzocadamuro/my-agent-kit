# Local data

Personal and employer-specific material lives outside this repository, in the data root (`~/.my-agent-kit/` by default; principles: where files go). Skills create missing folders on first use. It is deliberately not under `~/.claude/`: Claude Code treats that folder as protected configuration, so every write there needs approval, and headless runs refuse it.

```
<data root>/              ~/.my-agent-kit/ by default
  deny-words.txt          words that must never enter this repository (read by scripts/check.sh; `$MY_AGENT_KIT_DENY` names another file)
  suite-log.md            problems with the kit, written by /my:improve note and digest
  method.md               the user's decision kinds and which ones are handed over (§ Method)
  signals/<owner-name>-<branch>.md  raw signals collected during the work, until /my:improve digest turns them into notes
  projects/<owner>-<repo>.md  one profile per repository
  reviewers/<handle>.md   how a reviewer thinks, written by /my:pr:learn (comment focus), read by /my:pr:review
  reads/                  PR readings written by /my:pr:learn (header records the head commit)
  study/                  study pages, glossary.md and README.md (the index, with the comment ids studied)
  reviews/                analyses and drafts written by /my:pr:review, read again by its next review of the PR
  plans/                  plans written by /my:plan:scope --dry-run
  retros/                 one-page retrospective per finished change
  trials/                 private material for the kit's own trials, such as triages saved before their check (trials/triage-before-check/) and round reviews' inputs saved before the review (trials/review-before-check/), each with the answer that followed
  state/<owner>-<repo>-<branch>.json  where a change stands (state/session-<session id>.json while planning outside a worktree), written by /my:plan:scope, /my:plan:round and /my:plan:run, read by the status mod
  state/<same base>.progress.json, .activity.json  sidecars: a round's item progress; what a pr:* mode or improve run is doing
```

## Project profile

Template: [templates/project-profile.md](../templates/project-profile.md). Its file is `projects/<owner>-<repo>.md`, the same slug as the state file's name (`acme-web` for `acme/web`).

`/my:plan:scope` creates the profile on first use. It reads the repository's agent instructions (`CLAUDE.md`, `AGENTS.md`), contributing guides, CI workflows and skills, then asks the user to confirm it. A skill that finds a profile wrong records a signal, and `/my:improve run` can correct it.

## Reviewer profile

Template: [templates/reviewer-profile.md](../templates/reviewer-profile.md). It holds a reviewer's recurring lenses, their typical questions, and what they let pass. It is built from study pages, never from guesses.

## Suite log

One entry per problem, in the format of [templates/log-entry.md](../templates/log-entry.md); entries written before 5.2.0 have no `Kit:` line nor a version on their `Evidence:` lines, and stay valid. Entries are appended and never deleted. A fixed entry keeps its text and gains a `fixed <version>` status. The digest may append `Evidence:` lines to an open entry, never change its other lines.

## Method

`method.md` holds the decision kinds of the principles' § The method, one row each in a table with the columns `Kind · Judgement · Class · Matches · State · Last matches · Hand-over`: `K<n>`; the judgement in one line, as the habitual choice ("For X, choose Y"); `kept` for architecture, design, speaking for the user, plan approval, a boundary or rule crossing, anything published, ready for review, a release, someone else's code and moving the local stack, and `work` for every kind not in that list; the matches in a row; `asked`, `proposed` or `handed over`; the dates of the last matches; the date of the last hand-over or take-back. At most 30 kinds. No repository, project, code or person names and no code: repository facts belong in the project profile. A new kind is appended with `scripts/append-entry.sh kind <method.md> <row file>`, its row starting `| <id> |`: the script numbers it under a lock, so two sessions never take the same `K<n>`. To change a row, take the same lock (`mkdir <method.md>.lock`, removed afterwards), re-read the file, rewrite it whole through a temp file and a rename.

## State file

One file per change and folder, rewritten whole through a temp file and a rename, like its sidecars; one writer at a time per file. `/my:plan:scope` (from its first step), `/my:plan:round` and `/my:plan:run` write it; the optional status mod reads it and merges the sidecars. A run resuming after compaction reads it too.

- **Name:** `state/<owner>-<repo>-<branch>.json`, computed from the folder the session works in, never from the project profile's name: `<owner>-<repo>` from `git remote get-url origin` (`git@github.com:acme/shop.git` gives `acme-shop`), or `none-<name of the repository's top-level folder>` when there is no remote; `<branch>` from `git branch --show-current`, `/` becoming `-` (`detached` when empty). When git cannot answer (no repository, or a sandbox), use the repository and branch the user named; a missing repository becomes `none-<folder>`, a missing branch `detached`. The status mod computes it the same way, and shows nothing outside git.
- **The file follows the work:** `plan:scope` plans in the worktree branch's file once its session works in the worktree it opened. Before that, in a dry run, or when the session stays outside the worktree, the work belongs to the chat: it writes `state/session-<session id>.json` (the id from `$CLAUDE_CODE_SESSION_ID`; when it is empty, or has a character outside `[A-Za-z0-9_-]`, the folder's name above), and deletes it when the session moves into the worktree or at approval, when it writes the branch's file. The status mod reads the chat's own session files first, then the folder's, never another chat's, and ignores a `planning` or `running` file, or an activity, not updated for 6 hours.

```json
{
  "repo": "owner/name",
  "branch": "feature",
  "worktree": "/abs/path",
  "session": "<session id or unknown>",
  "startedAt": "2026-01-09T15:00:00Z",
  "updatedAt": "2026-01-10T09:40:00Z",
  "mode": "run",
  "plan": { "title": "…", "path": "/abs/path/.plans/plan.md" },
  "parts": [ {
    "title": "Part A: …", "short": "Checkout flow", "status": "running", "done": 2, "total": 3,
    "steps": [ { "label": "Cart totals", "status": "done" }, { "label": "Payment retry", "status": "done" }, { "label": "Checkout test", "status": "running" } ]
  } ],
  "round": 3,
  "step": "execute",
  "items": { "done": 3, "total": 6 },
  "state": "running",
  "reason": null,
  "rounds": [
    { "n": 1, "startedAt": "…", "endedAt": "…", "verdict": "block 1" },
    { "n": 2, "startedAt": "…", "endedAt": "…", "verdict": "block 1" },
    { "n": 3, "startedAt": "…" }
  ],
  "pr": 456,
  "commentsReadUntil": "2026-01-10T09:00:00Z"
}
```

- `step`: `triage`, `check`, `execute`, `verify`, `review`, `push`, `report`.
- `state`: `planning` (`/my:plan:scope` is at work; `step` is `research`, `interview`, `write`, `review` or `approval`), `ready` (the plan is approved, or a round ended and the next one can start), `running`, `needs_you` (a gate is waiting, `reason` says which), `stopped` (failed or capped, `reason` says why), `done` (the bar is met).
- `parts[].status` and `parts[].done`: derived at every write from the part's boxes in `plan.md`: `done` counts the ticked ones; `status` is `done` when all are ticked, `running` when some are or one of its steps is `running`, else `todo`. A plan without parts has one part, the plan itself.
- `startedAt`: when the work started. `plan:scope` writes it at its first step (a file that has one keeps it; a file left by a finished plan, `state: "done"`, counts as having none), carries it from the session file into the branch's file only when the branch's file has none, and nobody changes it afterwards.
- `parts[].short`: the part's title in two or three words and at most 16 characters, from its heading after "Part X:" (`Checkout flow`): what usually fits under a part in the band, which shows the letter alone when the title does not fit. Written by `plan:scope` step 8, and whenever the plan's parts change.
- `parts[].steps`: the part's steps in the plan's order, each `{ "label", "status" }`, `label` in two or three words (`Checkout test`). `plan.md`'s boxes are the source of truth: every write, by `plan:scope` step 8 or `plan:round`, derives each `status` again with `scripts/state-steps.sh`, the first that holds: `failed` when it is already `failed` and its box is unticked (only `plan:round` step 6 sets it, on the step of an item to blame; adding a new round's entry to `rounds` clears it); `running` while a round without `endedAt` has an item that implements or reworks it, a ticked step included; `done` when its box is ticked; else `todo`. When the plan's steps change, `steps` is rewritten from the plan and derived again.
- `parts[].left`: older files only. Kit 5.6.0 and before wrote the unticked steps here; no skill writes it now, and the status mod reads it only when `steps` is missing.
- `rounds[]`: one entry per round, written by `plan:round`: `{ "n", "startedAt" }` at the round's start (with `--verify N`, when round N has none), `endedAt` and `verdict` at its end; until `endedAt` is set the round is open. `verdict` is the review's verdict against the bar, or `failed: <reason>` when verification failed.
- `ticketFrom`: the ticket's status before `plan:scope` moved it to the start status, so a cancelled plan can move it back.
- `reason`: two or three words (`Plan approval`). The status band and line never show the work's name or the plan title; part titles and step labels, two or three words each, they may. A `name` left by an older version is ignored.
- **Progress sidecar** `<same base>.progress.json`: `{ "round": 3, "items": { "done": 4, "total": 6 }, "updatedAt": "…" }`, written only by the round's executor after each item, at the path the coordinator gives it.
- **Activity sidecar** `state/session-<session id>.activity.json`, or without a session id `<base>.activity.json`, `<base>` computed as above from the session's folder; the name is fixed once, when the mode starts, and kept for every later write of that mode: `{ "mode": "pr:review", "state": "running", "updatedAt": "…" }`, `state` being `running`, `needs_you` or `done`; written by the `pr:*` modes and `improve run`, each by the rule in its skill.
