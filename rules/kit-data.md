# Kit data

Personal and employer-specific material lives outside this repository, in the data root (`~/.my-agent-kit/` by default). Skills create missing folders on first use. It is deliberately not under `~/.claude/`: Claude Code treats that folder as protected configuration, so every write there needs approval, and headless runs refuse it.

```
<data root>/              ~/.my-agent-kit/ by default
  deny-words.txt          words that must never enter this repository (read by scripts/check.sh; `$MY_AGENT_KIT_DENY` names another file)
  suite-log.md            problems with the kit, written by /my:note after the user's yes
  method.md               the user's decision kinds and which ones are handed over (§ Method)
  signals/<owner-name>-<branch>.md  raw signals collected during the work, listed in the end report, until /my:note signals turns the approved ones into notes
  projects/<owner>-<repo>.md  one profile per repository
  reviewers/<handle>.md   how a reviewer thinks, written by /my:learn (comment focus), read by /my:review
  reads/                  PR readings written by /my:learn (header records the head commit)
  study/                  study pages, glossary.md and README.md (the index, with the comment ids studied)
  reviews/                analyses and drafts written by /my:review, read again by its next review of the PR
  plans/                  plans written by /my:scope --dry-run
  retros/                 one-page retrospective per finished change
  trials/                 private material for the kit's own trials, such as past triages saved before their check and past round reviews' inputs; rounds no longer write it
  state/<owner>-<repo>-<branch>.json  where a change stands (state/session-<session id>.json while planning outside a worktree), written by /my:scope and /my:run, read by the status mod
  state/<same base>.progress.json, .activity.json  sidecars: a round's item progress; what a pr:* mode or improve run is doing
```

## Project profile

Template: [skills/plan/profile/profile-template.md](../skills/plan/profile/profile-template.md). Its file is `projects/<owner>-<repo>.md`, the same slug as the state file's name (`acme-web` for `acme/web`).

`/my:scope` creates the profile on first use. It reads the repository's agent instructions (`CLAUDE.md`, `AGENTS.md`), contributing guides, CI workflows and skills, then asks the user to confirm it. A skill that finds a profile wrong records a signal, and `/my:improve run` can correct it. The exception: the facts its recorded sources state refresh at the start of `/my:scope`, `/my:run`, `/my:review` and `/my:sync` (`skills/plan/profile/SKILL.md` § Keeping it current).

## Reviewer profile

Template: [skills/pr/learn/reviewer-profile-template.md](../skills/pr/learn/reviewer-profile-template.md). It holds a reviewer's recurring lenses, their typical questions, and what they let pass. It is built from study pages, never from guesses.

## Suite log

One entry per problem, in the format of [skills/improve/note/note-template.md](../skills/improve/note/note-template.md); entries written before 5.2.0 have no `Kit:` line nor a version on their `Evidence:` lines, and stay valid. Entries are appended and never deleted. A fixed entry keeps its text and gains a `fixed <version>` status. `/my:note signals` may append `Evidence:` lines to an open entry after the user's yes, never change its other lines.

## Method

`method.md` holds the decision kinds of `rules/learning.md` § The method, one row each in a table with the columns `Kind · Judgement · Class · Matches · State · Last matches · Hand-over`: `K<n>`; the judgement in one line, as the habitual choice ("For X, choose Y"); `kept` for architecture, design, speaking for the user, plan approval, a boundary or rule crossing, anything published, ready for review, a release, someone else's code and moving the local stack, and `work` for every kind not in that list; the matches in a row; `asked`, `proposed` or `handed over`; the dates of the last matches; the date of the last hand-over or take-back. At most 30 kinds. No repository, project, code or person names and no code: repository facts belong in the project profile. A new kind is appended with `scripts/append-entry.sh kind <method.md> <row file>`, its row starting `| <id> |`: the script numbers it under a lock, so two sessions never take the same `K<n>`. To change a row, take the same lock (`mkdir <method.md>.lock`, removed afterwards), re-read the file, rewrite it whole through a temp file and a rename.

## State file

One file per change and folder, rewritten whole through a temp file and a rename, like its sidecars; one writer at a time per file. Every write goes through `${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`, which keeps the fields it is not told to change and, given the plan, runs `scripts/state-steps.sh`, the only writer of `steps`. `/my:scope` (from its first step) and `/my:run` write it; the optional status mod reads it and merges the sidecars. A run resuming after compaction reads it too.

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
- `state`: `planning` (`/my:scope` is at work; `step` is `research`, `interview`, `write`, `review` or `approval`), `ready` (the plan is approved, or a round ended and the next one can start), `running`, `needs_you` (a gate is waiting, `reason` says which), `stopped` (failed or capped, `reason` says why), `done` (the bar is met).
- `parts[].status` and `parts[].done`: derived at every write from the part's boxes in `plan.md`: `done` counts the ticked ones; `status` is `done` when all are ticked, `running` when some are or one of its steps is `running`, else `todo`. A plan without parts has one part, the plan itself.
- `startedAt`: when the work started. `plan:scope` writes it at its first step (a file that has one keeps it; a file left by a finished plan, `state: "done"`, counts as having none), carries it from the session file into the branch's file only when the branch's file has none, and nobody changes it afterwards.
- `parts[].short`: the part's title in two or three words and at most 16 characters, from its heading after "Part X:" (`Checkout flow`), in words that say what the work does, never a function, file or identifier name, even when the heading uses one (like `label` below; repository terms stay as they are elsewhere): what usually fits under a part in the band, which shows the letter alone when the title does not fit. Written by `plan:scope` step 8, and whenever the plan's parts change.
- `parts[].steps`: the part's steps in the plan's order, each `{ "label", "status" }`, `label` in two or three words that say what the step does (`Checkout test`, `Move grown frames`), never a function, file or identifier name, even when the plan's step uses one. `plan.md`'s boxes are the source of truth: every write, by `plan:scope` step 8 or `plan:run`, derives each `status` again with `scripts/state-steps.sh`, the first that holds: `failed` when it is already `failed` and its box is unticked (only `plan:run` step 6 sets it, with `--failed`, on the step of an item to blame; adding a new round's entry to `rounds` clears it); `running` while a round without `endedAt` has an item that implements or reworks it, a ticked step included; `done` when its box is ticked; else `todo`. When the plan's steps change, `steps` is rewritten from the plan and derived again.
- `parts[].left`: older files only. Kit 5.6.0 and before wrote the unticked steps here; no skill writes it now, and the status mod reads it only when `steps` is missing.
- `rounds[]`: one entry per round, written by `plan:run`: `{ "n", "startedAt" }` at the round's start (unless the round already has one: `state.sh --new-round`), `endedAt` and `verdict` at its end (`--end-round`); until `endedAt` is set the round is open. `verdict` is the review's verdict against the bar, or `failed: <reason>` when verification failed.
- `ticketFrom`: the ticket's status before `plan:scope` moved it to the start status, so a cancelled plan can move it back.
- `reason`: two or three words (`Plan approval`). The status band and line never show the work's name or the plan title; part titles and step labels, two or three words each, they may. A `name` left by an older version is ignored.
- **Progress sidecar** `<same base>.progress.json`: `{ "round": 3, "items": { "done": 4, "total": 6 }, "updatedAt": "…" }`, written only by the round's executor after each item, at the path the coordinator gives it.
- **Lane progress sidecar** `<same base>.lane-<id>.progress.json`, in the same shape, its `items` counting only the lane's: in a round with parallel lanes (`rules/parallel.md`) each lane's executor writes its own instead of the progress sidecar. The coordinator deletes it with the lane's worktree, once `verify-round.sh` passes.
- **Activity sidecar** `state/session-<session id>.activity.json`, or without a session id `<base>.activity.json`, `<base>` computed as above from the session's folder; the name is fixed once, when the mode starts, and kept for every later write of that mode: `{ "mode": "pr:review", "state": "running", "updatedAt": "…" }`, `state` being `running`, `needs_you` or `done`; written by the `pr:*` modes and `improve run`, each by the rule in its skill.

## Paths

- **Log and signals:** the log is `<data root>/suite-log.md`. Create it with a `# Suite log` heading if missing. Signals live in `<data root>/signals/`.
- **Kit source:** the git repository behind `${CLAUDE_PLUGIN_ROOT}`. Resolve it with `git -C "${CLAUDE_PLUGIN_ROOT}" rev-parse --show-toplevel`. If that fails (the plugin was installed from a marketplace cache), ask for the path of the user's clone. Never edit the cache.

## Old names

Entries and signals written before 3.0.0 name skills that are now modes, and before 5.0.0 and 8.1.0 a mode now part of another. Read them as their new names everywhere: in List and Log views, in Run selection, and in `/my:note signals`. Show only the new names, in tables and in prose alike; the old ones never reach the user, not even to explain the rename. A filter on a skill (`log plan`) matches every mode of it.

| Old         | New           |
| ----------- | ------------- |
| `scope-plan` | `plan:scope` |
| `pr-round`  | `plan:run`    |
| `plan:round` | `plan:run`   |
| `improve:digest` | `improve:note` |
| `learn`     | `pr:learn`    |
| `pr:study`  | `pr:learn`    |
| `review-lens` | `pr:review` |
| `explain-comment` | `pr:comments` |
| `merge-main` | `pr:sync`    |

## Showing entries

List and Log share one view. Each entry shows its id, skill, state, and the problem in one line, from "Why it was a problem" (or "What happened" in older entries). Its detail (what happened, why it was a problem, missing question, expected, suspected cause, where, evidence, and `File:` and `Leaves read:` when present) is shown when the user asks for it. Closed entries follow the open ones, under `Closed (<n>)`. Labels follow `rules/core.md`: states, ids and headers stay in English. An open entry from a version older than the current one (`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`) carries a short marker next to its state, in English like the states: `from <version>` (`from ~<version>` when approximate): its version is the newest of its `Kit:` line (unless `unknown`) and its `Evidence:` lines' `kit <version>`, so a note seen again after a fix counts from then; with neither, approximately, the latest release dated before its `When` (`git -C <kit source> tag --sort=creatordate --format='%(creatordate:iso) %(refname:short)'`, or without git or a kit source the CHANGELOG's release dates, a release of the same day counting as later; never ask for the clone here); none found, no marker.

## The activity file

**Activity (every mode):** write the activity sidecar at the path and in the shape of `${CLAUDE_PLUGIN_ROOT}/rules/kit-data.md` § State file: `running` as the first step and again when the user answers, `needs_you` while waiting for the user (an analysis to agree, a posting gate, a design conflict), `done` at every exit, stops included.

## Where files go

- **Per-change files** (plans, rounds, summaries, comment triage) live in the worktree's git-ignored `.plans/` folder, and disappear with the worktree.
- **Lasting personal material** lives in the data root: a root the user names, else `$MY_AGENT_KIT_HOME`, else `~/.my-agent-kit/`; never in this repository.
- **Personal material stays private.** Study pages, readings, the glossary, reviewer profiles, `method.md`, the suite log and the content of saved trials stay under the data root, never in a repository, artifact, doc or gist. They shape what the kit looks for, but nothing published (PR text, comments, replies, commits, messages) cites, quotes or names them.
- **Throwaway files** go in the session scratchpad.
- **Present a file the user must read** by opening it in the app's file pane (`show_pane`, pane `file`, absolute path). The pane opens files inside the session's working directory and added folders, not the scratchpad: such a file goes in the working directory (a git-ignored `.plans/`) or the data root, and a folder outside the working directory (the data root, a worktree entered later) is added first with `request_directory`, once per session. When the pane cannot open it (no window, a tool missing), give the absolute path as code and say why. A text the user must approve before it is published is pasted in chat, always.
- **Nothing employer-specific enters this repository.**
