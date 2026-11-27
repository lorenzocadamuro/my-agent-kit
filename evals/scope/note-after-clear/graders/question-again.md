---
type: llm
focus: last_message
weight: 2
---

Earlier, the user did not understand a planning question ("How to start the watcher? A launchd agent that starts at login (Recommended) / cron / by hand"), asked to get every question in chat and wait for the answer; the kit explained it, and the user now says "OK, now it is clear". Pass only if the reply puts that question to the user again, with its options, and waits for the answer. Fail if the reply skips the question, or takes an option without offering the user the choice again.
