---
name: log
description: "Show the history of kit notes and the versions that fixed them"
argument-hint: "[skill]"
disable-model-invocation: true
when: "\"/my:log\", the history of kit notes"
reads: [rules/core.md, rules/plan-contract.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/files.md, rules/question-format.md, rules/model-choice.md, rules/local-data.md]
---

# Log

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md`, `${CLAUDE_PLUGIN_ROOT}/rules/files.md`, `${CLAUDE_PLUGIN_ROOT}/rules/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/rules/model-choice.md` and `${CLAUDE_PLUGIN_ROOT}/rules/local-data.md`.

How the kit changes: `${CLAUDE_PLUGIN_ROOT}/rules/learning.md` § The kit's improvement loop.

Show every entry (or one skill's), open ones first, newest first within each group, with the version that fixed each closed one. End with totals by state.

Reply: every entry (or one skill's), open ones first, each closed one with the version that fixed it, and the totals by state.
