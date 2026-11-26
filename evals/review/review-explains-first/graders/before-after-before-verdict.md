---
type: regex
target: {source: file, path: review.md}
pattern: "^(?:(?!verdict|verdetto|ready to merge|ready for merge|not ready|mergeable|pront[ao]\\s+(?:per\\s+il|al|a\\s+essere|da)\\s+merg|non\\s+(?:è\\s+)?pront[ao]|si\\s+può\\s+(?:mergiare|fare\\s+(?:il\\s+)?merge)|approvabile)[\\s\\S])*?\\b(?:before|prima|today|oggi|currently|finora|until\\s+now|fino\\s+ad?\\s+(?:ora|oggi)|in\\s+passato)\\b(?:(?!verdict|verdetto|ready to merge|ready for merge|not ready|mergeable|pront[ao]\\s+(?:per\\s+il|al|a\\s+essere|da)\\s+merg|non\\s+(?:è\\s+)?pront[ao]|si\\s+può\\s+(?:mergiare|fare\\s+(?:il\\s+)?merge)|approvabile)[\\s\\S])*?\\b(?:after|dopo|with\\s+(?:this|the)\\s+(?:pr|change)|con\\s+(?:questa|la)\\s+(?:pr|modifica)|now|ora|adesso|from\\s+now\\s+on|d'ora\\s+in\\s+poi)\\b(?:(?!verdict|verdetto|ready to merge|ready for merge|not ready|mergeable|pront[ao]\\s+(?:per\\s+il|al|a\\s+essere|da)\\s+merg|non\\s+(?:è\\s+)?pront[ao]|si\\s+può\\s+(?:mergiare|fare\\s+(?:il\\s+)?merge)|approvabile)[\\s\\S])*?(?:verdict|verdetto|ready to merge|ready for merge|not ready|mergeable|pront[ao]\\s+(?:per\\s+il|al|a\\s+essere|da)\\s+merg|non\\s+(?:è\\s+)?pront[ao]|si\\s+può\\s+(?:mergiare|fare\\s+(?:il\\s+)?merge)|approvabile)"
flags: i
weight: 3
---
