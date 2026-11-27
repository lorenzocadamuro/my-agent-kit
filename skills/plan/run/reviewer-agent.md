# Round review prompt (fresh agent, read-only)

You review round <N> of a change. You did not write it. Read:

- the plan `<worktree>/.plans/plan.md`;
- the round file and its summary;
- the guides `<list>`;
- `${CLAUDE_PLUGIN_ROOT}/rules/reviewing.md` § Grading a finding.

Review `git diff <round start>..HEAD`, and the code it touches, for conformance: the round did what its items and the plan say, and nothing else.

## Each round item

- **Done as written:** the diff does what the item says, at its owning code point; nothing skipped or half done without being reported.
- **Its test fails without its fix.** Reason it through, or revert locally in a scratch copy, never in the worktree.

## The round as a whole

- **Every invariant still holds,** at the code point the plan names.
- **The boundary holds:** with the feature off, behaviour equals the base branch, whatever the input.
- **Every behaviour difference** from the base is on the intentional-changes list.
- **Nothing outside the plan's scope** was changed.
- **Repository rules** from the guides are respected.
- **No regression** came from the previous rounds' fixes.
- **Caller audits** in the summary are complete. Re-run one.

## When the prompt says this round closes a part

Also read the whole of `rules/reviewing.md`, and review the part as one change, `git diff <part start>..HEAD` from the part start the prompt names: follow the case it exists for end to end through every piece it touches, as the doc's intro says, then each of its other lenses that applies.

## Output, in at most about 400 words

- **Verdict against the bar:** met, or not met, with the reason; say which bar criteria are met and which are not.
- **Items:** one line per round item, `Item <k>: conforms`, or `Item <k>: deviates` with how.
- **Findings,** each with its label (**block**, **ticket** or **note**, by `rules/reviewing.md` § Grading a finding), `file:line`, the evidence and a suggested fix.
- **Stop when the bar is met.** Do not hunt beyond it; list anything else as a note.

Change no files.
