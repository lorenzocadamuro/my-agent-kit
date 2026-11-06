# /my:plan:scope — the plan is the contract

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md`, `${CLAUDE_PLUGIN_ROOT}/docs/model-choice.md` and `${CLAUDE_PLUGIN_ROOT}/templates/plan.md`.

## Arguments

| Argument               | Meaning                                                                                                                                                                                  |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ticket id or URL       | Read it through the tracker named in the project profile (Linear MCP: `get_issue` with `title`, `description`, `gitBranchName`, `status`, `team`, `project`, `relations`, `attachments`) |
| Free text              | The task description                                                                                                                                                                     |
| `--adopt <branch\|PR>` | Plan for existing work: read its diff and description, and do not create a new branch                                                                                                    |
| `--dry-run`            | Write the plan only. No worktree, no branch, no ticket change. Save it where the user says, or at `<data root>/plans/<slug>-<date>.md`                                                   |

**Status:** from step 1 to the approval, keep the planning state file current (`${CLAUDE_PLUGIN_ROOT}/docs/local-data.md` § State file: the worktree branch's file once this session works in the worktree; otherwise, `--dry-run` included, `session-<session id>.json`) with `state: "planning"`, `startedAt` set at step 1 (a file that already has one keeps it: `--adopt`, a re-scope; a file left by a finished plan, `state: "done"`, counts as having none, since a new plan is a new run), the plan's title once known, and `step`: `research` (steps 1–3), `interview` (4), `write` (5), `review` (6), `approval` (7). Rewrite it whole, keeping every field you do not change, through a temp file and a rename. The status line then shows the plan being made.

## Steps

### 1. Repository and project profile

- **Find the repository:** the current directory's git top level and remote slug. If there is none, ask which one; for `--dry-run` without a repository, plan from the files at hand.
- **Load `<data root>/projects/<owner>-<repo>.md`.** If it is missing, build it following [project-profile-setup.md](project-profile-setup.md), show a summary, and ask the user to confirm or correct it before going on.

### 2. Understand and classify

Read the ticket, its links and related issues. Then classify:

- **Type:** bug fix, feature, refactor, tool or infra.
- **Size:**
  - **S:** one area, about 200 changed production lines or fewer (tests apart, as in the size budget), no data or flag changes.
  - **L:** crosses services, adds flags, migrations or backfills, or is over about 1,500 production lines.
  - **M:** everything in between.

State the classification and its reason in one line; the user can override it in the first question batch.

**Understand first, when asked.** When the user asks to understand the problem before deciding to work on it, or the ticket asks for no code change at all (read data, decide, close), say so in one line, skip the worktree and the ticket below, do step 3's research read-only from where the session is (baseline only where it needs no worktree), explain what it found, and stop: set the planning state file to `needs_you` with reason "Go ahead?". The worktree, the ticket move and the interview wait for the user's go; then continue at "Then open the worktree", keep the research, and run only its baseline in the worktree.

**Then open the worktree,** so the plan is made where it will run (principles: always in a worktree). Skip it for `--dry-run`, which creates nothing, and when the profile says the user works without a worktree.

1. **Branch name:** the ticket's `gitBranchName`, or else the profile's naming rule.
2. **Worktree:** `git fetch origin main`, then `git worktree add <profile worktree root>/<branch> -b <branch> origin/main`. If `.plans/` is not ignored there (`git check-ignore -q .plans/`), add it to `.git/info/exclude`, never to a tracked `.gitignore`. Copy what `.worktreeinclude` lists (principles: entering a worktree), then start the profile's setup command there, in the background, so the baseline runs on a ready worktree.
   - If the branch already exists locally or remotely, stop and offer `--adopt`; set the planning state file to `needs_you` with that reason.
   - With `--adopt`, reuse the existing worktree, or add one for the existing branch.
3. **Move the session:** when the profile says the session follows the worktree, move this session into it as the principles say (entering a worktree: EnterWorktree, the app's change-directory tool, the check on the app's record, a Terminal tab there). From then on keep the worktree branch's state file, carrying this session's `startedAt` into it only when it has none (as in § Status), and delete this session's. Otherwise keep the session file, and plan from the worktree's files.

**Then the ticket,** when there is one, also without a worktree and never with `--dry-run`: the work has started, so move it to the profile's start status (Linear `save_issue` with `state`), unless it is already there or further on, and say so. Keep its previous status in the state file (`ticketFrom`). This is the only ticket change allowed without asking.

### 3. Research before asking

For S, do it yourself, and skip overlap and people and merge requirements. For M and L, research in two phases, with Explore agents on the model `${CLAUDE_PLUGIN_ROOT}/docs/model-choice.md` gives each:

1. **Search:** one agent, whose prompt opens with `Search only, decide nothing`, answers a fixed list, each item with `file:line` evidence or `unknown: <what could not be read>`: the callers by path of the shared code the plan relies on, with untruncated counts; every writer of each state the plan reads or hooks into; open PRs on the paths (overlap); CODEOWNERS and branch rules; the rules to load; the test or code that pins each behaviour the ticket describes. A missing item or a claim without evidence gets the table's fallback; an `unknown` does not.
2. **Analysis:** up to two agents, given the search's answers (not its opening words): how the things really work, the consequences, which rule decides each case, failure paths, and the baseline.

Together they collect:

- **How the things the plan relies on really work:** for shared code it extends, its callers by path (untruncated count), what each reads and the rule each applies (tolerances, exceptions, what it skips), each rule checked against the change; for code or data it replaces, every field its readers use and every rule it applies (precedence, ordering, what it skips, what it shows or announces to users); for a tool that measures or verifies, the order it runs its steps and when it takes the measurement. Cite `file:line`, and check each against one scenario that runs today. For the cases the change means to move (the instances a measurement counted, the requests that fail), classify which rule decides each one today, and check that the change reaches that rule. A plan built from a name or a description breaks where the mechanism differs.
- **The consequences of what the plan adds, changes or hooks into:** for each field, state, key or rule the plan adds or changes, or reads to start its own work (a size it watches, an event it follows), every writer across the code base and when it writes, not only the flow traced, who reads it (data saved before the change included), its transitions (backwards too), and any other route it opens; whether it mirrors another source and can be derived from it at each write instead of kept by transitions. For any code the plan runs, a throwaway variant or a measuring script included: what it writes outside the process (a document, a database, a server) and what it needs from outside (a CDN and its CORS rule, a port, an origin), tried once read-only before it touches shared data. For each new kind of work: what happens when it fails or times out, what bounds it (retries, a cost against a measured run), which writers can run at once, and whether every client already deployed (an old version still running) accepts what the change sends, in the rollout order. Cite `file:line`; what the plan must decide goes in the interview, and a production volume or frequency an option's recommendation depends on is measured first (principles: verify, don't assume). The same for each option the interview will offer: what it adds on a hot path (per frame, per item, per request) and which new event makes it redo work (a remount, a write, a recompute), read from the code.
- **New or existing behaviour:** for each behaviour the ticket or the user describes, find the test or code that pins it today. When the premise is false (the behaviour does not exist yet), it becomes scope, and you tell the user.
- **Overlap:** open PRs touching the same paths (`gh pr list --state open --json number,title,author,files,createdAt,updatedAt,isDraft,reviewDecision,mergeable --limit 100`, intersected with the paths), each with how live it is (age, last activity, draft or review state, conflicts), and the owners' recent work there. Building on an open PR is a question for the user with that evidence, never a default, even when the ticket asks for it.
- **People and merge requirements:**
  - CODEOWNERS entries for the paths;
  - branch rules (`gh api repos/<o>/<r>/rules/branches/main`), covering required reviews, code owners, checks and thread resolution.
- **Rules to load:** the guides the profile maps to these paths, and the repository's own rule files and the tests that enforce them (architecture or policy tests), each checked against the plan's new writes and deletes.
- **Baseline:** run the profile's check commands for these paths on `origin/main`, and the local command of every CI job that runs on these paths or on the paths of the files the plan adds (read the CI workflows; a job without one is named CI-only), and note pass, fail or missing tool (principles: measure the baseline). Every command the bar or the Verification relies on runs once here, in the worktree, with the prerequisites research found, which go into the Verification; one that needs an authorisation the approval will give runs its safe or read-only part now. For each check the bar will use, try it once on the change's likeliest wrong input (on a scratch copy), or read its code, and note whether it can fail (principles: a test or a check must be able to fail). For each scenario the bar measures or tests, count once on main that it holds what the change touches (the items, the code path), with the count in the notes: a scenario without it does not measure the change. When the change adds work to a hot path (per operation, per item, per frame, per request), also time that path on a large case, and propose a cost check for the bar: a deterministic cost test, or a limit against that baseline.

Keep research notes in the scratchpad. They feed the plan and, for M and L, the independent review.

### 4. Interview

Ask with the multiple-choice tool, following the question format, in batches of up to 4. Prefill the recommended option from the research.

| Size       | Topics                                                                                                                                             |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Every size | when research found risks behind a product choice, the design options that remove them, asked before or beside that choice; goal confirmation, boundary, bar for done (what is checked every round, what once at the end, and a condition that happens only after the merge, such as a deploy or a sync, proposed as a separate verification ticket) |
| M and L    | invariants, existing versus new behaviour (only where research found a question), out of scope, intentional changes, size budget in production lines (tests estimated apart) and split trigger |
| L          | people and what they are building next, rollout (flags, deploy order, migrations, backfills), extra gates and stop conditions                      |

About 4 questions for S, 8 for M, 12 for L. Never ask what research already answered. Ask now only what the plan and its first part need; a later part's choice becomes a gate or an open question of that part (question format: when to ask).

- **The method first:** read `<data root>/method.md`. A question the method lets you decide alone (principles: the method) is not asked: decide it and record it as `D<n>` with Chosen `decided alone (handed over: K<n>)`. After each answer, update its kind.
- Record each answer as a decision (`D<n>`, with date and reason).
- **When the question tool is unavailable** (a non-interactive run), take each interview question's recommended option, record it as an assumption `A<n>` in the Decisions table, with Chosen `assumed` (it counts for no kind; principles: the method), and continue.

### 5. Write the plan

- Write it to `<worktree>/.plans/plan.md` (for `--dry-run`, where the Arguments say), from `templates/plan.md`. If the profile names a plan style guide, follow its structure and keep the template's sections inside it.
- Drop the sections that do not apply to the size, all in one line and without their headings: `Dropped for size S: Invariants, Existing vs new behaviour, Size budget, People, Rollout, Parts; research skipped: overlap, people and merge requirements.` Content they would have held goes in a section the size keeps (an S plan's steps go in Verification).
- An S plan fits on about one page.

### 6. Independent review

For S, start no agent: confirm that the goal, the boundary, the bar and the gates are present; the user's approval at step 7 is the plan's review. For M and L, hand the plan, the research notes and the principles to a fresh general-purpose agent (model: `docs/model-choice.md`). It checks that:

- the boundary and the bar are checkable;
- each rule the plan states (boundary, invariants, out of scope) holds against every step of every part, and against the CI jobs that run on the files the plan adds;
- every invariant names where it holds and a test that can fail;
- every claim the plan rests on cites evidence or is marked unverified, negative claims included (no test can observe it, nothing else reads it, it fails on main, no built-in feature does it): for each, the reviewer tries to build the case that disproves it;
- out of scope and intentional changes are lists, not prose;
- the size budget is realistic against the research.

It also names any question the user should have been asked. Fix what it finds. A finding that needs the user becomes one more question.

### 7. Gate: plan approval

Show the plan's path and a summary of at most 14 lines: goal, boundary, bar, size and budget, one line on how far the plan moved from the ticket's own ask, both sizes in it ("the ticket asks a one-line timeout bump; the plan moves to chunked uploads, ~70 lines"), key decisions, open questions, the follow-ups already consolidated, each named with where it went (folded in when the ticket names it and it is small and in the same code, merged into one ticket, or recorded on an existing one), and the actions the plan will need that require the user's yes (anything published; commits, pushes or moving the local stack when the profile gates them), each with what happens without it, so they are authorised with the plan or replaced. Ask: approve / change something / cancel, and propose here each kind due for hand-over (principles: the method). On cancel, delete the planning state file, and offer to remove the worktree and its branch when they hold no commit (leaving it first with ExitWorktree if the session moved there), and to move the ticket back to `ticketFrom`. The approval is never assumed: without the question tool, stop here and set the planning state file to `needs_you` with reason "Plan approval"; a `--dry-run` skips this stop and goes on to step 8, which it skips.

### 8. Finish the workspace

Skip this step for `--dry-run`, and delete the planning state file: there is nothing to run. The worktree exists since step 2; only this is left:

1. **Setup:** make sure the setup command started in step 2 finished, or run it now if step 2 did not start it.
2. **State:** write the worktree branch's state file with `state: "ready"`, its `repo`, `branch` and `worktree`, `startedAt` as planning wrote it (the branch's file keeps its own; this session's planning file's only when the branch's file has none, as in § Status), the plan's title and path, and its parts, each with `short`, its title after "Part X:" in two or three words and at most 16 characters (so it shows under its part in the band), and `steps`, one `{ label, status }` per step, the label in two or three words (labels and `short` follow `local-data.md` § State file: words that say what the work does, never a code name); then run `${CLAUDE_PLUGIN_ROOT}/scripts/state-steps.sh <state file> <plan.md>`, which derives every status from the plan's boxes; then delete this session's planning file if there is one. The bar then shows in any session working in the worktree.
3. **Report:**
   - the worktree path and branch, and, when this session did not move there, that the run starts in a new session opened in the worktree;
   - the plan path;
   - the next step: `/my:plan:run` (or `/my:plan:round` to watch each round). From here the plan runs only through them (principles: the kit carries the plan it made).

### 9. Closing step

Follow the principles' closing step.
