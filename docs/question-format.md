# Question format

Every decision put to the user follows this format. A question the user cannot answer in under a minute is a bad question, not a slow user.

## When to ask

- **Ask only real decisions:** scope, boundary, the bar, product behaviour, anything published, and trade-offs where the user's priorities decide.
- **Do not ask what the code, the plan or a sensible default can answer.** What the code beside the choice already does (a sibling path's behaviour, the naming of its neighbours) is that default, or, when the choice is still real, one of the options. Pick the default, and state it in one line.
- **Batch related questions** (up to four at a time), and ask a decision only when the work needs it: a choice that belongs to a later part, or depends on what an earlier part will learn, waits for that part's gate.
- **Show it, then ask.** Anything a question or its options name that the user has not seen in this conversation is shown first, new or existing: a feature (the steps to see it), a function or a mechanism (what the user does that triggers it, and what follows), an agent's role, the values a choice would change today, a design still taking shape (a mockup, a draft, a small before/after). One concrete case beats an abstract description ("a user drags the batch while it loads"); two or three of the user's own cases walked through (the edge they care about included) say what is proven, with its evidence, and what is not. A gate first says what the work found, before what it asks. Apply the user's corrections as plain chat replies; ask with the tool once the user can predict what each option does and a real choice is left.
- **A question that can stop or postpone the work** (wait for another ticket, a dependency, cancel) is asked alone, before the others: its answer can make them moot.

## Shape

- **Use the multiple-choice question tool,** with the recommended option first and marked "(Recommended)". A free answer stays possible. Every decision carries its own recommended option, also one that depends on another decision in the same message: the recommendation then states the condition ("if you choose A in Q1, I recommend …"), and a gate written in a report rather than asked with the tool marks it the same way.
- **One decision per question.** A question that bundles two decisions (when to merge, and what a lagging environment runs) is split in two.
- **The options start from the user.** What the user already said about this choice in the conversation (a ticket in their words included) is one of the options, whole and in their terms, even when it joins two decisions (a retry "only on timeouts, three at most" is one option, not a trigger option in one question and a limit option in the next). Any other option that the code, the boundary or an earlier decision rules out is not offered; when the user's own path is the one ruled out, it stays an option and its Cons say why.
- **A change to the kit's `CONSTITUTION.md` is its own question,** never an option inside another decision: it names the clause, shows today's text and the new text, and asks explicitly whether to amend the constitution that way.
- **Introduce the questions in chat, right before them in the same message,** so the user arrives prepared: the situation (what is happening, what the user would see, why it matters now), what the kit prescribes here and why it asks, and what the choice changes. For a deploy or rollout, first say what the deployed thing does and what users see when it is missing or early.
- **Then keep each question short.** The question window covers the chat above it, so the question still opens with the situation in one line, its essential context only.
- **Each option states, in a few words each:**
  - **Effect:** what changes for the user, or in behaviour, if this is chosen, everywhere it shows (the page, logs, data). Verified, or marked unverified (principles: verify). A rule the option cites is quoted as its source writes it.
  - **Today:** what happens now without the change, on the main branch or in production; for an action beyond the minimum (publishing outside the pull request, an extra step), what is lost without it.
  - **Pros** and **Cons**, written as labels inside each option (their wording follows the user's output style), one short clause each; a shared header row does not count. Every option has both; an option with only a con is incomplete.
  - **Severity** when there is risk: how likely, how bad, and how easy to undo.
- **Keep terms as they are** (principles: language). The first time a repository or kit term, an internal id, an acronym, or an idea introduced earlier in this conversation appears, give its meaning in one line; never paraphrase it away.
- **Say why the recommended option is recommended,** by the kit's own reasoning (cost, risk, what the code does, what users see); a ticket or a spec is one input, never the reason by itself. When the question decides a point the ticket or a spec states, quote its words on that point in the question, and say which option departs from it. Name the principle it rests on, and what the user chose the last times for its kind, when it has one ("the last 3 times you chose …"; principles: the method). "It keeps today's behaviour", "it saves work" or a guarantee of the kit never makes an option the recommended one on its own: when it is the only reason, say so, and name any product principle that points the other way. An option that takes away a control the user has today (the session's model, the cost, when to stop) says so in its Cons. Before an option carries a number, look in the code for a mechanism that needs none (a promise that always settles, an event). A number nobody can measure before the change (a cap, a cadence, a wait) is not invented, not even as a provisional or starting value: recommend trying the change without it (measuring only) for a set time, then setting it from the measurement; when going without it is too risky, as for a protective bound (a timeout, a retry limit), say so and ask.

## When the user dismisses the questions or asks back

A dismissed batch, an answer like "I don't understand", or a free answer that holds a question or a doubt means "explain first", and is a signal. Answer in chat with the context the user is missing, and end the turn: no new question, with the tool or in text, until the user says it is clear. Then ask again with the tool, introduced as in § Shape. Never fall back to options in plain text.

## After the answer

- **Record the decision** in the plan's Decisions table (date, kind, recommended and chosen option, one line of reasoning) and, in the modes the method names, update its kind (principles: the method). When it changes a rule the plan states elsewhere (boundary, invariants, behaviour table, intentional changes, bar), update every place that repeats it in the same edit: the answer already decided them.
- **If the answer reframes the question, or makes a pending one stale,** restate the new understanding in one line, and drop or rewrite the stale question before asking it.
- **A free answer, a dismissal, or a question asked twice is a signal** (principles: closing step). Record it, then carry on, unless it holds a question or a doubt (above).
