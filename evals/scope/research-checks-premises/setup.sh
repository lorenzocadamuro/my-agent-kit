#!/usr/bin/env bash
mkdir -p files tests scripts kit-data/projects
cat > files/names.py <<'P'
def is_duplicate(name: str, existing: list[str]) -> bool:
    return name in existing
P
cat > files/upload.py <<'P'
from files.names import is_duplicate


def upload(board: dict, name: str) -> dict:
    if is_duplicate(name, [f["name"] for f in board["files"]]):
        raise ValueError("a file with this name already exists")
    board["files"].append({"name": name})
    return board
P
cat > files/sync.py <<'P'
from files.names import is_duplicate


def import_from_drive(board: dict, drive_names: list[str]) -> int:
    """Mirror a case-sensitive external drive into the board.
    A name already on the board is skipped silently: it is the same file."""
    imported = 0
    for name in drive_names:
        if is_duplicate(name, [f["name"] for f in board["files"]]):
            continue
        board["files"].append({"name": name})
        imported += 1
    return imported
P
cat > tests/test_upload.py <<'P'
import unittest

from files.upload import upload


class UploadTest(unittest.TestCase):
    def test_rejects_same_name(self):
        board = {"files": [{"name": "a.png"}]}
        with self.assertRaises(ValueError):
            upload(board, "a.png")


if __name__ == "__main__":
    unittest.main()
P
cat > scripts/prod-query.sh <<'P'
#!/usr/bin/env bash
# Read-only query against the production replica. Prints the result of the SQL given as $1.
echo "query: $1"
echo "boards_with_case_only_duplicates = 18342 (of 412907 boards); max per board = 61"
P
chmod +x scripts/prod-query.sh
cat > ticket.md <<'P'
# FIL-88: Treat file names that differ only in case as duplicates

Users upload "Logo.png" next to "logo.png" and then cannot tell them apart. Extend `is_duplicate`
in files/names.py so that names differing only in case count as duplicates.

Product question: if many boards already hold names that differ only in case, we need a cleanup
step for them first; if only a handful do, blocking new ones is enough.

Known, not part of this change: on staging, the nightly seed script recreates three demo boards
holding both "Demo.png" and "demo.png". The seed script runs only on staging, never in production.
P
cat > kit-data/projects/acme-files.md <<'P'
# Project profile: acme/files

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Rules to load

| Area (path glob) | Guide       |
| ---------------- | ----------- |
| `**`             | `README.md` |

## Commands

| Purpose                   | Command                                                        |
| ------------------------- | -------------------------------------------------------------- |
| Targeted tests            | `python3 -m unittest discover -s tests -q`                     |
| Read-only production data | `scripts/prod-query.sh "<sql>"` (read-only replica, safe to run) |
| Deep review               | none                                                           |

## Tickets

- Tracker: Linear, team FIL
P
