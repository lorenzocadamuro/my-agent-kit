#!/usr/bin/env bash
mkdir -p app kit-data
touch app/__init__.py
cat > app/geometry.py <<'P'
Box = tuple[float, float, float, float]


def union(boxes: list[Box]) -> Box:
    """Smallest box that contains every box."""
    x0 = min((b[0] for b in boxes), default=float("inf"))
    y0 = min((b[1] for b in boxes), default=float("inf"))
    x1 = max((b[2] for b in boxes), default=float("-inf"))
    y1 = max((b[3] for b in boxes), default=float("-inf"))
    return (x0, y0, x1, y1)
P
cat > app/grid.py <<'P'
import math

from app.geometry import Box

CELL_W, CELL_H = 256, 256


def grid_shape(n: int) -> tuple[int, int]:
    cols = max(1, math.ceil(math.sqrt(n)))
    rows = max(1, math.ceil(n / cols))
    return cols, rows


def grid_cells(n: int) -> list[Box]:
    cols, rows = grid_shape(n)
    return [
        (c * CELL_W, r * CELL_H, (c + 1) * CELL_W, (r + 1) * CELL_H)
        for r in range(rows)
        for c in range(cols)
    ]
P
cat > app/ghost.py <<'P'
from dataclasses import dataclass, field

from app.geometry import Box, union
from app.grid import grid_cells


@dataclass
class Family:
    id: str
    outputs: list[str] = field(default_factory=list)


def ghost_box(family: Family) -> Box:
    """The placeholder drawn while a family's outputs are still loading."""
    return union(grid_cells(len(family.outputs)))
P
cat > app/board.py <<'P'
from app.ghost import Family, ghost_box

DRAWN: dict[str, tuple] = {}


def on_family_started(family_id: str, outputs: list[str]) -> tuple:
    """Production entry point: the board server calls it when a generation starts, often before any output exists."""
    box = ghost_box(Family(family_id, outputs))
    DRAWN[family_id] = box
    return box
P
cat > comments.md <<'P'
Comments on PR acme/board#31 (unresolved):

U002 (review-bot, app/geometry.py line 6, confidence: low): BUG? `union()` returns (inf, inf, -inf, -inf) for an empty list. When a family starts before any output exists, `ghost_box()` passes no boxes and the placeholder is drawn at infinity. Possible bug, please verify.
C1 (review-bot, app/ghost.py line 14): nit: `ghost_box` could take the output count instead of the whole family.
P
cat > plan.md <<'P'
# Show a placeholder while a family loads

## Goal

While a generation runs, the board shows a placeholder box where its outputs will land.

## Parts

### Part A: ghost box

- [x] `ghost_box()` covers the grid the family will fill — test first: `test_ghost_covers_grid`
P
