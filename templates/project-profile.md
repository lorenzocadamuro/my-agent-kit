# Project profile: <owner/name>

Confirmed by the user on <date>. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Worktree root: <path pattern; prefer the editor's own worktree folder, e.g. <repo>/.claude/worktrees/<short-name> | none: work on `main` (one task at a time)>
- Session follows the worktree: <yes: move the session in (principles: entering a worktree) | no: open the worktree in a new session>
- Files assembled per checkout, never copied from `.worktreeinclude`: <paths | none>
- Setup after creating a worktree: `<command>`
- Test paths for the size budget (optional): <pathspecs, each single-quoted, passed as `drift.sh --tests`; default: test folders and test file names>
- Branch naming: <rule, e.g. "Linear gitBranchName when a ticket exists">
- PR title style: <rule>

## Rules to load

Agent instructions and guides that every executor and reviewer must read, by area:

| Area (path glob) | Guide       |
| ---------------- | ----------- |
| `**`             | `CLAUDE.md` |

Routing index for module rules, if any: <path>

## Commands

| Purpose                                 | Command |
| --------------------------------------- | ------- |
| Targeted tests                          |         |
| Full test suite (avoid locally if slow) |         |
| Lint / format                           |         |
| Codegen (pinned tools)                  |         |
| Migration checks                        |         |
| Deep review                             |         |
| PR description                          |         |
| Comment resolver                        |         |

## After a merge of main

- <generated files to regenerate>
- <lockfile policy>
- <migration re-parenting and local DB check>
- <services to restart>

## Manual testing

- Where the local stack runs, and whether to move it to the change's worktree for browser checks (a gate): <rule>
- Local stack variant: <e.g. native or compose> · Move to a worktree: `<command>` · Move back: `<command>`

## Tickets

- Tracker: <Linear | GitHub issues | none> · Team: <name>
- Status on start: <e.g. In Progress> · Branch name source: <field>

## Known pitfalls

- <short line each, with how to avoid it>
