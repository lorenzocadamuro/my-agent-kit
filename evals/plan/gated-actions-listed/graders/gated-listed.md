---
type: regex
target: last_message
pattern: 'commit[\s\S]{0,500}(if you don.t|without (it|them|that|your)|senza( il tuo s[iì]|,| di)|se non (lo |li )?autorizz)[^\n]{0,200}(stop|ferm)'
flags: i
weight: 3
---
