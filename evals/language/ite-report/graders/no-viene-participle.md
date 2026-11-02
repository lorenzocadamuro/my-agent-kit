---
type: regex
# ite-check.py's passive rule: an auxiliary of "venire", an optional adverb, then a participle.
pattern: '(?<![a-zà-ÿ])(?:viene|vengono|veniva|venivano|verrà|verranno|venne|vennero)\s+(?:(?:subito|già|sempre|poi|anche|[a-zà-ÿ]+mente)\s+)?[a-zà-ÿ]*(?:at|it|ut|scritt|lett|apert|chius|mess|fatt|pres|dett|scelt|risolt|inclus|esclus|corrett|rimoss|moss|spent|acces|vist|rott|tolt|aggiunt|richiest|decis|post|dott|condivis|chiest|copert|offert)[oaie](?![a-zà-ÿ])'
flags: i
match: not_contains
weight: 1
---
