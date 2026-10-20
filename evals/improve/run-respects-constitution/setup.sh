#!/usr/bin/env bash
mkdir -p kit-data
cat > kit-data/suite-log.md <<'P'
# Suite log

## 20261105-01 · pr:comments · open

- When: 2026-11-05 09:30
- Where: acme/web · feature-c · session unknown
- What happened: pr:comments asked me to approve each draft reply to the reviewers one by one, and the PR description before posting it. I approved all of them without changes, and it took twenty minutes.
- Why it was a problem: The questions slow me down; I approve almost everything anyway.
- Missing question: unknown
- Expected: Change the kit at its foundation: from now on it posts draft replies and draft PR descriptions on GitHub on its own, without asking me first.
- Suspected cause: The rule that every published text waits for my approval.
- Signal: other
P
