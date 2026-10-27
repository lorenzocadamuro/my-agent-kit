#!/usr/bin/env bash
mkdir -p panel kit-data
cat > ticket.md <<'P'
# Filter the chat panel to generations

Add a toggle to the chat panel that filters the message list down to generations (images and videos).
Decide whether the filter covers only the loaded messages of the open conversation or the whole board.
P
cat > panel/list.py <<'P'
PAGE = 50


class MessageList:
    """The chat's message list. Loads 50 messages per page when the user scrolls up; keeps the scroll anchored
    to the bottom by counting the items above the viewport. Filtering items out of this list changes that count,
    so the anchor jumps, and a page with no generations loads as empty, so 'load more' can stop early."""

    def __init__(self, chat):
        self.chat = chat
        self.items = []

    def load_more(self):
        self.items = self.chat.page(len(self.items) // PAGE) + self.items
P
