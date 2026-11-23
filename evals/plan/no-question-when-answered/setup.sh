#!/usr/bin/env bash
# An M change whose ticket states the goal, boundary, bar, size budget, invariants, out of scope and gates in the
# user's words, and whose code (the Markdown export and the store beside it) answers the rest: the record's fields, the encoding,
# an existing output file, how errors exit, a bad note name, a missing folder. No topic is left with two viable options, so the interview asks nothing,
# and the plan still writes the four fixed things and the summary names them.
mkdir -p notes tests kit-data/projects
touch notes/__init__.py
cat > kit-data/projects/me-notes.md <<'P'
# Project profile: me/notes

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Commands

| Purpose        | Command                                    |
| -------------- | ------------------------------------------ |
| Targeted tests | `python3 -m unittest discover -s tests -q` |
| Deep review    | none                                       |

## Tickets

- Tracker: none
P
cat > ticket.md <<'P'
# Notes CLI: JSON export and import

Goal: I move my notes between my two laptops. `notes export --json <file>` writes every note to one JSON file, and
`notes import <file>` reads that file back on the other laptop.

Boundary: `add`, `list`, `edit`, `delete` and `export --md` behave exactly as today, and the notes folder keeps its
layout (one file per note, named by its creation time).

Bar for done: a round-trip test (export, import into an empty folder, then the same titles, texts and creation
times) passes, and the existing tests stay green: `python3 -m unittest discover -s tests -q`, every round. Nothing
to check after the merge: it is a local tool.

Invariants: an import never overwrites a note that already exists (same creation time): it skips it and prints how
many it skipped. Creation times survive the round trip.

The JSON file is a plain list of the same records the Markdown export writes (`record()` in notes/export_md.py), no
version field. Export to a file that exists works like `export --md`.

Size: about 350 production lines across notes/cli.py, notes/store.py and a new notes/export_json.py; tests apart.
Over 500 production lines, stop and we split.

Out of scope: sync to a cloud folder, encryption, other formats (CSV, SQLite).

Gates: only the plan approval. Nothing is published: no PR, no messages.
P
cat > notes/store.py <<'P'
import os
import re
import subprocess
import time
from dataclasses import dataclass


@dataclass
class Note:
    name: str
    created: float
    text: str


NAME = re.compile(r"^\d+\.md$")


class Store:
    """One file per note under the folder; the file name is the creation time in nanoseconds."""

    def __init__(self, folder: str):
        self.folder = os.path.expanduser(folder)
        os.makedirs(self.folder, exist_ok=True)

    def all(self) -> list[Note]:
        notes = []
        for name in sorted(os.listdir(self.folder)):
            if not NAME.match(name):
                continue  # other files (.DS_Store, editor backups) are not notes
            with open(os.path.join(self.folder, name), encoding="utf-8") as f:
                notes.append(Note(name, int(name.split(".")[0]) / 1e9, f.read()))
        return notes

    def add(self, text: str) -> None:
        self.write(f"{time.time_ns()}.md", text)

    def write(self, name: str, text: str) -> None:
        """Write one note file. A name that is not `<digits>.md` is an error, so nothing lands outside the folder."""
        if not NAME.match(name):
            raise ValueError(f"not a note name: {name!r}")
        with open(os.path.join(self.folder, name), "w", encoding="utf-8") as f:
            f.write(text)

    def delete(self, name: str) -> None:
        os.remove(os.path.join(self.folder, name))

    def edit(self, name: str, editor: str) -> None:
        if subprocess.call([editor, os.path.join(self.folder, name)]) != 0:
            raise RuntimeError(f"{editor} failed")
P
cat > notes/export_md.py <<'P'
import os

from notes.store import Note, Store


def record(note: Note) -> dict:
    """The fields every export writes, in this order."""
    return {"name": note.name, "created": note.created, "title": note.text.splitlines()[0] if note.text else "", "text": note.text}


def export_md(store: Store, out: str, force: bool = False) -> int:
    """Write every note to one Markdown file. An existing file is an error unless force is set."""
    if os.path.exists(out) and not force:
        raise FileExistsError(f"{out} exists; use --force to overwrite")
    with open(out, "w", encoding="utf-8") as f:
        for note in store.all():
            r = record(note)
            f.write(f"## {r['title']}\n\n<!-- {r['name']} {r['created']} -->\n\n{r['text']}\n\n")
    return len(store.all())
P
cat > notes/cli.py <<'P'
import sys

from notes.export_md import export_md
from notes.store import Store

COMMANDS = ["add", "list", "edit", "delete", "export"]
EDITOR = "vi"


def main(argv: list[str], folder: str = "~/.notes") -> int:
    if not argv or argv[0] not in COMMANDS:
        print("unknown command", file=sys.stderr)
        return 1
    store = Store(folder)
    try:
        if argv[0] == "list":
            for note in store.all():
                print(note.text.splitlines()[0] if note.text else note.name)
        elif argv[0] == "delete":
            store.delete(argv[1])
        elif argv[0] == "add":
            store.add(" ".join(argv[1:]))
        elif argv[0] == "edit":
            store.edit(argv[1], editor=EDITOR)
        elif argv[0] == "export" and argv[1] == "--md":
            count = export_md(store, argv[2], force="--force" in argv)
            print(f"exported {count} notes")
    except Exception as exc:  # every failure exits with 1
        print(f"error: {exc}", file=sys.stderr)
        return 1
    return 0
P
cat > tests/test_export_md.py <<'P'
import os
import tempfile
import unittest

from notes.cli import main


class ExportMdTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.mkdtemp()
        with open(os.path.join(self.folder, "1700000000000000000.md"), "w", encoding="utf-8") as f:
            f.write("Groceries\nmilk")

    def test_export_writes_every_note(self):
        out = os.path.join(tempfile.mkdtemp(), "notes.md")
        self.assertEqual(main(["export", "--md", out], folder=self.folder), 0)
        with open(out, encoding="utf-8") as f:
            self.assertIn("## Groceries", f.read())

    def test_existing_file_needs_force(self):
        out = os.path.join(tempfile.mkdtemp(), "notes.md")
        open(out, "w").close()
        self.assertEqual(main(["export", "--md", out], folder=self.folder), 1)
        self.assertEqual(main(["export", "--md", out, "--force"], folder=self.folder), 0)
P
