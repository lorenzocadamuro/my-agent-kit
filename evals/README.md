# Evals

One folder per skill. Each case reproduces a problem the kit once had, so the fix stays fixed.

```
evals/<skill>/<case-name>/
  prompt.md        what the user asks, plus any setup the case needs
  graders/*.md     what a correct run must and must not do
```

Run them with:

```bash
claude plugin eval .                  # every case
claude plugin eval . --case '<glob>'  # a subset
```

`/my:improve run` adds a case for every note it fixes. A case is written so that it fails on the version before the fix.
