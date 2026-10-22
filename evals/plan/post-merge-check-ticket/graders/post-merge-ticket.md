---
type: llm
focus:
  source: file
  path: plan.md
weight: 3
---

The ticket's last condition ("synced to production") can only happen after the merge, at the next deploy. Pass only if the plan proposes a separate verification ticket for it: a new ticket, distinct from this one, with its text written in the plan (what to check, where, and when), for example under Out of scope or in the bar for done section. A plan that keeps the condition on this ticket (in the bar, as "the user confirms it after the deploy", or as "the ticket closes only after the sync"), or drops it, fails.
