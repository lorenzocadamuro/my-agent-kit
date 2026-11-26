---
name: go
description: "Route a request about the my kit's work to the skill that fits it, and open that skill: planning or running a code change (\"plan ENG-123\", \"run the plan\"), understanding, reviewing or answering a pull request (\"review this PR\", \"explain these comments\"), merging main into a branch, or noting and improving the kit itself."
disable-model-invocation: false
when: "any request about planning, running or reviewing a code change, a pull request and its comments, or the kit itself"
reads: [rules/core.md, skills/go/index.md]
---

# /my:go — one door to the kit

Read first: `${CLAUDE_PLUGIN_ROOT}/rules/core.md` and `${CLAUDE_PLUGIN_ROOT}/skills/go/index.md`.

Every other skill is user-invoked: this router picks one and opens its file. The index lists each skill with its command, its file, what it does and when it fits.

1. **The running plan's own work goes to the plan.** When a plan in the worktree's `.plans/plan.md` is approved and not done, and the request is part of its work ("implement part B", the work left after a gate), it becomes a round, as `${CLAUDE_PLUGIN_ROOT}/rules/plan-contract.md` § The kit carries the plan it made says: pick `round`, with that work as its source.
2. **Otherwise pick from the index** the skill whose "When" fits the request. A request that names no mode follows the table below.
3. **When two skills fit and lead to different work,** ask the user which one, as `${CLAUDE_PLUGIN_ROOT}/rules/core.md` § Questions the user can answer says, and wait.
4. **Open the chosen skill:** read its file, `${CLAUDE_PLUGIN_ROOT}/<file from the index>`, and follow it, with the request as its arguments. Never start it with the Skill tool: a user-invoked skill refuses it.

| Request | Skill |
| --- | --- |
| a plan request with no mode | `round` when a plan exists in the worktree; otherwise `scope`, said in one line |
| a PR request with no mode, or pasted comments | `comments` if the text is comments to answer, `learn` with a comment focus if the user wants to learn from them; otherwise ask which mode in one line |
