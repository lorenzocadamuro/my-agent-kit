#!/usr/bin/env bash
mkdir -p tracker tiles kit-data
cat > tracker/T-140.md <<'P'
# T-140 Test whether switching the image tier on zoom saves bandwidth
Status: Todo · Label: tile-experiments · Project: Viewer
Run an experiment: when the user zooms out, request the low-resolution tier instead of the full one, and measure bytes per session.
P
cat > tracker/T-101.md <<'P'
# T-101 Serve the low tier while zooming
Status: Canceled · Label: tile-experiments · Project: Viewer
Closed 2026-08-02: measured on 500 sessions. The zoom path already reads tiles from the client cache at the tier it last loaded, so switching the tier on zoom saved under 1% of bytes. Not worth it.
P
cat > tracker/T-117.md <<'P'
# T-117 Prefetch lower tiers on zoom out
Status: Canceled · Label: tile-experiments · Project: Viewer
Closed 2026-09-15: same finding as T-101. Zoom-out requests are 3% of tile bytes; any tier change there moves the total by less than 1%.
P
cat > tracker/T-122.md <<'P'
# T-122 Fix the login button color
Status: Done · Label: ui · Project: Web
P
cat > tiles/zoom.py <<'P'
def tiles_for_zoom(cache, view, tier):
    # Zoom reuses cached tiles at the tier last loaded; only missing tiles hit the network.
    hits = [t for t in view.tiles if cache.has(t, tier)]
    misses = [t for t in view.tiles if not cache.has(t, tier)]
    return hits, [("GET", t, tier) for t in misses]
P
