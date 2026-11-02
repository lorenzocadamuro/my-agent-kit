# my-agent-kit

A Claude Code plugin named `my`: a personal suite of workflow skills. Read [README.md](../README.md) for what each skill does and [docs/principles.md](../docs/principles.md) for the rules they share.

## Rules for editing this repository

- **`CONSTITUTION.md` changes only by hand or at the user's explicit request.** It wins over every other rule, the principles included. An amendment writes its reason in the `CHANGELOG.md` and puts "Amend constitution" in the commit message; the `commit-msg` hook blocks it otherwise. Agents never write that phrase on their own.
- **English only** in skills, docs, templates and commit messages. The ITE files of `mods/my-language` hold Italian on purpose: the examples in `output-styles/ITE.md`, and the ITE checker's word lists and test samples under `mods/my-language/scripts/`.
- **Generic content only.** No employer, project, ticket, pull request or colleague names. Personal and employer-specific material lives in `~/.my-agent-kit/`, never here. `scripts/check.sh` enforces this.
- **Shared rules live in `docs/principles.md`.** Skills reference that file through `${CLAUDE_PLUGIN_ROOT}/docs/principles.md` instead of restating it. Before adding a rule to a skill, check whether it belongs in the principles, and whether an existing rule can be merged or removed.
- **Keep skills short.** A skill states its job, its inputs, its steps and its output. Long reference material goes in a supporting file next to the SKILL.md.
- **Every change ships with its record:** the README skills table and text, a `CHANGELOG.md` entry, and a version bump in `.claude-plugin/plugin.json` following the versioning rules in the README.
- **A behaviour change needs an eval case** in `evals/<skill>/` that fails before the change and passes after it.
- **Run `scripts/check.sh` before committing.** The pre-commit hook runs it too.
- **Never commit or push without the user's approval.** Show the diff first.
