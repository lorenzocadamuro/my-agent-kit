# Project profile: <owner/name>

Confirmed by the user on <date>. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Worktree root: <path pattern, e.g. ~/worktrees/<repo>/<branch>>
- Setup after creating a worktree: `<command>`
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

## Tickets

- Tracker: <Linear | GitHub issues | none> · Team: <name>
- Status on start: <e.g. In Progress> · Branch name source: <field>

## Known pitfalls

- <short line each, with how to avoid it>
