# Eval case template

A new skill gets at least one case, on its main promise, in `evals/<name>/<case>/` (`evals/README.md` has the grader types and the lessons). The case is generic: no employer, project or person names.

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

- it fails before the skill exists, and on a mutant: the skill's text with the line it guards removed;
- it passes on the skill, 2 runs of 3;
- each grader fails a wrong answer and passes a correct one in other words (`evals/README.md` § Lessons).
