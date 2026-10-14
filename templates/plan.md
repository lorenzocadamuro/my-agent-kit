# <Title: what the change makes true, as a sentence>

<!-- Sections are tagged [always], [M+] (medium and large) or [L] (large only).
     Drop a tag's sections when the size is smaller, with one line saying so.
     If the project profile names a plan style guide, follow its structure and keep these sections inside it. -->

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

Reviews stop when these hold. Anything else becomes a ticket.

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

## Size budget [M+]

Budget: ~<N> changed lines, <N> files. Split trigger: <condition>.

## People [M+]

| Person / team | Role (reviewer, code owner) | What they are building next that touches this |
| ------------- | --------------------------- | --------------------------------------------- |

Merge requirements: <required reviews, code owners, required checks, thread resolution>.

## Rollout [L]

Flags, deploy order, data migrations, backfills, monitoring, how to turn it off.

## Parts [M+]

### Part A: <what this part makes the code do, as a sentence>

- [ ] <step> — test first: <test>

## Verification [always]

- Targeted tests: <commands from the project profile>
- Manual check: <what to see, where>

## Decisions [always]

| #   | Date | Decision | Why |
| --- | ---- | -------- | --- |
| D1  |      |          |     |

## Open questions

- <question> — owner, needed by <part/gate>
