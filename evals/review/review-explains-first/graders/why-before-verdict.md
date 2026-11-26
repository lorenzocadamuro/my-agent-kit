---
type: regex
target: {source: file, path: review.md}
pattern: "^(?:(?!verdict|verdetto|ready to merge|ready for merge|not ready|mergeable|pront[ao]\\s+(?:per\\s+il|al|a\\s+essere|da)\\s+merg|non\\s+(?:è\\s+)?pront[ao]|si\\s+può\\s+(?:mergiare|fare\\s+(?:il\\s+)?merge)|approvabile)[\\s\\S])*?\\b(?:accounting|contabil\\w*|export\\w*|finance|reconcil\\w*|riconcil\\w*|by\\s+hand|a\\s+mano|disagree\\w*|discrepan\\w*|non\\s+coincid\\w*|mismatch\\w*|cents?|centesim\\w*)\\b(?:(?!verdict|verdetto|ready to merge|ready for merge|not ready|mergeable|pront[ao]\\s+(?:per\\s+il|al|a\\s+essere|da)\\s+merg|non\\s+(?:è\\s+)?pront[ao]|si\\s+può\\s+(?:mergiare|fare\\s+(?:il\\s+)?merge)|approvabile)[\\s\\S])*?(?:verdict|verdetto|ready to merge|ready for merge|not ready|mergeable|pront[ao]\\s+(?:per\\s+il|al|a\\s+essere|da)\\s+merg|non\\s+(?:è\\s+)?pront[ao]|si\\s+può\\s+(?:mergiare|fare\\s+(?:il\\s+)?merge)|approvabile)"
flags: i
weight: 2
---
