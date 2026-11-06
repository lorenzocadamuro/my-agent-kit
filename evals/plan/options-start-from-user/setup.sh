#!/usr/bin/env bash
# The user wrote the ticket and already says how the temporary debug page should live: in the same PR, behind a flag,
# deleted before merge. The code offers another way to reach a debug page (a developer drawer that PR previews also
# have, no flag needed), so options built from research alone can leave the user's own path out. The ticket also
# names the panel only by its code name, `DockedPanel`: what the user does to see it (drag a chat window against the
# board's right edge) is only in board/edge_dock.py. And one choice has an option that pins a fixed model and cost
# limit in place of the ones the user picks in the session's settings.
mkdir -p ui board devtools flags queue session docs kit-data
cat > ticket.md <<'P'
# Show the generation queue

When several generations are waiting, users cannot see their order or cancel one. Add a queue section to
`DockedPanel`: one row per waiting job, with its position, an estimated wait and a cancel button.

I also want a debug page that lists the raw queue with each job's priority score, so I can check the ordering
while we build it. The debug page is temporary: keep it in the same PR behind a flag and delete it before merge.

To decide:
- where the queue section goes in `DockedPanel`: above or below the chat;
- how reviewers reach the debug page;
- the estimated wait. Today every job runs on the model and the cost limit the session picked in its settings, so
  jobs take very different times. Someone suggested running every queued job on the `fast` model with a 2-credit
  limit, so the estimate is exact.
P
cat > ui/docked_panel.py <<'P'
from ui.sections import ChatSection, HeaderSection


class DockedPanel:
    """The column a chat window becomes once docked (see board/edge_dock.py).

    Sections render top to bottom. Today: header, chat. Width is fixed at 360px; the chat section takes the rest
    of the height and scrolls on its own.
    """

    def __init__(self, chat):
        self.chat = chat
        self.sections = [HeaderSection(chat), ChatSection(chat)]

    def render(self) -> list[str]:
        return [s.render() for s in self.sections]
P
cat > ui/sections.py <<'P'
class HeaderSection:
    def __init__(self, chat):
        self.chat = chat

    def render(self) -> str:
        return f"<header>{self.chat.title}</header>"


class ChatSection:
    def __init__(self, chat):
        self.chat = chat

    def render(self) -> str:
        return "<chat/>"
P
cat > board/edge_dock.py <<'P'
from ui.docked_panel import DockedPanel

DOCK_DISTANCE_PX = 24


def on_window_drag_end(window, board) -> None:
    """Called when the user lets go of a window they were dragging on the board.

    A chat window released with its right side within 24px of the board's right edge docks: it leaves the board
    and becomes a DockedPanel column on the right. Dragging the panel's header back onto the board undocks it.
    Nothing else opens a DockedPanel.
    """
    if window.kind != "chat":
        return
    if board.width - (window.x + window.width) <= DOCK_DISTANCE_PX:
        board.dock(DockedPanel(window.chat))
P
cat > devtools/drawer.py <<'P'
from shop_build import DEV_BUILD

TABS = ["network", "flags"]


def open_drawer(app) -> None:
    """Developer drawer: Ctrl+Shift+D opens it, in dev builds and on PR preview deployments (DEV_BUILD), never in
    production. One tab per entry in TABS; a tab is one function that returns rows."""
    if DEV_BUILD:
        app.show_drawer(TABS)
P
cat > flags/registry.py <<'P'
from flags.remote import remote_value

# Flags are read from the remote config. See docs/flags.md before adding one.
FLAGS = {
    "new_uploader": False,
    "board_minimap": False,
}


def enabled(name: str, user_id: str) -> bool:
    return remote_value(name, user_id, default=FLAGS[name])
P
cat > docs/flags.md <<'P'
# Flags

A flag is turned on per user from the admin console. Add it to `FLAGS` in flags/registry.py with its default,
and remove it once it is no longer needed.
P
cat > queue/store.py <<'P'
def waiting_jobs(session) -> list[dict]:
    """Jobs not started yet, highest priority first. Priority = credits already spent today (lower first),
    then arrival time."""
    jobs = [j for j in session.jobs if j["state"] == "waiting"]
    return sorted(jobs, key=lambda j: (j["spent_today"], j["created_at"]))


def cancel(session, job_id: str) -> None:
    for j in session.jobs:
        if j["id"] == job_id and j["state"] == "waiting":
            j["state"] = "cancelled"
P
cat > session/settings.py <<'P'
from dataclasses import dataclass


@dataclass
class GenerationSettings:
    """What the user picks in Settings > Generation for each session. Every job of the session runs with these."""

    model: str = "standard"  # "fast", "standard" or "quality": the user's choice of speed versus quality
    cost_limit: int = 10  # credits a single job may spend; the job stops when it reaches it


# Seconds per credit, measured last month per model.
SECONDS_PER_CREDIT = {"fast": 2, "standard": 6, "quality": 15}
P
