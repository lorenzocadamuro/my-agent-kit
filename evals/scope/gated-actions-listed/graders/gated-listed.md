---
type: regex
target: last_message
pattern: 'commit[\s\S]{0,500}((if you don.t|without|senza|se non)[^\n]{0,200}(stop|ferm)|(if you don.t|without|senza|se non)[^\n.,;:]{0,30}((il\s+tuo|il|tuo|your|the)\s+(sì|yes|approv\w*|consenso|ok)|(questi|these|i\s+due|the\s+two|quei|those)\s+commit)[^\n]{0,200}(rest\w*\s+apert|riman\w*\s+apert|non\s+gira|remains?\s+open|stays?\s+open|(does\s+not|doesn.t|won.t|will\s+not)\s+run))'
flags: i
weight: 3
---
