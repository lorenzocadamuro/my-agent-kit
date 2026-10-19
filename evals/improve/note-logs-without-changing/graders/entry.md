---
type: llm
focus:
  source: file
  path: kit-data/suite-log.md
weight: 2
---

This is the suite log after the run. Pass only if it holds exactly one new entry that:

1. has an id in the form `YYYYMMDD-NN` and the status `open`;
2. names a planning skill (for example `scope-plan` or `plan`);
3. states concretely that the same feature-flag question was asked twice, with different wording the second time;
4. has an "Expected" line, a suspected cause, and the signal "question re-asked";
5. has its reasoning fields (what happened, expected, why it was a problem) in English, the language of the prompt.
