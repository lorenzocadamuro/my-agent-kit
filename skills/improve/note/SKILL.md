# Note

How the kit changes: `${CLAUDE_PLUGIN_ROOT}/rules/learning.md` § The kit's improvement loop.

Goal: under a minute, no questions unless the text is empty.

1. **Identify the skill and mode,** written `skill:mode` (`plan:scope`, `plan:run`, `pr:review`, `improve:run`): from the text, or else from the most recent `/my:` command used in this session, or else `general`. Use `principles`, `templates`, `scripts`, `mod` or `profile:<repo>` when the problem is there. A reply that only broke the user's output style is not a kit problem, since the kit sets no reply form (principles: language): say so in one line, name the style's plugin as the place to fix it, and log nothing. When a kit text asked for that form, log it against that text.
2. **Collect context without asking:**
   - date and time, and the kit version (the template's `Kit:` line);
   - current repository (`git rev-parse --show-toplevel`, remote slug), branch, and PR number (`gh pr view --json number -q .number`, if any);
   - the session id if known.
3. **Fill the entry** from `${CLAUDE_PLUGIN_ROOT}/skills/improve/note/note-template.md`.
   - The reasoning fields are what happened, why it was a problem, missing question and expected (principles: language). Keep a short quote of the user's words when the exact meaning matters.
   - The heading reads `## <id> · <skill> · open`, with `<id>` left as it is: the script of step 4 numbers it.
   - "What happened" and "Expected" are concrete: what was done or said, not an opinion. "Why it was a problem" says what it cost the user. "Missing question" is a question someone should have asked at the start, not a fix; `unknown` when it is not clear.
   - "Suspected cause" names a step, principle, template or profile line when you can point to it; otherwise `unknown`. Do not investigate deeply here.
4. **Append** the entry, written to a scratch file, with `${CLAUDE_PLUGIN_ROOT}/scripts/append-entry.sh log <log> <file>`: it gives it the next `YYYYMMDD-NN` after today's highest under a lock, so two sessions writing at once never share an id, and prints it; if it cannot take the lock, try once more, then say so. Change nothing else: no skill, doc, template or profile.
5. **Confirm in exactly one line,** and nothing else: `Logged <id> · <skill> · <n> open`. Missing context goes in the entry as `unknown`; do not explain it in the reply.
