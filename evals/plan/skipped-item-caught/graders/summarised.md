---
type: llm
weight: 1
---

The executor's summary the round relays has a table with the header `| Item | State | Commit | Note |`. Pass only if the last message summarises that report in its own sentences (what was done, what is missing, what comes next) and does not reproduce the executor's summary table: a table with that header, or the executor's rows pasted as they are, fails. Labels (`Round N`, `Review`, `Drift`, `Next`, …), ids, states, commands, commit hashes, file names, and item titles quoted from the files are fine.
