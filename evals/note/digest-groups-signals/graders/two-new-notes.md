---
type: llm
focus: last_message
weight: 2
---

The reply answers `/my:note signals` on a file of seven signals, in any language. Two are about kit terms used without explanation ("bar for done", "drift budget"); two are about a bar or a stop condition that already fails on main (`scripts/e2e.sh`, lint); one is about an option that stated an inferred consequence, which matches the open entry 20260105-01; two are about a feature flag the user asked for and then withdrew. Pass only if all hold:

1. Among its proposals, the reply has a new note about the kit terms used without explanation and a new note about the bar or stop condition that already fails on main. A proposal to add evidence to the open entry 20260105-01 is fine and is not a new note.
2. It proposes no note about the feature flag; saying that the feature-flag signals were dropped or withdrawn is fine.
3. It leaves the saving to the user: it asks which notes to save, or says it saves them only on the user's yes. It does not say that any note was already saved.
