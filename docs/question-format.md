# Question format

Every decision put to the user follows this format. A question the user cannot answer in under a minute is a bad question, not a slow user.

## When to ask

- **Ask only real decisions:** scope, boundary, the bar, product behaviour, anything published, and trade-offs where the user's priorities decide.
- **Do not ask what the code, the plan or a sensible default can answer.** Pick the default, and state it in one line.
- **Batch related questions** (up to four at a time), and ask a decision only when the work needs it: a choice that belongs to a later part, or depends on what an earlier part will learn, waits for that part's gate.
- **Explore first, then decide.** While a design is still taking shape (a UI, a layout, a naming scheme), iterate in the chat on a mockup or a draft, and apply the user's corrections as plain chat replies; ask with the tool once the shape is stable and a real choice is left.

## Shape

- **Use the multiple-choice question tool,** with the recommended option first and marked "(Recommended)". A free answer stays possible.
- **One decision per question.** A question that bundles two decisions (when to merge, and what a lagging environment runs) is split in two.
- **Introduce the questions in chat, right before them in the same message,** in the user's language, so the user arrives prepared: the situation in plain words (what is happening, what the user would see, why it matters now), what the kit prescribes here and why it asks, and what the choice changes. For a deploy or rollout, first say what the deployed thing does and what users see when it is missing or early.
- **Then keep each question short.** The question window covers the chat above it, so the question still opens with the situation in one plain line, its essential context only.
- **Each option states, in a few words each:**
  - **Effect:** what changes for the user, or in behaviour, if this is chosen. Verified, or marked unverified (principles: verify).
  - **Today:** what happens now without the change, on the main branch or in production.
  - **Pros** and **Cons**, written as labels inside each option (in the user's language, for example "Pro" / "Contro"), one short clause each; a shared header row does not count. Every option has both; an option with only a con is incomplete.
  - **Severity** when there is risk: how likely, how bad, and how easy to undo.
- **Keep terms as they are** (principles: language). The first time a repository or kit term, an internal id, an acronym, or an idea introduced earlier in this conversation appears, give its plain meaning in one line; never paraphrase it away.
- **Show the case.** One concrete example beats an abstract description ("a user drags the batch while it loads"). For a structural or visual rule, show it: a small before/after (two trees, two rows, a mockup), and say in one line what it shows.
- **Say why the recommended option is recommended:** the principle it rests on, and what the user chose the last times for its kind, when it has one ("the last 3 times you chose …"; principles: the method). When the only reason is "it keeps today's behaviour", say so, and name any product principle that points the other way.

## When the user dismisses the questions or asks back

A dismissed batch, an answer like "I don't understand", or a free answer that holds a question or a doubt means "explain first", and is a signal. Answer in chat, in plain words, with the context the user is missing, and end the turn: no new question, with the tool or in text, until the user says it is clear. Then ask again with the tool, introduced as in § Shape. Never fall back to options in plain text.

## After the answer

- **Record the decision** in the plan's Decisions table (date, kind, recommended and chosen option, one line of reasoning) and, in the modes the method names, update its kind (principles: the method). When it changes a rule the plan states elsewhere (boundary, invariants, behaviour table, intentional changes, bar), update every place that repeats it in the same edit: the answer already decided them.
- **If the answer reframes the question, or makes a pending one stale,** restate the new understanding in one line, and drop or rewrite the stale question before asking it.
- **A free answer, a dismissal, or a question asked twice is a signal** (principles: closing step). Record it, then carry on, unless it holds a question or a doubt (above).
