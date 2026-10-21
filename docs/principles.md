# Principles

Every skill in this kit follows these rules. Skills point here instead of restating them, so a change made here reaches all of them.

These principles serve [CONSTITUTION.md](../CONSTITUTION.md). Where they disagree, the constitution wins.

## Proportional, not strict

- **Size the process to the task.** First classify the work (bug fix, feature, refactor, tool, infra, review) and its size (S, M, L). Ask only the questions that kind of work needs. A small bug fix gets a half-page plan; a large cross-cutting change gets the full one.
- **Skip what does not apply, and say so in one line.** Leaving a section out on purpose is fine; leaving it out by accident is not.
- **Four things are always fixed:** the goal, the boundary, the bar for done, and the gates. Everything else scales with the task.
- **Any rule can be overridden** when the user says why. Record the reason in the plan.

## The plan is the contract

- **Boundary first.** State what must stay exactly as it is today (for example, "with the feature flag off, behaviour equals the main branch"). Write it before any code.
- **Invariants are checkable.** Each one names where in the code it holds, and a test that fails when it breaks.
- **New or existing behaviour?** Before treating a behaviour as a requirement, find the test or code that pins it today. If none exists, it is a new feature: it goes through scope, not through a fix.
- **The bar for done is set at the start.** It is the stop criterion for every review. A review stops when the bar is met, not when it runs out of things to say.
- **Out of scope is a list.** A finding outside the plan becomes a ticket, not a fix.
- **Intentional changes are a list.** Every difference from today's behaviour that the change means to make is written down. An unlisted difference is either a bug or a missing entry.
- **Size budget and split trigger.** Agree a rough size up front. Crossing it means stop and decide whether to split.

## Humans decide at gates, agents do the rest

- **The gates are agreed in the plan:**
  - plan approval;
  - any decision outside the bar or the boundary;
  - marking a change ready for human review;
  - anything published: PR text, review comments, replies, messages, ticket changes beyond the agreed ones.
- **Between gates, agents work alone.** No relaying messages between sessions, no babysitting.
- **Pushing to a draft branch is not a gate.** A round that passed verification pushes on its own, so CI and backup happen early. A user can turn this off per run. In the kit's own repository (the one behind `${CLAUDE_PLUGIN_ROOT}`), work branches are pushed too, but a push that would move its `main` or a tag waits for the release gate (the full diff and the user's yes), whatever branch the work is on.
- **Chores never land on the user.** Restarting services, cleaning containers and rerunning suites belong to the agent doing the work.
- **Notify at gates.** When the work stops for a decision, or a long round ends, send a short desktop notification and put the summary in chat.

## The method

- **The gate decisions of the `plan:*` modes and `pr:sync` are learned as kinds** in `<data root>/method.md` ([local-data.md](local-data.md) § Method); other modes neither cite nor update kinds, and only the coordinating session edits the file. Each such decision belongs to a kind; one that fits none gets the next `K<n>`, in generic words, starts `asked`, and its first answer counts like any other (match 1, mismatch 0). Two kinds are close when the same judgement would recommend the same option; merged, they keep the lower count and the less autonomous state, and are `kept` if either is.
- **A recommendation follows its kind's judgement** unless research says otherwise, and then says so. Only the user's choice counts: an assumption counts for no kind and creates none (its Kind cell may name the kind it fits), and a hand-over is never assumed. A match adds one; a mismatch rewrites the judgement to the user's choice, resets the count to 0 and sets a `proposed` or `handed over` kind back to `asked`. The plan's Decisions table records both options (plans with older columns stay valid).
- **At 5 matches a `work` kind becomes `proposed`,** and the next gate in any session proposes handing it over: yes makes it `handed over`; no sets it back to `asked`, count 0. `kept` kinds are recorded, so recommendations can cite them, and never proposed.
- **A handed-over kind is decided alone, by its judgement, only when the decision clearly fits it** and research does not point elsewhere; otherwise ask, and the answer counts. The report and the plan then say "decided alone (handed over: K<n>)".
- **The user takes a kind back by saying so in chat,** in any session: the coordinator sets it to `asked`, count 0, with the date.

## Questions the user can answer

Follow [question-format.md](question-format.md) for when to ask, and for the shape of every question and of each of its options.

## Verify, don't assume

- **Check every claim against the code or the data** before it shapes a decision or reaches the user, including claims made by other agents and your own: a ticket's premises, live state (flags, config, the environment, a preview), the consequences written into a question's options, and "done", "it is live" or "it works". Each one carries its evidence (`file:line`, a read-only query, a measurement in the page) or is marked unverified.
- **Audits are never truncated.** Report the match count and every hit.
- **Measure the baseline before promising a check.** A command enters the bar for done or a stop condition only after it ran on `origin/main`. If it already fails there (a missing tool, a known failure), write it as "no new failures against the baseline", with the baseline counts.
- **A test must be able to fail.** Drive the production caller, and check that reverting the fix makes the test fail.
- **The writer is not the reviewer.** Reviews run in a fresh context that did not write the code.
- **Stop and report** when the code contradicts the plan, instead of improvising.
- **Agents in the background cannot ask the user.** When they reach a decision, they stop and report the options. The coordinating session asks.

## Review depth follows the stakes

- **Every round: a light conformance review** of that round's diff against the plan, by a fresh agent. The lenses are in [review-lenses.md](review-lenses.md).
- **At milestones: the project's deep review tool,** named in the project profile. The milestones are before "ready for human review", and when drift exceeds the budget. The bar is passed in as the stop criterion.
- **Every finding is labelled** block, ticket or note, by [review-lenses.md](review-lenses.md) § Grading a finding. Only block findings enter the next round.

## Repository rules are inputs, not assumptions

- **Each repository has a local profile** in `<data root>/projects/<repo>.md`. It names the commands (tests, codegen, migrations, deep review, PR description), the guides to load, and the post-merge checks. The format is in [local-data.md](local-data.md).
- **Load the relevant rules explicitly.** Before work starts, find the guides that apply to the files being touched, and hand them to both the executor and the reviewer.
- **When a fix suggested by a reviewer conflicts with a repository rule,** the rule wins until the user decides otherwise.

## The kit carries the plan it made

- **An approved plan runs only through `/my:plan:run` or `/my:plan:round`.** Together with `/my:plan:scope`, which keeps it while planning, they keep the state file, and so the status line, true from the first step to the last.
- **A request to do part of it directly** ("implement part B") becomes a round with that part as its source.
- **Leave the kit for a change only when the user says so;** then delete its state file, and work as plain Claude Code.

## Always in a worktree

- **Work happens in the worktree of the change, never in the main checkout,** unless the project profile says how the user works there instead (for example "work on `main`, no worktree" in a single-thread repository). Every skill checks the worktree (or what the profile names), branch, HEAD and clean tree at start, and stops if they are wrong.
- **New branches start from `origin/main`,** never from whatever branch happens to be checked out.
- **One writer per worktree at a time.**

## Where files go

- **Per-change files** (plans, rounds, summaries, comment triage) live in the worktree's git-ignored `.plans/` folder, and disappear with the worktree.
- **Lasting personal material** lives in the data root: a root the user names, else `$MY_AGENT_KIT_HOME`, else `~/.my-agent-kit/`; never in this repository. The layout is in [local-data.md](local-data.md).
- **Personal material stays private.** Study pages, readings, the glossary, reviewer profiles, `method.md` and the suite log stay under the data root, never in a repository, artifact, doc or gist. They shape what the kit looks for, but nothing published (PR text, comments, replies, commits, messages) cites, quotes or names them.
- **Throwaway files** go in the session scratchpad.
- **Link only files the app can open.** The desktop app's file pane opens files inside the session's working directory and added folders, not the scratchpad. A file the user must read goes in the working directory (a git-ignored `.plans/`) or the data root. Before linking a file under the data root (`~/.my-agent-kit/` by default), add that folder to the session with the app's directory-request tool (`request_directory`), once per session. When the tool is missing, show the path as code, not as a link.
- **Nothing employer-specific enters this repository.**

## Language

- **Skills, prompts for other agents, plans, hand-off files, commit messages, comment and reply drafts are in English.** Signals and the reasoning in log entries are the exception.
- **Reasoning is in the user's language:** the conversation and the reports shown to the user (files under `.plans/` stay in English), study material, signals and the reasoning in log notes. Plain words, the why before the what.
- **Vocabulary is never translated.** Repository terms (code names, domain nouns, flags, commands) and the kit's own terms (`bar for done`, `boundary`, `round`, states, ids, table headers) stay as they are in every language, so the user finds them in the code and in conversations with colleagues. The first time a term appears in a conversation, give its meaning in one plain line.

## Name the session after the work

- **When a skill opens a fresh session,** rename it as soon as it knows the work (after reading the ticket, the PR or the request). The app's default title is the command name ("Scope plan ENG-123"), which says nothing about the work.
- **Format:** `<ticket or PR id> <2-3 words>` when there is one (`ENG-123 Webhook retries`, `PR 456 Auth middleware`); otherwise two or three words naming the problem (`Flaky checkout test`).
- **How:** the app's session-title tool (`set_session_title`, session `self`). Skip it silently when the tool is missing (terminal, headless runs) or the session already has a title about the work.

## Closing step of every skill

The kit learns while it is used. Every skill collects signals during the work and digests them at the end; only `/my:improve` note, list, log, method and digest are exempt.

- **A signal is a sign that the kit's directives missed something:**
  - the user answers with a free answer ("Other") or dismisses a question. Record why: the question was unclear, the proposed method did not fit, or the user added an instruction of their own;
  - the user asks for a simpler explanation, or the reasoning in the chat shows a gap in the plan or the method;
  - a decision is reversed, a gate comes as a surprise, or a stop the plan did not foresee happens;
  - a review finding, or a real comment from a reviewer or a bot, that the plan, the research or the round's own review should have caught;
  - rework in a round.
- **Record each one when it happens, without interrupting the work.** Append one line to this session's signals file, `<data root>/signals/<owner-name>-<branch>.md` (`/` in the branch becomes `-`; without a branch, `<owner-name or "none">-<date>-<session id or time>.md`), creating it with a `# Signals: <repo> · <branch>` heading: `- <date time> · <kind> · <skill:mode> · <what happened> · <source>`. Only the coordinating session writes signals.
- **At the end, run `/my:improve digest <this session's signals file>`.** It turns pending signals into a few clear notes in the log. When there were none, say nothing about it.
- **Never edit a skill on your own.**
