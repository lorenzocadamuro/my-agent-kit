#!/usr/bin/env bash
mkdir -p sync tests notes kit-data
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
