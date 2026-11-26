#!/usr/bin/env bash
mkdir -p notes api export tests kit-data/projects .github
cat > notes/__init__.py <<'P'
P
cat > api/__init__.py <<'P'
P
cat > export/__init__.py <<'P'
P
cat > notes/titles.py <<'P'
def make_title(text: str, limit: int = 40) -> str:
    """The note's title: its first line, cut at `limit` characters with an ellipsis."""
    first = text.strip().splitlines()[0] if text.strip() else "Untitled"
    return first if len(first) <= limit else first[: limit - 1] + "…"
P
cat > api/notes.py <<'P'
from notes.titles import make_title


def list_notes(db) -> list[dict]:
    """GET /notes: one row per note, with its title."""
    return [{"id": n["id"], "title": make_title(n["text"])} for n in db.select("notes")]
P
cat > api/search.py <<'P'
from notes.titles import make_title


def search(db, query: str) -> list[dict]:
    """GET /search: notes whose text contains the query, titles cut at 60 characters."""
    hits = [n for n in db.select("notes") if query.lower() in n["text"].lower()]
    return [{"id": n["id"], "title": make_title(n["text"], limit=60)} for n in hits]
P
cat > export/markdown.py <<'P'
from notes.titles import make_title


def to_markdown(note: dict) -> str:
    """Export a note as Markdown: the title as a heading, then the text."""
    return f"# {make_title(note['text'], limit=200)}\n\n{note['text']}\n"
P
cat > tests/__init__.py <<'P'
P
cat > tests/test_titles.py <<'P'
import unittest

from notes.titles import make_title


class MakeTitleTest(unittest.TestCase):
    def test_first_line(self):
        self.assertEqual(make_title("Groceries\nmilk"), "Groceries")

    def test_cut_with_ellipsis(self):
        self.assertEqual(make_title("x" * 50, limit=10), "x" * 9 + "…")

    def test_empty(self):
        self.assertEqual(make_title("   "), "Untitled")


if __name__ == "__main__":
    unittest.main()
P
cat > .github/CODEOWNERS <<'P'
/notes/   @acme/notes-core
/export/  @acme/integrations
P
cat > README.md <<'P'
# acme/notes

Notes service. Run the tests with `python3 -m unittest discover -s tests -q`.
P
cat > ticket.md <<'P'
# NOTE-41: Titles skip Markdown heading marks

Notes written in Markdown start with `# ` or `## `, so their titles show the hash marks.
Change `make_title` in notes/titles.py to drop leading `#` marks and the space after them,
everywhere titles are shown. Titles are only used by the notes list today.
P
cat > kit-data/projects/acme-notes.md <<'P'
# Project profile: acme/notes

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Rules to load

| Area (path glob) | Guide       |
| ---------------- | ----------- |
| `**`             | `README.md` |

## Commands

| Purpose        | Command                                    |
| -------------- | ------------------------------------------ |
| Targeted tests | `python3 -m unittest discover -s tests -q` |
| Deep review    | none                                       |

## Tickets

- Tracker: Linear, team NOTE
P
