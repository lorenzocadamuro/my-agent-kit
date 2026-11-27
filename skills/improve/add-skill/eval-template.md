# Eval case template

A new skill gets a smoke case, on its main promise, in `evals/<name>/<case>/`, only when a small fixture reaches that promise and the case fails on its mutant, the kit without the skill (`evals/README.md` § A new case; it also has the grader types and the lessons). Otherwise it gets no case, and the review checks its wording. The case is generic: no employer, project or person names.

```
evals/<name>/<case>/
  case.yaml
  setup.sh          the fixture files the prompt needs, and a ./kit-data data root
  graders/<fact>.md one fact per grader
```

```yaml
schema_version: "1"
name: <case>
context:
  scaffold_script: setup.sh
execution:
  max_turns: 30
  allowed_tools: [Read, Glob, Grep, Bash, Write, Edit, Skill]
  prompt: |
    /my:<name> <what the user types> — use ./kit-data as the data root for this test. Git does not run here.
```

```markdown
---
type: regex
target: last_message
pattern: "<the fact the reply must hold>"
flags: i
weight: 2
---
```

Before it counts:

- it fails on its mutant, the kit without the skill; when it passes there, delete it: the skill has no case;
- it passes on the kit with the skill, by the rerun rule of `evals/README.md` § Running;
- its line is in `evals/README.md` § Smoke set, in the same commit as its folder;
- each grader fails a wrong answer and passes a correct one in other words (`evals/README.md` § Lessons).
