# Review lenses

Shared by `/my:pr:review`, the review step of `/my:plan:round` and `/my:plan:run`, and `/my:pr:comments`. Senior reviewers rarely hunt for line-level bugs first. They ask whether the change keeps its promises. Start from the promise: follow the change's main scenario (the case it exists for) end to end through every piece it touches, where most real defects sit. Then use the other lenses that fit the change, and skip the rest silently.

## The lenses

| Lens                        | Question to ask                                                                                                            | Typical failure it catches                             |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| **Promise**                 | What does this change promise (description, plan, docs)? Does every path keep it?                                          | A guarantee that holds on the happy path only          |
| **Coherence**               | Where pieces meet: is one value computed from the same input everywhere? Do the texts a model reads (prompt, tool descriptions, returned fields) agree? Is each condition as narrow as its intent? | Two pieces each right alone, wrong together            |
| **Ownership**               | Which single place owns each state transition? Can two writers race?                                                       | Two code paths updating the same record                |
| **Durability**              | If the process restarts between two steps, what state is left? Is an acknowledgement sent only after the data is saved?    | An acknowledgement that a restart turns into a lie     |
| **Idempotency**             | What happens on a retry, a duplicate event or a replay?                                                                    | Double effects, stuck records                          |
| **Every caller and writer** | Who else calls this, or writes this data: tools, imports, copies, backfills, test fakes? Give the full count, untruncated. | A caller missed because an audit was cut short         |
| **Boundary**                | With the feature off, is behaviour identical to before, whatever the client sends?                                         | A change leaking to everyone through a shared path     |
| **Rollback**                | Can this be turned off or reverted once data already exists in the new shape?                                              | Records that only the new code understands             |
| **Trust boundary**          | Which inputs come from outside? Does any of them reach code that runs with more privilege?                                 | A tool that runs untrusted refs with local credentials |
| **Reuse**                   | Does an existing helper or chokepoint already do this?                                                                     | A second implementation that drifts from the first     |
| **Evidence**                | Which commit and which run produced each number or claim in the description? Is it still true at the head?                 | A description that no longer matches the code          |
| **Overlap**                 | Do open PRs, or the reviewers' own plans, touch the same concept?                                                          | A merge conflict that is really a design conflict      |
| **Tests**                   | Would each test fail if the fix were reverted? Does it drive the real caller?                                              | A test built on a state the caller never produces      |
| **Proportionality**         | Does the stated goal need this finding fixed now, or is it a follow-up?                                                    | Perfection the goal does not need                      |

## Grading a finding

- **block:** breaks the promise, an invariant, the boundary or the bar for done.
- **ticket:** real, but outside the plan's scope. Write the ticket text and do not fix it in this change.
- **note:** style, naming, optional improvements.

**Weigh reach and impact:** who can trigger it (every user, one API client, an operator) and what it costs when they do. A flaw only a rare caller can reach, with a contained cost, is a note unless it breaks the promise.

**"The main branch has the same problem" is not a reason to downgrade.** If the finding breaks a guarantee this change advertises, it is a block.

## Questions worth asking the author

Turn the lenses into the questions that matter most for this change, none when nothing is worth asking, for example:

- "Which single place decides X, and does every consumer read only that?"
- "List every way this can end in a success state while being wrong."
- "What happens if the process restarts right after Y?"
- "Is this behaviour new, or does a test pin it today?"
- "What would make this hard to roll back once it has run in production?"
