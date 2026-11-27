---
# unslop rule 22: no praise or agreement openers. The input opens by thanking for "the great feedback"; fails when the first sentence of out.md, after any heading, still thanks, praises or agrees.
type: regex
target: {source: file, path: out.md}
pattern: "^(?:\\s*#[^\\n]*\\n)*\\s*[^.!?\\n]*\\b(?:thanks|thank you|great|good (?:point|catch|question|idea|suggestion|feedback)|you(?:'|’)?re (?:right|correct)|agreed|fair point|appreciate|excellent)\\b"
flags: i
match: not_contains
weight: 1
---
