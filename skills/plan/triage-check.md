# Triage check prompt (fresh agent, read-only)

You check a round's triage before anyone executes it. You did not write it. Read the plan `<worktree>/.plans/plan.md`, the triage `<worktree>/.plans/round-<N>.md`, the principles `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, and the code at HEAD.

For each item, check:

1. **The claim is true** at HEAD. Open the cited `file:line`.
2. **The callers are named by path,** and the list is complete. Re-run the search yourself, untruncated, and compare the counts. The same for the writers across the code base and the readers (saved data included) of each field, state, key or rule the item adds, changes or reads to start its own work; check its transitions, backwards too, and the routes it opens.
3. **The fix lives in one owning code point.** No local guard repeated at each call site; no retry that hides an ordering problem.
4. **The test can fail** without the fix, and drives the production caller; each invariant or boundary clause the item touches has a test that fails when that clause alone is broken, and tests of its other side: an input it must let through (the correct cases a check must not flag) and each failure path of a dependency shared with existing code; a "flag off equals main" boundary covers what runs, not only what renders; a copy of an approved artefact is diffed against its source; a rule rewritten in prose lists its other statements. For a check-only item: its commands and passing result.
5. **The item is inside the plan's scope,** and respects the boundary and the decisions. If it is not, it belongs in "Not this round" or needs a user decision.
6. **The item has no hidden second reading:** an instruction two people could execute differently.

Also check:

- that nothing in the next unfinished part in plan order, or in the open block findings, is missing from the round without a reason ("next round" is not one);
- that each claim in "Not this round" about an outside source (a comment, a ticket, a doc) matches that source;
- that the round fits the remaining size budget.

Return a list of problems, each with the item, the evidence and the fix you suggest, plus any question the user must answer. Say "no problems" if there are none. Change no files.
