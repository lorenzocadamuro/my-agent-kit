# Evals

One folder per skill. Each case reproduces a problem the kit once had, or a promise a skill makes, so the behaviour stays fixed.

```
evals/<skill>/<case-name>/
  prompt.md        frontmatter + what the user types   (or case.yaml, below)
  graders/*.md     one grader per file; all must pass
  setup.sh         optional fixture script, only with case.yaml
```

`prompt.md` frontmatter keys: `max_turns`, `timeout_seconds`, `allowed_tools`, `env`, `model`, `runs`, `tags`, `append_system_prompt`.

A case that needs fixture files (an existing glossary, a log) uses `case.yaml` instead, and the run needs `--scaffold`:

```yaml
schema_version: "1"
name: <case-name>
context:
  scaffold_script: setup.sh      # runs in the case workspace before the prompt
execution:
  max_turns: 30
  allowed_tools: [Read, Glob, Grep, Bash, Write, Edit, Skill]
  prompt: |
    /my:<skill> ...
```

## Running

Always local-only, one run per case (2–3 for a noisy grader: `rules/verifying.md` § Verify, don't assume, "Stop and report"), with no spend cap: each release reports what it spent. `--ablation none` skips the no-plugin baseline, which doubles the cost and rarely helps here.

```bash
claude plugin eval <kit> --no-publish --runs 1 --trust-plugin \
  --ablation none --allow-tools Bash Write Edit --scaffold [--case '<glob>']
```

Without `--no-publish`, the report is uploaded to claude.ai. Results land in `evals/results/` (git-ignored).

## Graders

Frontmatter `type` is one of `regex`, `tool_order`, `tool_used`, `file_exists`, `llm` or `baseline`. Each grader also takes `weight` (default 1).

| Type | Fields | Use for |
| --- | --- | --- |
| `file_exists` | `path`, `exists` (default true) | an output file was (or was not) written |
| `tool_used` | `tool`, `input_match` (regex on the input), `min`, `max`, `arm` | "must not call X": `min: 0`, `max: 0`, `arm: both` |
| `tool_order` | `before`, `after` | step ordering |
| `regex` | `pattern`, `target`, `match` (`contains`, `not_contains`, `count:N`), `flags` | exact strings in output |
| `llm` | body = rubric; `focus` | judgement on content |

`target` and `focus` take `last_message` (default), `trace`, `files`, or a file:

```yaml
focus:
  source: file
  path: data/out.md
```

## Lessons

- The judge sees a truncated trace. For "never did X", use `tool_used`, not an `llm` grader with `focus: trace`.
- Point an `llm` grader at the file it judges (`focus: {source: file, ...}`) rather than at the transcript.
- Keep data out of the real `~/.my-agent-kit`: prompts name a local data root (for example `./kit-data`), which the skills honour.
- Sandboxed runs have no working `git` (the macOS xcrun shim is blocked) and no `gh` auth. Skills must degrade to `unknown`, not fail. For git-centric skills, the scaffold (which runs outside the sandbox) builds the repository and saves the git outputs the skill needs under `git-out/`; the prompt says to use them. Real git behaviour is covered by the trials, not the evals.
- `focus: files` shows only the list of written files, not their content. Have the prompt name the output file, and point the grader at it.
- `--case` takes one glob; repeating the flag keeps only the last one.
- LLM judges fail on long artifacts, even with a trivial rubric. Check facts with `regex` graders (`target: {source: file, path}`, `flags: is`), and keep `llm` graders for short files or the last message.
- `input_match` matches the whole tool input, content included. Anchor it on the field you mean, for example `"file_path":\s*"[^"]*/skills/`.
- A case must be able to fail. Write it against the problem first, then fix the skill.
- Each grader works on both sides before it counts, on samples its author did not choose alone: it fails the note's own wrong answer (one that restates the bug, or leaves out the one thing checked) and passes correct answers in other words from kept runs (`--keep-temp`) of the new version, and of the old one where it already behaved (a heading in between, another language, a pretty-printed file); a kept run of the old version that failed is a wrong sample. Hand-written samples only add to these, and the fresh review tries each new grader on samples of its own. Try a regex with the flags the harness uses (JavaScript RegExp: no inline `(?s)` or `(?i)`; use `flags`). An `llm` judge gives no reasons: prefer regexes on the facts.
