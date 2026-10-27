#!/usr/bin/env bash
mkdir -p board kit-data
cat > ticket.md <<'P'
# Fewer tile layers while panning

While the user pans the board, each visible shape gets its own tile layer, which is slow on boards with many shapes.
Group adjacent visible shapes into one tile layer per run, so fewer layers are mounted.
P
cat > board/render.py <<'P'
from board.viewport import visible_shapes


def render_frame(board, viewport):
    """Called on every animation frame while the user pans or zooms (~60 times a second)."""
    layers = []
    for shape in visible_shapes(board, viewport):
        layers.append(mount_layer([shape]))
    return layers


def mount_layer(shapes):
    """Creates a tile layer; remounting a layer re-rasterises it (~4 ms per layer)."""
    return {"shapes": [s.id for s in shapes]}
P
cat > board/viewport.py <<'P'
def visible_shapes(board, viewport):
    """Shapes intersecting the viewport, in z-order. Changes whenever a shape enters or leaves the viewport while panning."""
    return [s for s in board.shapes if viewport.intersects(s.bounds)]
P
cat > board/layout.py <<'P'
def on_layout_changed(board):
    """Called when shapes are added, moved or deleted (a few times a minute), not while panning."""
    board.order = sorted(board.shapes, key=lambda s: s.z)
P
