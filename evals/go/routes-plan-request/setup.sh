#!/usr/bin/env bash
# A repository with no plan yet: a plain "plan <ticket>" must reach the scope skill through the router.
mkdir -p git-out kit-data
cat > git-out/git.txt <<'P'
$ git remote get-url origin
git@github.com:acme/shop.git
$ git status --short --branch
## main...origin/main
$ git worktree list
/repo  a1b2c3d [main]
P
