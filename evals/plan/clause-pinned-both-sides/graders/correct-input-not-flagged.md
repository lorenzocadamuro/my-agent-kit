---
type: regex
target: {source: file, path: wt/.plans/round-3.md}
pattern: "^(?:[ \\t]*(?:[-*+]|\\d+\\.)?[ \\t]*(?:\\*\\*|`)?(?:tests?\\b|test_\\w+|tests?\\s+first|pin\\w*|clause\\w*|clausol\\w*|invariant\\w*|I\\d\\b|boundary|confine|negative|positive|failure|error|edge)|\\|(?=[^\\n]*\\btest_))(?:[^\\n]|\\n[ \\t]+(?:[-*+]|\\d+\\.)\\s)*?(\\b(not|never|non|mai)\\b\\W{0,6}(be\\s+|get\\s+|viene\\s+|venga\\s+|vengono\\s+|essere\\s+)?(flag\\w*|segnal\\w*|report\\w*|returned|restituit\\w*)|\\bunflagged\\b|\\b(no|zero|nessun\\w*)\\s+(finding|flag|violation|segnalazion\\w*|line\\s+number|riga)|\\blet\\w*\\s+(it\\s+|them\\s+)?through|lascia\\w*\\s+passare|returns?\\s+(\\[\\]|an?\\s+empty|nothing)|restituisc\\w*\\s+(\\[\\]|una\\s+lista\\s+vuota|niente)|→\\s*\\[\\]|==\\s*\\[\\]|\\bfalse\\s+positive|\\bfalsi\\s+positivi|\\btest_\\w*(through|not_flag\\w*|no_flag\\w*|ignor\\w*|allow\\w*|skip\\w*|accept\\w*|keeps?_clean|clean|reference\\w*|refs?)\\b)"
flags: im
weight: 3
---
