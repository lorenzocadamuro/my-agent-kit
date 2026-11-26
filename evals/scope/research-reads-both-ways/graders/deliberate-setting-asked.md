---
type: regex
target: {source: file, path: plan.md}
pattern: "(optimistic[_ ]?cancel|optimistic stop|pessimistic cancel|cancel(lation)? ottimistic\\w*)[^\\n]{0,240}(keep|kept|unchanged|stays|resta|mantien\\w*|invariat\\w*|question|domanda|on purpose|di proposito|deliberat\\w*|guard|pinned|double[- ]refund|doppi rimborsi|fails|\\b[AD]\\d+\\b)|(keep|kept|unchanged|resta|mantien\\w*|on purpose|di proposito|deliberat\\w*|changing|cambiare)[^\\n]{0,240}(optimistic[_ ]?cancel|optimistic stop)|double[- ]refund guard"
flags: i
weight: 3
---
