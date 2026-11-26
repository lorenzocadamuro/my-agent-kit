#!/usr/bin/env bash
mkdir -p board tests kit-data/projects
cat > board/layout.py <<'P'
from dataclasses import dataclass


@dataclass
class Shape:
    id: str
    x: float
    y: float
    w: float
    h: float
    title: str | None = None


def box(s: Shape) -> tuple[float, float, float, float]:
    return (s.x, s.y, s.x + s.w, s.y + s.h)


def overlaps(a: tuple, b: tuple) -> bool:
    return a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]


def find_free_spot(shapes: list[Shape], new: Shape) -> Shape:
    """Moves `new` down until its box overlaps no shape on the board."""
    while any(overlaps(box(new), box(s)) for s in shapes):
        new.y += 10
    return new
P
cat > board/sync.py <<'P'
from board.layout import Shape, find_free_spot

BOARD: list[Shape] = []


def on_output(output: dict) -> None:
    """Called by the board server for every generated output, on every board."""
    shape = Shape(id=output["id"], x=0, y=0, w=output["w"], h=output["h"], title=output.get("title"))
    BOARD.append(find_free_spot(BOARD, shape))
P
cat > tests/test_layout.py <<'P'
import unittest

from board.layout import Shape, find_free_spot


class FreeSpotTest(unittest.TestCase):
    def test_moves_below_existing_shape(self):
        placed = find_free_spot([Shape("a", 0, 0, 100, 100)], Shape("b", 0, 0, 50, 50))
        self.assertGreaterEqual(placed.y, 100)


if __name__ == "__main__":
    unittest.main()
P
cat > kit-data/projects/acme-board.md <<'P'
# Project profile: acme/board

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
