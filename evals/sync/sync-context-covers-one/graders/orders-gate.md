---
type: regex
target:
  source: file
  path: decision.md
pattern: "orders\\.py[^\\n]*(gate|stop|ferm|attesa|wait|(be|va|da|to) decid|va decis|decision|scegli|domanda|question|option|opzion)"
flags: i
weight: 2
---
