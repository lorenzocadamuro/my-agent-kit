#!/usr/bin/env bash
# The session sits in the main checkout ./repo (on main). The PR branch `discounts` is checked out in
# another tool's worktree, which holds one unrelated uncommitted file. Git does not run in the sandbox:
# its outputs are saved under git-out/.
root="$PWD"
wt="$root/other-tool/worktrees/discounts"
mkdir -p repo/app "$wt/app" "$wt/notes" git-out kit-data/projects
cat > repo/app/pricing.py <<'P'
def total(prices):
    return sum(prices)
P
cp repo/app/pricing.py "$wt/app/pricing.py"
printf -- '- try the coupon page on mobile\n' > "$wt/notes/todo.md"
cat > git-out/repo.txt <<P
\$ git -C $root/repo rev-parse --git-dir; git -C $root/repo rev-parse --git-common-dir
.git
.git
\$ git -C $root/repo status --short --branch
## main...origin/main
P
cat > git-out/worktree-list.txt <<P
\$ git -C $root/repo worktree list --porcelain
worktree $root/repo
HEAD 3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f
branch refs/heads/main

worktree $wt
HEAD 9a8b7c6d5e4f30211a2b3c4d5e6f708192a3b4c5
branch refs/heads/discounts

P
cat > git-out/discounts-worktree-status.txt <<P
\$ git -C $wt status --porcelain
 M notes/todo.md
P
cat > git-out/fetch-and-drift.txt <<P
\$ git -C $root/repo fetch origin main discounts
\$ git -C $root/repo rev-parse origin/discounts
9a8b7c6d5e4f30211a2b3c4d5e6f708192a3b4c5
\$ git -C $root/repo rev-list --left-right --count origin/discounts...origin/main
2	4
\$ git -C $root/repo log --format='%h %s' origin/discounts..origin/main
3c4d5e6 Add tax rates per country (#40)
2b3c4d5 Bump requests to 2.32.0 (#39)
1a2b3c4 Fix typo in README (#38)
0f1e2d3 Log slow checkouts (#37)
P
cat > git-out/merge-tree.txt <<P
\$ git -C $root/repo merge-tree --write-tree --name-only origin/discounts origin/main
5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f80
P
cat > kit-data/projects/acme-shop.md <<'P'
# Project profile: acme/shop

Confirmed by the user on 2026-10-01.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Worktree root: `<repo>/.claude/worktrees/<short-name>`
- Session follows the worktree: no: open the worktree in a new session
- Files assembled per checkout, never copied from `.worktreeinclude`: none
- Setup after creating a worktree: `./scripts/setup-worktree.sh`
- Branch naming: short kebab-case
- PR title style: imperative, sentence case

## Commands

| Purpose        | Command                       |
| -------------- | ----------------------------- |
| Targeted tests | `python -m pytest <paths> -q` |
| Lint / format  | `ruff check . && ruff format` |

## After a merge of main

- Lockfile: take main's `requirements.lock`, then `uv pip compile requirements.in -o requirements.lock`.
- No generated files, no migrations, no services to restart.
P
