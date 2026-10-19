---
type: llm
focus:
  source: file
  path: kit-data/study/page.md
weight: 3
---

This is the study page. Pass only if all hold:

1. The page is written in Italian (quotes may stay in English).
2. A first section ("layer 0") of about 150 words or fewer gives the verdict with counts by weight, at most 3 things the author owes, and one reasoning move.
3. At most 5 comments are treated in depth, the two blocking ones (non-idempotent retry; marked paid before confirmation) among them. The remaining comments appear as short rows in a table, not as full sections.
4. Idempotency is not re-explained at length: the page links or refers to the existing glossary entry.
5. Code that could not be verified is marked as unverified rather than invented with fake file contents.
