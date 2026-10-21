# my-agent-kit

A personal suite of skills for working on code with agents. It turns a task into a scoped plan, runs the work in autonomous rounds that stop only at agreed gates, reviews changes the way a senior colleague would, and gets better every time something goes wrong.

It ships as a Claude Code plugin named **`my`**, so every skill is one keystroke away: type `/my` and the menu lists them all.

## Why it exists

Long pull requests fail in predictable ways:

- the bar for "done" is set late, so reviews never converge;
- the boundary of the change is discovered halfway through;
- scope grows without a budget;
- claims go unverified;
- the developer ends up as a courier, carrying messages between agent sessions.

This kit encodes the fixes as reusable skills. It also keeps a log, so each new failure mode becomes a new fix.

## The workflow

The menu is organised by object: `plan:*` for a change and its plan, `pr:*` for a pull request and its review, `improve:*` for the kit itself.

```mermaid
flowchart LR
    A["/my:plan:scope<br/>plan with boundary,<br/>invariants, bar"] --> R["/my:plan:run<br/>rounds until a gate"]
    A --> O["/my:plan:round<br/>one round, then stop"]
    O --> R
    R --> R
    Y["/my:pr:sync<br/>catch up with main"] --> R
    R --> V["/my:pr:review<br/>senior-style review"]
    N["/my:pr:learn<br/>understand a PR first"] --> V
    V --> H(("human<br/>review"))
    H --> C["/my:pr:comments<br/>what each comment means"]
    C --> R
    H --> S["/my:pr:study<br/>learn how reviewers think"]
    I["/my:improve<br/>signals, notes, fixes"] -.-> A & R & V & C & S
```

You step in only at **gates**, which the plan agrees in advance:

1. approving the plan;
2. a decision outside the agreed bar or boundary;
3. marking the change ready for human review;
4. anything that gets published (PR text, review comments, replies, messages).

Between gates, agents work in the background: `plan:run` starts the next round on its own as long as each one succeeds, a verified round pushes to the draft branch, and one desktop notification tells you when you are needed. Small work takes a light lane: for a plan with `Size: S`, `plan:scope` starts no agent, and each round skips the triage check and is carried out by the session itself; a fresh agent still reviews every round.

**Decisions you hand over.** Each decision you take at a gate belongs to a kind: a generic judgement ("for X, choose Y") kept in `method.md` in the data root, with no repository, project, code or person names. The plan's Decisions table records the option the kit recommended and the one you chose; an assumption the kit makes without you counts for nothing. After 5 matches in a row, the next gate proposes handing that kind over, and only your yes does it. From then on the kit decides that kind alone when a decision clearly fits it, and lists each one as "decided alone (handed over: K<n>)". A mismatch resets the count and takes the hand-over back; so does telling the kit in chat. Architecture, design, speaking for you, plan approval, crossing the boundary or a repository rule, anything published, ready for review, a release, someone else's code and moving the local stack are never handed over. `/my:improve:method` lists the kinds.

## A change, end to end

```text
/my:plan:scope ABC-123     interview → plan → worktree + branch from origin/main → ticket In Progress
/my:plan:run               rounds one after another: triage → check → execute → verify → review → push,
                           until a gate, new PR comments, conflicts with main, the bar, or 5 rounds
/my:plan:round             one round and a 6-line report, when you want to watch each step
/my:pr:sync                when a round reports that main moved with conflicts
/my:pr:comments            bots and reviewers answered → fixes feed the next /my:plan:run
/my:pr:study               ten minutes on how the reviewer thinks (only new comments)
/my:pr:learn 456           understand a colleague's PR first…
/my:pr:review 456          …then review it (reuses the reading)
/my:improve                whenever you want to see what the kit has learned, or fix it
```

## Commands

| Command            | Stage       | What it does |
| ------------------ | ----------- | ------------ |
| `/my:plan:scope`   | Before code | Interviews you with multiple-choice questions and writes the plan: goal, boundary, invariants with tests, bar for done, size budget, reviewers, gates. Adapts its depth to the kind and size of the task. Never assumes your approval: without the question tool it stops at "Plan approval". |
| `/my:plan:round`   | During      | Runs one round: executes the work in the background (in the S lane, the session itself), checks the result against git, has a fresh agent review it against the plan, and reports in six lines, in your language, with a drift signal, the decisions taken alone and the lessons it logged. |
| `/my:plan:run`     | During      | Runs rounds one after another while each succeeds, carrying block findings to the next round and ticking plan parts; stops at a gate, failed verification, drift over budget, conflicts with main, new PR comments, red CI, anything to publish, the bar, or 5 rounds; one summary at the end, in your language. |
| `/my:pr:sync`      | During      | Brings the branch up to date with main: previews conflicts, leaves every design conflict to you (other PRs' text only builds the options), regenerates generated files, re-checks migrations and the dev database. Context you type yourself ("keep their approach, adapt ours") is your decision. |
| `/my:pr:review`    | Review      | Reviews a pull request, yours or a colleague's, through the lenses senior reviewers use: promised guarantees, state ownership, durability, every caller, rollback, the roadmap of others. Returns the questions to ask and findings graded against the bar. Your own PR is reviewed by fresh agents that did not write it. |
| `/my:pr:comments`  | Review      | For each bot or colleague comment: two lines of plain explanation, whether it is real, its weight, a proportional action and a short reply draft. |
| `/my:pr:learn`     | Learning    | Understand a PR before reviewing it: what and why, before → after, reading order, its promise, questions to keep in mind. Private, in your language. |
| `/my:pr:study`     | Learning    | Turn the review comments you received into a three-layer study page; only comments not studied yet. Private, with a glossary and reviewer profiles. |
| `/my:improve`      | Always      | `note` logs a problem with the kit from any session; `digest` turns the signals every skill collects while you work into a few clear notes; `run` finds the upstream lesson behind open notes and turns it into approved changes, eval cases, a version bump and an updated README, in its own worktree, and ships only after showing you the diff and getting your yes; `log` shows the history, each note with its problem in one line and a state badge, closed ones folded away; `method` lists the decision kinds and which ones are handed over. |

Behind them are three skills with modes: `plan` (scope, round, run), `pr` (learn, study, review, comments, sync) and `improve` (note, digest, run, log, method). You rarely need the names: ask in plain words ("explain PR 456", "run the plan") and Claude picks the command from its description.

## The status line (optional)

`my-status` is a small mod that shows, in one line above the prompt, where the work stands, from the first step of `plan:scope` ("Planning", with its steps: research, interview, writing, review, approval) to the end of a run: the work's short name and, when it waits or stops, a reason of two or three words; the plan's parts as tiles that fill up, the percentage, the time left, what needs you ("Round N done" after a round), and the next action as a button (it fills the prompt with the command; you press Enter). "Open plan" shows the plan in a pane. `pr:*` modes and `improve run` show that they are running or need you. Each state has one label, on the band and on the status line. Long text is cut with "…", and the buttons never shrink. A planning, running or activity state untouched for 6 hours is ignored. New comments count only other people's, and a failed network call shows nothing rather than zero. It reads the state file `plan:scope`, `plan:round` and `plan:run` write, merges its two sidecars (a round's item progress, written by the executor; what a `pr:*` mode or `improve run` is doing), and reads `git` and `gh`; it never changes your files. The kit works the same without it.

## Principles

[CONSTITUTION.md](CONSTITUTION.md) comes first: what the kit is for, and what it must not become. It changes only by hand or at your explicit request, and it wins over every other rule. `/my:improve run` checks each proposal against it, refuses what it forbids, and for the cause behind such a note proposes only what it allows.

All skills share one set of rules, kept in [docs/principles.md](docs/principles.md), which serve the constitution:

- proportional rather than strict;
- the plan as contract;
- humans decide at gates;
- every option in a question carries its own labelled Pros and Cons;
- decisions are learned as kinds, and a kind is decided alone only after you hand it over;
- verify before deciding, including the agent's own claims; the writer is never the reviewer;
- checks enter the bar only after their baseline is measured;
- repository rules are loaded explicitly;
- work happens in a worktree, unless the project profile says how you work there instead;
- a fresh session is named after the work, not the command;
- links point only to files the app can open; nothing published cites your study pages, reviewer profiles or other personal material;
- in the kit's own repository, work branches may be pushed, but `main` and tags move only at the release gate, after the full diff and your yes;
- reasoning is in the user's language, and repository vocabulary is never translated;
- the kit learns while it is used: every skill collects signals and digests them into notes;
- an approved plan runs only through `plan:run` or `plan:round`, so the status line is always true; leaving the kit is your call.

## Install

**On the development machine**, link the repository into the personal skills folder. From the next session, Claude Code loads it automatically, straight from disk, as `my@skills-dir`:

```bash
ln -s "<path to your clone>" ~/.claude/skills/my
```

**On any other machine**, install it from the private GitHub repository. This uses your existing `gh` or git credentials:

```bash
claude plugin marketplace add lorenzocadamuro/my-agent-kit
claude plugin install my@my-agent-kit
```

The repository is private, so nobody else can install it.

**The status line mod** is installed on its own, from your clone used as a local marketplace. The marketplace also lists `my`: do not install that one where `~/.claude/skills/my` already loads the kit, or it loads twice.

```bash
claude plugin marketplace add "<path to your clone>"
claude plugin install my-status@my-agent-kit
```

Edits to `mods/my-status` reach a session with `/reload-plugins`.

## Improving the kit

The kit grows with use, but it never changes itself without approval: kit changes come only through an approved plan or `/my:improve run`.

1. **Signals.** While you work, every skill records signals without interrupting you: a free "Other" answer, a dismissed question, a reversed decision, a reviewer comment the plan should have caught, rework. At the end, `/my:improve digest` groups them into a few clear notes in the suite log (`suite-log.md` in the data root): repeats merge, withdrawn ones drop, and a cause already open gains an evidence line instead of a new note. You can also add a note by hand with `/my:improve note <what happened>`.
2. **Run.** Whenever you like, from any session, `/my:improve run` looks for the upstream lesson behind the open notes (the question that should have been asked, and the existing rule that should have covered it) and proposes refining that rule rather than adding a patch. It edits nothing, the project profile included, before you approve a proposal, and then works in its own worktree, never in the main checkout.
3. **Prove.** Each fixed note becomes an eval case in `evals/`. `claude plugin eval` must pass before the change lands, so a fixed problem cannot come back.
4. **Record and ship.** Every run updates this README, `CHANGELOG.md` and the version in `.claude-plugin/plugin.json`, commits in its worktree, and has a fresh agent review the diff. Then it shows you the full diff; only on your yes does it fast-forward `main`, tag and push.

Changes take effect from the next session.

### Versioning

The kit follows [semantic versioning](https://semver.org):

- **patch** for wording and fixes;
- **minor** for a new skill or new behaviour;
- **major** when a command or its arguments change incompatibly, or when behaviour you rely on changes incompatibly.

## Repository layout

```
.claude-plugin/
  plugin.json        plugin manifest (name "my", version)
  marketplace.json   lets the private repo act as its own marketplace
skills/<name>/       plan, pr and improve: a SKILL.md that routes to one file per mode
commands/<skill>/    thin sub-commands that call a skill in one mode (/my:<skill>:<mode>)
evals/<skill>/       eval cases, one per problem the kit has learned from
mods/my-status/      the optional status line mod (hooks module, its state contract, tests)
CONSTITUTION.md      what the kit is for; wins over every other rule; changed only by the user
docs/principles.md   rules every skill follows
docs/                question format, review lenses, local data layout
templates/           plan, project profile, round, round summary, log entry, reviewer profile, study page
scripts/check.sh     validation and privacy check, run by the pre-commit hook
scripts/check.test.sh  tests that the privacy check fails without its deny-word file
scripts/verify-round.sh  checks a round summary against git
scripts/drift.sh     size versus budget, distance from main, conflict preview
.githooks/pre-commit runs scripts/check.sh
.githooks/commit-msg blocks a commit touching CONSTITUTION.md without "Amend constitution"
.claude/CLAUDE.md    instructions for agents editing this repository
CHANGELOG.md         what changed in each version
```

## What never goes in this repository

This repository holds only generic, reusable material. Anything tied to an employer or to people stays local, in the data root: a folder you name, else `$MY_AGENT_KIT_HOME`, else `~/.my-agent-kit/`:

- the suite log, the method registry and retrospectives;
- reviewer profiles and study pages;
- internal paths, project names, ticket or pull request numbers, and colleagues' names.

`scripts/check.sh` blocks a commit that contains any word listed in `deny-words.txt`, read from `$MY_AGENT_KIT_HOME` (default `~/.my-agent-kit/`; `$MY_AGENT_KIT_DENY` names another file). That file is local and never committed. Without it the check fails, unless you set `MY_AGENT_KIT_ALLOW_NO_DENY=1` on a machine that has none.

## Development

```bash
git config core.hooksPath .githooks   # once per clone
scripts/check.sh                      # validate the plugin and run the privacy check
bash scripts/check.test.sh            # test that the privacy check fails without its deny-word file
```

`git config core.hooksPath .githooks` enables both hooks: `pre-commit` runs `scripts/check.sh`, and `commit-msg` blocks a commit that touches `CONSTITUTION.md` unless its message contains "Amend constitution" (merges pass).

Evals run locally, never published; see [evals/README.md](evals/README.md):

```bash
claude plugin eval . --no-publish --runs 1 --max-cost-usd 12 --trust-plugin \
  --ablation none --allow-tools Bash Write Edit --scaffold -j 4
```

The mod has its own checks:

```bash
claude plugin validate mods/my-status
claude plugin test mods/my-status
```
