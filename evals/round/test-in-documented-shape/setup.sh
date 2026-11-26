#!/usr/bin/env bash
mkdir -p wt/.plans wt/ui wt/tests git-out kit-data
cat > wt/.plans/plan.md <<'P'
# One registry helper for menu entries

Size: M · Type: tool

## Goal
Every menu declares its entries through one helper, and adopters follow one guide.

## Boundary
No existing menu changes in this PR.

## Bar for done
- [ ] helper and guide, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 2 passed).

## Size budget
Budget: ~250 changed production lines, 5 files; tests apart. Split trigger: more than 250 production lines.

## Parts

### Part A: entry type
- [x] `Entry` with `id`, `label`, optional `tooltip`, `handler` in `ui/entry.py` — test first: test_entry

### Part B: helper and guide
- [ ] `define_entries(*entries)` in a new `ui/registry.py`: checks that ids are unique and labels are non-empty, and returns the entries sorted by id; reading `entry.tooltip` returns None when it is not set — test first: test_define_entries
- [ ] the adopter guide `docs/registry.md`: each feature declares its entry in its own module, `features/<name>_entry.py`, as `ENTRY = Entry(...)`, and `features/__init__.py` imports those modules and passes their `ENTRY` to `define_entries` — check only
P
cat > wt/ui/entry.py <<'P'
from dataclasses import dataclass
from typing import Callable, Optional


@dataclass
class Entry:
    id: str
    label: str
    handler: Callable[[], None]
    tooltip: Optional[str] = None
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: entry type
Comments read until: none
## Items
### 1. Entry type
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict against the bar: Part A meets it.
## Block
- none
P
cat > git-out/git.txt <<'GITOUT'
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
$ scripts/drift.sh --lines 300 --files 6
size: 2 files, +60 -0 (60 lines) since merge-base 9f8e7d6c5b4
production: 1 files, +30 -0 (30 lines), budget 300 lines, 6 files: within budget
tests: 1 files, +30 -0 (30 lines), outside the budget
commits: 1 ahead, 0 behind origin/main
merge preview: clean
GITOUT
