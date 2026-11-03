---
type: regex
target: {source: file, path: wt/.plans/round-3.md}
pattern: "^(?:[ \\t]*(?:[-*+]|\\d+\\.)?[ \\t]*(?:\\*\\*|`)?(?:tests?\\b|test_\\w+|tests?\\s+first|pin\\w*|clause\\w*|clausol\\w*|invariant\\w*|I\\d\\b|boundary|confine|negative|positive|failure|error|edge)|\\|(?=[^\\n]*\\btest_))(?:[^\\n]|\\n[ \\t]+(?:[-*+]|\\d+\\.)\\s)*?(FetchError|(?<![_\\w])(fetch|fetch_text|rules\\s+fetch|download)\\b[^\\n]{0,60}?\\b(rais\\w*|throw\\w*|time[sd]?\\s?out|timeout|fail(s|ing|ed)?(?!\\s+(without|when|if|before|unless|on\\s+main|senza|se|quando|prima))|errors?|fallisc\\w*|fallit\\w*|scade|unreachable|irraggiungibil\\w*|down)\\b|\\b(failing|failed|fallit\\w*|broken|timed[- ]out)\\s+(rules\\s+)?(fetch|download)|time[sd]?\\s?out|timeout|network\\s+error|errore\\s+di\\s+rete|unreachable|irraggiungibil\\w*|\\btest_\\w*(fetch\\w*_(fail\\w*|error\\w*|rais\\w*|times?_?out|timeout|down)|(fail\\w*|error\\w*|broken|timeout|unreachable)\\w*_(fetch|rules)))"
flags: im
weight: 3
---
