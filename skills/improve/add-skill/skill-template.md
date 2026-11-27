# Skill template

A skill of this kit is one folder, `<area>/<name>/` under `skills/`, holding a `SKILL.md` in this shape and the templates or agent briefs only it uses. The area is one of the folders under `skills/` (`plan`, `pr`, `improve`, `writing`); a new area needs the user's yes.

```markdown
---
name: <name: lowercase words joined by hyphens, unique in the kit; the command is /my:<name>>
description: "<what it does, in one sentence the router and the README show>"
argument-hint: "<only when it takes arguments: their shape>"
disable-model-invocation: true
when: "\"/my:<name>\", <the phrases a user says when they want it>"
reads: [<the kit files it uses: rules files, a skill it applies; the same list as Read first>]
---
Source: <the link at a commit, or "pasted by the user on <date>">, <its license>; adapted: <each change from the source and why, or "none">.

# /my:<name> — <what it is for, in a few words>

Read first: `${CLAUDE_PLUGIN_ROOT}/<path>`, … and `${CLAUDE_PLUGIN_ROOT}/<path>`.

<The job in one or two sentences, then the inputs, then the steps. A rule that a `rules/` file already states is cited there, never restated.>

Reply: <what the reply holds, in one line>.
```

Checks the kit makes on it (`scripts/check.sh`):

- the five frontmatter fields, `disable-model-invocation: true` (only `go` is model-invoked), a unique `name`;
- `reads` and the "Read first:" line list the same files, and each exists;
- a workflow ends with its `Reply:` line;
- its folder is in the `skills` array of `.claude-plugin/plugin.json`, and `scripts/index.sh --write` has added it to `skills/go/index.md` and the README skill list.

A workflow also ends with the closing step (`rules/learning.md` § Closing step of every skill), unless that section exempts it. Text copied under a license keeps its notice in `THIRD_PARTY_NOTICES.md`.
