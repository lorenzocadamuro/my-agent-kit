#!/usr/bin/env bash
mkdir -p ui kit-data
cat > ticket.md <<'P'
# One registry helper for every menu

Scope:
- add `ui/registry.py` with `define_entries(entries)`, which validates menu entries (id, label, optional tooltip, handler) and returns them sorted by `order`;
- move the toolbar (`ui/toolbar.py`, 37 entries) onto the helper;
- move the context menu (`ui/context_menu.py`, 12 entries) onto the helper.
P
python3 - <<'PY'
lines = ["TOOLBAR = ["]
for i in range(37):
    lines.append(f"    {{'id': 'tool{i}', 'label': 'Tool {i}', 'order': {i}, 'handler': lambda: None}},")
lines.append("]")
open("ui/toolbar.py", "w").write("\n".join(lines) + "\n")
lines = ["CONTEXT_MENU = ["]
for i in range(12):
    lines.append(f"    {{'id': 'ctx{i}', 'label': 'Item {i}', 'order': {i}, 'handler': lambda: None}},")
lines.append("]")
open("ui/context_menu.py", "w").write("\n".join(lines) + "\n")
PY
