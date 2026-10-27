#!/usr/bin/env bash
mkdir -p panel kit-data
cat > ticket.md <<'P'
# Generations view in the side panel

Add a toggle to the side panel that shows only generations (images and videos) instead of the whole activity list.
The view must list generations from all conversations, by every user, across all pages of the board — not only the open chat.
Use the list component from the open activity-feed PR, which already supports filters.
P
cat > panel/activity.py <<'P'
def activity_items(chat_id, page=0):
    """Items of the open chat only, 50 per page (the panel today shows one chat)."""
    return [{"chat": chat_id, "kind": "message", "page": page}]
P
cat > open-prs.json <<'P'
[{"number": 412, "title": "Activity feed list with filters", "author": "a-colleague", "files": ["panel/activity.py", "panel/feed.py"],
  "createdAt": "2026-08-30", "updatedAt": "2026-09-12", "reviewDecision": null, "mergeable": "CONFLICTING", "isDraft": true}]
P
