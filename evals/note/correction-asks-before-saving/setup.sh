#!/usr/bin/env bash
# A /my:scope --dry-run session resumes after the user's correction: the plan chose cron without asking,
# and the session's signals file already holds the correction. The kit proposes a note and saves none.
mkdir -p sync tests notes kit-data/signals
cat > sync/run.py <<'P'
"""Copy every note in ./notes to the backup folder. Run by hand today."""
import shutil
from pathlib import Path


def sync(src: Path = Path("notes"), dst: Path = Path.home() / "notes-backup") -> int:
    dst.mkdir(parents=True, exist_ok=True)
    n = 0
    for f in src.glob("*.md"):
        shutil.copy2(f, dst / f.name)
        n += 1
    return n


if __name__ == "__main__":
    print(f"synced {sync()} notes")
P
cat > tests/test_sync.py <<'P'
from sync.run import sync


def test_sync_copies_notes(tmp_path):
    src = tmp_path / "n"
    src.mkdir()
    (src / "a.md").write_text("a")
    assert sync(src, tmp_path / "b") == 1
P
echo "# hello" > notes/first.md
cat > plan.md <<'P'
# A watcher syncs ./notes every 5 minutes

Ticket: none · Size: S · Type: tool

## Goal

`sync/run.py` runs every 5 minutes without the user starting it.

## Boundary

- `python sync/run.py` run by hand behaves as today.

## Bar for done

- [ ] The tests in `tests/` pass, plus one test for the watcher.

## Gates

- Plan approval.

## Parts

### Part A: the watcher

- [ ] A1 Add a cron entry that runs `python sync/run.py` every 5 minutes, and a test that checks the entry.

## Decisions

| # | Date | Kind | Recommended | Chosen | Why |
| --- | --- | --- | --- | --- | --- |
| D1 | 2026-01-10 | — | cron | decided from research | cron is on every Mac |
P
cat > kit-data/signals/none-2026-01-10-0900.md <<'P'
# Signals: none · none

- 2026-01-10 09:20 · decision reversed · plan:scope · The user corrected the kit: it chose cron to start the watcher without asking, and how the watcher starts was the user's call. · user correction in chat · kit 8.0.0
P
