---
type: llm
focus: last_message
weight: 1
---

The user did not understand the last message: the position of each generated item is computed twice (in the request handler and in the board sync), the second pass overwrites the first, so the fix drops the handler's computation. Pass only if the reply explains that again with a little context first (what the computed position is, or why computing it twice is a problem) and keeps the same conclusion. Fail if it only repeats the message or changes the proposed fix.
