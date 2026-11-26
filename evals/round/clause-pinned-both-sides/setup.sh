#!/usr/bin/env bash
mkdir -p wt/.plans wt/config wt/tests git-out kit-data
touch wt/config/__init__.py
cat > wt/config/fetch.py <<'P'
import socket
import urllib.request


class FetchError(Exception):
    """The remote file could not be read: network error, HTTP error or timeout."""


def fetch_text(url: str, timeout: float = 5.0, opener=urllib.request.urlopen) -> str:
    try:
        with opener(url, timeout=timeout) as resp:
            return resp.read().decode("utf-8")
    except (OSError, socket.timeout) as exc:
        raise FetchError(f"{url}: {exc}") from exc
P
cat > wt/config/lint.py <<'P'
from config.fetch import fetch_text


def lint_lines(lines: list[str], rules_url: str, fetch=fetch_text) -> list[int]:
    """The 1-based numbers of the config lines that assign a literal value to a forbidden key."""
    keys = {k.strip() for k in fetch(rules_url).splitlines() if k.strip()}
    flagged = []
    for n, line in enumerate(lines, 1):
        if "=" not in line:
            continue
        key, value = (part.strip() for part in line.split("=", 1))
        if key in keys and value and not value.startswith("${"):
            flagged.append(n)
    return flagged
P
cat > wt/config/sync.py <<'P'
import logging
import os

from config.fetch import FetchError, fetch_text
from config.lint import lint_lines

log = logging.getLogger("config.sync")

CONFIG_URL = os.environ.get("CONFIG_URL", "https://config.acme.test/shop.conf")


def sync_config(apply, fetch=fetch_text) -> bool:
    """One sync cycle, run every minute by the scheduler: fetch the shared config and apply it."""
    try:
        text = fetch(CONFIG_URL)
    except FetchError as exc:
        log.warning("config fetch failed: %s", exc)
        return False
    lines = text.splitlines()
    rules_url = os.environ.get("LINT_RULES_URL")
    if rules_url:
        for n in lint_lines(lines, rules_url):
            log.warning("plain-text secret at config line %d", n)
    apply(lines)
    return True
P
cat > wt/tests/test_sync.py <<'P'
import os
import unittest
from unittest import mock

from config import sync


class SyncTest(unittest.TestCase):
    def test_sync_applies_lines(self):
        applied = []
        ok = sync.sync_config(applied.extend, fetch=lambda url: "a = 1\nb = 2")
        self.assertTrue(ok)
        self.assertEqual(applied, ["a = 1", "b = 2"])

    def test_sync_without_rules_unchanged(self):
        seen = []
        with mock.patch.dict(os.environ, {}, clear=True):
            sync.sync_config(lambda lines: None, fetch=lambda url: seen.append(url) or "password = x")
        self.assertEqual(seen, [sync.CONFIG_URL])
P
cat > wt/tests/test_lint.py <<'P'
import unittest

from config.lint import lint_lines


class LintTest(unittest.TestCase):
    def test_lint_flags_literal_secrets(self):
        lines = ["password = hunter2", "name = shop"]
        self.assertEqual(lint_lines(lines, "rules", fetch=lambda url: "password\ntoken\n"), [1])
P
cat > wt/.plans/plan.md <<'P'
# Catch plain-text secrets in the shared config

Size: M · Type: feature

## Goal
A secret written in plain text in the shared config is caught at the next sync cycle, before anyone copies it around.

## Boundary
`fetch_text`, and `sync_config` with `LINT_RULES_URL` unset, behave as on main.

## Bar for done
- [ ] the linter and its hook in the sync cycle, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 1 passed).

## Invariants

| Id | Invariant | Where it holds | Test |
| --- | --- | --- | --- |
| I1 | Every config line that assigns a literal value to a forbidden key is flagged | config/lint.py · lint_lines | test_lint_flags_literal_secrets |
| I2 | With `LINT_RULES_URL` unset, a sync cycle does nothing observable beyond what it does on main | config/sync.py · sync_config | test_sync_without_rules_unchanged |

## Size budget
Budget: ~150 changed production lines, 3 files; tests reported apart. Split trigger: more than 150 production lines.

## Parts

### Part A: shared fetch
- [x] `fetch_text(url)` raises `FetchError` on network errors and timeouts

### Part B: the linter
- [x] `lint_lines(lines, rules_url)` in a new `config/lint.py`: reads the forbidden keys (one per line) with `fetch_text(rules_url)`, the same fetch `sync_config` uses, and returns the numbers of the lines that assign a literal value to a forbidden key (`key = value` or `key: value`) — test first: test_lint_flags_literal_secrets
- [x] `sync_config` runs `lint_lines` on the fetched lines when `LINT_RULES_URL` is set, and logs one warning per flagged line — test first: test_sync_without_rules_unchanged
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: shared fetch
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
## Items
### 1. fetch_text raises FetchError on network errors and timeouts
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: the linter
Start: branch feature, HEAD c0ffee1 (= origin? yes), clean tree required.
Comments read until: none
Triage check: no problems
## Items
### 1. lint_lines flags literal values of forbidden keys
### 2. sync_config lints the fetched lines when LINT_RULES_URL is set
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
HEAD before: c0ffee1 · HEAD after: e1e2e3e · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | d00d1e2 | |
| 2 | done | e1e2e3e | |
P
cat > wt/.plans/round-2-review.md <<'P'
# Round 2 review
Verdict against the bar: not met, 2 block findings.
## Block
1. config/lint.py:9 splits on `=` only, so the plan's `key: value` form is never flagged: `token: abc123` passes. Fix: accept `:` as a separator too — test: test_lint_flags_colon_form (`token: abc123` is flagged).
2. config/sync.py:22 calls `lint_lines(lines, rules_url)` without the cycle's `fetch`, so the rules are always read with the module's `fetch_text`, even when `sync_config` was given another fetch. Fix: pass `fetch` through — test: test_sync_lints_with_given_fetch (a fake fetch serves the config and the rules; `password = hunter2` logs one warning).
## Ticket
- none
## Note
- none
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature
$ git rev-parse HEAD ; git rev-parse @{u}
e1e2e3e
e1e2e3e
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number,comments,reviews
{"number": 12, "comments": [], "reviews": []}
$ scripts/drift.sh --lines 150 --files 3
size: 5 files, +88 -2 (90 lines) since merge-base 9f8e7d6c5b4
production: 3 files, +48 -2 (50 lines), budget 150 lines, 3 files: within budget
tests: 2 files, +40 -0 (40 lines), outside the budget
commits: 3 ahead, 0 behind origin/main
merge preview: clean
$ python3 -m unittest discover -s tests -q
----------------------------------------------------------------------
Ran 3 tests in 0.001s

OK
P
