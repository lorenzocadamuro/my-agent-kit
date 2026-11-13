---
type: llm
focus:
  source: file
  path: questions.md
weight: 3
---

The ticket bundles three deliverables: a new helper, the move of the toolbar onto it, and the move of the context menu onto it. Pass only if the first question in the file (whatever its numbering or heading) asks which of these deliverables go in this change, for example whether the moves belong in later PRs, before any question about how to build the helper or how to migrate the menus. Fail if the first question is about anything else, or if the scope question comes only later.
