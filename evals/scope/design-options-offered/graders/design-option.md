---
type: llm
focus:
  source: file
  path: questions.md
weight: 3
---

The ticket frames a product choice (filter the loaded messages of the open conversation, or the whole board). The code shows that filtering inside `MessageList` breaks its scroll anchor and stops pagination early on pages with no generations. A design that avoids both is a separate generations view, shown instead of the list by the toggle (with its own query and pagination).

Pass only if the questions offer a design alternative that removes those risks (a separate view or list for generations, or an equivalent that does not filter `MessageList` in place), as its own question or as options asked before or beside the scope question, and say which risk it removes. Fail if the only questions are about the scope (open conversation vs whole board) with the filter assumed to live inside the existing list.
