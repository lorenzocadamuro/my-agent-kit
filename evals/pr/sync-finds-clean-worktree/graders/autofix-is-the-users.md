---
type: regex
target: trace
pattern: "\\{\"type\":\"assistant\"[^\\n]*?\"type\":\"text\",\"text\":\"(?:[^\"\\\\]|\\\\.)*?(?:(?:only\\s+you|solo\\s+tu|you\\s+(?:need|have|must|can|will\\s+need|'ll\\s+need)|devi|dovrai|tocca\\s+a\\s+te|spetta\\s+a\\s+te)(?:[^\"\\\\]|\\\\.){0,200}?auto-?fix|auto-?fix(?:[^\"\\\\]|\\\\.){0,200}?(?:only\\s+you|solo\\s+tu|you\\s+(?:need|have|must|can|will\\s+need|'ll\\s+need)|devi|dovrai|tocca\\s+a\\s+te|spetta\\s+a\\s+te|da\\s+te|by\\s+you|yourself|tu\\s+stess[oa]|\\btu\\b|manually|manualmente))"
flags: i
weight: 2
---
