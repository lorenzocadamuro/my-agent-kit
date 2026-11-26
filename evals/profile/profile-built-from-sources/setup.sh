#!/usr/bin/env bash
# A small repository whose facts sit in its sources: the branch rule in CLAUDE.md, the test command in
# CI (not the package script), the deep review tool in a repository command, and a service's own
# instructions in a nested CLAUDE.md.
mkdir -p repo/.github/workflows repo/.claude/commands repo/services/api git-out kit-data/projects
cat > repo/CLAUDE.md <<'P'
# Shop

- New branches start from `origin/develop`, never from `main`.
- Merge `develop` into your branch; never rebase a pushed branch.
- PR titles: `[area] what changes`.
P
cat > repo/services/api/CLAUDE.md <<'P'
# API service

- Every change to `services/api/**` regenerates the client with `pnpm --filter api codegen` before commit.
P
cat > repo/.github/workflows/ci.yml <<'P'
name: ci
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm test:ci --runInBand
P
cat > repo/package.json <<'P'
{ "name": "shop", "scripts": { "test": "jest --watch", "test:ci": "jest --ci", "lint": "eslint ." } }
P
cat > repo/.claude/commands/deep-review.md <<'P'
---
description: Deep review of the current branch against develop, by several fresh agents. Invoke as /deep-review.
---
Run the deep review.
P
cat > git-out/git.txt <<'P'
$ git -C repo remote get-url origin
git@github.com:acme/shop.git
$ git -C repo symbolic-ref refs/remotes/origin/HEAD
refs/remotes/origin/develop
$ gh api repos/acme/shop/rules/branches/develop
[]
P
