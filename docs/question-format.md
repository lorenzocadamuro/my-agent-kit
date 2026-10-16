# Question format

Every decision put to the user follows this format. A question the user cannot answer in under a minute is a bad question, not a slow user.

## When to ask

- **Ask only real decisions:** scope, boundary, the bar, product behaviour, anything published, and trade-offs where the user's priorities decide.
- **Do not ask what the code, the plan or a sensible default can answer.** Pick the default, and state it in one line.
- **Batch related questions** (up to four at a time), and ask them at the point the work actually needs them.

## Shape

- **Use the multiple-choice question tool,** with the recommended option first and marked "(Recommended)". A free answer stays possible.
- **One decision per question.** A question that bundles two decisions (when to merge, and what a lagging environment runs) is split in two.
- **Start the question with the situation in plain words:** what is happening, what the user would see, and why it matters now. For a deploy or rollout, first say what the deployed thing does and what users see when it is missing or early.
- **Each option states:**
  - **Effect:** what changes for the user, or in behaviour, if this is chosen.
  - **Today:** what happens now without the change, on the main branch or in production.
  - **Pros** and **cons**, one short clause each. Every option has both; an option with only a con is incomplete.
  - **Severity** when there is risk: how likely, how bad, and how easy to undo.
- **No internal IDs or jargon** (finding numbers, internal function names, acronyms) without a one-line meaning next to them.
- **One concrete example beats an abstract description.** "A user drags the batch while it loads" beats "manual manipulation during the loading state".

## When the user dismisses the questions

A dismissed batch, or an answer like "I don't understand", means "explain first". Explain in plain words, with the context the user is missing, then ask again with the tool. Never fall back to options in plain text.

## After the answer

- **Record the decision** in the plan's decision list, with the date and one line of reasoning.
- **If the answer reframes the question,** restate the new understanding in one line before acting on it.
- **If the same question has to be asked twice,** that is a signal for the closing step: offer `/my:improve note`.
