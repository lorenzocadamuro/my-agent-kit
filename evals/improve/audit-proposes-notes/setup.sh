#!/usr/bin/env bash
# A small kit to audit (./kit): one skill written as a list of prohibitions, one written as steps;
# and a data root (./kit-data) with an empty suite log.
set -euo pipefail
mkdir -p kit-data kit/.claude-plugin kit/skills/pr/tidy kit/skills/pr/label
printf '# Suite log\n' > kit-data/suite-log.md
printf '{ "name": "my", "version": "2.0.0", "skills": ["./skills/pr/tidy", "./skills/pr/label"] }\n' > kit/.claude-plugin/plugin.json
cat > kit/skills/pr/tidy/SKILL.md <<'P'
---
name: tidy
description: "Tidy the imports of the files a branch changes."
disable-model-invocation: true
when: "\"/my:tidy\", \"tidy the imports\""
reads: []
---

# /my:tidy

Never touch a file the branch does not change. Don't reorder anything except imports. Do NOT add new imports.
Never remove an import that a side effect needs. Don't run the formatter on the whole repository. Never
commit. Do not push. Don't ask the user anything. Never leave a blank line between import groups unless
the project does. Do not explain what you changed. NEVER touch generated files.

Reply: the files tidied.
P
cat > kit/skills/pr/label/SKILL.md <<'P'
---
name: label
description: "Suggest labels for a pull request from the files it changes."
disable-model-invocation: true
when: "\"/my:label\", \"which labels fit this PR\""
reads: []
---

# /my:label

1. List the files the pull request changes.
2. Map each top-level folder to the label the repository's label list gives it.
3. Propose the labels, one line each, with the folder that earned it.

Reply: the proposed labels, each with its folder.
P
