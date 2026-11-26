#!/usr/bin/env bash
mkdir -p web tests kit-data
cat > ticket.md <<'P'
# Load only the open chat's job items

Today the chat view loads every job item of the board when it opens. Load only the items of the open chat instead.
Nothing on screen changes: the same items show in the same places; the view just sends fewer and smaller requests.
P
cat > web/chat_view.py <<'P'
def load_items(api, board_id, chat_id):
    items = api.get(f"/boards/{board_id}/job-items")
    return [i for i in items if i["chat_id"] == chat_id]
P
cat > tests/test_chat_view.py <<'P'
import unittest
from web.chat_view import load_items


class FakeApi:
    def __init__(self, items):
        self.items, self.calls = items, []

    def get(self, url):
        self.calls.append(url)
        return self.items


class T(unittest.TestCase):
    def test_filters_by_chat(self):
        api = FakeApi([{"chat_id": 1}, {"chat_id": 2}])
        self.assertEqual(load_items(api, 9, 1), [{"chat_id": 1}])
P
cat > kit-data/method.md <<'P'
# Method

| Kind | Judgement | Class | Matches | State | Last matches | Hand-over |
| ---- | --------- | ----- | ------- | ----- | ------------ | --------- |
| K31 | For the bar of a frontend UI step (new or changed UI), choose tests plus a browser check on the local stack | work | 4 | asked | 2026-10-30, 2026-11-02, 2026-11-05, 2026-11-07 | — |
P
