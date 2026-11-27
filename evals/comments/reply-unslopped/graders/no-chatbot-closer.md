---
# unslop rule 20: no chatbot phrases, such as a closer that offers more help ("I'm happy to ...", "Let me know if ...", "If you'd rather, I can switch it"). An ending open to the colleague's view ("Which do you prefer?") passes.
type: regex
target: {source: file, path: reply.md}
pattern: "\\bhappy to\\b|\\blet me know if\\b|\\bhope this helps\\b|\\bfeel free to\\b|\\bI(?:'ll|’ll|\\s+can|\\s+could|\\s+will)\\s+(?:also\\s+|then\\s+|gladly\\s+)?(?:switch|change|rework|update|adjust|move|make|do|go|send|push|open|add|share|walk|take|follow|help)\\b(?:(?!\\n\\s*\\n\\s*\\S)[\\s\\S])*$"
flags: i
match: not_contains
weight: 2
---
