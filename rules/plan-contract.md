## The plan is the contract

- **Boundary first.** State what must stay exactly as it is today (for example, "with the feature flag off, behaviour equals the main branch"). Write it before any code.
- **Invariants are checkable.** Each one names where in the code it holds, and a test that fails when it breaks.
- **New or existing behaviour?** Before treating a behaviour as a requirement, find the test or code that pins it today. If none exists, it is a new feature: it goes through scope, not through a fix.
- **The bar for done is set at the start.** It is the stop criterion for every review. A review stops when the bar is met, not when it runs out of things to say.
- **Out of scope is a list.** A finding outside the plan is never fixed in it: it becomes a ticket, or, when the user accepts it as it is, the plan records why, with no ticket (the recommended option when it concerns only a non-production environment).
- **Intentional changes are a list.** Every difference from today's behaviour that the change means to make is written down. An unlisted difference is either a bug or a missing entry.
- **Size budget and split trigger.** Agree a rough size up front, in production lines and files: tests are estimated and reported apart, and never trigger the split (a plan written before reads its numbers as production). Crossing it means stop and decide whether to split.

## The kit carries the plan it made

- **An approved plan runs only through `/my:plan:run` or `/my:plan:round`.** Together with `/my:plan:scope`, which keeps it while planning, they keep the state file, and so the status line, true from the first step to the last.
- **Every change to the plan's work becomes a round** with that work as its source, whoever starts it: a request to do part of it directly ("implement part B"), or the work left after a gate (after a rollout step or a restart). Whoever makes the change, even a few lines, it gets the round's fresh review (`plan:round` step 7) before the push.
- **Leave the kit for a change only when the user says so;** then delete its state file, and work as plain Claude Code.
