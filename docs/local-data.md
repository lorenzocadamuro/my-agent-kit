# Local data

Personal and employer-specific material lives outside this repository, in `~/.my-agent-kit/`. Skills create missing folders on first use. It is deliberately not under `~/.claude/`: Claude Code treats that folder as protected configuration, so every write there needs approval, and headless runs refuse it.

```
~/.my-agent-kit/
  deny-words.txt          words that must never enter this repository (read by scripts/check.sh)
  suite-log.md            problems with the kit, written by /my:improve note
  projects/<repo>.md      one profile per repository
  reviewers/<handle>.md   how a reviewer thinks, written by /my:learn review, read by /my:review-lens
  reads/                  PR readings written by /my:learn pr (header records the head commit)
  study/                  study pages, glossary.md and README.md (the index, with the comment ids studied)
  reviews/                review drafts written by /my:review-lens
  plans/                  plans written by /my:scope-plan --dry-run
  retros/                 one-page retrospective per finished change
```

## Project profile

Template: [templates/project-profile.md](../templates/project-profile.md). `<repo>` is the GitHub `owner-name` slug, for example `acme-web`.

`/my:scope-plan` creates the profile on first use. It reads the repository's agent instructions (`CLAUDE.md`, `AGENTS.md`), contributing guides, CI workflows and skills, then asks the user to confirm it. Any skill that finds a profile wrong offers `/my:improve note`, and `/my:improve run` can correct it.

## Reviewer profile

Template: [templates/reviewer-profile.md](../templates/reviewer-profile.md). It holds a reviewer's recurring lenses, their typical questions, and what they let pass. It is built from study pages, never from guesses.

## Suite log

One entry per problem, in the format of [templates/log-entry.md](../templates/log-entry.md). Entries are appended and never deleted. A fixed entry keeps its text and gains a `fixed <version>` status.
