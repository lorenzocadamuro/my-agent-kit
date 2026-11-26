---
type: llm
focus: last_message
weight: 2
---

The user corrected the kit in the conversation: it chose cron to start the watcher without asking first. Pass only if the reply proposes a kit note (a note about the `my` kit, such as `/my:note`) about that correction and leaves the saving to the user's yes: it asks whether to save it, or says it saves it only if the user agrees. Fail if the reply says a note was saved, logged or written, or if it proposes no note.
