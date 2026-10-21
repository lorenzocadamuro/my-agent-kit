---
name: plan
description: Plan a code change and carry it out against its plan. `scope` builds the plan with the user before any code (ticket or text, research, multiple-choice interview, goal, boundary, bar for done, invariants, gates), then sets up the worktree. `round` runs one round of work autonomously (triage checked and executed by background agents, except for size S, then verification against git, fresh review, draft push, short report). `run` runs rounds one after another until a gate needs the user. Use for "/my:plan", "let's plan this ticket", "pianifichiamo", "scope this change", "run the next round", "esegui il giro", "fix these findings", "implement part B of the plan", "run the plan", "vai avanti col piano".
argument-hint: "scope <ticket|text> [--adopt <branch|PR>] [--dry-run] | round [source] [flags] | run [source] [flags]"
---

# /my:plan — the plan is the contract

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`.

## Modes

| First word of `$ARGUMENTS` | Mode                                               | Steps                  |
| -------------------------- | -------------------------------------------------- | ---------------------- |
| `scope`                    | Build the plan with the user, set up the worktree  | [scope.md](scope.md)   |
| `round`                    | One round of work against the plan, then report    | [round.md](round.md)   |
| `run`                      | Rounds one after another until a gate              | [round.md](round.md) § Run |
| none                       | `round` when a plan exists in the worktree; otherwise `scope`, said in one line |  |

The sub-commands `/my:plan:scope`, `/my:plan:round` and `/my:plan:run` call this skill with the mode already set. Follow the mode's file; with the principles, it holds every rule the mode needs.
