---
name: scope-plan
description: Build the plan for a code change together with the user, before any code. Reads the ticket (Linear or text), researches the code, open PRs, owners and existing tests, then interviews the user with multiple-choice questions (with pros and cons) scaled to the size of the task, and writes a plan with goal, boundary, bar for done, invariants, out of scope, intentional changes, size budget, people and gates. After approval, creates the worktree and branch from origin/main (the ticket's branch name), moves the ticket to In Progress, and saves the plan in the worktree. Use for "/my:scope-plan", "let's plan this ticket", "pianifichiamo", "scope this change", or a ticket id with a request to start work. Also re-scopes a PR that got out of hand (--adopt).
argument-hint: "<ticket id | url | description> [--adopt <branch|PR>] [--dry-run]"
---

# /my:scope-plan — the plan is the contract

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

- **The code involved:** entry points, the owning code points, and the callers by path, with an untruncated count, of every shared function or chokepoint the change extends, with what each caller reads. A plan written from one caller of shared code breaks the others.
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
| Every size | goal confirmation, boundary, bar for done                                                                                                          |
| M and L    | invariants, existing versus new behaviour (only where research found a question), out of scope, intentional changes, size budget and split trigger |
| L          | people and what they are building next, rollout (flags, deploy order, migrations, backfills), extra gates and stop conditions                      |

About 4 questions for S, 8 for M, 12 for L. Never ask what research already answered.

- Record each answer as a decision (`D<n>`, with date and reason).
- **When the question tool is unavailable** (a non-interactive run), take the recommended option, record it as an assumption `A<n>` in the Decisions table, and continue.

### 5. Write the plan

- Use `templates/plan.md`. If the profile names a plan style guide, follow its structure and keep the template's sections inside it.
- Drop the sections that do not apply to the size, with one line each saying so.
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

Show the plan's path and a summary of at most 12 lines: goal, boundary, bar, size and budget, key decisions, open questions. Ask: approve / change something / cancel.

### 8. Set up the workspace

Skip this step for `--dry-run`.

1. **Branch name:** the ticket's `gitBranchName`, or else the profile's naming rule.
2. **Worktree:** `git fetch origin main`, then `git worktree add <profile worktree root>/<branch> -b <branch> origin/main`.
   - If the branch already exists locally or remotely, stop and offer `--adopt`.
   - With `--adopt`, reuse the existing worktree, or add one for the existing branch.
3. **Setup:** run the profile's setup command, in the background when it is slow.
4. **Plan file:** write it to `<worktree>/.plans/plan.md`.
   - If `.plans/` is not ignored (`git check-ignore -q .plans/`), add it to `.git/info/exclude`, never to a tracked `.gitignore`.
5. **Ticket:** move it to the profile's start status (Linear `save_issue` with `state`), and say so in the summary. This is the only ticket change allowed without asking.
6. **Move the session:** when the profile says the session follows the worktree, switch this session into it with the EnterWorktree tool (`path` set to the worktree). The tool accepts worktrees under the repository's `.claude/worktrees/`. Otherwise, tell the user to open the worktree in a new session.
7. **Report:**
   - the worktree path and branch;
   - the plan path;
   - the next step: `/my:pr-round`.

### 9. Closing step

Follow the principles' closing step.
