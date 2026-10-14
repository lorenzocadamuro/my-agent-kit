# Principles

Every skill in this kit follows these rules. Skills point here instead of restating them, so a change made here reaches all of them.

## Proportional, not strict

- **Size the process to the task.** First classify the work (bug fix, feature, refactor, tool, infra, review) and its size (S, M, L). Ask only the questions that kind of work needs. A small bug fix gets a half-page plan; a large cross-cutting change gets the full one.
- **Skip what does not apply, and say so in one line.** A section left out on purpose is fine; a section left out by accident is not.
- **Only four things are always fixed:** the goal, the boundary, the bar for done, and the gates. Everything else scales with the task.
- **Any rule can be overridden** when the user says why. Record the reason in the plan.

## The plan is the contract

- **Boundary first.** State what must stay exactly as it is today (for example "with the feature flag off, behaviour equals the main branch"). Write it before any code.
- **Invariants are checkable.** Each one names where in the code it holds and a test that fails when it breaks.
- **New or existing behaviour?** Before treating a behaviour as a requirement, find the test or code that pins it today. If none exists, it is a new feature and goes through scope, not through a fix.
- **The bar for done is set at the start.** It is the stop criterion for every review. A review stops when the bar is met, not when it runs out of things to say.
- **Out of scope is a list.** A finding outside the plan becomes a ticket, not a fix.
- **Size budget and split trigger.** Agree on a rough size up front; crossing it means stop and decide whether to split.

## Humans decide at gates, agents do the rest

- **Gates are agreed in the plan:** plan approval; any decision outside the bar or the boundary; the diff before a push; anything published (PR text, review comments, messages).
- **Between gates, agents work alone.** No relaying messages between chats, no babysitting.
- **Chores never land on the user.** Restarting services, cleaning containers and rerunning suites belong to the agent doing the work.

## Questions the user can answer

- **Multiple choice, recommended option first,** with a free answer always possible.
- **Every option shows:** the user-visible effect, what happens today without the change, pros, cons, and how serious the issue is.
- **No internal IDs or jargon** without a one-line meaning.

## Verify, don't assume

- **Check every claim against the code or the data** before it shapes a decision, including claims made by other agents.
- **Audits are never truncated.** Report the match count and every hit.
- **A test must be able to fail.** Drive the production caller, and check that reverting the fix makes the test fail.
- **The writer is not the reviewer.** Reviews run in a fresh context that did not write the code.
- **Stop and report** when the code contradicts the plan, instead of improvising.

## Repository rules are inputs, not assumptions

- **Load the relevant rules explicitly.** Before work starts, find the guidance that applies to the files being touched (style guides, contribution rules, module docs), and hand it to both the executor and the reviewer.
- **When a fix suggested by a reviewer conflicts with a repository rule,** the rule wins until the user decides otherwise.

## Always in a worktree

- **Work happens in the worktree of the change, never in the main checkout.** Every skill checks the worktree, branch, HEAD and clean tree at start, and stops if they are wrong.
- **One writer per worktree at a time.**

## Where files go

- **Per-change files** (plans, round notes, summaries) live in the worktree's git-ignored `.plans/` folder and disappear with the worktree.
- **Lasting personal material** (improvement log, retrospectives, reviewer profiles, study pages) lives in `~/.claude/my/`, outside this repository.
- **Throwaway files** go in the session scratchpad.

## Language

- **Skills, prompts for other agents, and hand-off files are in English.**
- **Conversation with the user, and study material, are in the user's language.**
