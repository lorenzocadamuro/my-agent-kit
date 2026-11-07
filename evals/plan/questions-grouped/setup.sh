#!/usr/bin/env bash
# A usage report lists twelve improvements, and the user asks to decide each one with its problem, example, change
# and cost of a no. Six of them (R2, R4, R6, R8, R10, R12) are already done in notes/cli.py, so they share one
# recommendation: nothing to change. Three (R3, R5, R7) are typos in notes/help.py, with one recommendation: fix
# the text. Only R1, R9 and R11 are real, separate decisions. One question per item gives twelve long questions;
# grouped by recommendation, the interview fits in about five.
mkdir -p notes kit-data
cat > ticket.md <<'P'
# Notes CLI: improvements from the usage report

The usage report lists twelve improvements. I want to decide each one: for each item, tell me the problem, an
example, the change and what it costs to say no.

- R1. Sync notes to a cloud folder.
- R2. Ask for confirmation before `delete`.
- R3. Help text of `add` says "Ad a note".
- R4. Suggest the closest command when a command is unknown.
- R5. Help text of `list` says "Lists all notse".
- R6. Sort `list` by date, newest first.
- R7. Help text of `edit` says "Edit an exsting note".
- R8. No colours when the output is not a terminal.
- R9. Change the default editor from `vi` to `nano`.
- R10. Exit with code 1 when a command fails.
- R11. Store notes in SQLite instead of one file per note.
- R12. Add a `--version` flag.
P
cat > notes/cli.py <<'P'
import difflib
import sys

from notes import help as helptext
from notes.store import Store

VERSION = "1.4.0"
COMMANDS = ["add", "list", "edit", "delete"]
EDITOR = "vi"


def color(text: str, code: str) -> str:
    # No colours when stdout is not a terminal (pipes, files).
    if not sys.stdout.isatty():
        return text
    return f"\033[{code}m{text}\033[0m"


def main(argv: list[str]) -> int:
    if argv and argv[0] == "--version":
        print(VERSION)
        return 0
    if not argv or argv[0] not in COMMANDS:
        guess = difflib.get_close_matches(argv[0] if argv else "", COMMANDS, n=1)
        print(f"unknown command" + (f"; did you mean {guess[0]}?" if guess else ""), file=sys.stderr)
        return 1
    store = Store("~/.notes")
    try:
        if argv[0] == "list":
            for note in sorted(store.all(), key=lambda n: n.created, reverse=True):
                print(color(note.title, "1"))
        elif argv[0] == "delete":
            if input(f"Delete {argv[1]}? [y/N] ").lower() != "y":
                return 0
            store.delete(argv[1])
        elif argv[0] == "add":
            store.add(" ".join(argv[1:]))
        elif argv[0] == "edit":
            store.edit(argv[1], editor=EDITOR)
    except Exception as exc:  # every failure exits with 1
        print(f"error: {exc}", file=sys.stderr)
        return 1
    return 0
P
cat > notes/help.py <<'P'
HELP = {
    "add": "Ad a note",
    "list": "Lists all notse",
    "edit": "Edit an exsting note",
    "delete": "Delete a note",
}
P
cat > notes/store.py <<'P'
import os
import subprocess
import time
from dataclasses import dataclass


@dataclass
class Note:
    title: str
    created: float


class Store:
    """One file per note under the folder."""

    def __init__(self, folder: str):
        self.folder = os.path.expanduser(folder)

    def all(self) -> list[Note]:
        # The file name is the creation time in nanoseconds, so editing a note never changes its date.
        return [Note(name, int(name.split(".")[0]) / 1e9) for name in os.listdir(self.folder)]

    def add(self, text: str) -> None:
        with open(os.path.join(self.folder, f"{time.time_ns()}.md"), "w") as f:
            f.write(text)

    def delete(self, name: str) -> None:
        os.remove(os.path.join(self.folder, name))

    def edit(self, name: str, editor: str) -> None:
        if subprocess.call([editor, os.path.join(self.folder, name)]) != 0:
            raise RuntimeError(f"{editor} failed")
P
