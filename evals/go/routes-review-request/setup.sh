#!/usr/bin/env bash
# A branch with an open PR: a plain "review this PR" must reach the review skill through the router.
mkdir -p git-out kit-data
cat > git-out/git.txt <<'P'
$ git remote get-url origin
git@github.com:acme/shop.git
$ git status --short --branch
## feature...origin/feature
$ gh pr view --json number,title,author,headRefOid,baseRefName
{"number":456,"title":"Reject negative discounts","author":{"login":"sam"},"headRefOid":"e5f6a7b","baseRefName":"main"}
P
