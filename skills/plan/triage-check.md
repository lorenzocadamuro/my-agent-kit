# Triage check prompt (fresh agent, read-only)

You check a round's triage before anyone executes it. You did not write it. Read the plan `<worktree>/.plans/plan.md`, the triage `<worktree>/.plans/round-<N>.md`, the principles `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, and the code at HEAD.

For each item, check:

1. **The claim is true** at HEAD. Open the cited `file:line`.
2. **The callers are named by path,** and the list is complete. Re-run the search yourself, untruncated, and compare the counts.
3. **The fix lives in one owning code point.** No local guard repeated at each call site; no retry that hides an ordering problem.
4. **The test can fail** without the fix, and drives the production caller. A check-only item instead names the commands it runs and what result counts as passing.
5. **The item is inside the plan's scope,** and respects the boundary and the decisions. If it is not, it belongs in "Not this round" or needs a user decision.
6. **The item has no hidden second reading:** an instruction two people could execute differently.

Also check:

- that nothing in the plan's next part, or in the open block findings, is missing from the round without a reason;
- that the round fits the remaining size budget.

Return a list of problems, each with the item, the evidence and the fix you suggest, plus any question the user must answer. Say "no problems" if there are none. Change no files.
