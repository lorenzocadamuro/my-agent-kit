# Ready-for-review gate

Step 10 of `/my:run`. When the review says the bar is met and no block finding remains:

1. Run the plan's "once, at the end" checks. If one fails, the bar is not met: its failures become the next round's items, and the state stays `ready` (or `needs_you` when the fix is a decision), written with `${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`. Then read `${CLAUDE_PLUGIN_ROOT}/skills/pr/review/SKILL.md` and follow it on the PR in `local` mode and the deep review, if this round did not already.
2. Write a one-page retrospective to `<data root>/retros/<repo>-<branch>.md`: rounds, rework and its causes, decision reversals, drift, and what the reviewers asked.
3. Ask the user, one question each: mark the PR ready, update the description (the new text pasted in chat), notify the reviewers (all of these are publishing). After the last answer, the state is `done` (`state.sh --set state=done`).

