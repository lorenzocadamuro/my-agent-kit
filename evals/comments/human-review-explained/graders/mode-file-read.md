---
type: regex
target: trace
pattern: "\\{\"type\":\"assistant\"[^\\n]*?\"name\":\"(?:Read|Bash|Grep)\",\"input\":\\{\"(?:file_path|command|pattern|path)\":\"(?:[^\"\\\\]|\\\\.)*?(?:/skills/pr/comments(?:\\.md|/SKILL\\.md)|/rules(?:/|\\b(?:[^\"\\\\]|\\\\.)*?)review-lenses\\.md)"
weight: 1
---
