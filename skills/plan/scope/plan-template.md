# <Title: what the change makes true, as a sentence>

<!-- Section tags: [always], [M+] (medium and large), [L] (large only). -->

Ticket: <id + url, or "none"> · Size: <S|M|L> · Type: <bug fix|feature|refactor|tool|infra>
Repo: <owner/name> · Branch: <name> · Worktree: <path> · Base: origin/main @ <sha>

## Goal [always]

<One to three sentences: the outcome for users or developers, not the tasks.>

## Boundary [always]

<What must stay exactly as it is today. Example: "With the flag off, every response and stored record equals main, whatever the client sends.">

## Bar for done [always]

The change is ready to merge when:

- [ ] <criterion, checkable>
- [ ] no block finding open against the bar
- [ ] <reviewer-specific asks met>

How it is checked, and what it costs:

- Every round: <the quick check that decides whether a round worked, e.g. targeted tests, a screening run> (~<time or cost>; fails on: <the likeliest wrong input it was seen failing on>)
- Once, at the end: <the full proof that the change is done, e.g. the full suite, two independent A/B runs, a manual check> (~<time or cost>; fails on: <…>)
- Cost, when the change adds work to a hot path: <a deterministic cost test, or a limit against the baseline timed on origin/main on a large case>
- After the merge, only when a condition happens then (a deploy, a sync): <a separate verification ticket, its text: what to check, where and when>

## Gates [always]

Default gates from the principles, plus: <any extra gate, or "none">.

## Invariants [M+]

| #   | Statement | Holds at (file · function) | Test that fails if broken |
| --- | --------- | -------------------------- | ------------------------- |
| I1  |           |                            |                           |

## Existing vs new behaviour [M+]

| Behaviour | Today (test or code that pins it) | After |
| --------- | --------------------------------- | ----- |

## Intentional changes [M+]

Differences from today that this change means to make, for everyone or behind the flag:

- <difference> — <who sees it>

## Out of scope [always]

| Item | Why not now | Ticket |
| ---- | ----------- | ------ |
| <item> | <reason> | <ticket, or "none: accepted (D<n> or A<n>), <reason>"> |

## Size budget [M+]

Budget: ~<N> changed production lines, <N> files; tests ~<N> lines, reported apart. Split trigger: <condition, on production code>.

## People [M+]

| Person / team | Role (reviewer, code owner) | What they are building next that touches this |
| ------------- | --------------------------- | --------------------------------------------- |

Merge requirements: <required reviews, code owners, required checks, thread resolution>.

## Rollout [L]

Flags, deploy order, data migrations, backfills, monitoring, how to turn it off.

## Parts [M+]

A step is ready only when every label under it is filled; `none` with its reason counts as filled.

### Part A: <what this part makes the code do, as a sentence>

- [ ] <step>
  - Files: <paths, and the owning code point (file · function)>
  - Searches: <each caller or writer search, run at the base, with its count>
  - Test: <name, in the shape users are told to write it; what it drives; it fails without the fix>
  - Environment: <providers, mocks, fixtures, and how each state the test needs is produced>
  - Pins: <each invariant or boundary clause the step touches: the test that fails when that clause alone breaks, and the input it must let through>
  - Estimate: <production lines, as a number>

## Verification [always]

- Targeted tests: <commands from the project profile, each with its baseline on origin/main>
- Manual check: <what to see, where>

## Decisions [always]

| #   | Date | Kind | Recommended | Chosen | Why |
| --- | ---- | ---- | ----------- | ------ | --- |
| D1  |      | K<n> | <the recommended option's text, not its letter> | <the chosen option's text, "decided alone (handed over: K<n>)", "from the request", "decided from research", or "assumed"> |     |

## Open questions

- <question> — owner, needed by <part/gate>
