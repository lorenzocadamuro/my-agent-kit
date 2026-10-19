#!/usr/bin/env bash
mkdir -p kit-data/signals
cat > kit-data/suite-log.md <<'P'
# Suite log

## 20260105-01 · principles · open

- When: 2026-01-05 10:00
- Where: acme/web · feature-y · session unknown
- What happened: A decision option described a consequence the agent had inferred, not read in the code; the user chose it and had to reverse it later.
- Expected: Every consequence stated in an option is verified in the code, or marked unverified.
- Suspected cause: question-format "Shape" does not ask to verify stated effects.
- Signal: decision reversed
P
cat > kit-data/signals/acme-web-feature-z.md <<'P'
# Signals: acme/web · feature-z

- 2026-01-10 09:10 · free answer · scope-plan · The user answered "Other": did not understand what "bar for done" means, and asked for an explanation. · question D3
- 2026-01-10 09:40 · question dismissed · pr-round · The user dismissed a batch that used "drift budget" without saying what it is. · round 1 gate
- 2026-01-10 11:00 · reviewer correction · pr-round · A reviewer noted that the plan's bar requires `scripts/e2e.sh` to pass, but it already fails on main (no browser installed). · review comment on the PR
- 2026-01-10 11:30 · rework · pr-round · Round 2 stopped: its stop condition "lint passes" could never hold, lint already fails on main. · round 2 summary
- 2026-01-10 12:00 · reviewer correction · pr-round · A bot found that an option said "the retry keeps the old size"; that was inferred, not read in the code, and the decision was reversed. · bot comment on the PR
- 2026-01-10 13:00 · free answer · pr-round · The user answered "Other": put the new export behind a feature flag. · round 3 question
- 2026-01-10 15:00 · free answer · pr-round · The user withdrew the earlier instruction: no feature flag, the export is an internal tool. · round 3 follow-up
P
