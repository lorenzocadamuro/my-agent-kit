---
type: regex
target: {source: file, path: wt/.plans/round-2.md}
pattern: "^(?=[^\\n]*(surviv|kept|\\bkeeps?\\b|stays|remain|not\\W{0,4}deleted|isn.t\\W{0,4}deleted|never\\W{0,4}deleted))[^\\n]*(unsaved|uncovered|\\bnot\\W{0,4}(yet\\s+)?(saved|covered)|\\bno\\s+(covering\\s+)?save\\b|without\\s+(a\\s+|any\\s+)?(covering\\s+)?save|never\\s+saved|isn.t\\W{0,4}(covered|saved)|covers\\W*\\s*(only|is\\s+false|returns\\s+false|false))"
flags: im
weight: 3
---
