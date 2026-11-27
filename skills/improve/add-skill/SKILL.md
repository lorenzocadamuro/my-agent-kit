---
name: add-skill
description: "Add a skill to the kit from a pasted text or a link: look for an existing skill with the same job and for conflicts with the constitution, then adapt it to the kit's template with its source and an eval case, and ship it after your yes."
argument-hint: "<pasted skill text | link>"
disable-model-invocation: true
when: "\"/my:add-skill\", \"add this skill to the kit\", \"import this skill\""
reads: [rules/core.md, rules/learning.md, rules/verifying.md, rules/worker.md, rules/repository.md, rules/kit-data.md, rules/asking.md, rules/reviewing.md, rules/models.md, rules/writing-for-agents.md, CONSTITUTION.md]
---

# /my:add-skill — bring a skill into the kit

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md`, `${CLAUDE_PLUGIN_ROOT}/rules/learning.md`, `${CLAUDE_PLUGIN_ROOT}/rules/verifying.md`, `${CLAUDE_PLUGIN_ROOT}/rules/worker.md`, `${CLAUDE_PLUGIN_ROOT}/rules/repository.md`, `${CLAUDE_PLUGIN_ROOT}/rules/kit-data.md`, `${CLAUDE_PLUGIN_ROOT}/rules/asking.md`, `${CLAUDE_PLUGIN_ROOT}/rules/reviewing.md`, `${CLAUDE_PLUGIN_ROOT}/rules/models.md`, `${CLAUDE_PLUGIN_ROOT}/rules/writing-for-agents.md` and `${CLAUDE_PLUGIN_ROOT}/CONSTITUTION.md`.

How the kit changes: `${CLAUDE_PLUGIN_ROOT}/rules/learning.md` § The kit's improvement loop.

It works and ships as `/my:improve run` does. Read `${CLAUDE_PLUGIN_ROOT}/skills/improve/improve/SKILL.md` § Run and follow its step 1 (preflight), its constitution check (step 3, first bullet) and its steps 5 to 7 (the kit worktree, eval first, the gates, the record, the fresh review, and the ship only after the user's yes), with the steps below as the change; its activity sidecar follows improve's **Activity** paragraph (§ Run), with mode `improve:add-skill`. `<kit>` below is the kit worktree of step 5.

1. **Read the candidate:** the pasted text, or the link, read-only (a repository file through `gh api` at a commit). Save it in the session scratchpad. Note its source (the link at that commit, or "pasted by the user") and its license.
2. **Check it against the constitution,** as that constitution check says, for each thing the candidate does or tells an agent to do. When one contradicts a clause or a "What the kit must not become" bullet, stop and write nothing: quote the candidate's line, name the clause, and say that only the user can amend the constitution.
3. **Look for the same job.** Run `${CLAUDE_PLUGIN_ROOT}/scripts/skill-overlap.sh --root ${CLAUDE_PLUGIN_ROOT} <candidate file>` (steps 1 to 3 run before improve's step 5 creates the kit worktree), and read the skills it ranks first. A shared word is not the same job: the same job means the same input and the same result for the user. When an existing skill does the candidate's job, write nothing and ask one question (`rules/asking.md`), naming that skill: integrate (its useful parts go into the existing skill, as a `/my:improve run` change), improve (the existing skill stays and takes only what the candidate does better), or add (a separate skill whose `when` says how the two differ). Otherwise say in one line which skill came closest and why its job differs.
4. **Adapt it** in `<kit>`, to `skill-template.md` (next to this file): its folder in the area the user named or the one its job fits, the frontmatter, the Source line with each adaptation, the "Read first:" line equal to `reads`, the closing step, the `Reply:` line; a rule a `rules/` file states is cited, not restated. Apply `${CLAUDE_PLUGIN_ROOT}/rules/writing-for-agents.md` to the text. Text copied under a license gets its notice in `THIRD_PARTY_NOTICES.md`. Add the folder to the `skills` array of `.claude-plugin/plugin.json` and run `${CLAUDE_PLUGIN_ROOT}/scripts/index.sh --write <kit>`.
5. **Its eval case,** from `eval-template.md` (next to this file), on the skill's main promise.
6. **Make `<kit>/scripts/check.sh` pass,** then go on with the gates, the record (a new skill is a minor version) and the ship question of `/my:improve run`, showing the diff.

## Rules

- Never edit `CONSTITUTION.md`, and never ship without the user's yes on the diff.
- Generic content only: a candidate's employer, project or people names stay out of the kit (`.claude/CLAUDE.md` of the kit).

Reply: the stop and its clause, the question with the existing skill it names, or the added skill with its folder, its case, the diff and the ship question.
