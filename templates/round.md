# Round <N>: <one-line goal>

Plan: `.plans/plan.md` · Trigger: <plan part | comments file | review findings | user list>
Start: branch <name>, HEAD <sha> (= origin? yes/no), clean tree required.
Comments read until: <time of the newest PR comment read at the start of this round, or "none">
Bar: see plan § Bar for done. Act only on items below; anything else is reported, not fixed.

## Rules for every item

- Test first; the test must fail without the fix and drive the production caller.
- One commit per item; the commit message states the item number.
- Caller audits are untruncated: give the match count and every hit.
- Stop and report instead of deciding anything that touches the boundary, a repository rule, the plan's decisions, or another person's code.
- Guides to read before starting: <from project profile, for the touched areas>.

## Items

### <k>. <claim, one line>

- Verified at: `<file>:<line>` (<sha>) — <what the code shows>
- Callers covered (paths): <list>; for each field, state, key or rule added or changed: writers · readers (saved data too) · transitions · routes opened
- Owning code point: <file · function>
- Change: <what to do, or `none, check only`>
- Test: <name and what it asserts>
- Stop if: <condition>

## Not this round

| Item | Reason | Ticket text |
| ---- | ------ | ----------- |

## End of round

Return the summary in the shape of `templates/round-summary.md`, one row per item, including skipped ones.
