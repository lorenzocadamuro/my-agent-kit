---
name: note
description: "Log a problem with the my kit, without changing anything; with `signals`, propose notes from the signals the work collected and save each on your yes"
argument-hint: "<what happened> | signals [file]"
disable-model-invocation: true
when: "\"/my:note <what happened>\", \"annota\", \"note this problem with the kit\", \"the skill did X wrong\"; \"/my:note signals [file]\" to turn the signals the work collected into proposed notes"
reads: [rules/core.md, rules/plan-contract.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/files.md, rules/question-format.md, rules/model-choice.md, rules/local-data.md]
---

# Note

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md`, `${CLAUDE_PLUGIN_ROOT}/rules/files.md`, `${CLAUDE_PLUGIN_ROOT}/rules/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/rules/model-choice.md` and `${CLAUDE_PLUGIN_ROOT}/rules/local-data.md`.

How the kit changes: `${CLAUDE_PLUGIN_ROOT}/rules/learning.md` § The kit's improvement loop.

Goal: under a minute, no questions unless the text is empty. The text the user gives is their yes: the note is saved. With `signals` as the first word, follow § Signals instead.

1. **Identify the skill and mode,** written `skill:mode` (`plan:scope`, `plan:run`, `pr:review`, `improve:run`): from the text, or else from the most recent `/my:` command used in this session, or else `general`. Use `principles`, `templates`, `scripts`, `mod` or `profile:<repo>` when the problem is there. A reply that only broke the user's output style is not a kit problem, since the kit sets no reply form beyond the `unslop` rules (`rules/core.md`: language): say so in one line, name the style's plugin as the place to fix it, and log nothing. When a kit text asked for that form, log it against that text.
2. **Collect context without asking:**
   - date and time, and the kit version (the template's `Kit:` line);
   - current repository (`git rev-parse --show-toplevel`, remote slug), branch, and PR number (`gh pr view --json number -q .number`, if any);
   - the session id if known.
3. **Fill the entry** from `${CLAUDE_PLUGIN_ROOT}/skills/improve/note/note-template.md`.
   - The reasoning fields are what happened, why it was a problem, missing question and expected (`rules/core.md`: language). Keep a short quote of the user's words when the exact meaning matters.
   - The heading reads `## <id> · <skill> · open`, with `<id>` left as it is: the script of step 4 numbers it.
   - "What happened" and "Expected" are concrete: what was done or said, not an opinion. "Why it was a problem" says what it cost the user. "Missing question" is a question someone should have asked at the start, not a fix; `unknown` when it is not clear.
   - "Suspected cause" names a step, principle, template or profile line when you can point to it; otherwise `unknown`. Do not investigate deeply here.
   - "File" names the kit file the problem is about, and "Leaves read" the rule files the skill had loaded when it happened; leave out either line when it is not known.
4. **Append** the entry, written to a scratch file, with `${CLAUDE_PLUGIN_ROOT}/scripts/append-entry.sh log <log> <file>`: it gives it the next `YYYYMMDD-NN` after today's highest under a lock, so two sessions writing at once never share an id, and prints it; if it cannot take the lock, try once more, then say so. Change nothing else: no skill, doc, template or profile.
5. **Confirm in exactly one line,** and nothing else: `Logged <id> · <skill> · <n> open`. Missing context goes in the entry as `unknown`; do not explain it in the reply.

## Signals

`/my:note signals [file]` turns the signals the work collected (`rules/learning.md`: closing step) into proposed notes. No note is saved without the user's yes in the conversation.

1. **Read the pending signals:** lines without a mark, in the given file. Without a file, every file under `<data root>/signals/`, so leftovers from sessions that ended early are picked up.
2. **Drop what a later signal contradicts or withdraws.** Mark both the withdrawn and the withdrawing signal `→ dropped: <why>`; never delete a line.
3. **Group by upstream cause:** the missing question or directive behind the signals, not the surface event. A session usually yields one to three groups.
4. **Propose each group,** after re-reading the log: as `Evidence:` lines on the open entry with the same cause (name its id), or as a new entry (its skill and what happened, in one line). Ask the user which to save, and save nothing before the yes.
5. **On the yes, for each group the user approved:**
   - for an open entry with the same cause, append one `- Evidence: <date> · <skill> · <what happened> · <source> · kit <version>` line per signal at its end, the version copied from the signal (none when it has none). Never change its other lines;
   - otherwise write a new entry as in steps 3–4, with the signals as Evidence lines. Its "Where" comes from the signals file's heading, its `Kit:` from the newest version its signals carry (else this skill's own).
   - Mark each of its signals `→ <entry id>`, and each signal of a group the user declines `→ declined: <date>`.
6. **Reply** with the proposals and the question; after the yes, in one line: `Saved <k> signals → <ids>`. With no pending signals, reply nothing.

Never change a skill, doc, template or profile.
