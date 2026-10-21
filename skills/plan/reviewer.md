# Round review prompt (fresh agent, read-only)

You review round <N> of a change. You did not write it. Read:

- the plan `<worktree>/.plans/plan.md`;
- the round file and its summary;
- the guides `<list>`;
- `${CLAUDE_PLUGIN_ROOT}/docs/review-lenses.md`.

Review `git diff <round start>..HEAD`, and the code it touches.

## Fixed checks (every change)

- **Repository rules** from the guides are respected.
- **No item was skipped or half done** without being reported.
- **Each new test fails** without its fix. Reason it through, or revert locally in a scratch copy, never in the worktree.
- **Caller audits** in the summary are complete. Re-run one.
- **No regression** came from the previous rounds' fixes.

## Checks from the plan

- **Every invariant still holds,** at the code point the plan names.
- **The boundary holds:** with the feature off, behaviour equals the base branch, whatever the input.
- **Every behaviour difference** from the base is on the intentional-changes list.
- **Nothing outside the plan's scope** was changed.
- **The bar:** say which bar criteria are met and which are not.

## Output

- **Verdict against the bar:** met, or not met, with the reason.
- **Findings,** each with its label (**block**, **ticket** or **note**, by the lenses doc § Grading a finding), `file:line`, the evidence and a suggested fix.
- **Stop when the bar is met.** Do not hunt beyond it; list anything else as a note.

Change no files.
