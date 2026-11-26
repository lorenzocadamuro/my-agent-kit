---
name: profile
description: "Build the project profile of a repository, from its agent instructions, guides, CI workflows and skills, and ask the user to confirm it."
disable-model-invocation: true
when: "\"/my:profile\", or `/my:scope` when `<data root>/projects/<owner>-<repo>.md` does not exist"
reads: [rules/core.md, rules/plan-contract.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/files.md]
---

# Building a project profile

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md` and `${CLAUDE_PLUGIN_ROOT}/rules/files.md`.

Used by `/my:plan:scope` when `<data root>/projects/<owner>-<repo>.md` does not exist. The result follows `${CLAUDE_PLUGIN_ROOT}/skills/plan/profile/profile-template.md`. The profile holds employer-specific facts and therefore never enters the kit repository.

## Sources, in order

1. **Agent instructions:** `CLAUDE.md`, `.claude/CLAUDE.md`, `AGENTS.md`, plus nested ones in the top-level service folders. Extract the git rules (where new branches start, merge or rebase policy, PR title style), worktree rules, comment and style rules, and lockfile and codegen rules.
2. **The guide index**, if the instructions link one (a `guidance/README.md`, a routing table, module charters). Map path globs to guides for the "Rules to load" table.
3. **Repository skills and commands** (`.claude/skills/*/SKILL.md`, `.claude/commands/*.md`): read only the descriptions. Find the tools for deep review, PR descriptions, comment resolution, local stack and migrations, and use their exact invocation.
4. **CI workflows** (`.github/workflows/*.y*ml`): the test, lint and codegen-check commands CI runs. These are the commands that matter.
5. **Package manifests** (`package.json` scripts, `pyproject.toml`, `Makefile`): targeted test commands per area.
6. **Merge requirements:** `gh api repos/<o>/<r>/rules/branches/<default>` and `CODEOWNERS`.

## Rules

- **Prefer commands the repository already documents** over ones you assemble yourself.
- **Mark every guess** with "(unconfirmed)". The user confirms or corrects these.
- **Keep it short:** one line per command or rule, and links instead of copies.
- **Ask the user only** what the sources cannot answer: how they work in this repository (parallel tasks in worktrees, or one at a time on `main`, and which files `.worktreeinclude` lists that are assembled per checkout rather than copied), how their local stack runs (variant, and the commands to move it to a worktree and back), the ticket tracker and its start status, and which slow suites to avoid locally.
