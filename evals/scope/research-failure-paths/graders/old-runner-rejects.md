---
type: regex
target: {source: file, path: plan.md}
pattern: "(1\\.4\\.0|deployed runner|runner (in produzione|deployato|attuale|già deployato)|old(er)? runner|runner (vecchio|precedente)|version skew|skew)[^\\n]{0,300}(422|reject|refus|rifiut|forbid|unknown field|campo sconosciuto)|(422|reject|refus|rifiut)[^\\n]{0,300}(1\\.4\\.0|deployed runner|old(er)? runner|runner (in produzione|deployato|vecchio|precedente))|(deploy|release|rilasci)[^\\n]{0,120}runner[^\\n]{0,120}(first|before the server|prima del server|prima)|runner[^\\n]{0,40}(release|deploy|rilascio)[^\\n]{0,120}(before|first|prima)[^\\n]{0,80}server"
flags: i
weight: 3
---
