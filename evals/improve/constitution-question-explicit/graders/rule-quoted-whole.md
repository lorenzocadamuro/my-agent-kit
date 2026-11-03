---
type: regex
target: last_message
pattern: '(solo|soltanto|unicamente|only)[^\n]{0,20}(a mano|by hand|manualmente|manually)(?![^\n]{0,60}(richiesta|request|chied|ask))'
match: not_contains
flags: i
weight: 2
---
