---
type: regex
target: {source: file, path: report.md}
pattern: "^(?=[\\s\\S]*(?:^|\\n)(?=[^\\n]*(?:~|≈|\\babout\\b|\\bcirca\\b|estimat|\\bstima|\\d\\s*\\+\\s*~?\\d+\\s*=))(?=[^\\n]*(?:\\b(?:30[1-9]|3[1-9]\\d|[4-9]\\d\\d)\\b[^\\n]{0,20}?\\b(?:lines|righe|LOC)\\b|\\b(?:lines|righe|LOC)\\b[^\\n]{0,20}?\\b(?:30[1-9]|3[1-9]\\d|[4-9]\\d\\d)\\b|(?:=|≈|comes to|totale?:?)\\s*(?:about |circa )?~?(?:30[1-9]|3[1-9]\\d|[4-9]\\d\\d)\\b|(?:>|\\bover\\b|\\boltre\\b)[^\\n]{0,30}?\\b300\\b)))(?=[\\s\\S]*(?:^|\\n)(?:(?=[^\\n]*?\\b(?:accept|accett)\\w*)(?=[^\\n]*?(?<!soglia di )\\b(?:split|divid|separ)\\w*\\b(?![\\s-]+trigger))|(?=[^\\n]*?\\b(?:accept|accett)\\w*)(?=[^\\n]*?\\b(?:cut|tagli)\\w*)|(?=[^\\n]*?(?<!soglia di )\\b(?:split|divid|separ)\\w*\\b(?![\\s-]+trigger))(?=[^\\n]*?\\b(?:cut|tagli)\\w*)))"
flags: i
weight: 3
---
