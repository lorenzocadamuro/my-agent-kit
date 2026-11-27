# Principles

Every skill in this kit follows these rules. Skills point here instead of restating them, so a change made here reaches all of them.

These principles serve [CONSTITUTION.md](../CONSTITUTION.md). Where they disagree, the constitution wins.

## Proportional, not strict

- **Size the process to the task.** First classify the work (bug fix, feature, refactor, tool, infra, review) and its size (S, M, L). Ask only at the real forks that kind of work has ([asking.md](asking.md) § When to ask). A small bug fix gets a half-page plan; a large cross-cutting change gets the full one. The verification too: check what changes, take what is already proven as given, and say so.
- **Skip what does not apply, and say so in one line.** Leaving a section out on purpose is fine; leaving it out by accident is not.
- **Four things are always fixed:** the goal, the boundary, the bar for done, and the gates. They are always written in the plan and named in the approval summary, and asked only at a real fork. Everything else scales with the task.
- **Any rule can be overridden** when the user says why. Record the reason in the plan.

## Humans decide at gates, agents do the rest

- **The gates are agreed in the plan:**
  - plan approval;
  - any decision outside the bar or the boundary;
  - marking a change ready for human review;
  - anything published: PR text, review comments, replies, messages, ticket changes beyond the agreed ones.
- **Between gates, agents work alone.** No relaying messages between sessions, no babysitting.
- **Pushing to a draft branch is not a gate.** A round that passed verification pushes on its own, so CI and backup happen early. A user can turn this off per run. In the kit's own repository (the one behind `${CLAUDE_PLUGIN_ROOT}`), work branches are pushed too, but a push that would move its `main` or a tag waits for the release gate (the full diff and the user's yes), whatever branch the work is on; every plugin of the repository whose files changed gets a version bump, and after the push its installed copies are updated and checked (`/my:improve` § Run, Ship).
- **Chores never land on the user.** Restarting services, cleaning containers and rerunning suites belong to the agent doing the work.
- **Notify at gates.** When the work stops for a decision, or a long round ends, send a short desktop notification and put the summary in chat.

## When the user questions or corrects the kit

- **A question, a request to explain or a correction from the user** ends with a judgement: does the exchange point to a kit fix? If it does, the reply proposes a note in the same conversation (its skill and what happened, in one line) and asks whether to save it; the note is saved, through `${CLAUDE_PLUGIN_ROOT}/skills/improve/note/SKILL.md`, only on the user's yes. An answer like "I don't understand" to a question the kit asked is a request to explain, and points to a kit fix: the question did not show what it named. The reply then only explains and asks nothing, a note included ([asking.md](asking.md) § When the user dismisses the questions or asks back); once the user says it is clear, the reply asks the question again and, in the same batch, a second question that proposes the note (save it or not). A dismissed batch or a free answer that holds a doubt is not this trigger: the reply explains the same way, and the signal waits for the end report ([asking.md](asking.md) § After the answer). Work the kit does alone never stops for a note: its signals wait for the end report ([learning.md](learning.md) § Closing step of every skill).

## Language

- **Working texts are in English:** skills, prompts for other agents, plans and `.plans/` files, hand-off files, commit messages, comment and reply drafts (`unslop` applies to these, below), and the band's states, reasons, short titles and step labels (the kit's vocabulary).
- **The kit sets no language for text written for the user, and no form beyond the `unslop` rules:** the conversation, reports, questions, notifications, chapter titles, study pages, signals and the reasoning in log notes. The user's output style and own instructions do; the kit ships no style of its own. Whatever the style, the why comes before the what. An agent's report reaches the user summarised, never forwarded as it is.
- **The kit applies `unslop`** (`${CLAUDE_PLUGIN_ROOT}/skills/writing/unslop/SKILL.md`) to its replies to the user and to text for other people (reports, questions, comment and reply drafts, PR text), on top of the user's style; where the two disagree, the user's style wins. Comment and reply drafts are working texts in English (above), and `unslop` applies to them; the other working texts (plans, `.plans/` files, commits, prompts for other agents) are out of its scope.
- **Text addressed to a colleague** (a review draft, a reply to a review) states the problem, its evidence and the options, and leaves the decision to them: a suggested path reads as one option, not a plan to follow; no stance or verdict ("I'd keep this as is", "on purpose", "deliberate"); it ends open to their view.
- **Vocabulary is never translated.** Repository terms (code names, domain nouns, flags, commands) and the kit's own terms (`bar for done`, `boundary`, `round`, states, ids, table headers) stay as they are in every language, so the user finds them in the code and in conversations with colleagues. The first time a term appears in a conversation, give its meaning in one line.

## Name the session after the work

- **When a skill opens a fresh session,** rename it as soon as it knows the work (after reading the ticket, the PR or the request). The app's default title is the command name ("Scope plan ENG-123"), which says nothing about the work.
- **Format:** `<ticket or PR id> <2-3 words>` when there is one (`ENG-123 Webhook retries`, `PR 456 Auth middleware`); otherwise two or three words naming the problem (`Flaky checkout test`).
- **How:** the app's session-title tool (`set_session_title`, session `self`). Skip it silently when the tool is missing (terminal, headless runs) or the session already has a title about the work.
