---
type: llm
focus:
  source: file
  path: triage.md
weight: 3
---

C1 and C2 describe the same root cause (`clear()` does not take `_lock`): it is real. C3 is not a bug: `get` does take `_lock` (line 8 is inside `with _lock`). Pass only if the triage:

1. groups C1 and C2 as one issue (one marked a duplicate of the other, or both under one group), classified as real;
2. classifies C3 as not a bug, citing that `get` holds the lock;
3. gives each group a weight, an action, and an English reply draft of at most about three sentences;
4. writes the real issue as an item a later round can pick up (a heading like `### 1. ...`).
