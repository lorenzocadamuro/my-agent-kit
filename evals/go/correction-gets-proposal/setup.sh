#!/usr/bin/env bash
# A plain correction reaches the router: the kit proposes a note and saves it only on a yes.
# The data root holds an empty suite log, so a saved note shows as a new entry.
mkdir -p git-out kit-data
: > kit-data/suite-log.md
cat > git-out/git.txt <<'P'
$ git remote get-url origin
git@github.com:acme/shop.git
$ git status --short --branch
## feature...origin/feature
P
