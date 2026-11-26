---
name: digest
description: "Turn the signals collected during the work into a few clear kit notes"
argument-hint: "[signals file]"
disable-model-invocation: true
when: "\"/my:digest\", at the end of every other skill, or by the user"
reads: [rules/core.md, rules/plan-contract.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/files.md, rules/question-format.md, rules/model-choice.md, rules/local-data.md]
---

# Digest

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md`, `${CLAUDE_PLUGIN_ROOT}/rules/files.md`, `${CLAUDE_PLUGIN_ROOT}/rules/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/rules/model-choice.md` and `${CLAUDE_PLUGIN_ROOT}/rules/local-data.md`.

How the kit changes: `${CLAUDE_PLUGIN_ROOT}/rules/learning.md` § The kit's improvement loop.

Run at the end of every other skill (principles: closing step), or by the user. Goal: a few clear notes, no noise, no questions.

1. **Read the pending signals:** lines without a mark, in the given file. Without a file (the user runs it by hand), every file under `<data root>/signals/`, so leftovers from sessions that ended early are picked up.
2. **Drop what a later signal contradicts or withdraws.** Mark both the withdrawn and the withdrawing signal `→ dropped: <why>`; never delete a line.
3. **Group by upstream cause:** the missing question or directive behind the signals, not the surface event. A session usually yields one to three groups.
4. **For each group,** re-read the log first.
   - If an open entry has the same cause, append one `- Evidence: <date> · <skill> · <what happened> · <source> · kit <version>` line per signal at its end, the version copied from the signal (none when it has none). Never change its other lines.
   - Otherwise write a new entry as in Note steps 3–4 (the marks of step 5 below carry the id the script prints), with the signals as Evidence lines. Its "Where" comes from the signals file's heading, its `Kit:` from the newest version its signals carry (else the digest's own).
5. **Mark each digested signal** `→ <entry id>`.
6. **Reply in one line:** `Digested <k> signals → <ids>`. With no pending signals, reply nothing.

Never change a skill, doc, template or profile.
