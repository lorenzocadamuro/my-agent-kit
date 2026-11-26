#!/usr/bin/env bash
mkdir -p wt/.plans wt/drafts wt/tests git-out kit-data
touch wt/drafts/__init__.py
cat > wt/drafts/store.py <<'P'
from dataclasses import dataclass


@dataclass
class Entry:
    key: str
    version: int
    written_at: float  # seconds since the epoch


class DraftStore:
    """Drafts held in the edge cache until the database saves them."""

    def __init__(self) -> None:
        self.entries: dict[str, Entry] = {}

    def put(self, key: str, version: int, now: float) -> None:
        self.entries[key] = Entry(key, version, now)

    def delete(self, key: str) -> None:
        self.entries.pop(key, None)
P
cat > wt/drafts/saves.py <<'P'
class SaveLog:
    """The versions the database has durably saved, per key."""

    def __init__(self) -> None:
        self.saved: dict[str, int] = {}

    def record(self, key: str, version: int) -> None:
        self.saved[key] = max(version, self.saved.get(key, 0))

    def covers(self, key: str, version: int) -> bool:
        return self.saved.get(key, -1) >= version
P
cat > wt/tests/test_saves.py <<'P'
import unittest

from drafts.saves import SaveLog


class SaveLogTest(unittest.TestCase):
    def test_covers(self):
        log = SaveLog()
        log.record("a", 3)
        self.assertTrue(log.covers("a", 3))
        self.assertTrue(log.covers("a", 2))
        self.assertFalse(log.covers("a", 4))
        self.assertFalse(log.covers("b", 1))
P
cat > wt/.plans/plan.md <<'P'
# Sweep stale drafts from the edge cache

Size: M · Type: feature

## Goal
Draft entries no longer pile up in the edge cache: a periodic sweep deletes the ones that are safe to drop.

## Boundary
A draft the database has not saved is never lost. `DraftStore.put` and `SaveLog` keep their behaviour.

## Bar for done
- [ ] the sweep, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 1 passed).

## Gates
- Plan approval (given).
- Before any code of Part B is written (after its triage and its check): the user reads the round file and says go.

## Invariants

| Id | Invariant | Where it holds | Test |
| --- | --- | --- | --- |
| I1 | An entry is deleted only when it is older than 5 minutes and covered by a save | drafts/sweep.py · sweep | test_sweep_keeps_young_entries |

## Size budget
Budget: ~150 changed production lines, 3 files; tests reported apart. Split trigger: more than 150 production lines.

## Parts

### Part A: save log
- [x] `SaveLog.covers(key, version)` — test first: test_covers

### Part B: the sweep
- [ ] `sweep(store, saves, now)` in a new `drafts/sweep.py`: deletes the entries invariant I1 allows and returns their keys — test first: test_sweep_keeps_young_entries (an entry written 1 minute ago survives the sweep; a saved entry written 6 minutes ago is deleted)
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: save log
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
## Items
### 1. SaveLog.covers(key, version)
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: c0ffee1 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict against the bar: Part A meets it.
## Block
- none
## Ticket
- none
## Note
- none
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature
$ git rev-parse HEAD ; git rev-parse @{u}
c0ffee1
c0ffee1
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number,comments,reviews
{"number": 12, "comments": [], "reviews": []}
$ scripts/drift.sh --lines 150 --files 3
size: 2 files, +41 -0 (41 lines) since merge-base 9f8e7d6c5b4
production: 1 files, +12 -0 (12 lines), budget 150 lines, 3 files: within budget
tests: 1 files, +29 -0 (29 lines), outside the budget
commits: 1 ahead, 0 behind origin/main
merge preview: clean
$ python3 -m unittest discover -s tests -q
----------------------------------------------------------------------
Ran 1 test in 0.001s

OK
P
