# /my:plan:scope — the plan is the contract

Read first: `${CLAUDE_PLUGIN_ROOT}/docs/principles.md`, `${CLAUDE_PLUGIN_ROOT}/docs/question-format.md` and `${CLAUDE_PLUGIN_ROOT}/templates/plan.md`.

Talk to the user in their language. Write the plan in English.

## Arguments

| Argument               | Meaning                                                                                                                                                                                  |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ticket id or URL       | Read it through the tracker named in the project profile (Linear MCP: `get_issue` with `title`, `description`, `gitBranchName`, `status`, `team`, `project`, `relations`, `attachments`) |
| Free text              | The task description                                                                                                                                                                     |
| `--adopt <branch\|PR>` | Plan for existing work: read its diff and description, and do not create a new branch                                                                                                    |
| `--dry-run`            | Write the plan only. No worktree, no branch, no ticket change. Save it where the user says, or at `<data root>/plans/<slug>-<date>.md`                                                   |

**Data root:** `$MY_AGENT_KIT_HOME`, or a root the user names; otherwise `~/.my-agent-kit`.

**Status:** from step 1 to the approval, keep the state file current (`${CLAUDE_PLUGIN_ROOT}/docs/local-data.md` § State file) with `state: "planning"`, the plan's title once known, and `step`: `research` (steps 1–3), `interview` (4), `write` (5), `review` (6), `approval` (7). The status line then shows the plan being made.

## Steps

### 1. Repository and project profile

- **Find the repository:** the current directory's git top level and remote slug. If there is none, ask which one; for `--dry-run` without a repository, plan from the files at hand.
- **Load `<data root>/projects/<owner-name>.md`.** If it is missing, build it following [project-profile-setup.md](project-profile-setup.md), show a summary, and ask the user to confirm or correct it before going on.

### 2. Understand and classify

Read the ticket, its links and related issues. Then classify:

- **Type:** bug fix, feature, refactor, tool or infra.
- **Size:**
  - **S:** one area, about 200 changed lines or fewer, no data or flag changes.
  - **L:** crosses services, adds flags, migrations or backfills, or is over about 1,500 lines.
  - **M:** everything in between.

State the classification and its reason in one line; the user can override it in the first question batch.

### 3. Research before asking

For M and L, run up to three Explore agents in parallel. For S, do it yourself. Collect:

- **How the things the plan relies on really work:** for shared code it extends, its callers by path (untruncated count) and what each reads; for code or data it replaces, every field its readers use and every rule it applies (precedence, ordering, what it skips, labels a screen reader announces); for a tool that measures or verifies, the order it runs its steps and when it takes the measurement. Cite `file:line`, and check each against one scenario that runs today. A plan built from a name or a description breaks where the mechanism differs.
- **New or existing behaviour:** for each behaviour the ticket or the user describes, find the test or code that pins it today. When the premise is false (the behaviour does not exist yet), it becomes scope, and you tell the user plainly.
- **Overlap:** open PRs touching the same paths (`gh pr list --state open --json number,title,author,files --limit 100`, intersected with the paths), and the owners' recent work there.
- **People and merge requirements:**
  - CODEOWNERS entries for the paths;
  - branch rules (`gh api repos/<o>/<r>/rules/branches/main`), covering required reviews, code owners, checks and thread resolution.
- **Rules to load:** the guides the profile maps to these paths.
- **Baseline:** run the profile's check commands for these paths on `origin/main`, and note pass, fail or missing tool (principles: measure the baseline).

Keep research notes in the scratchpad. They feed both the plan and the independent review.

### 4. Interview

Ask with the multiple-choice tool, following the question format, in batches of up to 4. Prefill the recommended option from the research.

| Size       | Topics                                                                                                                                             |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Every size | goal confirmation, boundary, bar for done (what is checked every round, and what once at the end)                                                                                                          |
| M and L    | invariants, existing versus new behaviour (only where research found a question), out of scope, intentional changes, size budget and split trigger |
| L          | people and what they are building next, rollout (flags, deploy order, migrations, backfills), extra gates and stop conditions                      |

About 4 questions for S, 8 for M, 12 for L. Never ask what research already answered.

- Record each answer as a decision (`D<n>`, with date and reason).
- **When the question tool is unavailable** (a non-interactive run), take each interview question's recommended option, record it as an assumption `A<n>` in the Decisions table, and continue.

### 5. Write the plan

- Use `templates/plan.md`. If the profile names a plan style guide, follow its structure and keep the template's sections inside it.
- Drop the sections that do not apply to the size, all in one line and without their headings: `Dropped for size S: Invariants, Existing vs new behaviour, Size budget, People, Rollout, Parts.` Content they would have held goes in a section the size keeps (an S plan's steps go in Verification).
- An S plan fits on about one page.

### 6. Independent review

Hand the plan, the research notes and the principles to a fresh general-purpose agent. It checks that:

- the boundary and the bar are checkable;
- every invariant names where it holds and a test that can fail;
- each existing-behaviour claim cites evidence;
- out of scope and intentional changes are lists, not prose;
- the size budget is realistic against the research.

It also names any question the user should have been asked. Fix what it finds. A finding that needs the user becomes one more question.

### 7. Gate: plan approval

Show the plan's path and a summary of at most 12 lines: goal, boundary, bar, size and budget, key decisions, open questions. Ask: approve / change something / cancel. On cancel, delete the planning state file. The approval is never assumed: without the question tool, stop here and set the state file to `needs_you` with reason "Plan approval"; a `--dry-run`, which sets up nothing, ends as today.

### 8. Set up the workspace

Skip this step for `--dry-run`, and delete the planning state file: there is nothing to run.

1. **Branch name:** the ticket's `gitBranchName`, or else the profile's naming rule.
2. **Worktree:** `git fetch origin main`, then `git worktree add <profile worktree root>/<branch> -b <branch> origin/main`.
   - If the branch already exists locally or remotely, stop and offer `--adopt`; set the planning state file to `needs_you` with that reason.
   - With `--adopt`, reuse the existing worktree, or add one for the existing branch.
3. **Setup:** run the profile's setup command, in the background when it is slow.
4. **Plan file:** write it to `<worktree>/.plans/plan.md`. Then write the worktree branch's state file with `state: "ready"`, its `repo`, `branch` and `worktree`, the plan's title and path, and its parts; and delete the planning file of the folder this skill ran in. The bar then shows in any session working in the worktree: this one if it moves there (step 6), or the one the user opens there.
   - If `.plans/` is not ignored (`git check-ignore -q .plans/`), add it to `.git/info/exclude`, never to a tracked `.gitignore`.
5. **Ticket:** move it to the profile's start status (Linear `save_issue` with `state`), and say so in the summary. This is the only ticket change allowed without asking.
6. **Move the session:** when the profile says the session follows the worktree, switch this session into it with the EnterWorktree tool (`path` set to the worktree). The tool accepts worktrees under the repository's `.claude/worktrees/`. Otherwise, tell the user to open the worktree in a new session.
7. **Report:**
   - the worktree path and branch;
   - the plan path;
   - the next step: `/my:plan:run` (or `/my:plan:round` to watch each round). From here the plan runs only through them (principles: the kit carries the plan it made).

### 9. Closing step

Follow the principles' closing step.
