# my-agent-kit

A Claude Code plugin named `my`: a personal suite of workflow skills. Read [README.md](../README.md) for what each skill does and the files of [rules/](../rules/) for the rules they share.

## Rules for editing this repository

- **`CONSTITUTION.md` changes only by hand or at the user's explicit request.** It wins over every other rule, the principles included. An amendment writes its reason in the `CHANGELOG.md` and puts "Amend constitution" in the commit message; the `commit-msg` hook blocks it otherwise. Agents never write that phrase on their own.
- **English only** in skills, rules, templates and commit messages.
- **Generic content only.** No employer, project, ticket, pull request or colleague names. Personal and employer-specific material lives in `~/.my-agent-kit/`, never here. `scripts/check.sh` enforces this.
- **Shared rules live in `rules/`.** Skills reference those files through `${CLAUDE_PLUGIN_ROOT}/rules/<file>.md`, listed in their `reads` field and their "Read first:" line, instead of restating them. Before adding a rule to a skill, check whether it belongs in `rules/`, and whether an existing rule can be merged or removed.
- **Keep skills short.** A skill states its job, its inputs, its steps and its output. Long reference material goes in a supporting file next to the SKILL.md.
- **Every change ships with its record:** the README skills table and text, the skill index (`scripts/index.sh --write` after a frontmatter change), a `CHANGELOG.md` entry, and a version bump in `.claude-plugin/plugin.json` following the versioning rules in the README.
- **A behaviour change that a small fixture can reach gets a smoke case, written first, whose mutant fails.** Other behaviour changes get a script test, or the review checks the wording.
- **Before each release, the smoke set passes** (`evals/README.md` § Running).
- **Run `scripts/check.sh` before committing.** The pre-commit hook runs it too.
- **Never commit or push without the user's approval.** Show the diff first.
