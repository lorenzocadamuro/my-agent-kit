---
# unslop rule 20: no chatbot phrases, such as a closer that offers more help ("I'm happy to ...", "Let me know if ..."). An ending open to the colleague's view ("Which do you prefer?") passes.
type: regex
target: {source: file, path: reply.md}
pattern: "\\bhappy to\\b|\\blet me know if\\b|\\bhope this helps\\b|\\bfeel free to\\b"
flags: i
match: not_contains
weight: 2
---
