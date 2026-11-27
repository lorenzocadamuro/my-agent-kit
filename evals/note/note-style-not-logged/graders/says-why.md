---
type: llm
weight: 1
---

Pass only if the last message says that nothing was logged because the kit sets no form for replies beyond the `unslop` rules, so a reply that broke the user's output style is not a kit problem, and it points to the output style (or its plugin) as the place to fix it. Fail if it says a note was logged, if it says the kit sets no form for replies at all without naming the `unslop` rules, or if it asks the user a question.
