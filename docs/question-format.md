# Question format

Every decision put to the user follows this format. A question the user cannot answer in under a minute is a bad question, not a slow user.

## When to ask

- **Ask only real decisions:** scope, boundary, the bar, product behaviour, anything published, and trade-offs where the user's priorities decide.
- **Do not ask what the code, the plan or a sensible default can answer.** Pick the default, and state it in one line.
- **Batch related questions** (up to four at a time), and ask them at the point the work actually needs them.
- **Explore first, then decide.** While a design is still taking shape (a UI, a layout, a naming scheme), iterate in the chat on a mockup or a draft, and apply the user's corrections as plain chat replies; ask with the tool once the shape is stable and a real choice is left.

## Shape

- **Use the multiple-choice question tool,** with the recommended option first and marked "(Recommended)". A free answer stays possible.
- **One decision per question.** A question that bundles two decisions (when to merge, and what a lagging environment runs) is split in two.
- **Start the question with the situation in plain words:** what is happening, what the user would see, and why it matters now. For a deploy or rollout, first say what the deployed thing does and what users see when it is missing or early.
- **Each option states:**
  - **Effect:** what changes for the user, or in behaviour, if this is chosen. Verified, or marked unverified (principles: verify).
  - **Today:** what happens now without the change, on the main branch or in production.
  - **Pros** and **Cons**, written as labels inside each option (in the user's language, for example "Pro" / "Contro"), one short clause each; a shared header row does not count. Every option has both; an option with only a con is incomplete.
  - **Severity** when there is risk: how likely, how bad, and how easy to undo.
- **Keep terms as they are** (principles: language). The first time a repository or kit term, an internal id, an acronym, or an idea introduced earlier in this conversation appears, give its plain meaning in one line; never paraphrase it away.
- **Show the case.** One concrete example beats an abstract description ("a user drags the batch while it loads"). For a structural or visual rule, show it: a small before/after (two trees, two rows, a mockup), and say in one line what it shows.
- **Say why the recommended option is recommended:** the principle it rests on, and what the user chose the last times for its kind ("the last 3 times you chose …"; principles: the method). When the only reason is "it keeps today's behaviour", say so, and name any product principle that points the other way.

## When the user dismisses the questions

A dismissed batch, or an answer like "I don't understand", means "explain first", and is a signal. Explain in plain words, with the context the user is missing, then ask again with the tool. Never fall back to options in plain text.

## After the answer

- **Record the decision** in the plan's Decisions table (date, kind, recommended and chosen option, one line of reasoning), and update its kind (principles: the method).
- **If the answer reframes the question, or makes a pending one stale,** restate the new understanding in one line, and drop or rewrite the stale question before asking it.
- **A free answer, a dismissal, or a question asked twice is a signal** (principles: closing step). Record it, then carry on.
