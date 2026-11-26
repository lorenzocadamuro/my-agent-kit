---
name: go
description: "Route a request about a plan, a pull request or the kit to the skill that fits it, and open that skill."
disable-model-invocation: false
when: "any request about planning, running or reviewing a code change, a pull request and its comments, or the kit itself"
reads: [rules/core.md, skills/go/index.md]
---

# /my:go

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md` and `${CLAUDE_PLUGIN_ROOT}/skills/go/index.md`.

| Request | Skill |
| --- | --- |
| a plan request with no mode | `round` when a plan exists in the worktree; otherwise `scope`, said in one line |
| a PR request with no mode, or pasted comments | `comments` if the text is comments to answer, `learn` with a comment focus if the user wants to learn from them; otherwise ask which mode in one line |
