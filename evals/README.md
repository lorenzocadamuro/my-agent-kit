# Evals

The smoke set: the cases listed in § Smoke set, each one proven to need its rule, because a mutant of the kit (its text without that rule) was run and the case failed there. It holds 18 cases at 8.4.0. It runs once at each release, not at each change.

```
evals/<skill>/<case-name>/
  prompt.md        frontmatter + what the user types   (or case.yaml, below)
  graders/*.md     one grader per file; all must pass
  setup.sh         optional fixture script, only with case.yaml
```

A skill needs no folder here: only the skills with a smoke case have one.

## Smoke set

One `<skill>/<case>` line per case, in the code block between the `smoke:start` and `smoke:end` markers. `scripts/check.sh` reads the lines between the markers (the fence lines and blank lines apart) and fails when a case folder under `evals/` is not listed, or when a listed case has no folder. Run output (`results/`, `runs/`) is not a case.

<!-- smoke:start -->
```text
add-skill/constitution-conflict-stops
add-skill/same-job-asks
comments/reply-unslopped
go/routes-plan-request
go/routes-review-request
profile/profile-built-from-sources
run/decision-updates-plan
run/failed-step-recorded
run/gate-answer-moves-state
run/mid-part-review-conformance
run/part-end-review-lenses
run/ready-step-skips-check
run/round-digest-writes-note
run/round-review-conformance
run/short-title-fits
scope/profile-refreshes-changed-source
unslop/text-unslopped
wait-what/re-pitch-adds-premise
```
<!-- smoke:end -->

## Running

Once at each release, before the ship question, on the release's head. It takes about 8 minutes and $12 (measured 2026-11-27: 18 cases, $12.10, 472 s).

```bash
claude plugin eval . --no-publish --runs 1 --trust-plugin --ablation none \
  --allow-tools Bash Write Edit --scaffold -j 4 --json --keep-temp
```

Always local: without `--no-publish`, the report is uploaded to claude.ai. `--ablation none` skips the no-plugin baseline, which doubles the cost. `--case '<glob>'` runs one case (it takes one glob; repeating the flag keeps only the last one). Results land in `evals/results/` (git-ignored).

- **The rerun rule.** Each case runs once; a case that passes has passed. A case that fails runs twice more and passes at 2 of 3. This overrides `rules/verifying.md` § Verify, don't assume (a noisy check "runs 2–3 times before it is called passed or failed") for a passing smoke case only: a choice made when the smoke set replaced the full suite, for its cost, and because each of the 18 passed every recorded run.
- **A case that fails on unchanged text in two releases leaves the set:** remove its folder and its line. Its grader is never widened to make it pass.

## A new case

Only for a behaviour a small fixture can reach. Otherwise there is no case, and the review checks the wording.

The mutant is the kit's text without the behaviour: for a new rule, the text before the change; for an existing rule, the text with the rule removed from every place that states it.

1. Write the case.
2. Run it on the mutant. Keep it only if it fails there; if it passes, delete it and let the review check the wording.
3. Run it on the changed text, by the rerun rule.
4. Add its line to § Smoke set, in the same commit as its folder: `scripts/check.sh` fails without it.

A plan names a case only after its mutant run. Graders are fact graders (`regex`, `file_exists`, `tool_used`, `tool_order`): a new case has no `llm` grader.

## CHANGELOG

Each release has one line `Smoke set: N of N, $X`. A new case lists its counts before the change and on the mutant (one run when the rule is new, since its mutant is the text before the change).

## Graders

Frontmatter `type` is one of `regex`, `tool_order`, `tool_used`, `file_exists`, `llm` or `baseline`. Each grader also takes `weight` (default 1).

| Type | Fields | Use for |
| --- | --- | --- |
| `file_exists` | `path`, `exists` (default true) | an output file was (or was not) written |
| `tool_used` | `tool`, `input_match` (regex on the input), `min`, `max`, `arm` | "must not call X": `min: 0`, `max: 0`, `arm: both` |
| `tool_order` | `before`, `after` | step ordering |
| `regex` | `pattern`, `target`, `match` (`contains`, `not_contains`, `count:N`), `flags` | exact strings in output |
| `llm` | body = rubric; `focus` | only in `wait-what/re-pitch-adds-premise`; a new case has none |

`target` and `focus` take `last_message` (default), `trace`, `files`, or a file:

```yaml
target:
  source: file
  path: data/out.md
```

`prompt.md` frontmatter keys: `max_turns`, `timeout_seconds`, `allowed_tools`, `env`, `model`, `runs`, `tags`, `append_system_prompt`.

A case that needs fixture files (an existing glossary, a log) uses `case.yaml` instead, and the run needs `--scaffold` (17 of the 18 do):

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

## Lessons

- The judge sees a truncated trace. For "never did X", use `tool_used`.
- `input_match` matches the whole tool input, content included. Anchor it on the field you mean, for example `"file_path":\s*"[^"]*/skills/`.
- Check facts in a file with `regex` graders (`target: {source: file, path}`, `flags: is`). `focus: files` shows only the list of written files, not their content: have the prompt name the output file, and point the grader at it.
- The one `llm` grader left, in `wait-what/re-pitch-adds-premise`, judges the last message only: LLM judges failed on long artifacts, even with a trivial rubric, and give no reasons.
- Keep data out of the real `~/.my-agent-kit`: prompts name a local data root (for example `./kit-data`), which the skills honour. A case may use the eval home's default data root instead when its `setup.sh` refuses any folder outside the eval home, as `wait-what/re-pitch-adds-premise` does.
- Sandboxed runs have no working `git` (the macOS xcrun shim is blocked) and no `gh` auth. Skills must degrade to `unknown`, not fail. For git-centric skills, the scaffold (which runs outside the sandbox) builds the repository and saves the git outputs the skill needs under `git-out/`; the prompt says to use them. Real git behaviour is covered by the trials, not the evals.
- Each grader works on both sides before it counts, on samples its author did not choose alone: it fails the mutant's run and the note's own wrong answer (one that restates the bug, or leaves out the one thing checked), and passes correct answers in other words from kept runs (`--keep-temp`) of the changed text (a heading in between, another language, a pretty-printed file). Hand-written samples only add to these, and the fresh review tries each new grader on samples of its own. Try a regex with the flags the harness uses (JavaScript RegExp: no inline `(?s)` or `(?i)`; use `flags`).
