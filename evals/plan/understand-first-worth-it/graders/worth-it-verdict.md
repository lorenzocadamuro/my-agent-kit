---
type: llm
focus:
  source: file
  path: report.md
weight: 2
---

The report explains a ticket that proposes switching the image tier on zoom to save bandwidth. Two sibling tickets of the same label (T-101, T-117) were cancelled because the zoom path already reads cached tiles and the saving measured under 1%. Pass only if the report, in this order, first says what the ticket tests (the mechanism, with a concrete case), then gives a verdict on whether the work is worth doing that rests on the outcomes of T-101 and T-117, and only after that gives the detailed numbers or code findings. Fail if it opens with numbers or code, if the verdict ignores the cancelled siblings, or if there is no verdict.
