---
# unslop rule 22: no praise or agreement openers. Fails when the first sentence, after any heading, thanks, praises or agrees.
type: regex
target: {source: file, path: reply.md}
pattern: "^(?:\\s*#[^\\n]*\\n)*\\s*[^.!?\\n]*\\b(?:thanks|thank you|great (?:point|question|catch|suggestion|idea)|good (?:point|catch|question|idea|suggestion)|you(?:'|’)?re (?:right|correct)|agreed|fair point|appreciate|excellent|nice catch)\\b"
flags: i
match: not_contains
weight: 2
---
