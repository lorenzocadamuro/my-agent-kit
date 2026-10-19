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
  - **Effect:** what changes for the user, or in behaviour, if this is chosen. Verified, or marked unverified (principles: verify).
  - **Today:** what happens now without the change, on the main branch or in production.
  - **Pros** and **cons**, one short clause each. Every option has both; an option with only a con is incomplete.
  - **Severity** when there is risk: how likely, how bad, and how easy to undo.
- **Keep terms as they are** (principles: language). The first time a repository or kit term, an internal id, an acronym, or an idea introduced earlier in this conversation appears, give its plain meaning in one line; never paraphrase it away.
- **One concrete example beats an abstract description.** "A user drags the batch while it loads" beats "manual manipulation during the loading state".

## When the user dismisses the questions

A dismissed batch, or an answer like "I don't understand", means "explain first", and is a signal. Explain in plain words, with the context the user is missing, then ask again with the tool. Never fall back to options in plain text.

## After the answer

- **Record the decision** in the plan's decision list, with the date and one line of reasoning.
- **If the answer reframes the question, or makes a pending one stale,** restate the new understanding in one line, and drop or rewrite the stale question before asking it.
- **A free answer, a dismissal, or a question asked twice is a signal** (principles: closing step). Record it, then carry on.
