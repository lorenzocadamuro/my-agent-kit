#!/usr/bin/env bash
# Two unrelated plan requests in one message, in a repository with no plan: each works in its own
# worktree, so the router starts them apart as two sessions, not one after the other here.
mkdir -p git-out kit-data
cat > git-out/git.txt <<'P'
$ git remote get-url origin
git@github.com:acme/shop.git
$ git status --short --branch
## main...origin/main
$ git worktree list
/repo  a1b2c3d [main]
P
