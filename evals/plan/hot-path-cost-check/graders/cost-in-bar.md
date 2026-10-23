---
type: regex
target: {source: file, path: plan.md}
pattern: "\\n#+ *Bar for done(?:(?!\\n#+ )[\\s\\S])*?(\\bcost|performance|complexit|quadratic|O\\(n|benchmark|timing|time budget|\\d+ ?ms\\b|perf_counter|timeit)"
flags: i
weight: 3
---
