#!/usr/bin/env bash
# A log that already holds today's 01. Two sessions writing at once must never share an id: the note is
# appended through the kit's lock script (whose own test runs ten writers at once), never by hand.
mkdir -p kit-data
today="$(date +%Y%m%d)"
cat > kit-data/suite-log.md <<P
# Suite log

## ${today}-01 · plan:scope · open

- When: $(date +%Y-%m-%d) 09:00
- Kit: 5.2.0
- Where: acme/shop · feature · session s1
- What happened: the plan asked the size budget twice.
- Why it was a problem: a question asked again.
- Missing question: unknown
- Expected: ask it once.
- Suspected cause: unknown
- Signal: question re-asked
P
