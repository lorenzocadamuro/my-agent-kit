# Changelog

All notable changes to this kit are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [8.2.0] - 2026-11-27

Tools for growth. The kit can take in a skill from outside, audit its own text, keep each project profile current, and report its size, its repeats and the evals a change reaches. The rules merge into fewer files, and each skill reads only the rules it uses.

### Improve (`add-skill`, `improve`)

- C8: `/my:add-skill` brings a skill into the kit from a pasted text or a link. It checks the candidate against the constitution first and stops, naming the clause, when it breaks one; `scripts/skill-overlap.sh` ranks the kit's skills by shared trigger words, and when one already does the same job it asks whether to integrate, improve or add. Otherwise it adapts the skill to `skill-template.md`, with a source line and an eval case from `eval-template.md`, makes `check.sh` pass, and ships it as `/my:improve run` does, after the diff and the user's yes. Its note id is `improve:add-skill`.
- C7: `/my:improve audit [folder]` starts one read-only agent per skill of the kit (the plugin's own, or the one in the folder), each applying `rules/writing-for-agents.md` to that skill's text; the findings come back as proposed notes, saved only on the user's yes.
- `rules/learning.md` § The kit's improvement loop names `/my:add-skill` among the ways the kit changes.

### Profile (`profile`, `scope`, `run`, `review`, `sync`)

- C9: a profile records the files it was built from, each with its git blob hash, in a Sources section, and marks the user's own answers `(user)`. At the start of `/my:scope`, `/my:run`, `/my:review` and `/my:sync`, `scripts/profile-fresh.sh` compares the hashes with the repository's default branch (`origin/<default>`, never the PR head; without git, the files in the folder in git's blob form). A fact a changed source states is refreshed with a one-line report; a fact the user answered, and every fact of a profile written before 8.2.0, changes only after the user's yes. A profile without Sources gets them recorded on its first check, with one line. The procedure lives in `skills/plan/profile/SKILL.md` § Keeping it current; `profile-template.md`, `rules/kit-data.md` and `improve` name it as the exception to "a profile changes through `/my:improve`".

### Rules (C11, C16)

- `rules/question-format.md` becomes `rules/asking.md`; the `rules/core.md` section that only pointed to it is gone.
- `rules/review-lenses.md` and the `rules/core.md` section "Review depth follows the stakes" become `rules/reviewing.md`.
- `rules/model-choice.md` and the `rules/core.md` section "Which model an agent runs on" become `rules/models.md`.
- `rules/local-data.md` and `rules/files.md` become `rules/kit-data.md`.
- Each section moved verbatim; a pointer the merge made point into its own file was removed or became an in-file reference. Every path follows.
- Each skill's `reads` and "Read first:" list only the rules it uses: every workflow keeps `core`, `learning` and `verifying`, a skill that starts agents keeps `worker`, and any other rule stays when the skill's text or a file it opens names it or relies on one of its sections. `go`, `unslop` and `wait-what` keep theirs. `log` and `method` now read 4 rule files instead of 10; `note`, `profile` and `learn` 5; `sync` and `comments` 6.

### Scripts (C18)

- `scripts/budget.sh` reports the words of each kit file and of each skill with its reads; `scripts/single-source.sh` reports the sentences two kit files repeat; `scripts/affected.sh` lists the eval cases a set of changed files reaches. They only report: `check.sh` runs their tests, never their output.

### Evals

- New cases: `add-skill/new-skill-added`, `add-skill/same-job-asks`, `add-skill/constitution-conflict-stops`, `improve/audit-proposes-notes`, `scope/profile-refreshes-changed-source`, `scope/profile-answer-kept`.
- `comments/human-review-explained` and `improve/run-flags-old-notes` graders also accept the new rule file names.

## [8.1.0] - 2026-11-26

The accepted behaviour changes of the restructure. `/my:run` always runs the whole plan; the `round` skill is gone. A note is saved only with your yes. The kit gains `unslop`, `wait-what` and `blast-radius`, a rule on writing for agents, and a `Reply:` line at the end of every workflow.

### Constitution

- Clause 5 amended at the user's explicit request (2026-11-26): "The kit learns from what happens while I use it (my corrections, reviewers' comments, work done twice). When I question or correct it in the conversation, it proposes a note, and it saves the note only with my yes. What it notices while it works alone never stops the work, and it reports that at the end. It fixes the cause upstream, not the single case. Over time it proposes solutions in line with my past choices, inside the agreed boundary." The reason: the user wants active control over every note, with no interruption while the kit works alone.
- Clause 7 amended at the user's explicit request (2026-11-26): "I choose the language and the style of everything the kit explains to me, and I can change them at any moment. The kit adds no rule of its own on the language of that text. On its form, it adds only the `unslop` rules, on top of the style I choose, and my style wins where the two disagree. It explains the why before the what. Code and repository names are never translated." The reason: shorter replies with no AI patterns, as in pstack.

### Plan (`run`)

- C3: `/my:run` runs the plan round after round; the `round` skill, `/my:round`, `--verify` and `--triage-only` are gone. A request or a finding during a plan joins the open round (step 4) or the next one (`rules/plan-contract.md`), and `run` goes on. Step 10 moves to `skills/plan/run/ready-gate.md`. Each round reports one line; the six-line round report is gone, and the full summary comes at the end of the run.
- With `--verify` gone, a run resumes a round whose executor finished from the state file and its progress sidecar (§ Rounds and steps).
- `go` sends a plan request to `run` when a plan exists in the worktree.
- The end summary gains `Signals:`, this run's pending signals; `Lessons:` names the notes the user approved, or none.
- Every workflow ends with a `Reply:` line that names what its report already holds (C13); `check.sh` fails a workflow without one (all skills but `go`, `unslop` and `wait-what`).

### Notes (`note`, `improve`)

- C4: a note is saved only with the user's yes. A question, a request to explain or a correction from the user ends with a judgement on whether it points to a kit fix; if so, the reply proposes a note and asks (`rules/core.md` § When the user questions or corrects the kit). Work the kit does alone never stops for a note: every skill lists its pending signals in its end report (`rules/learning.md` § Closing step of every skill).
- `digest` merges into `note`: `/my:note <what happened>` still saves at once (the text is the yes); `/my:note signals [file]` groups pending signals into proposed notes and saves each only on the yes, marking a declined group's signals `→ declined: <date>`. `/my:improve digest [file]` does the same. Old `improve:digest` ids read as `improve:note`.
- The text is the yes only when the user asked for the note (`/my:note <text>`, `/my:improve note <text>`, `/my:improve <text>`, or in words). A plain correction that reaches `note` or `improve` through `go` gets the proposal and is saved only on the yes; `note`'s "When" no longer lists "the skill did X wrong".
- A note may carry `File:` (the kit file it is about) and `Leaves read:` (the rule files the skill had loaded); the detail view shows them. Notes without them stay valid.

### Writing

- C5: `/my:unslop`, from pstack (MIT), verbatim with one source line. The kit applies it to its replies to the user and to text for other people (reports, questions, review and reply drafts, PR text), on top of the user's style, which wins where they disagree; review and reply drafts stay working texts in English, and the other working texts are out of its scope (`rules/core.md` § Language). `review`, `comments`, `run` and `improve` read it.
- C6: `/my:wait-what`, from mattpocock/skills (MIT), verbatim, plus one line that adds the glossary `/my:learn` keeps.
- C7: `rules/writing-for-agents.md` holds mattpocock/skills' `writing-for-agents` and its `SKILL-MECHANICS.md` (MIT), verbatim, their links made in-file anchors; `improve` reads it.
- The lines that said the kit sets no form now say no form beyond the `unslop` rules: `rules/core.md`, `note`, the README and `no-form-rules.test.sh`, whose guard still passes with no new allowed line.
- `THIRD_PARTY_NOTICES.md` holds both MIT notices.

### Review (`pr`)

- C10: `/my:blast-radius`, from pstack (MIT), with four adaptations: `arena` becomes up to 3 fresh agents with the same question, and the sentence that justified it, "Different models catch different real bugs", is gone, since kit agents run on the session model (`rules/model-choice.md`); `unslop` becomes the kit's `writing/unslop`; the line about the companion skills `how` and `why` is gone. It reads `rules/learning.md`, whose closing step it follows; `unslop` and `wait-what` join the skills exempt from that step.

### Status mod (`my-status` 1.2.0)

- The "One round" button is gone; a ready or stopped plan shows Run plan.

### Fixes after the round 6 review

- The README no longer lists `round` under `plan/`; `rules/plan-contract.md` names where a request during a plan goes (the open round at step 4, or the next one); `no-old-names` rejects `plan:round`.

### Evals

- The 32 `round` cases and the 3 `run` cases start `/my:run` and live in `evals/run/`, with new fixtures that mark the earlier steps done; new case `run/run-continues-to-next-round` (it also checks that round 2's review was written).
- 23 rewritten cases pass without the rule they guard (decision D29), kept as guards: added-item-checked, changed-step-still-checked, clause-pinned-both-sides, decided-step-still-checked, deferred-row-verified, failed-step-cleared, failed-step-reworked, gate-explained-cold, moved-step-still-checked, out-of-scope-becomes-ticket, parts-follow-plan-order, review-fix-still-checked, round-reviewed-by-fresh-agent, run-carries-blocks, run-stops-before-publishing, s-lane-file-first, skipped-item-caught, skipped-rework-stays-done, state-says-what-is-left, step-labels-plain, test-in-documented-shape, triage-check-reuses-helper, triage-estimates-size.
- `digest-groups-signals` moves to `evals/note/`; it and `run/round-digest-writes-note` now grade proposed notes and no note written.
- `evals/README.md` § Lessons: a case may use the eval home's default data root when its `setup.sh` refuses any folder outside the eval home.
- `review/review-gate-for-colleague`: the grader `new-apart-from-raised` also accepts a count of new findings stated in other words ("sei nuovi", "3 finding nuovi", "2 block nuovi", "Finding nuovi: 2 block"), but only next to a finding noun or after a colon; "one new route" or "2 new tests" does not count, and a review that lists findings without telling new from raised still fails.
- New cases: `note/correction-asks-before-saving` (0/1 before, 3/3 after; fails with the 7.3.0 closing step and without the `rules/core.md` trigger), `comments/reply-unslopped` and `unslop/text-unslopped` (3/3 each; 1/4 and 0/2 before, 0/1 each on their mutants: besides "leverage" and dashes, which the model drops on its own, they grade `unslop` rule 22, no praise or agreement opener, and rule 20, no chatbot closer such as "I'm happy to …"; the text case's input holds both), `wait-what/re-pitch-adds-premise` (0/1 before, 3/3 after; fails when the glossary path is gone from the skill and its reads), `blast-radius/five-sections` (0/1 before, 3/3 after; fails without "What to hand back"), `go/correction-gets-proposal` (0/1 before, 3/3 after; fails with the old "When" phrase and goal line of `note`).
- `note/note-style-not-logged`: its `says-why` rubric follows the new wording (the kit sets no form beyond the `unslop` rules), and fails a reply that says the kit sets no form at all.

## [8.0.0] - 2026-11-26

The kit gets one door and one folder per skill. `/my:go` is the only skill Claude starts by itself: it reads a generated index and opens the skill that fits. Every command is now its own skill, `/my:<skill>`, with no aliases for the old names. The shared rules leave `docs/` for small files in `rules/`. Each skill keeps the text and behaviour it had in 7.3.0: the texts moved verbatim, and only their paths, short references, slash names and calls to other skills changed.

### Slash names

| 7.3.0 | 8.0.0 |
| --- | --- |
| `/my:plan:scope` | `/my:scope` |
| `/my:plan:round` | `/my:round` |
| `/my:plan:run` | `/my:run` |
| `/my:pr:learn` | `/my:learn` |
| `/my:pr:review` | `/my:review` |
| `/my:pr:comments` | `/my:comments` |
| `/my:pr:sync` | `/my:sync` |
| `/my:improve note`, `/my:improve:note` | `/my:note` |
| `/my:improve digest`, `/my:improve:digest` | `/my:digest` |
| `/my:improve log`, `/my:improve:log` | `/my:log` |
| `/my:improve method`, `/my:improve:method` | `/my:method` |
| `/my:improve`, `/my:improve run` | unchanged; its argument table still sends `note`, `digest`, `log` and `method` to those skills |
| `/my:plan`, `/my:pr` with no mode | `/my:go` |
| none | `/my:go`, `/my:profile` |

Notes, signals and activity files keep naming a skill by area and mode (`plan:scope`, `pr:review`), so every file written before stays valid.

A `/my:` command with punctuation glued to it (`/my:log,`) no longer reaches its skill: the line does not run as a command, only `go` is model-invoked, and the model does not route such a line through it.

### Layout

- `skills/<area>/<skill>/SKILL.md`, one per skill, listed in the `skills` array of `plugin.json`; `commands/` is gone. Each `SKILL.md` has the fields `name`, `description`, `disable-model-invocation` (true for all but `go`), `when` (the trigger phrases of its old description) and `reads`, plus `argument-hint` where its command had one.
- `plan:round` and `plan:run` keep one text: all of `round.md` is `skills/plan/run/SKILL.md`, and `skills/plan/round/SKILL.md` follows it once.
- The improve skill splits into `note`, `digest`, `improve`, `log` and `method`. Its paths, old names and entry view move to `rules/local-data.md`, its first sentence to `rules/learning.md` § The kit's improvement loop.
- The profile setup becomes `/my:profile`; `/my:scope` still runs it when a repository has no profile.
- The agent briefs become `skills/plan/run/executor-agent.md`, `reviewer-agent.md` and `check-agent.md`; each template moves next to the skill that writes it.
- A call to another skill reads that skill's `SKILL.md` by path and follows it, because a user-invoked skill refuses the Skill tool; an offer does it on the user's yes.

### Rules

- `docs/principles.md` splits, verbatim, into `rules/core.md`, `plan-contract.md`, `learning.md`, `verifying.md`, `worker.md`, `repository.md` and `files.md`. `question-format.md`, `review-lenses.md`, `model-choice.md` and `local-data.md` move to `rules/` whole.
- Every skill that read the principles reads the seven files; each "Read first:" line lists the same files as `reads`. A short reference names its file: "(principles: the method)" is now "(`rules/learning.md`: the method)".
- The pr activity rule moves to `rules/local-data.md` § The activity file, with a pointer in each pr skill.

### Scripts

- `scripts/index.sh` builds `skills/go/index.md` and the README skill list; `scripts/index.test.sh` tests it.
- `scripts/check.sh` adds the layout checks, which always run: the frontmatter and "Read first:" line of every skill, a current index, one eval folder per skill and one skill per eval folder, no kit text naming a missing skill or file (relative links and backticked bare paths included, a line number or an anchor after a path ignored), only `go` model-invoked, the status mod's commands, unique names. `check.test.sh` sees each one fail on a broken fixture.
- `no-form-rules.test.sh` scans `skills/`, `rules/` and the README.

### Status mod (`my-status` 1.1.0)

- Review comments, Merge main, One round and Run plan fill in `/my:comments`, `/my:sync`, `/my:round` and `/my:run`.

### Evals

- The 93 cases move to `evals/<skill>/` by their first command, and every `/my:` mention names the new command. The triage-check graders also accept `check-agent.md`, the eight no-plugin-write graders cover `rules/`, and `comments/human-review-explained` accepts the skill's own load. A command with punctuation glued to it (`/my:log,`) does not run as a command, so every case prompt that starts with a command starts with the bare one.
- Four new cases, each passing on this version: `go/routes-plan-request` and `go/routes-review-request` (3 runs each), `round/round-digest-writes-note`, `profile/profile-built-from-sources` (3 runs). Each fails on a mutant: the two `go` cases when the router is removed (0 of 3 each), `round-digest-writes-note` when the round's digest call is removed (0.00), and `profile-built-from-sources` when the rule "Mark every guess with (unconfirmed)" is removed (its grader `guess-marked`, 0 of 3; it pins the "(unconfirmed)" marker, which the rule names). Their first mutants (a Skill tool call instead of the read, an empty index, no "Sources, in order" list) still passed: the model finds the skill file on its own.
- Spend measured for this release: $13.54 for the branch and mutant runs of the new cases, $110.66 for the full suite (97 cases) and its reruns on both versions, and $8.55 for the runs that followed it (the two fixed prompts, the router fallback trials, one `origin/main` run per open regression): $132.75 in all.

## [7.3.0] - 2026-11-23

A plan run spends its time on the work, not on checking it again. `plan:scope` writes each step ready to execute and checks it once. A round executes those steps without a triage check, and its review checks conformance. The interview asks only at real forks. Kit 7.3.0, minor: no command or argument changes, and plans written by 7.2.0 still run.

### Principles

- § Proportional, not strict: ask only at the real forks of the kind of work. The plan always holds the four fixed things: goal, boundary, bar for done and gates. The approval summary names them. They are asked only at a real fork.
- § The method: a decision taken `from the request` or `decided from research` is an assumption. It counts for no kind and creates none.
- § Review depth follows the stakes: every round gets a conformance review of its diff against its items and the plan, in at most about 400 words. The round that completes a part also reviews the whole part with the lenses that fit.
- `docs/question-format.md`: the real forks are architecture, design, product behaviour, anything published, and trade-offs that rest on the user's priorities. Scope, boundary and the bar are asked only at a real fork.
- `docs/review-lenses.md`: the plan review of `plan:scope` uses the lenses too. A round review uses them only at the round that completes a part.
- `docs/model-choice.md`: the A/B rows of the triage check and the round review are gone, and so is § Pending. `docs/local-data.md`: rounds no longer write `trials/`. Data already saved stays.

### Plan (`plan`)

- `scope` step 4: no topic table and no question count. A topic becomes a question only at a real fork: two or more viable options are left, and the choice rests on the user. Every other topic is decided and recorded as `D<n>`, with Chosen `from the request` or `decided from research`. Zero questions is a valid interview.
- `scope` steps 3, 5 and 6: each step of an M or L plan carries six labels, filled from the research. They are `Files:`, `Searches:`, `Test:`, `Environment:`, `Pins:` and `Estimate:`. The plan review checks each step once, as the triage check checks a round item. It also reruns each search at the base and traces each step's main scenario with the lenses. It checks that each part is a vertical slice.
- `scope` step 7: the approval summary names goal, boundary, bar, gates, the parts, and all decided topics on one line. On approval, the plan is copied to `.plans/plan-approved.md`.
- `round` step 3: a ready step goes into the round file as written, marked `Ready from plan`. Its searches run again at HEAD. A ready step has all six labels filled and has not changed since approval. A moved count, a changed or partial step, a review block fix and an added item take the full triage.
- `round` step 4: the triage check runs only for the items that step 3 triaged in full. A round of ready steps writes `Triage check: skipped (ready steps)`. It starts no agent before the executor.
- `round` step 7 and `reviewer.md`: the review gives a verdict for each item against the diff, in at most about 400 words. When a round closes a part, the prompt names the part start, and the review follows the part's main scenario with the lenses. The part start is the `Start:` HEAD of the earliest round file whose `Trigger:` names the part. Without one, it is the `Start:` HEAD of the earliest round file.
- `round` steps 4 and 7: triages, check reports and review inputs are no longer copied to the data root.
- `templates/plan.md`: the six step labels, and the Chosen values `from the request` and `decided from research`. `templates/round.md`: the `Triage check:` line and the `Ready from plan` item.

### Evals

- Ten new cases. Six fail on the 7.2.0 text and pass on this version. Their two runs on 7.2.0 scored as follows.
  - `plan/plan-steps-ready`: 0.08 and 0.08.
  - `plan/ready-step-skips-check`: 0.00 and 0.00.
  - `plan/round-review-conformance`: 0.40 and 0.40.
  - `plan/mid-part-review-conformance`: 0.17 and 0.50.
  - `plan/part-end-review-lenses`: 0.50 and 0.50.
  - `plan/no-question-when-answered`: 0.38 and 0.75.
- Four are guards and pass on both versions: `plan/review-fix-still-checked`, `plan/changed-step-still-checked`, `plan/moved-step-still-checked` and `plan/decided-step-still-checked`.
  - `plan/moved-step-still-checked`: a ready step names a helper that an earlier round renamed, and it still gets the full triage.
  - `plan/decided-step-still-checked`: a ready step is named by a decision taken after approval, and it still gets the full triage.
- In `no-question-when-answered`, the grader `no-fixed-topic-question` is not a stable guard. On 7.2.0 it failed in one of the two runs. The case fails there on `reply-names-fixed` in both runs. That grader now also needs the gates named, because the fixture leaves the gates to the defaults.
- Two cases are removed with the trial copies: `plan/triage-saved-before-check` and `plan/review-inputs-saved`.
- `plan/triage-estimates-size`: the gate grader accepts an estimate or sum line over the trigger, with the gate asked anywhere in the report. It still fails a report with no gate. Known gap: a report that only restates "split, accept with a reason, or cut scope" also passes.
- Full suite on this version: 91 cases with `-j 4`, 79 pass, 2604 s. Each failure ran twice more here and twice on 7.2.0. Four cases failed more often here. More runs settled three of them.
  - `pr/broken-promise` passed 3 of 3, and `plan/triage-estimates-size` passed 2 of 2.
  - `pr/review-gate-for-colleague` passed 2 of 2 after its grader fix, in the next bullet.
  - `pr/nothing-worth-adding` stays open. Its `verdict-in-chat` judge failed 3 of 11 runs here and 0 of 10 on 7.2.0. The kept failing reply meets the rubric, so the case is accepted as not a new failure. A follow-up ticket will make the rubric say that a reply can name an unverified outside risk without counting it as a finding.
- `pr/review-gate-for-colleague`: the grader `new-apart-from-raised` now passes correct reviews that name the new findings in other words. It allows up to three words between the noun and "are new" or "sono nuovi", but no relative pronoun. A guard rejects "non" or "not" right before the verb, so "Due problemi qui sotto non sono nuovi" fails. It also allows "nessuno li ha sollevati". The miss was not new: the grader failed once on 7.2.0 too. The new pattern passes two real reviews and four hand-written correct samples, and fails eight wrong samples.
- Spend: $134.75 in all ($66.79 for the full suite, $17.72 for a stalled rerun batch, discarded, $36.73 for the reruns on both versions, $13.51 for the runs that settled the four cases).

## [7.2.0] - 2026-11-13

Research reads the code it relies on in both directions and as it really behaves, the interview settles the frame before its questions, rounds catch what the review would block before the code, and `pr:review` submits the review with the event you choose. Kit 7.2.0, minor: new behaviour; `pending` stays available as a mode, and nothing is posted without your yes.

### Principles

- § The method: a recommendation follows its kind only when the decision clearly fits the kind's own case; a neighbouring case cites no kind, or names it as a weak fit.
- § Verify, don't assume: a test drives the production caller in the shape the guide or the plan tells users to write it, and a check is seen failing on the likeliest wrong inputs, alone and, when it guards several rules, together.
- § Repository rules are inputs: the rules that apply are found by the files touched and by what the change does (a rollout, text agents or users read, a schema), the repository's agent instructions included.
- § Always in a worktree: once the session works in a worktree, data-root files are written with the Write tool or one plain command per call, never a compound shell command.
- § Language: a text addressed to a colleague states the problem, its evidence and the options, and leaves the decision to them. The rule moved here from `pr:comments`, so `pr:review` drafts follow it too.
- `docs/question-format.md` § When to ask: a question that can cut the work (which parts of a bundled request go in this change) is asked alone and first, like one that can stop or postpone it, before research goes deep on that part; a request to explore or prototype gets the alternatives in chat, and the interview waits for the reply. § Shape: a choice of several items (reviewers, files) is one multi-select question; an option that fixes something names each case that happens today which it changes.
- `docs/review-lenses.md`: new Rules lens.

### Plan (`plan`)

- `scope` step 2: related tickets include the closed and cancelled ones of the same label or project, with why they closed; a bundled request gets the scope question first; the "understand first" report opens with the mechanism and one concrete case, then whether the work is worth doing against those outcomes, then the data.
- `scope` step 3: the search covers both directions of the code the plan relies on, replaces or renames, the values each writer writes, the settings turned off on purpose, and what the unchanged path shares with the changed code; the analysis checks the plan's assumed values against them, and each deliberate setting the plan changes becomes an interview question.
- `scope` step 4: the frame is settled first (question format). Step 6: the plan review attacks premises about shared state values, and makes sure that every bar command ran on main and was tried on a wrong input, and that every new interface compiled once against a real caller.
- `round` step 3: the test of each item follows the shape users are told to write; items step 4's check changes are estimated again before executing, and the drift gate asks again when the estimate grew since step 2 asked it. Step 5: the S lane makes its changes only once the round file is written.
- `triage-check.md`: new item 7, the review lenses hold for the change each item plans.

### Pull requests (`pr`)

- `review`: new default mode `submit`; `pending` stays as a mode, and `summary` now submits too instead of staying pending. At the gate the kit recommends the event: `COMMENT` by default, `APPROVE` when only notes or blocks too small for another round trip are left, `REQUEST_CHANGES` only for a serious problem. The head is read again before the drafts and right before posting. The verdict names the findings no one raised first. Rules load by what the change does. Step 9 is the closing step, before any watch. New step 10: on your yes at the gate to a submitted review, a background poll watches a colleague's PR, and a follow-up review runs from the saved analysis when the author tags you or requests your review again; it submits `APPROVE` on its own only if you allowed it at the gate.
- `comments`: the colleague-reply rule now points to the principles.

### Improvement loop (`improve`)

- `run` step 7: at the ship question, when `origin/main` moved past the worktree's base, the run lists what changed in the files the cases read, merges, and reruns only the cases those changes touch.

### Evals

- Nine new cases, run once on 7.1.0 and once on this version. Two reproduce their notes: `plan/test-in-documented-shape` (a `--triage-only` round for a helper whose guide puts each entry in its own feature module; 7.1.0 tested only inline entries, this version names a test built as the guide says) and `pr/review-gate-for-colleague` (a colleague's PR with a default-off gate rule in `CLAUDE.md` and an open bot thread; 7.1.0 proposed a pending review with no event and did not count the new findings apart from the bot's, this version recommends `COMMENT` and says the two blocks are new). Seven already behaved on 7.1.0 and stay as regression checks: `plan/research-reads-both-ways`, `plan/scope-cut-asked-first`, `plan/prototype-stays-in-chat`, `plan/understand-first-worth-it`, `plan/kind-must-fit`, `plan/triage-check-reuses-helper` and `plan/s-lane-file-first`. On this fixture, 7.1.0 already asked the scope cut first, but its research had counted the 37 toolbar entries the cut drops, which no grader measures.
- Graders fixed after trying them on the kept runs: `kind-must-fit` first failed a correct 7.1.0 answer that named K31 and said it did not apply; `scope-cut-asked-first` missed a correct first question headed "Perimetro"; `no-github` matched the command text written into `review.md` instead of a real call. After the fresh review, which wrote its own near misses and correct answers, every regex grader of the nine cases is anchored on its fact and a verdict word on the same line: `shared-label` needs the label helper named as shared with the flag-off path; `deliberate-setting-asked` now reads `plan.md` and passes a plan that keeps the setting with its reason, not only one that asks; `reuses-helper` needs the helper named as the owner or the callee; `test-follows-guide` skips lines marked check only or inline; `event-recommended` needs a recommendation word next to the event, so the 7.1.0 pending proposal fails; `new-apart-from-raised` counts new blocks or findings; `no-prescribed-plan` fails "split it into" but passes a question; `rule-by-behaviour` needs the missing gate raised as a problem; `no-github` also catches `gh pr review`. `scope-cut-asked-first` and `understand-first-worth-it`'s verdict became `llm` graders on short files, since their facts (the first question, the order mechanism, verdict, data) do not fit a regex. Each corrected regex passes the kept correct answers of both versions and the review's correct samples, and fails the kept wrong answers and the review's near misses (node, the harness's flags).
- No case covers the data-root writes from a worktree (the sandbox has no worktree guard), the ship step of `improve run` (it needs a real repository and a moving `main`), the watch of `pr:review` (it needs GitHub), the estimate after the triage check, or the multi-select reviewer question (both come only after an executed check or a ready-for-review gate, which a sandbox round does not reach).
- After the review fixes, the nine new cases pass 9/9 on this version (one run; `review-gate-for-colleague` after its grader also accepted "non le ha segnalate nessuno", tried on the kept runs of both versions).
- Full suite on this version before the review fixes (85 cases, one run): 73 passed. Three failures were the new cases with their first graders, now fixed. The other nine ran twice more on this version and twice on 7.1.0: `constitution-question-explicit`, `baseline-and-callers` and `duplicates` 2/2 on both; `own-pr-fresh-review` 2/2 here and 1/2 on 7.1.0; `run-report-plain`, `invariant-clause-pinned` and `run-carries-blocks` 1/2 on both (`run-carries-blocks` stops before round 2 in one run of each); `options-start-from-user` 1/2 here and 2/2 on 7.1.0 (2 of 3 at the 7.1.0 release); `design-options-offered` 0 of 3 runs here and 1/2 on 7.1.0 (1/2 at the 7.1.0 release). Its kept runs here offer a derived view that keeps `MessageList.items` whole, or a separate endpoint, which the rubric names as an equivalent, but the judge fails them; the harness flags the 8,000-character file as too long for an `llm` judge. It stays for a later note, with the grader of `deferred-row-verified` that 7.1.0 named.
- Spend: $111.29 in all ($15.91 for the nine new cases on both versions, $61.98 for the full suite, $7.50 for the new cases after the review fixes, $25.90 for the reruns on both versions).

## [7.1.0] - 2026-11-09

Questions are read as you will read them before they are sent, and eval graders are tried on samples their author did not choose alone. Kit 7.1.0, minor: new behaviour, nothing you rely on changes.

### Principles

- `docs/question-format.md` § Shape: new "Before you send a batch, read it as the user, from the chat alone", without opening a file. The whole interview's decisions are counted first: decisions with the same recommendation (already covered, the same place, the same fix) become one question that lists them, each still open to a different answer, and a long exact text is pasted once in chat before the batch, never repeated in each question. "One decision per question" names this as its one exception.

### Improvement loop (`improve`)

- `run` step 4: the explanation of each group goes in chat, right before the questions; a report file is extra detail, never the explanation.
- `run` step 5.1 and `evals/README.md` § Lessons: a grader counts only after it fails the note's own wrong answer (its "What happened" and Evidence lines) and passes correct answers in other words from kept runs (`--keep-temp`) of the new version, and of the old one where it already behaved; a kept run that failed on the old version is a wrong sample, and a hand-written sample only adds to these.
- `run` step 6: the fresh review also runs each new or changed grader on one near miss and one correct answer it writes itself.

### Evals

- New `plan/questions-grouped`: a `--dry-run` scope whose ticket asks to decide twelve items, each with its problem, example, change and cost of a no. Six items are already done in the code, three are typos in one file, three are real decisions. Graders on `questions.md`: at most eight questions, the done items never spread over two questions (judged on each question's heading and its first two lines), and at least one question written. It cannot reproduce the note: on this fixture the old kit already listed the done items once and grouped the typos (1/1 after the fixture fix). The first fixture left two items half done, so the old kit asked about them, correctly, and failed 0/2 on the fixture, not on the problem. The note's miss came from a live interview of 24 kit rules with long exact texts, which a sandbox file cannot show. Kept as a regression check. After 1 of 2 runs passed: the failing run grouped the done items in one question and named one of them again to explain another question; the grader then narrowed to the heading and first two lines, and passes the three kept runs (one before, two after) and a hand-written answer, and fails one question per item and a split of the done items. After the fresh review: `few-questions` counts nine question headings instead of reading the highest number, so a numbering that restarts per section fails and a numbering after the items (Q1, Q9, Q11) passes; `covered-items-together` keeps two known limits the review found by its own samples, a done item named only four lines below its heading, and a short back-reference to the done items ("R2–R12 above") in a question's second line.
- No case pins the grader rule of `run` steps 5.1 and 6: it would need an improve run, with its own eval harness, inside the sandbox.
- Full suite (77 cases, one run): 70 passed. The 7 failures, rerun twice on this version and twice on 6.3.0: `free-answer-gets-an-answer` passes 2/2 on both; `small-task` 2/2 here and 1/2 on 6.3.0; `gated-actions-listed` 1/2 here and 0/2 on 6.3.0; `recommendation-rests-on-data` 1/2 here and 0/2 on 6.3.0; `nothing-worth-adding` and `design-options-offered` 1/2 on both (LLM judges). `deferred-row-verified` passes 2 of 6 runs here and 2 of 5 on 6.3.0: its `no-wrong-premise` regex fails correct answers on both versions, for example "`docs/realtime.md` unchanged", because the line names the file without a negation word. This change does not touch that grader; it stays for a later note.
- After the review fixes: `questions-grouped` 2/2; `free-answer-gets-an-answer` and `gate-explained-cold` 1/1; `options-start-from-user` 2 of 3 runs here and 0 of 2 on 6.3.0 (its `user-path-offered` grader: the user's path split across two questions, as the 6.3.0 entry describes).
- Where these numbers come from: every run above used this change built on 6.3.0, before the merge with 7.0.0. 7.0.0 changed only wording in the files these cases read (`docs/principles.md` § Language, the Pros and Cons line of `docs/question-format.md`, the style references and the List and Log form in `skills/improve/SKILL.md`) and nothing in `skills/plan/scope.md`, so the cases did not run again. The merged suite has 76 cases.
- Spend: $98.43 in all ($5.12 for the new case before and after the change, $52.63 for the full suite, $19.77 for the reruns of its failures on both versions, $8.37 for three more runs of `deferred-row-verified` on each version, $12.54 for the cases after the review fixes).

## [7.0.0] - 2026-11-09

The kit no longer ships output styles or sets the form of chat replies. The `my-language` mod, with its ITE and STE styles, the `/language` command and the ITE checker, is removed, and three modes stop prescribing tables and badges in chat: the language and form of replies come from the output style and the instructions you install outside the kit. Kit 7.0.0, major: `/my:improve note` no longer takes a `style:<name>` target, and the `my-language` plugin leaves the marketplace.

### Removed

- `mods/my-language/` (output styles ITE and STE, `/language`, `ite-check.py` and the mod's tests), and its entry in `.claude-plugin/marketplace.json`.
- `evals/language/` (`ite-report`, `ste-report`), `evals/improve/note-targets-style`, `scripts/evals-with-pack.sh` and its test, and the `/evals-*/` line of `.gitignore`.
- The README "Output languages" section, the mod's install, update and check commands, and its layout lines; the "Output style cases" section of `evals/README.md`; the ITE exception in `.claude/CLAUDE.md`.

### Principles

- § Language: the user's output style and own instructions set the language and form of text written for the user; the kit ships no style. `scripts/no-form-rules.test.sh` still guards that no kit text sets them.

### Improvement loop (`improve`)

- List and Log: each entry shows its id, skill, state and problem; the visual widget, the Markdown table and the emoji badges are gone, and the reply form comes from the user's output style. States stay the kit's English words. Closed entries follow the open ones under `Closed (<n>)`.
- `note`: a reply that only broke the user's output style is not logged. The reply says so in one line and names the style's plugin as the place to fix it. When a kit text asked for that form, the note goes against that text. `run` no longer reads style files or the ITE checker.

### Pull requests (`pr:comments`, `pr:sync`)

- `pr:comments` step 6: the chat gives each group's comments, explanation, class, weight and action, with no prescribed table; the `.plans/comments-<date>.md` file keeps its table.
- `pr:sync` step 10: the report gives each conflicted file with its class and resolution, with no prescribed table.

### Evals

- New `improve/log-follows-reply-style`: `/my:improve log` with a reply style that forbids tables, lists and emoji; the reply shows every entry with its id, state and problem, with no table and no badge. It also passes on 6.3.0 (1/1): a reply style in the system prompt already won over the skill's table, so the case guards that no kit text brings the conflict back. After 1/1.
- `improve/log-shows-problems`: the emoji badge and table-cell graders become one judged grader, `english-states`: each entry's state stays the English word in an Italian reply.
- New `improve/note-style-not-logged`: a note about a reply that used a list and bold text against the user's output style writes no suite log, and the reply says why. Before 0/1 (6.3.0 logged the note), after 1/1.
- Regression on 7.0.0: `improve/log-shows-problems` 1/1, `pr/uncertain-claim-reproduced` 1/1. The `pr:sync` cases did not run: only the wording of the report changed. Spend for this release: $1.85.

### Upgrade

- Run `claude plugin uninstall my-language@my-agent-kit`, and remove `my-language@my-agent-kit` from `enabledPlugins` in `~/.claude/settings.json` if it stays there. If a folder's `.claude/settings.local.json` or your `~/.claude/settings.json` still holds `"outputStyle": "my-language:ITE"` or `"my-language:STE"`, replace or remove it.

## [6.3.0] - 2026-11-06

Questions start from what you know and said; research follows every writer of what a plan hooks into; claims and proposals name the run that showed them; sync finds or prepares a clean worktree; a review explains the PR before its verdict; scope can stop after research when you want to understand first; every sub-command reads its own mode file; and eval graders are tried on both sides before they count. Kit 6.3.0, minor: new behaviour, nothing you rely on changes.

### Principles

- `docs/question-format.md` § When to ask: "Explore first, then decide" becomes "Show it, then ask": anything a question or its options name that the user has not seen in this conversation is shown first, new or existing (a feature with the steps to see it, a function or mechanism with what triggers it, an agent's role, today's values, a design still taking shape); a gate first says what the work found. "Show the case" merges into it.
- § Shape: new "The options start from the user": what the user already said about a choice is one of its options, in their terms; an option the code, the boundary or an earlier decision rules out is not offered (moved here from `plan:scope` step 3, so every mode has it). A guarantee of the kit alone never makes an option the recommended one, and an option that takes away a control the user has today (the session's model, the cost, when to stop) says so in its Cons. Before an option carries a number, look in the code for a mechanism that needs none (a promise that always settles, an event).
- § Verify, don't assume: the list of texts checked claim by claim becomes every text that reports a result or proposes a change, in chat or a file, yours or dictated to an agent; each claim names the run or read that showed it and says only what that run exercised; a proposed change says whether it ran against its area's tests, or "not run"; partial proof means a smaller claim.
- § The kit carries the plan it made: every change to the plan's work becomes a round, whoever starts it: a request, or the work left after a gate (a rollout step, a restart).

### Planning (`plan:scope`, `plan:round`)

- `plan:scope` step 2: when the user asks to understand the problem first, or the ticket asks for no code, scope researches read-only, explains, and stops with `needs_you` ("Go ahead?"); the worktree, the ticket move and the interview wait for the user's go.
- `plan:scope` step 3: research follows every field, state, key or rule the plan adds, changes or reads to start its own work, with every writer across the code base, not only the flow traced (also in the search agent's fixed list, the round's triage and the triage check); any code the plan runs, a throwaway variant included, is checked for what it writes and needs outside the process, tried once read-only before it touches shared data; the baseline also runs the CI jobs of the files the plan adds, and counts once on main that each scenario the bar measures holds what the change touches.
- `plan:scope` step 6: the plan review checks each rule the plan states (boundary, invariants, out of scope) against every step of every part and the CI jobs of the files it adds.
- Step labels and part short titles say what the work does in words, never a function, file or identifier name (`local-data.md` § State file, `plan:scope` step 8).
- `plan:round` § The state file: the `--running` steps of the open round are passed at every write until the one that ends it, the writes after the executor and during the review and the push included.

### Pull requests (`pr:review`, `pr:sync`)

- `pr:review` step 6: when no `/my:pr:learn` reading exists at the current head, the analysis opens with about five lines on what the PR changes and why, before → after, then the verdict; with a reading, a link to it.
- `pr:sync` step 1: it finds the branch's worktree; a busy or dirty one, or a session sitting elsewhere, gets a new detached worktree at `origin/<branch>`, entered as the principles say (`.worktreeinclude`, the profile's setup), and pushed with `git push origin HEAD:<branch>`. When the user asks for Auto-fix on a PR this session did not open, it says at the start that the user turns it on.

### Commands

- Each sub-command in `commands/` names the mode file to read before any other step (`comments.md`, `scope.md`, `round.md` § Run, …) or, for `improve`, its section; the `plan` and `pr` routers say to read the mode's file before any other step.

### Improvement loop (`improve`)

- `run` step 5.1 and `evals/README.md` § Lessons: a grader counts only after it was tried on both sides: it passes a correct answer in other words and fails a close wrong one.

### Evals

- New `plan/options-start-from-user`: a `--dry-run` scope whose ticket states, in the user's words, a temporary debug page kept in the same PR behind a flag and deleted before merge, an existing panel named only by its code name, and a proposal that overrides the session's model and cost limit. Graders on `questions.md`: the user's path is offered whole (one option holds the flag and the removal before merge, or the flag option sits in a question that removes the page before merge for every option), the panel is shown by the steps to open it, and the cons of the overriding option itself name the lost control. Before 0/2 (both runs split the path across two questions or never offered it). After the first wording of the rule, 3 of 6 runs offered the path whole and the others split it across two questions, so the rule now says "whole … even when it joins two decisions", with an example of its own; then 3/3.
- New `pr/review-explains-first`: `/my:pr:review` on a colleague's small PR with no reading; a before/after and the reason come ahead of the verdict. Before 0/1 (the analysis opened with the verdict), after 3/3.
- New `pr/sync-finds-clean-worktree`: the PR branch is checked out in another tool's dirty worktree, the session sits in the main checkout, and the user asks for Auto-fix on a PR this session did not open. Graders: a new worktree from `origin/<branch>`, the profile's setup before the merge, the busy worktree untouched, no gate on the new worktree, no merge commit, and Auto-fix named as the user's. The Auto-fix grader needs the user as the one who turns it on, and fails "Auto-fix attivato: non devi fare nulla" and "I turned on Auto-fix; you can relax". Before 1/3 with the Auto-fix request (the failing runs made no new worktree or put the setup after the merge, and did not name Auto-fix as the user's; without the request the old kit asked a gate and failed 2/2), after 3/3 with the final graders.
- `pr/human-review-explained` gains `mode-file-read`: an assistant tool call reads `skills/pr/comments.md` (by Read, `cat` or Grep). On the old kit the file was read in 3 of 3 runs, so the 3-of-8 failure did not reproduce; the grader guards it. After 3/3, and 1/1 in the full suite.
- New `plan/step-labels-plain`: a round fills `short` and `steps` from a plan whose steps are code identifiers; no label is a code name. It passes on the old kit too (2/2: the coordinator already wrote words); code names come only from `state-steps.sh`'s fallback when nobody writes a label. Kept as a regression check.
- Graders fixed and tried on both sides with saved runs and hand-written samples: `plan/option-cost-priced`'s `options-priced` takes the Italian forms of the same idea ("ri-rasterizza", "rasterizzato di nuovo", "da capo") and no longer matches "pan" inside a longer word; `improve/run-report-plain`'s `case-before-change` allows a Markdown heading between the case and the missing question, and `says-time-cost` takes "ogni round … minuti" and "minuti in più per round"; `plan/state-says-what-is-left` replaces its Haiku judge with three regex graders on the state file, independent of whitespace and line layout. After: 1/1 each, then `run-report-plain` 2/2 (the old kit 0/2 on this case).
- No case pins these changes, each for its reason:
  - research that lists every writer and the CI jobs of new paths: on a small fixture the old kit already found the hidden writer and the job (2/2); the note's miss came from a large code base;
  - understand first: the eval sandbox has no working git, so the old kit never reaches the worktree step (2/2 passed);
  - the review after a gate: the old kit already reviewed the work left after a gate when `/my:plan:run` resumed (1/1); the note's miss came from a long live session;
  - claims that name their runs: the old kit already flagged an unsupported round summary (1/1); the note's miss came from texts the round does not check;
  - the `--running` steps at every write until the round ends, and the grader rule itself.
- Full suite (76 cases, one run, Claude Code 2.1.290): 66 passed. The 10 failures, rerun on this version and on 6.2.0: `failed-step-cleared`, `failed-step-reset`, `broken-promise`, `own-pr-fresh-review`, `approval-states-drift` and `run-report-plain` pass 2/2 here (the last two fail on 6.2.0: 0.70 and 0.58); `recommendation-rests-on-data` (1/2 here, 0/2 on 6.2.0) and `small-task` (1/2 here, 2/2 on 6.2.0) fail on a different grader from run to run; `design-options-offered` passes 3 of 6 runs here and 3 of 5 on 6.2.0 (an LLM judge on a long file); `run-carries-blocks` passes 4 of 5 here and 4 of 5 on 6.2.0 (one run timed out at 300 s). After the review fixes, a second full suite: 66 of 76 passed. Of its four new failures, `clause-pinned-both-sides` and `gated-actions-listed` pass 2/2 here and on 6.2.0, `run-finds-upstream-lesson` fails now and then on both (1/2 here, 0/2 and 1/1 before on 6.2.0), and `skipped-rework-stays-done` passes 2 of 7 runs here and 3 of 5 on 6.2.0: in the failing runs, on both versions, the coordinator reads the executor's skipped rework as an item to blame and unticks its step; this change does not touch that step, and the difference is within what this many runs can tell apart, so it stays an open question for a later run.
- The review found that the first Auto-fix grader passed the wrong answer and that two graders of `options-start-from-user` passed near misses ("no flag needed", a Cons line on another option); all three were rewritten and tried on both sides with the kept runs and the reviewer's samples.
- Spend: $193.26 in all ($15.15 for writing the cases and their before-runs, $6.72 for the pr cases' after-runs and the sync case's rerun, $53.36 for the first full suite, $37.06 for the reruns of its failures on both versions, $20.33 for the question and sync cases after the review, $44.21 for the second full suite, $16.43 for the reruns of its new failures).

## [6.2.0] - 2026-11-06

The kit now names, in one table, the model each agent it starts runs on. Agents that only search and decide nothing run on Sonnet (unless the session runs on a cheaper model), which costs less; every other agent keeps the session's model, so the model you choose for the session still sets the cost. Each round outside the S lane also saves its triage before the triage check, and every round saves the round review's inputs before the review, each with the answer that followed, so a later trial can test the check and the review on rounds whose answers are known. Kit 6.2.0, minor: new behaviour, nothing you rely on changes.

### Principles

- New § Which model an agent runs on: `docs/model-choice.md` names it, one row per agent the skills start; an agent it does not name keeps the session's model, and no skill names a model itself.
- New `docs/model-choice.md`: the table (role, where it starts, model, why, the model version tested). The research search agent runs on `sonnet` (checked on claude-sonnet-5-5 by `plan/research-search-on-sonnet`, size M, 2 of 2; no A/B); the research analysis agents, the plan review, the triage check and the round review (both "A/B pending on captured rounds"), the executor, the deep review's outer agent, the `pr:review` agents, the `improve run` review and any other agent keep the session's model. A Sonnet row passes `model: "sonnet"`, except in a session whose model is cheaper (Haiku), where it passes none. § Fallback: a Sonnet agent whose result omits an item of its list, or gives a claim without `file:line` evidence, runs once more with the same prompt on the session's model; an item answered `unknown` (no `gh`, no git, no access) is no reason to rerun. § Tested: when the `sonnet` alias moves to another model, the tests or the A/B named in a row run again. § Pending: the triage check's A/B waits for at least 3 saved rounds, the round review's for at least 3 saved rounds with block findings.
- `docs/local-data.md`: the data root gains `trials/`, private material for the kit's own trials.
- `docs/principles.md` § Where files go: the content of saved trials joins the personal material that stays private.

### Planning (`plan:scope`, `plan:round`)

- `plan:scope` step 3: research for M and L runs in two phases. First one search agent, whose prompt opens with "Search only, decide nothing", answers a fixed list, each item with `file:line` or `unknown: <what could not be read>`: the callers of the shared code by path with untruncated counts, open PRs on the paths, CODEOWNERS and branch rules, the rules to load, and the test or code that pins each behaviour the ticket describes. Then up to two analysis agents, given its answers: how things really work, the consequences, which rule decides each case, failure paths and the baseline. At most three agents, as before; what research collects does not change.
- `plan:round` step 4: outside the S lane, before the triage check starts, the round file is copied to `<data root>/trials/triage-before-check/<owner>-<repo>-<branch>-round-<N>.md` (`-2`, `-3`, … for a later check of the same round); after the check, its report is saved next to the copy, as `…-round-<N>-check.md`.
- `plan:round` step 7: in every lane, before the round review starts, `plan.md`, `round-<N>.md` and `round-<N>-summary.md` are copied with `cp` into `<data root>/trials/review-before-check/<owner>-<repo>-<branch>-round-<N>/`, and the diff the review is given is written there as `round-<N>.diff` (`-2`, `-3`, … for a later review of the same round); after the review, `round-<N>-review.md` is copied there too.
- `plan:scope`, `plan:round`, `pr:review` and `improve` read `docs/model-choice.md` first, and every sentence that starts an agent points to it. The prompt files of the executor, the round review and the triage check do not change.

### Evals

- New `plan/research-search-on-sonnet`: a `--dry-run` scope of size M in an Opus session, with no git and no `gh`; one agent with `model: "sonnet"` and the search prompt, no agent on another model, and no rerun for the access gap. Before 0/1 (no Agent with `model: "sonnet"` and the search prompt), after 2/2.
- New `plan/triage-saved-before-check`: a `--triage-only` round of an M plan; the copy exists, and the `cp` runs before the triage check's agent starts. Before 0/1 (no copy), after 3/3: in each kept trace the round file is copied with `cp` into `trials/triage-before-check/`, then one agent with no `model` starts with the triage check's prompt pasted. The grader matches the `cp` itself (a `mkdir` of the folder no longer counts) and also a check started by reference to `triage-check.md`; `plan/added-item-checked` takes the same prompt match and still passes. The first grader, which matched only a pasted prompt, saw 2/3 (in the failing run the copy was saved, but no agent with the triage check's prompt was seen; trace not kept, cause not known). A later grader checks that the triage check's report is saved next to the copy (`acme-shop-feature-round-2-check.md`): before 0/1, after 2/2.
- New `plan/review-inputs-saved`: a `--verify 1` round of an S plan; the review's inputs (`plan.md`, `round-1.md`, `round-1-summary.md`, `round-1.diff`) and, after the review, `round-1-review.md` exist under `trials/review-before-check/acme-shop-feature-round-1/`; the saved diff holds the round's change; a `cp` into that folder runs before the review agent starts (by its pasted prompt or by reference to `reviewer.md`). Before 0/1 (nothing saved), after 2/2; `plan/round-reviewed-by-fresh-agent` still passes (1/1). Accepted limit: the order grader pins only the first `cp` before the review agent, not the diff's save, which may be a redirect or a Write.
- `plan/added-item-checked`, `plan/round-reviewed-by-fresh-agent` and `pr/own-pr-fresh-review` gain a `no-model` grader: the triage check, the round review and the `pr:review` agents start with no `model`. All three pass before and after.
- The ten `--dry-run` scope cases run again after the change, to check that scope research did not regress; they do not fix the size, and the only runs whose size was recorded, three of `plan/option-cost-priced`, were S, which starts no research agent. After the change, 8 pass; `plan/design-options-offered` fails as it did before the change; `plan/option-cost-priced` passed 3 of 5 runs (1 of 1 before). Of its three later runs, all S, the one failure wrote the researched cost in Italian wording the grader's regex misses; the cause of the first failure is not known. A scratch copy with the size fixed at M started the Sonnet search agent in 3 of 3 runs and an analysis agent in 2 of 3; its grader passed 2 of 3, the failure from the same kind of wording; all 3 runs stopped at the harness's default limit of 300 s (the case sets none; `plan/research-search-on-sonnet` sets 600 s).

## [6.1.0] - 2026-11-03

Plans, rounds and questions check what they used to take on trust: the plan review tests every claim the plan rests on, negative ones included; a round's tests pin both sides of each clause; an item added to a round in progress passes the triage check; a recommendation rests on data or on what the code beside the choice already does; and a change to the constitution is asked as its own explicit question. `my-language` 0.1.1: the ITE checker no longer counts quoted examples or text copied from the app as errors, and `/language` names the settings source that sets the active style. Kit 6.1.0, minor: new behaviour, nothing you rely on changes.

### Principles

- § Verify, don't assume: the user's own proposals are claims to check, like other agents' and your own.
- `docs/question-format.md` § When to ask: what the code beside the choice already does (a sibling path's behaviour, the naming of its neighbours) is the default stated in one line, or one of the options when the choice is still real.
- § Shape: "it keeps today's behaviour" or "it saves work" never makes an option the recommended one on its own; a number nobody can measure before the change (a cap, a cadence) is not invented, not even as a provisional or starting value: the recommendation is to try the change without it (measuring only) for a set time, then set it from the measurement, and to say so and ask when going without it is too risky. An option's Effect quotes any rule it cites as its source writes it; its Today says, for an action beyond the minimum (publishing outside the pull request, an extra step), what is lost without it. A change to `CONSTITUTION.md` is its own question, never an option inside another decision: it names the clause, shows today's text and the new text, and asks whether to amend the constitution that way.

### Planning (`plan:scope`, `plan:round`)

- `plan:scope` step 6: the plan review checks every claim the plan rests on, not only claims about existing behaviour; negative claims included (no test can observe it, nothing else reads it, it fails on main, no built-in feature does it), and for each it tries to build the case that disproves it, or the plan marks it unverified.
- `plan:round` step 3 "Pin each clause" and `triage-check.md` point 4: besides the test that fails when a clause alone is broken, the tests of its other side: an input the clause must let through (for a check such as a linter, a regex or a grader, the correct cases it must not flag), and each failure path (an error, a timeout) of a dependency the new work shares with existing code.
- `plan:round` step 4: only the S lane skips the independent triage check, also when a round of an M or L plan looks small; an item added to a round in progress goes into the round file first and passes the check before it runs.

### Improvement loop (`improve`)

- `run` step 3: when the user wants an amendment that a note needs, it is asked as its own question (question-format § Shape).

### Output languages: `my-language` 0.1.1

- `ite-check.py`: text in double quotes (straight, typographic, guillemets) is cited, not used: its words still count for the sentence length, a sentence end inside it still ends the sentence, and no form rule fires on them; on a line with an odd number of straight quotes (an inch mark) only typographic quotes and guillemets count. Each line is its own paragraph, as in a reply, so text copied from the app (list markers and headings lost) keeps its lines apart; a line with a tab is a table row. On a reply copied from the app (a measurement in this session, not kept in the repository) that gave 8 findings, 5 of them false, it now gives 4: the 2 long sentences, the soft "si ripete", and a list item of 7 sentences.
- `/language` without an argument reads the style from every settings source through Claude Code: managed and command-line settings win over the folder's file, project settings and the user default fill in when the folder sets none. The active line names the source (`active: ITE (user default)`) and the list marks that style; a source above the winner that cannot be read adds `(unverified: …)`; with no style anywhere it says `active: Default (no style)`.
- README "Measure a reply" says how quoted and copied text are read.

### Evals

- New `plan/clause-pinned-both-sides`: a round adds a checker that also reads a shared fetch; the triage names a correct input that must not be flagged, and a failed shared fetch. Before 1/2 (the run that failed named no input to let through; the failed fetch was pinned in every run, 4 of 4 over two designs), after 3/3.
- New `plan/added-item-checked`: the user adds a one-line item to a round in progress and asks to do it at once; the item goes into the round file and a fresh triage check runs. Before 1/2 (the failing run edited the code first and wrote the item afterwards, with no check), after 3/3.
- New `plan/recommendation-rests-on-data`: a cap on a new feature with no usage data, and a time window a sibling quota already settles. Before 0/2 (both runs recommended an invented cap of 24 a day; the window followed the sibling in both), after: with the first wording ("try the change, then measure") one run of five still recommended "starting at 24 provisionally", so the rule now says "not even as a provisional or starting value"; with it, 3/3 runs recommend no number and measure first (two of them failed a grader that missed "measure only" and "matches"; both graders were widened and checked against the real plans: the cap plans before the change still fail the cap graders, while the window grader passed before the change too, as a guard).
- New `improve/constitution-question-explicit`: a note whose only fix contradicts the constitution, and the user is open to amending it. Before 0/2 (the clause and the new text were shown, but no question asked whether to amend; "Defer" was recommended), after 3/3.
- No case pins these changes, each for its reason:
  - the plan review's negative claims: in 6 runs over three fixture designs, today's research already disproved negative claims planted in a ticket or a repository guide; the notes' failures came from claims the plan itself wrote, which a scope eval cannot plant;
  - the user's own proposals as claims to check, and an option's Today saying what is lost: both live in an interactive exchange (the user proposes, or decides whether to publish), which a non-interactive eval does not reach;
  - "it keeps today's behaviour" alone never recommends an option: `plan/recommendation-rests-on-data` covers the invented number, not this reason;
  - a failed shared fetch in `plan/clause-pinned-both-sides`: today's kit already pins it (4 of 4).
- Graders tightened after the review: `correct-input-not-flagged` no longer takes "never flagged" (it restated the bug); `triage-check-agent` matches only the triage check's prompt; `window-follows-sibling` reads a Decisions row; `cap-no-guessed-number` also catches a provisional number without a unit; new `amendment-not-bundled` fails an amendment asked together with "defer". The four new cases then passed 2/2 each.
- Full suite (69 cases, one run, Claude Code 2.1.290): 61 passed. The 8 failures, rerun on this version and on 6.0.0: `deferred-row-verified`, `gated-actions-listed`, `invariant-clause-pinned` and `broken-promise` pass 2/2 on this version; `design-conflict-stops` (1/2 on both) and `run-report-plain` (0/2 here, 1/4 on 6.0.0) fail on 6.0.0 too; `small-task` passes 3/4 here and 4/4 on 6.0.0, its failing grader differs from run to run; `human-review-explained` passed 3/8 here and 7/7 on 6.0.0: in the failing run the agent called `/my:pr:comments` but never followed it to the `pr` skill, so it never read `comments.md`, whose rule the grader checks; this version does not touch that path, and the gap is logged as a note.
- Spend: $111.11 in all ($19.88 for writing the four cases and their before-runs, $16.63 for the after-runs and the cap rule's reruns, $41.26 for the full suite, $26.52 for the reruns of its failures, $6.82 for the cases after the grader fixes).

### Project profile (outside the repository)

- The kit's profile counts 69 cases at about $41 a full run (2026-11-03), and says that a plan adding a part to the kit names how `/my:improve` reaches it (note target, eval cases, version).

## [6.0.0] - 2026-11-02

You choose the language and the writing style of everything Claude explains to you, in any session, with or without a `/my` command: the new `my-language` mod ships two output styles, ITE (simplified technical Italian) and STE (simplified technical English), and `/language` switches between them in the terminal and in the desktop app, from your next message. The kit itself no longer sets any language or sentence form: it keeps only its content rules (the why before the what, the question format, terms kept as they are), so two rule sets never overlap, and Claude Code puts the style in the system prompt, so each reply is written once, with no translation or rewrite afterwards. Kit 6.0.0, major: without the mod, or with `/language off`, the kit stops guaranteeing Italian replies, a behaviour you relied on. `my-language` 0.1.0, its first release.

Intentional changes:

- The kit no longer sets the language or the sentence form of text for the user, in every session.
- New mod `my-language` with the ITE and STE output styles and the `/language` command; the user-level default is ITE (`"outputStyle": "my-language:ITE"` in `~/.claude/settings.json`); a switch stays for the folder until switched again, and two sessions in the same folder share it.
- `CONSTITUTION.md` clause 7 amended (below).
- `.claude/CLAUDE.md` "English only" gains an exception: the ITE files of the mod hold Italian examples and word lists on purpose.
- Eval graders that checked the language or "plain words" became content graders, or moved to the style cases.
- `/my:improve` takes `style:<name>` as a note target.

### Constitution

- Clause 7 amended at the user's explicit request (2026-11-02): "It speaks the language I choose." The user chooses the language and the style of everything the kit explains, and can change them at any moment; the kit adds no rule of its own on the language or the sentence form of that text. It still explains the why before the what, and code and repository names are never translated. The reason: the language and style of what the kit explains come from the output style the user chooses (`my-language`), and the kit adds no language rule of its own.

### Principles

- The form rules are removed: "reasoning is in the user's language", "plain words" and "translated and summarised" leave `docs/principles.md`, `docs/question-format.md`, the skills, the commands and the templates; each line keeps its content part. An agent's report still reaches the user summarised, never forwarded as it is.
- § Language is rewritten: working texts (skills, prompts for agents, plans and `.plans/` files, hand-off files, commit messages, drafts, the band's labels) stay English; text written for the user has no language or sentence-form rule from the kit, only the active output style's; vocabulary is never translated, and a term is defined in one line at first use.
- Option labels for pros and cons stay required (content); their wording follows the active style.
- `docs/question-format.md` § Shape: every decision carries its own recommended option, also one that depends on another decision in the same message; the recommendation then states the condition, and a gate written in a report marks it the same way. With ITE, a size decision that depended on an earlier one came with no recommendation, and `plan/triage-estimates-size` passed 4 of 9 runs; after the rule, 2 of 3 with ITE (each reply recommends an option on the size decision; the failing run's recommendation sits above the split option, where the grader does not look) and 3 of 3 without a style.

### Improvement loop (`improve`)

- `note` takes `style:<name>` for a reply that broke an output style's rules (`style:ITE`, never `style:my-language:ITE`), and `mod` as before. `run` reads the style file, its cases in `evals/language/` and, for ITE, measures the quoted reply with the ITE checker; a fix to a style bumps the mod's version.

### Evals

- Language graders became content graders: `plan/skipped-item-caught` drops `language.md` and `chat-language.md` for a regex grader `summarised.md` (the report is summarised, not pasted: the reply holds neither the executor's table header nor an executor row); `improve/note-explains-why` drops `reasoning-in-italian.md` for `why-says-cost.md` (the note says what the problem cost: time, a reversed decision, rework), which fails on a cause-only line; `plan/free-answer-gets-an-answer`, `pr/budget-and-known-term` and `improve/note-logs-without-changing` drop the language from one criterion each.
- Judged graders that failed correct replies now check facts with regexes, and four regex graders accept more correct wordings: `improve/note-logs-without-changing` checks the entry's id and `open` state, its skill (`plan:scope` or `plan`) and its Expected, Suspected cause and Signal fields with regexes, and its judge keeps the other two criteria, in any language; `pr/budget-and-known-term`'s `page.md` judge became six regex graders (layer 0 with its count of blocking comments, at most five in-depth comments, both blocking comments named, the others as table rows, a link to the glossary entry, an unverified mark); `plan/gate-explained-cold`'s `drop-option-effect` takes imperatives such as "Togli", "Rinuncia a" and "Lascia … fuori", and its `store-option-effect` takes "in una sola regione"; `plan/triage-estimates-size`'s `gate-before-executing` takes a first-person recommendation ("Raccomando", "Consiglio di", not the noun after an article) and a recommendation up to two lines below the split line, while a question or "gate" must stay on that line; `pr/budget-and-known-term`'s `page-layer0` allows two words between the count and "blocking". Dropped and narrowed claims, no longer checked: the reply "summarises in its own sentences" (`summarised.md`); the page owes "at most 3 things", makes "one reasoning move", does not re-explain a known term at length beyond the glossary link, and invents no file contents beyond the unverified mark; the verdict in layer 0, and counts for weights other than blocking (`page.md`).
- New case `improve/note-targets-style`: a note about an ITE reply is logged as `style:ITE` (0/3 before, target `mod`; 3/3 after).
- New `evals/language/ite-report` and `ste-report`: a report with steps, the style's body as `append_system_prompt`, graded by regexes for the style's form rules only (ITE: no gerund, no "viene" passive, no "effettu-", sentences of at most 25 words outside table rows, numbered steps; STE: no contraction, no weak modal, no semicolon or em-dash, a vertical list). Without the style 0/3 and 0/3; with it 3/3 and 3/3. They grade form only (D24): ITE's one idea per sentence puts reasons in sentences of their own, which a word regex cannot see, so the "why" check stays in the kit's own cases. `packs.test.sh` checks that each case's text equals its style's body, in `prompt.md` or in `case.yaml`.
- New `scripts/evals-with-pack.sh <style>`: a git-ignored copy `evals-<style>/` of the suite with the style's body added to every case, run with `--eval-dir evals-<style>`; it approximates a session with that style.
- Baseline before any kit edit (Claude Code 2.1.290, Default style): 62 cases, 53 passed in one run, the 9 failures rerun 3 times; one baseline failure (`plan/state-says-what-is-left`). The full suite with no style and with ITE's text, against this baseline, runs at the release gate.
- Eval and measurement spend: $216.51 in all: $64.62 before the release gate ($51.50 for the baseline and its reruns, $1.63, $5.29 and $6.20 in the rounds after it), $109.98 for the release gate's checks, $34.19 for the grader fixes and reruns after them, and $7.72 for the recommendation rule's reruns.

### Scripts

- New `scripts/no-form-rules.test.sh` (with `scripts/no-form-rules.allow`, the lines that describe what the user types): no skill, doc, template, command or README line sets the language or the sentence form of text for the user.
- `scripts/check.sh`, and so the pre-commit hook, also runs the mods' script tests (`mods/*/scripts/*.test.sh`); `check.test.sh` proves a failing mod test fails it.

### Measurement

Six prompts (a round report, a question with two options, a term explained, a short chat answer, a failing test, an agent's report summarised), each in an Italian and an English version, one run per prompt and arm (one run took 323,716 input tokens in one turn, cause unknown; it was excluded and the four report arms were run again), `claude -p --model claude-opus-5-5 --tools ""`, the style's body through `--append-system-prompt` (close to the mod, not the mod itself). off-IT and ITE use the Italian prompts, off-EN and STE the English ones. Tokens in count input, cache creation and cache read; the ITE findings come from `ite-check.py`; the English forms are should/may/might/would/could, ";", "—" and contractions.

| Arm | Runs | Tokens in | Tokens out | Words | Time (s) | Cost ($) | ITE findings /100 words (hard+soft) | ITE sentence-length | English forms /100 words (count): modal · ; · — · contraction |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| off-IT | 6 | 24707 | 5202 | 1627 | 72.9 | 0.18 | 1.0 (9+8) | 3 | - |
| ITE | 6 | 30391 | 8121 | 1367 | 95.2 | 0.24 | 0.0 (0+0) | 0 | - |
| off-EN | 6 | 24424 | 4313 | 1809 | 66.5 | 0.17 | - | - | 0.6 (10) · 0.2 (3) · 0.0 (0) · 0.4 (7) |
| STE | 6 | 30518 | 3497 | 1468 | 53.7 | 0.16 | - | - | 0 · 0 · 0 · 0 |

- Each style's own size: ITE about 947 tokens, STE about 1,016 (the input of a styled run minus the off run on the same prompt).
- ITE: 16% fewer words, but output tokens rose 56% and time 31%, cause not measured. STE: 19% fewer words, output tokens and time each fell 19%.
- ITE's 20- and 25-word limits: no sentence-length finding with ITE, 3 without it. The replies read as short sentences, sometimes repetitive ("Il sistema scrive le note di rilascio. Il sistema usa i titoli delle pull request."); one run each, so a later style version may revisit the limits.

| Prompt | Arm | Tokens in | Tokens out | Words | Time (s) | ITE findings /100 words (hard+soft) | ITE sentence-length | English forms /100 words: modal · ; · — · contraction |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| report | off-IT | 4215 | 726 | 224 | 10.7 | 1.0 (2+0) | 1 | - |
| report | ITE | 5162 | 1422 | 191 | 16.1 | 0.0 (0+0) | 0 | - |
| report | off-EN | 4099 | 597 | 247 | 9.2 | - | - | 0.4 · 0.4 · 0.0 · 1.2 |
| report | STE | 5113 | 437 | 193 | 6.3 | - | - | 0 · 0 · 0 · 0 |
| question | off-IT | 4153 | 1284 | 386 | 16.2 | 2.3 (2+7) | 1 | - |
| question | ITE | 5098 | 1818 | 300 | 18.0 | 0.0 (0+0) | 0 | - |
| question | off-EN | 4076 | 932 | 466 | 12.0 | - | - | 0.2 · 0.2 · 0.0 · 0.0 |
| question | STE | 5091 | 725 | 347 | 9.6 | - | - | 0 · 0 · 0 · 0 |
| term | off-IT | 3994 | 1127 | 397 | 14.8 | 0.4 (0+1) | 0 | - |
| term | ITE | 4942 | 1482 | 272 | 16.7 | 0.0 (0+0) | 0 | - |
| term | off-EN | 3984 | 993 | 452 | 13.4 | - | - | 0.9 · 0.0 · 0.0 · 0.9 |
| term | STE | 5001 | 734 | 353 | 12.4 | - | - | 0 · 0 · 0 · 0 |
| short answer | off-IT | 3981 | 205 | 76 | 5.1 | 0.0 (0+0) | 0 | - |
| short answer | ITE | 4933 | 223 | 76 | 5.9 | 0.0 (0+0) | 0 | - |
| short answer | off-EN | 3969 | 202 | 78 | 4.9 | - | - | 0.0 · 1.3 · 0.0 · 0.0 |
| short answer | STE | 4985 | 242 | 105 | 4.7 | - | - | 0 · 0 · 0 · 0 |
| failing test | off-IT | 4099 | 1233 | 327 | 16.9 | 1.6 (5+0) | 1 | - |
| failing test | ITE | 5048 | 1560 | 279 | 19.7 | 0.0 (0+0) | 0 | - |
| failing test | off-EN | 4073 | 1069 | 332 | 18.8 | - | - | 0.6 · 0.0 · 0.0 · 0.0 |
| failing test | STE | 5090 | 825 | 261 | 11.8 | - | - | 0 · 0 · 0 · 0 |
| agent summary | off-IT | 4265 | 627 | 217 | 9.2 | 0.0 (0+0) | 0 | - |
| agent summary | ITE | 5208 | 1616 | 249 | 18.8 | 0.0 (0+0) | 0 | - |
| agent summary | off-EN | 4223 | 520 | 234 | 8.2 | - | - | 0.9 · 0.0 · 0.0 · 0.0 |
| agent summary | STE | 5238 | 534 | 209 | 8.9 | - | - | 0 · 0 · 0 · 0 |

### Output languages: `my-language` 0.1.0

- Two output styles in `output-styles/`, each with `keep-coding-instructions: true` and the same scope sentence: the rules cover every text written for the person to read (chat, reports, questions, notifications, chapter titles, study pages, signals, the reasoning in log notes); code, commits, plans, prompts for agents and drafts for other people keep the repository's rules. They hold form rules only.
- ITE, simplified technical Italian: one idea per sentence; at most 20 words in an instruction, 25 in a description; active voice; the `tu` imperative; no gerund, no "viene/vengono" + participle, no passive "si", no support verbs, at most two chained "di", no construction that needs the congiuntivo, no idioms; examples in Italian.
- STE, simplified technical English in the spirit of ASD-STE100, adapted from AminBlg/SimpleEnglish (MIT, credited with its source commit in `THIRD-PARTY.md`): imperative procedures, at most 20 or 25 words a sentence, no contractions, no should/may/would/might/could, no semicolons or em-dashes, a strict mode for compliance. It says it is not the official standard and ASD did not certify it; ASD-STE100 is a registered trademark of ASD.
- `/language` lists the styles and `off`, marking the active one; `/language <name>` writes `outputStyle` (`my-language:<name>`) into the folder's `.claude/settings.local.json`, keeping every other key, and the style applies from the next message (Claude Code's settings watcher picks it up about a second later); `off` writes `default`. An unknown name, or a settings file that is not valid JSON, writes nothing and says why. The command answers without a model turn, and the mod hooks no prompt event (only `session.start` and `command.run`), so the organization's built-in guard does not block it. The choice survives `/clear` and `/compact` (checked live in the desktop app).
- `scripts/ite-check.py` measures a reply against ITE's rules: one finding per line and the findings per 100 words; it never blocks. `scripts/packs.test.sh` checks every style's front matter, scope sentence and notice, that no style holds a content rule, and that the eval cases carry each style's text exactly; `scripts/ite-check.test.sh` fires each checker rule on a wrong sample and keeps it silent on a clean one. `claude plugin test mods/my-language`: 22 tests.
- Leave Claude Code's own `language` setting at its default: once set, it adds a second language rule beside the style.

## [5.8.0] - 2026-10-30

Fifteen fixes from 31 open notes: plans research deeper and try their checks first, the user sees cases before questions, each promise of a plan gets a test per clause, the band's statuses and the kit's ids are produced by scripts instead of by hand, and reviews judge a PR as it is. Kit 5.8.0, minor: new behaviour, nothing you rely on changes incompatibly. `my-status` 1.0.1, patch: a fix.

### Planning (`plan:scope`)

- Research also checks what happens when new work fails or times out, what bounds it, which writers run at once, whether clients already deployed accept what the change sends in the rollout order, and whether new state mirrors a source it can be derived from. For the cases the change means to move, it classifies which rule decides each one today and checks the change reaches it.
- The rules to load include the repository's own rule files and the tests that enforce them.
- The baseline runs the local command of every CI job on the touched paths, and every command the bar relies on runs once in the worktree with its prerequisites; one that needs a later authorisation runs its safe part.
- The approval summary says how far the plan moved from the ticket's ask, and lists the follow-ups already consolidated.
- A part's short title is at most 16 characters, so it shows under its part in the band.

### Questions (`docs/question-format.md`)

- "Explore first" covers behaviours and premises too: two or three of the user's own cases walked through, with what is proven and what is not, before the questions. A question that can stop or postpone the work is asked alone, first. An option's effect names every place it shows.

### Rounds (`plan:round`, `plan:run`)

- The triage pins each invariant or boundary clause an item touches with a test that fails when that clause alone is broken; "flag off equals main" covers what runs, not only what renders; a copy of an approved artefact is diffed against its frozen source; a rule rewritten in prose lists every other sentence stating it.
- Claims in "Not this round" and in rows carried from earlier rounds are verified like items; a claim about a comment, a ticket or a doc is quoted from it. The triage check looks at both.
- Parts go in plan order: the default source is the open block findings, then the next unfinished part in plan order, and a round that takes a later part first says why ("next round" is not a reason).
- A review note on a text the next round rewrites goes with that item.
- A run that stops on a decision explains it after its summary so it can be answered cold: the terms, why the plan needs it, what each option changes.
- The chapter title's goal is in the user's language.
- New `scripts/state-steps.sh` derives the state file's step and part statuses from `plan.md`'s boxes, the running steps passed by the coordinator, and a kept failed mark; `plan:scope` and every `plan:round` write call it, so no status is set by hand.

### Principles

- A text that reports findings (a plan or a question written mid-run, a summary, a comment draft, a deferred row) is checked claim by claim against its source before it is reviewed or shown.
- A worktree is created and set up with absolute paths or `git -C`, never a `cd`, which would make EnterWorktree refuse.
- Text the kit writes into the app (chapter titles, notifications) is in the user's language.

### Reviews (`pr:review`)

- The verdict judges the PR at its head: facts about its base (another open PR, the merge order) are information, not conditions. The drafts state the current state, with no thanks for fixes and no courtesy praise; a point a newer commit fixed leaves them.

### Improvement loop (`improve`)

- New `scripts/append-entry.sh` appends a log note or a method kind numbered under a lock, so two sessions writing at once never share an id, and lists duplicate ids. `note`, `digest` and the method use it. The log entry template's heading is `## <id> · <skill> · open`.
- `list` first reports ids held twice in the log or the method. A method row is rewritten under the same lock.
- `run` writes its whole report for a reader who never saw the notes: each group opens with a concrete case of what went wrong and the notes it joins, then what changes for the user and what it costs in time, then the rule quoted in its own words and the change; each option's cost is in the user's time first.

### Scripts

- `scripts/check.sh`, and so the pre-commit hook, also runs the scripts' own tests, with git's hook variables cleared: inside a hook, `GIT_DIR` and `GIT_INDEX_FILE` would point a test's scratch repositories at the kit's own. `drift.test.sh` clears them itself too.

### Evals

- 13 new cases, one per fix that an eval can reach; five of them (research failure paths, CI checks in the bar, the invariant clause, the deferred row, the decision explained cold) already pass on 5.7.0 with small fixtures and stay as guards. LLM judges that failed good and bad replies alike were replaced by regex graders checked against every collected reply. `run-finds-upstream-lesson` accepts synonyms of "same cause" and the rule's other sentence. Not reachable by an eval (no question tool, chapter tool or worktree in the sandbox): the question order, the chapter title's language and the worktree without `cd`.

### Status band: `my-status` 1.0.1

- Fixed: with the steps open and the room short, a part half done (a step done, none under way, as at a gate) folded into an "n to do" chip like a part not started, counting all its steps. Only parts with every step to do fold now.

## [5.7.0] - 2026-10-29

The status band shows the approved v2 design from real data: pictures on the desktop and characters on the terminal, each part's steps, how long the work has run and has left, and the session's background agents; the kit writes every datum it shows. Kit 5.7.0, minor: the state file gains fields, and nothing you rely on in the skills changes incompatibly. `my-status` 1.0.0, major: the band changes incompatibly.

### State file and plans

- `docs/local-data.md` § State file gains `startedAt`, `parts[].short` (the part's title after "Part X:" in two or three words) and `parts[].steps` (`{ label, status }`, the label in two or three words, the status `todo`, `running`, `done` or `failed`), and `rounds[]` gets a writer. The band rule becomes "never the work's name or the plan title; part titles and step labels, two or three words each, it may".
- `plan:scope` writes `startedAt` at step 1, and at step 8 each part's `short` and `steps`. It no longer writes `parts[].left`, which `steps` replaces; the mod still reads `left` from older files. `startedAt` is carried from the session's planning file into the branch's file only when the branch's file has none, and a file left by a finished plan (`state: "done"`) counts as having none, so a new plan starts afresh.
- Step statuses are derived, not set by transitions: every write derives each step's status from `plan.md`'s boxes and the open round, the first that holds: `failed` while it is already failed and its box unticked; `running` while an item of the open round implements or reworks it, a ticked step included; `done` when its box is ticked; else `todo`. The parts' `status` and `done` follow from the boxes.
- `plan:round` appends `{ n, startedAt }` to `rounds` at a round's start (with `--verify N`, only when round N has none) and sets `endedAt` and `verdict` at its end; a gate pauses the round and does not end it. On a failed verification it sets `stopped` with a two-or-three-word reason, marks the step of the item to blame `failed` and unticks its box, whoever ticked it and in whichever round. A `failed` step clears when the next round starts. A file an older version wrote gets `short` and `steps` from the plan first.

### Status band: `my-status` 1.0.0

- The prototype approved on 2026-10-28 replaces the one-row band. On the desktop the band is pictures, in their own colours for the light or dark scheme: the header (state, a second line with the part and step, up to three figures with captions: steps done, time left, elapsed), the parts as capsules with a segment per step and a label row of letters and short titles, the steps opened under them by a chevron, the background agents, and an action row in the bottom-right corner with Open plan in the corner. Blank Buttons lie over the pictures that are controls. On the terminal the band says the same in characters. An adapter reads the real state file in place of the prototype's fake data; part of the drawing follows an MIT-licensed mod, credited in the code.
- On the desktop, text is fitted by whole words and whole pieces: the second line drops whole pieces, a short title shows whole or not at all, labels wrap, an agent's task shows the words that fit, and its running tool shows whole, then without the argument's folders, then its name alone. An agent's task is first limited to its whole words within 60 characters (a first word longer than 60, to its first 60), a running tool's argument to its first 60 characters; a single word wider than its room is drawn whole past it. When the band is taller than `maxRows`, the agents fold to their head, then, with the steps open, each part not started shows as one "n to do" chip; past that the app scrolls. When you open both the steps and the agents and they do not fit, the agents stay open and the band scrolls: the user's choice at the live check, over letting the last one opened fold the other. The terminal folds the agents when its rows run out and cuts the second line, the label row, the step rows and the agent rows (before their time) at their end when too long for its width; the other rows are not cut, so the header, which needs up to about 80 columns with three figures, and a part's capsule, which needs a cell per step in its column, do not fit a narrower terminal. Fitting them to the width is left for later.
- A state file written by 5.6.0 still draws: numbered segments from `done` and `total`, labelled from `left`, the short title from the heading after "Part X:" (the letter alone when it does not fit, on the terminal too), the time left "estimating…".
- Kept as they were: how the state file and its sidecars are found, the 6-hour staleness, the PR comment and conflict checks with their 10-minute cache, the status line's format, buttons that fill the prompt and never submit, `/my-status` and the Open plan pane.
- Calibration: 24 px per app row and 8.33 px per column, estimated from screenshots; `/my-status measure` reports them and what the band last measured.
- Fixed: the time left keeps both units when its two ends differ. 5.6.0 showed "~48–2 h" for 48 minutes to 2 hours; 5.7.0 shows "48 min–2 h", and drops the first unit only when both ends share it ("10–19 min", "2–3 h"). The status line shows the same text.
- Live check on 2026-10-29, the band side by side with the approved prototype: every state matched it; the time-left format was fixed (above); the signals were not checked live, and the tests cover them.

Intentional changes:

- The band's look and layout change entirely, and the hover hint of 5.4.0 is removed: the steps open under the capsules instead.
- The band shows part short titles and step labels; the rule is "never the work's name or the plan title". The band's own text follows it; an agent's task shows as its spawner described it, and the Open plan pane keeps the plan's title as its title.
- New PR comments and conflicts with main are no longer states of their own: they are "Review comments (n)" and "Conflicts with main" with "Merge main" in the action row, beside the state's actions, and extras in the status line (`my: Ready · 3 comments · 2 kit notes`).
- Running no longer shows the round number nor the executor's item progress: the percentage counts the plan's steps only. The progress sidecar's `items` is no longer read; its `updatedAt` still keeps a running file fresh.
- Status-line words follow the prototype: "Ready" (no longer "Round N done"), "Done" (no longer "Bar met"), the time left without "~".
- The background agents of the session (task, model and effort, tool in use, time) show below the band, only while there is kit work: a plan's state file, or a `pr:*` or `improve run` activity. In Running, and only then, the state mark, the step under way and the running agents pulse, with a still copy under reduced motion.
- The "next" step Ready outlines is derived by the mod (the first step to do), not written by the kit. Reasons stay two or three words, as the kit writes them.
- A part takes its letter from a "Part X" heading, else from its position (A, B, …); its short title comes only from such a heading, never from a plan title.
- Decided while porting, and recorded here: Ready before any round reads "Plan approved"; a Needs you or Stopped header with no step under way or failed shows the next step, and Running the first step not done; the percentage needs steps and the time left needs parts, so a plan without them shows the elapsed time alone; Done's total time is the last round's end minus the start, and does not tick; an activity shows its mode and the time since the mod first saw it, with no actions and no comment or conflict extras; Open plan shows in Ready, Running, Needs you, Stopped and Done, and in Planning once the plan file exists, and does nothing when the state file has no plan path; a running file untouched for 6 hours is ignored even with new comments, so the band shows nothing (before, the comments showed alone).
- New: Show question. In Needs you, when the newest assistant message the transcript drew has scrolled out of view, the band offers Show question, which scrolls back to it (with none seen, a toast says so); in view, it says "Answer in the chat below ↓". The test harness cannot scroll a transcript: the tests pin that the press reaches the scroll. Its tracking of the newest message resets when a session starts.
- New: `/my-status measure`.

Tests: `claude plugin test mods/my-status` mounts the band through the engine, on both surfaces, from state files read through the mod's own lookup: 47 tests before, 55 after. The old view code and its tests leave together; the tests that pinned columns, the drop order and the hover hints go with them, and four behaviours they pinned moved to the band tests: a stale activity draws nothing, a file without `updatedAt` never goes stale, a reason shows only in Needs you and Stopped, and buttons carry names, the commands only behind them.

### Evals

- `plan/state-says-what-is-left` extended to the new shape (steps with their status, short titles, the round's end): 0.5 and 0.5 before, 1.0 and 1.0 after. It failed before through `left`; its new steps-per-part grader passes before too.
- New case `plan/failed-step-recorded` (a round's verification fails): before, 4 of 9 graders, all four new ones failing (recomputed offline from the stored evidence, the graders being regexes); after, 1.0 and 1.0. Its plan-ticks grader is a guard and passes before and after. Its LLM graders were replaced by regexes: the judge passed a wrong verdict and failed a correct file.
- New case `plan/failed-step-reset` (a failed step clears when the next round starts): 0.4 and 0.4 before, 1.0 and 1.0 after.
- New case `plan/failed-step-reworked` (a reworked step fails again): 0.73 and 0.45 before, 1.0 and 1.0 after.
- Guards that pass before and after: `plan/failed-step-cleared`, `plan/skipped-rework-stays-done`, `plan/stale-step-follows-plan`.
- An exception to "test first", approved by the user: deriving the step statuses from the plan's boxes (instead of transitions) shipped without a case that fails first, because none could: the default model already behaves as the derivation says. The two guards above and five earlier cases cover it, all passing after.
- `run-carries-blocks` and `gate-answer-moves-state` pass (`run-carries-blocks` once 0.8, `round-2.md` not written in one run, then 1.0); `small-task` passes 2 of 3 (the plan judge's noise). The suite has 52 cases. Eval spend for this release: $66.39 in all: $29.36 in rounds 1–4, $28.97 for the full suite, and $8.06 for reruns of six cases on main and on the branch, none of them a regression of this change.
- `improve/note-id-stays-unique` already fails on 5.6.0, so not because of this change; it is logged as suite-log note 20261028-06 and left for later.

### Left for later

- An eval variant of `plan/state-says-what-is-left` with a 5.6.0 fixture (no steps, short titles or `startedAt`): a round fills `short` and `steps` from the plan, appends to `rounds` at its start, and marks steps running after triage.
- At a round's start, set `endedAt` on any earlier round still open (a gate never answered), then derive the statuses again.
- `plan:scope` step 8 to point at the derivation, and `plan:round` to rewrite `short` too when the plan's parts change.

## [5.6.0] - 2026-10-27

A worktree the app really shows, with the repository's include files; plans that price each option, quote the ticket instead of obeying it, check an overlapping PR before building on it, offer the design that removes a risk, and list the actions that will need your yes. Minor: new behaviour, nothing you rely on changes incompatibly.

### Worktrees

- Principles § Always in a worktree, "Entering a worktree": after `git worktree add`, copy the git-ignored files `.worktreeinclude` lists (plain git does not), except those the profile names as assembled per checkout; move the session with EnterWorktree, never `cd`, and in the desktop app also with its change-directory tool; the move holds only once the app's record of the session (`get_session` with `self`) names the worktree; then open a Terminal tab there when none is. Tried live: EnterWorktree moved the agent and new Terminal tabs but not the app's record (still the main checkout after the turn ended); the change-directory tool moved it. The 5.5.0 check (`git rev-parse` in the shell) passed after a `cd` while the app stayed on the main checkout.
- The app moves the session when the turn ends, so the check on its record comes at the start of the next turn; without the app's tools (a terminal session), EnterWorktree and its result are the move and the proof.
- `plan:scope` step 2 follows it. `improve run` keeps using its kit worktree by absolute path and does not move the session: it may run from another project's session. The project profile template gains "Files assembled per checkout", and the profile setup asks for them.

### Plans

- `plan:scope` step 3: the consequences research covers each option the interview will offer: what it adds on a hot path and which new event makes it redo work, read from the code; an option the code rules out is not offered.
- `plan:scope` step 3, Overlap: each overlapping PR with how live it is (age, last activity, draft or review state, conflicts); building on it is a question for the user with that evidence, even when the ticket asks for it.
- Question format: a recommendation rests on the kit's own reasoning, a ticket or spec being one input, never the reason by itself; a question on a point the ticket states quotes its words and says which option departs from it.
- `plan:scope` step 4: when research found risks behind a product choice, the design options that remove them are asked before or beside that choice.
- `plan:scope` step 7: the approval summary lists the actions the plan will need your yes for (anything published; commits, pushes or moving the local stack when the profile gates them), each with what happens without it.

### Evals

- New case `plan/gated-actions-listed` (the bar needs an A/B that only measures commits; the profile gates commits): on 5.5.0 the approval summary names the commits as a gate but never what happens without them (3 of 3 runs); after, it says the work stops before the A/B without that yes, or asks to authorise it with the plan (4 of 5 runs; the fifth was judged by a narrower first regex and its output not kept). Its LLM judge failed both versions alike, so the case is graded by regex, checked on every saved summary.
- New cases `plan/option-cost-priced`, `plan/ticket-not-law` and `plan/design-options-offered` could not be made to fail on 5.5.0's text in a small fixture: the model already priced each option's per-frame work and remounts, checked the overlapping PR's age, draft and conflicts, and offered a separate view for the risky filter. Its first ticket quote was translated, its second verbatim. The misses came from long sessions on a large codebase. LLM judges on these long files failed correct outputs, so the cases are graded by regex where they can be; they stay as guards and pass after (1 run each).
- No case for entering a worktree: evals have neither the app nor git; the rule rests on the live trial above.
- `false-premise`, `baseline-and-callers`, `hot-path-cost-check` and `free-answer-gets-an-answer` pass (1 run each); `small-task` passes 2 of 3 (one run failed its planning-state grader, the flake 5.3.0 and 5.5.0 recorded). The suite has 46 cases. Eval spend for this release: $16.04, no cap.

## [5.5.0] - 2026-10-26

No more spend caps; replies to a colleague's review explain instead of taking a stance; the bar leaves a gate as soon as you answer; a plan's ticket starts when its worktree does, and the session checks it is really in the worktree. Minor: new behaviour, nothing you rely on changes incompatibly.

### Improve and evals

- No spend cap: the eval commands lose `--max-cost-usd` (`evals/README.md`, README), and `improve run` step 5.3 says "Report the spend; there is no spend cap". The caps a coordinator wrote in its agents' briefs ("Spend cap about $N") came from no rule and from no measure; one was crossed by 26% ($18.93 against ~$15). Each release keeps reporting what it spent. Measured from the saved eval results (`evals/results/`, 132 case runs, 2026-10-14 to 19): a case run costs $0.33 at the median, $1.67 at most.

### Pull requests

- `pr:comments` step 5: a colleague's review gets one reply for the whole review, posted as a PR comment, that explains for each point where the behaviour comes from and what the alternative would cost, with no stance or verdict, ending open to their view; a point already fixed takes its "Addressed in" line inside it. Bots keep the short, factual replies. Step 7 never resolves the threads of a colleague's review answered with an explanation: the reviewer does.

### Plans

- `plan:round` § The state file: a gate's answer is a write: the state leaves `needs_you` before acting on the answer. Step 10.3: after the last answer of the ready-for-review gate, the state is `done`.
- `plan:scope` step 2: the ticket moves to the start status right after the worktree is opened (also without a worktree, never with `--dry-run`, never backwards), no longer at step 8 after approval, which an approval like "start now" could skip. Its previous status is kept in the state file (`ticketFrom`, `docs/local-data.md`), and on cancel step 7 offers to move it back. After EnterWorktree, the session checks its folder is the worktree, and says so when it is not.

### Evals

- New case `pr/human-review-explained` (a colleague asks for two changes the plan explains): on 5.4.0 it fails (two replies, "This is deliberate", "Kept at 3 on purpose"); after a first wording (a sub-bullet under the 3-sentence rule) it still failed the same way; after the rule was split by who wrote the review, it passes.
- New case `plan/gate-answer-moves-state` (the ready-for-review gate answered in the prompt, the state file still `needs_you`): it passes on 5.4.0 too (1 run), so the miss came from a long session, not from a short one; it stays as a guard, and passes after (1 run).
- No case for the ticket and session in `plan:scope`: they need a tracker and the worktree tool, which an eval cannot give.
- `uncertain-claim-reproduced`, `duplicates`, `false-premise`, `skipped-item-caught` and `state-says-what-is-left` pass (1 run each); `human-review-explained` passes 3 of 3 after the rule was split.
- `small-task`: its `planning-state` grader failed 3 of 5 runs on a first wording of `plan:scope` step 2, where the ticket paragraph ran on from item 3 of the list (no blank line), against 4 of 4 on 5.4.0's text; with the paragraph apart it passed 3 of 3 (one of those runs failed the plan judge 1 vote to 2, on the plan's content, which the change does not touch). The suite has 42 cases. Eval spend for this release: $12.57, no cap.

## [5.4.0] - 2026-10-26

The status band says what a part still needs: with the pointer on a part's tile, the line shows that part and its remaining steps. Minor: new behaviour, nothing you rely on changes incompatibly.

### Status band

- `my-status` 0.3.0: each tile of a plan part carries a hint, revealed while the pointer is on it (a hover group: no hook runs). The hint is drawn over the line, from right after the tiles to its end, covering every other element whole while the pointer stays (no piece of a button or text shows): `Part D · left: Report, Draft PR`, `Part B · done`, or `Part D · 1 of 2 done` for a state file without the new field. It is shown only whole: when the full hint does not fit, `Part D · 2 left`; when that does not fit either, no hint. It names the part by what comes before its title's colon when that is a word and a letter or number (`Part D`, `Parte A`), else by its number, never by its title. A card above the line is not possible: the band clips what it draws to its own row.
- The test harness cannot move a pointer, so the hover itself is checked by hand in the app; the tests pin the hints' text, position and fit, and that each card is drawn hidden.

### Plans

- State file: `parts[].left` lists the part's unticked steps, two or three words each, empty when it is done (`docs/local-data.md`). `plan:scope` writes it with the parts (step 8); `plan:round` step 6 updates each ticked part's `status`, `done` and `left`, and does the same when the plan's steps change. No eval covers `plan:scope` writing it: the case covers the round.

### Evals

- New case `plan/state-says-what-is-left` (a verified round finished Part A and one of Part B's three steps): on 5.3.0 it fails 2 of 2 runs (the state file's parts carry counts only; the first run was judged by an earlier wording of the grader), after it passes (2 runs, before and after the review fixes). The suite has 40 cases.
- `skipped-item-caught`, `round-reviewed-by-fresh-agent`, `run-carries-blocks` and `small-task` pass (1 run each). Eval spend for this release: $4.94.

## [5.3.0] - 2026-10-23

Plans look ahead (a cost check for hot paths, the round's size estimated before it runs, a decision applied everywhere the plan repeats it), comment triage and reviews rely only on what was tried, every change gets a fresh review, and a note checks its id against the log after writing it. Minor: new behaviour, nothing you rely on changes incompatibly.

### Plans

- `plan:scope` step 3: when the change adds work to a hot path (per operation, per item, per frame, per request), the baseline also times that path on a large case, and the bar gets a cost check: a deterministic cost test, or a limit against that baseline. The plan template's "How it is checked" gains a "Cost" line.
- `plan:round` step 3: the triage estimates the production lines each item adds (tests apart); when the drift so far plus the estimate passes the split trigger, step 2's drift gate is asked then, before executing. The round template's "Change" line carries the estimate.
- Question format § After the answer: a decision that changes a rule the plan states elsewhere (boundary, invariants, behaviour table, intentional changes, bar) updates every place that repeats it in the same edit, since the answer already decided them. `plan:round` records gate answers in the plan by that rule.
- A change the coordinator makes itself, in the S lane or on a direct request of a few lines, runs steps 6–8 like the full lane: step 7's fresh review comes before the push, and the push waits for it (principles, "A request to do part of it directly"). The triage's early size gate is not asked again when step 2 already asked it in the round.

### Pull requests

- `pr:comments` step 3: a group that claims a bug, above all one a bot marks uncertain, is classified real only once reproduced through the production caller; otherwise it is "not verified", with the command that would decide it, a check-only item with no reply until it is decided.
- `pr:review` step 1 holds the command that reads each review thread's resolved state, path, line, first comment and its commit (`gh api graphql`, `reviewThreads`, with `<owner>`, `<repo>`, `<n>`). It was run once, read-only, on a real pull request: it answered in under a second with every field filled. `pr:learn` reuses it for its comments overview.
- `pr:review`: on a PR reviewed before, the fresh agents also get the earlier analysis and the open threads; a reply in an existing thread stays with the user because it cannot wait in a pending review (the review payload the skill posts cannot carry a thread reply). `learning.md` mentions the reading's review comments overview after its three layers.

### Improve

- Note step 4 and Digest step 4: after appending an entry, re-read the log; if another entry has the same id (another session wrote at the same moment), the entry just written takes the next free number of that day, changing only its header, and a digest marks its signals with the final id. Two sessions that both renumber at the same moment can still land on one id; that tie-break is left for a later version.

### Evals

- New case `plan/decision-updates-plan` (the user answers a gate that turns "a release is final at any delay" into "within 24 hours"; the rule is repeated in the boundary, an invariant and the behaviour table): on 5.2.0 it fails 2 of 2 runs, recording the decision and leaving the three places unchanged (one run asked a second gate to rewrite them); after, it passes 1 of 1.
- New case `improve/note-id-stays-unique`: its scaffold starts a short-lived process that plays another session, appending a note with the same id right after the skill writes its own. On 5.2.0 it fails (two `-02` entries); after, it passes (the skill's entry becomes `-03`, the other keeps its header).
- New cases `plan/hot-path-cost-check`, `plan/triage-estimates-size` and `pr/uncertain-claim-reproduced` could not be made to fail on 5.2.0's text in a small fixture: there the model already timed the hot path and put a cost check in the bar (1 of 1 run that finished, the other timed out at 300 s, now 600 s), estimated Part B and asked the size gate before executing (at least 2 of 3 runs, across fixture tweaks; an LLM judge failed one of those correct reports, so the case is now graded by regex), and reproduced the bot's claim through the production caller (1 of 1). The misses they come from happened on large codebases. They stay as guards of the new rules, and pass after (1 run each). After the fresh review, their graders were tightened (a cost line that names a real check; a size gate actually put to the user; the bot's claim classified not a bug or not verified, and the caller driven through Python) and re-checked on the saved outputs of the runs above and on failing samples, without new runs; the bot finding's id became `B1`.
- No case for the coordinator's own change: executing a round needs commits, and evals have no working git; `plan/round-reviewed-by-fresh-agent`, which pins step 7 in the S lane, passes (1 run).
- `small-task`, `false-premise`, `baseline-and-callers`, `skipped-item-caught`, `duplicates`, `broken-promise`, `later-round-confirms-fixes`, `note-logs-without-changing` and `digest-groups-signals` pass (1 run each; `small-task` failed its planning-state grader once and passed on a second run, a known flake). `run-carries-blocks` passed 1 of 2: the failed run stopped before writing round 2's triage, with no trace kept to say why. The suite has 39 cases.
- Prose in `skills/`, `docs/` and `templates/`: 1,427 → 1,429 lines.

## [5.2.0] - 2026-10-23

A note now records the kit version it was written with, and `/my:improve run` checks a note from an older version against what changed since, so it no longer "fixes" a rule a later release already fixed or rewrote. Minor: new behaviour, nothing you rely on changes incompatibly.

### Improve

- A log entry gains a `Kit:` line: the `version` in the plugin's `plugin.json`, read when the writing skill starts, so it is the version the session follows (a chat keeps the version it started with while the kit moves on). Note fills it; Digest fills it from the newest version its signals carry. A signal line ends with `kit <version>`, and the digest copies it onto each `Evidence:` line it writes from that signal. Entries, evidence lines and signals written before have none and stay valid.
- List and Log mark an open entry from a version older than the current one with `from <version>` next to its state. Its version is the newest of its `Kit:` line and its `Evidence:` lines' versions, so a note seen again after a fix counts from then, not from when it was first written; with neither, approximately (`from ~<version>`), the latest release dated before its `When`: release tags with their dates, or without git the CHANGELOG's release dates.
- `run` step 2 flags each selected entry from an older version, reads what changed since that version where its suspected cause points (CHANGELOG, `git log v<version>..origin/main`), and classifies it: still valid, already fixed (by which version) or obsolete (that part was rewritten). Only still-valid entries go on to the upstream lesson; each other one is shown in one line with its reason and a proposed closing, `fixed <version> (already)` or `wontfix: obsolete since <version>`, applied only on your yes, and without waiting for a ship. `--propose-only` shows the same, reading what changed from the CHANGELOG alone.

### Evals

- New case `improve/run-flags-old-notes` (three open notes: one written with 4.0.0 whose cause 5.1.0 fixed; one written with 4.0.0 on a cause 5.1.0 also fixed, but with an evidence line from 5.1.0 saying it happened again; one current and still valid; no git in the sandbox, so the run falls back to the plugin's own CHANGELOG): on 5.1.0 the run already called the old note fixed, but without the version marker and proposing a plain `fixed 5.1.0`, so it fails its two version graders (1 run, re-graded on its saved reply after the final graders). After: 3 of 3 runs pass. The third note came with the evidence-line version: on the text without it, the run already kept that note open by reading its evidence (2 of 2 runs pass `seen-again-not-fixed`, that its id is not proposed as `fixed … (already)`), but marked it `from 4.0.0`, so it fails `marker-newest-evidence` (1 run, re-graded on its saved reply); after, 3 of 3 runs mark it `from 5.1.0` and keep it open. An intermediate text gave the run its own `from <version>, now <current>` form beside the views' marker: 3 of 5 runs missed a grader on that form, the two kept ones having shown `from 4.0.0` in the table and the versions in prose; the run now uses the views' marker, kept in English like the states, and the grader checks it. An LLM grader on the proposals was dropped: its judge failed 5.1.0's reasonable reply 3 of 3 with no reason given.
- `note-logs-without-changing` gains a grader that the entry has a `Kit:` line: it fails on 5.1.0 (1 run) and passes after. `note-explains-why`, `digest-groups-signals`, `run-finds-upstream-lesson`, `run-respects-constitution` and `log-shows-problems` pass (1 run each); after the evidence-line version, `digest-groups-signals` and `note-logs-without-changing` pass again (1 run each). The suite has 34 cases.
- Prose in `skills/`, `docs/` and `templates/`: 1,425 → 1,427 lines.

## [5.1.0] - 2026-10-23

The size budget and its split trigger count production code, not tests, so the guard tests a plan asks for no longer stop a run at "drift over budget". Minor: new behaviour, nothing you rely on changes incompatibly.

### Plans

- `scripts/drift.sh` splits the change's size into production and tests and prints both, after the total `size:` line, which stays. The `--lines` and `--files` budgets compare production only; test lines and files are reported and never put a change over budget. Test files by default: paths with a `test`, `tests`, `__tests__`, `spec` or `specs` folder, and files named `*_test.*`, `*.test.*`, `*.spec.*`, `test_*.*`, `*_spec.*` or `conftest.py`; a file moved across is classed by its new path. `--tests <pathspec>…` replaces the default, and the `--` excludes work as before.
- The principles, `plan:scope` (the S and L size classes, the interview's budget topic), the plan template and `plan:round` (the `drift.sh` call and the report's Drift line, with test lines apart) state the budget in production lines and files; tests are estimated and reported apart. A plan written before reads its numbers as production lines.
- The project profile gains an optional "Test paths" line, passed to `drift.sh` as `--tests`.

### Tests and evals

- New `scripts/drift.test.sh`, in a temporary repository: fails on 5.0.0's `drift.sh` in 9 of 11 checks (test lines push a change over a budget its production code meets; `--tests` is unknown), passes 11 of 11 after. It replaces an eval case: evals have no working git.
- `plan/round-reviewed-by-fresh-agent`'s fixture shows the new `production:` and `tests:` lines in its `drift.sh` output; it passes 2 of 2 (one run before the fixture change, one after). `plan/run-carries-blocks` passes 1 of 1. `plan/small-task` passes 1 of 2: the failed run lost the plan judge and did not write the planning state; the second passed both. `plan/skipped-item-caught` passes 1 of 3 on its language graders (its catch grader 3 of 3): one run wrote `report.md` in English, one fully Italian run drew FAIL votes; 5.0.0's prose, run once for comparison, passed. The language judge is noisy here, and the one text change these cases read is the report's Drift line.
- Prose in `skills/`, `docs/` and `templates/`: 1,424 → 1,425 lines.

## [5.0.0] - 2026-10-22

A review gives its judgement first and writes for GitHub only once you agree with it; one command explains a PR or the review it received; planning research checks the premises of its recommendations. Major: `/my:pr:study` is removed.

### Breaking

- `pr:review` in `local` mode pastes the drafts in chat too, as in the other modes (the skill said both yes and no).
- `/my:pr:study` is removed: use `/my:pr:learn <PR> <comment id or URL | reviewer | comments [all]>`, or paste the comments after it. It studies the review comments as before (study page, glossary, reviewer profiles, only comments not studied yet). Without a focus, `/my:pr:learn` explains the whole PR as before. `/my:improve` reads `pr:study` in old log entries as `pr:learn`.

### Review

- `pr:review` first shows a private analysis in chat, in your language: ready to merge or not and why; the PR's main scenario followed end to end through every piece; one section per question that matters, each with its answer and nature (architecture or design, lines to fix, a nit). "Nothing worth adding" is a valid outcome: no quota of questions or findings. The questions to the author, the inline comments and the summary come only once you agree with the analysis (in chat, or already in your instructions), then the publishing gate as before. Without your agreement and with no way to ask, it stops after the analysis.
- Without a focus, `/my:pr:learn` ends the reading with a short overview of the PR's review comments (who said what, one line per reviewer, which threads are still open) pointing to `/my:pr:learn <PR> comments`; a re-run refreshes it.
- On a PR already reviewed (an earlier analysis in the data root, or reviews by others), the analysis first says, after the verdict, what the head fixed since then, what is still open and what the author answered. A point already raised in an open thread is not a new finding: the review names the thread and its author, and a draft adds to it only something new, as a reply you post in that thread.
- Before calling a shape wrong or proposing a refactor, the review finds why the code is shaped that way; a deliberate design is not a finding. Collection reads review bodies and general comments as well as inline ones.
- The review lenses start from the promise (its main scenario, end to end, before the other lenses) and gain a Coherence lens: one value computed from different inputs, texts a model reads that disagree, a condition wider than its intent. Evidence asks whether the description is still true at the head. Severity weighs reach and impact (who can trigger it, what it costs); "the main branch has the same problem" is still no reason to downgrade a broken promise. The questions for the author have no fixed count. The round reviewer starts from the plan's main scenario too.

### Plans

- A recommendation's premise is checked like any other claim: a production volume or frequency it depends on is measured with a read-only query before the interview, or the recommendation says it is unverified and which measure would decide it.
- For shared code the change extends, `plan:scope` research reports the rule each caller applies (tolerances, exceptions, what it skips), not only what it reads, and checks each rule against the change.
- An out-of-scope item you accept as it is can carry its reason in the plan with no ticket ("none: accepted (D<n> or A<n>), <reason>" in the Ticket column; a review grading a finding `ticket` offers the same), the recommended option when it concerns only a non-production environment. A ticket is one option, not the rule.

### Evals

- New case `pr/nothing-worth-adding` (a pure rename with nothing to raise): fails on 4.2.0 in 3 of 3 runs (questions and findings to fill the review), passes after on the chat verdict, 2 of 2 on an earlier fixture (whose formatting bug drew an out-of-scope ticket) and 2 of 2 on the final one. A grader on the review file's question count was dropped: its judge passed a three-question file on 4.2.0 and failed a zero-question file after.
- New case `pr/drafts-wait-for-agreement` (the broken-promise PR, with no agreement in the prompt): `review.md` holds English draft sections on 4.2.0 (1 of 1 run) and none after (2 of 2). An LLM grader on the reply was dropped: it passed 4.2.0's reply and failed two correct replies that asked whether the analysis holds.
- New case `plan/research-checks-premises`: its staging-only item gets a ticket on 4.2.0 in 2 of 2 runs and "none: accepted" after in 2 of 2. Its volume and caller-rule graders already pass on 4.2.0 (the prose principle and the fixture's profile were enough): they guard the new text.
- New case `pr/later-round-confirms-fixes` (a PR already reviewed: an earlier analysis in the data root whose block the head fixed, and a colleague's open thread): before this change it fails in 4 of 4 runs (the fix is confirmed only inside the scenario or later, and twice a new inline comment repeats the colleague's point instead of replying in her thread); after, 5 of 5 pass. These counts apply its final regex graders to the saved outputs, plus one live run after: an LLM grader was dropped, its judge having failed three correct files after the change. `pr/broken-promise` (2 of 2) and `pr/drafts-wait-for-agreement` (1 of 1) still pass; `pr/own-pr-fresh-review` passes 1 of 2, the failure a judge vote against a file with the block, the questions and the drafts (its fixture has no earlier review).
- New case `pr/learn-overviews-comments` (a PR with one open and two resolved review threads): before this change both runs mention the comments only inside layer 0 or the collapsed layer 2 (one with no `/my:pr:learn … comments` pointer at all), so neither reading ends with the overview; after, 2 of 2 pass. `pr/pr-explains-not-judges` (a PR with no comments, 1 of 1) and `pr/budget-and-known-term` (2 of 2) still pass.
- `pr/broken-promise`, `pr/own-pr-fresh-review` and `pr/review-keeps-study-private` now say in the prompt that the drafts need not wait for agreement, since evals cannot answer. `pr/budget-and-known-term` runs through `/my:pr:learn acme/orders#42 comments`; it already passes on 4.2.0 (3 of 3 runs), where the model adapted, so it guards the merge rather than proving it; after, 5 of 7 runs pass (3 of 4 on the final text), the two failures being split judge votes on the glossary and the page. The suite has 33 cases.
- Prose in `skills/`, `docs/` and `templates/`: 1,418 → 1,424 lines (17,556 → 18,334 words).

## [4.2.0] - 2026-10-22

The kit speaks your language even when everything it read is in English, introduces its questions in chat before asking them, plans in the change's worktree from the start, puts in the bar only checks that can fail, and its release updates the plugins you have installed. Minor: new behaviour, nothing you rely on changes incompatibly.

### Language and what you see

- The chat is in your language even when the skills, plans and agents' reports it read are in English; an agent's report reaches you translated and summarised, never forwarded as it is.
- When you say what you see (the chat's language, a missing explanation, a screen), the kit checks it against the session record (transcript, files, screenshots) before answering, and never contradicts you from memory.

### Questions

- Right before a batch of questions, in the same message and in your language, the chat introduces them: the situation, what the kit prescribes and why it asks, and what the choice changes. The questions and each option's Effect, Today, Pros, Cons and Severity then stay short, a few words each. This replaces the 4.1.0 rule that a longer explanation goes in chat and ends the turn: the separate turn stays only when you dismiss the questions or ask back.

### Plans

- `plan:scope` opens the change's worktree from `origin/main` as soon as the ticket or request is read (the branch name known), moves the session there when the profile says so, writes the plan in its `.plans/`, and plans in the branch's state file once the session works there (the session file stays for a dry run, or a session that stays outside the worktree). The profile's setup command starts there in the background, so the baseline runs on a ready worktree. At approval only the ready state and the ticket move are left; on cancel it offers to remove the worktree. `--dry-run` still creates nothing, and neither does a profile where you work without a worktree.
- Since an unapproved plan now sits in the worktree, `plan:round` and `plan:run` refuse a plan whose state file is still `planning` (or `needs_you` for "Plan approval"), and offer to finish `plan:scope` instead.
- A check enters the bar for done only after it was seen failing on the change's likeliest wrong input (or its code shows it checks that); otherwise the plan says it cannot fail and looks for one that can. `plan:scope` tries each bar check that way in its baseline.
- A condition that happens only after the merge (a deploy, a sync, a rollout) is proposed as a separate verification ticket, its text in the plan: the interview's bar topic and the template's "After the merge" line, written only when there is one. Each bar check in the template names the wrong input it was seen failing on, in its own line, so a small plan stays short.

### Release

- `improve run` bumps the version of every plugin of the repository whose files changed, and after the yes and the push updates the installed copies (`claude plugin marketplace update`, then `claude plugin update`), checks they hold the new code, and tells you to restart. The principles' release gate says the same. Reviewed only: the eval sandbox has no installed plugins.

### Evals

- New case `plan/post-merge-check-ticket`: fails on 4.1.1 (2 of 2 runs: the sync stays on the ticket as "the user confirms after the deploy"), passes 3 of 3 after. The suite has 28 cases.
- The introduction before questions has no case: a grader for it on `plan/run-stops-before-publishing` failed 1 of 4 runs on 4.1.1 and 1 of 5 after, because without the question tool (headless evals cannot open it, even when allowed) the context already lands in chat; the noise was not kept in a gate case.
- `plan/skipped-item-caught` gains `chat-language` (the last message is in Italian, the executor's English summary not pasted): a guard, since 4.1.1 already speaks Italian in this one-round case (one judge failure was on a fully Italian message). Both language graders now allow item titles and tool output quoted from the files.
- The check that a bar check can fail has no case: on a one-file fixture 4.1.1 already said, in 2 of 2 runs, that the validation script could not catch a wrong name; the miss came from a hook whose code was not read. Opening the worktree at the start has none either: evals have no working git, and the dry-run cases guard that `--dry-run` creates nothing.
- Prose in `skills/`, `docs/` and `templates/`: 1,414 → 1,418 lines.

## [4.1.1] - 2026-10-22

While planning, the state belongs to the chat, not the folder: two chats planning in the same folder no longer overwrite each other, and a third chat there no longer shows their plan. Patch: a fix, nothing you rely on changes.

### Status

- `plan:scope` writes its planning state to `state/session-<session id>.json` (the id from `$CLAUDE_CODE_SESSION_ID`) and deletes it at approval, when it writes the worktree branch's file as before. The activity sidecar of `pr:*` modes and `improve run` is `state/session-<session id>.activity.json`. Without a session id, the folder's name stays.
- `my-status` reads the chat's own session file (`$.session.id()`) and the folder and branch file, and shows the newer of the two (a missing date counts as oldest), so a leftover planning file never hides a live run; its fallback by worktree skips session files. A chat never shows another chat's planning or activity when both have a session id; folder-named files (written by 4.1.0, or by a chat without an id) still show in every chat of that folder, as the README says. The 6-hour rule covers session files.
- Mod tests: 37 → 42 (four fail on 4.1.0; the stale guard passes already).
- `my-status` is versioned 0.2.1, so installed copies update.

### Evals

- `plan/small-task` (`planning-state`) and `pr/broken-promise` (`activity`) now require the session name, with an id of at least one character and no unexpanded variable: both fail on 4.1.0 (1 of 1 run each); after, `activity` passes 3 of 3 runs and `planning-state` 2 of 3 (the third run showed the name only as `session-$CLAUDE_CODE_SESSION_ID.json`).
- Prose in `skills/`, `docs/` and `templates/` stays at 1,414 lines.

## [4.1.0] - 2026-10-21

The kit asks when you can answer, shows you the files it wants you to read, tries what it relies on before relying on it, follows what a plan adds, keeps its own checks, and the status band shows only where the work stands. Minor: new behaviour, nothing you rely on changes incompatibly.

### Questions

- A free answer or a dismissal that holds a question or a doubt gets an answer in chat, and the turn ends there: no new question until you say it is clear.
- A longer explanation goes in chat and ends the turn, because the question window covers the text above it; the short question comes after, carrying its own essential context.
- A decision is asked only when the work needs it: `plan:scope` asks what the plan and its first part need, and a later part's choice becomes a gate or an open question of that part.

### Files you must read

- A file you must read opens in the app's file pane, by absolute path, after its folder is added to the session when it lies outside the working directory (the data root, a worktree entered later). When the pane cannot open it, the kit gives the absolute path as code and says why. A text you must approve before it is published is pasted in chat, always. `pr:learn`, `pr:study` and `pr:review` follow this instead of `open <file>` or a bare path; `pr:comments` pastes its reply drafts, and `plan:round` the draft-PR body and the description update, with the question.

### Verification

- Every tool, client or command a plan relies on, or the kit hands you, runs once for real first, and its prerequisites (access, environment) and measured duration go into the plan or the message. A command that changes shared state (production config, deploys, data, anything published) is tried only as a dry run or its read-only part, or else marked "not tried" and you are told.
- A test drives the real consumer (the client that will call the code), not only its handler; an intermittent defect is captured first (temporary instrumentation, a trace of the failing repetition); an audit's claim about behaviour is reproduced, or marked "text only" and fixed in text; the verification is sized to what changes. The executor prompt carries the consumer and capture clauses.
- A check or a stop condition (the plan's, the round's, the coordinator's own) is never skipped, run less often or turned into a ticket without your yes (a gate), and one that fires goes to you. In `plan:round` a decision that relaxes one is a gate, and the executor stops when an item's `Stop if` holds. A check with a noisy result (an LLM judge, a model's choice) runs 2–3 times before it is called passed or failed.

### Plans

- `plan:scope` research follows what the plan adds or changes: for each new or changed field, state, key or rule, who writes it and when, who reads it (data saved before the change included), its transitions (backwards too), and any other route it opens. The round triage, the triage check and the round template carry the same check for each item.

### Status

- The band shows no work name, plan title or PR label, which the chat and the branch already give: only the state, the tiles, the percent and the time left, a reason of two or three words for `needs_you` and `stopped`, and the buttons. `pr:*` modes and `improve run` show their mode. The status line reads `my: <state>[ · extras] · <n> kit notes`.
- Nothing is cut with "…". The state and the first button always show; every other element is added whole, in a fixed order (the reason, the other buttons, the percent, the tiles, Open plan, the detail, the time), only while the band fits.
- The state file and the activity sidecar no longer carry `name`: `plan:scope` and `plan:round` stop writing it, and a `name` left by 4.0.x is ignored.
- Mod tests: 33 → 37.
- `my-status` is versioned 0.2.0 (it stayed 0.1.0 through 4.0.0): the installed mod is a copy kept by version, so without the bump an installed copy never received the 4.0.0 and 4.1.0 band. The README says how to update it.

### Evals

- New cases: `plan/free-answer-gets-an-answer` (fails on 4.0.0 in 3 of 3 runs, passes in 4 of 5 after) and `plan/tool-tried-first` (a guard: 4.0.0 already passes it). `pr/pr-explains-not-judges` and `pr/broken-promise` gain a grader for the absolute path (both fail on 4.0.0); `pr/pr-explains-not-judges` also gains two guards against `open` (4.0.0 already passes them). The suite has 27 cases.
- Following what a plan adds, and the coordinator keeping its own checks, have no case: the cases written for them passed on the text before the change (2 of 2 runs each), because a one-page fixture makes the consequence obvious, while the misses came from work spread over many rounds. They were not kept. `evals/README.md` says how many runs a noisy grader needs.
- `pr/sync-context-covers-one`: `pricing-decided` fails only on a gating word on the `pricing.py` line (it failed a correct run that wrote "user decision"), and `orders-gate` no longer takes "decided by" as a gate. 3 of 3 runs pass.
- Prose in `skills/`, `docs/` and `templates/` stays at 1,414 lines.

## [4.0.0] - 2026-10-21

The kit now keeps its constitution (3.2.1): it never ships itself or takes a decision you have not handed over, its status is true and always visible, small work stays light, and it learns your decisions one kind at a time. Major, because behaviour you rely on changes: how `improve run` ships, how `pr:sync` handles design conflicts, and how S work runs.

### Changed (breaking)

- `/my:improve run` no longer ships on its own. It edits nothing, the project profile included, before you approve a proposal; its preflight only fetches `origin/main` (never a pull, so the live kit does not move before your yes), stops unless local `main` is an ancestor of it, and reads the kit there, so proposals cite current text (`--propose-only` skips the preflight and reads the plugin's own files); it makes the approved changes in its own worktree from `origin/main`, never in the main checkout; it commits there and has a fresh agent review the diff against the approved proposals and the constitution. Then it shows the full diff, says how many commits of `main..origin/main` the fast-forward also brings, and asks: only on yes does it fast-forward `main`, tag and push. On no it keeps the worktree and leaves the entries open; entries close only after shipping.
- `/my:pr:sync` leaves every design conflict to you. Other PRs' descriptions and comments only build the options, even when they tell other branches how to resolve the conflict; only context you typed yourself that says how to resolve decides, for every design conflict it clearly covers (general or per file), and the kit says in one line per file how it applies it; a conflict it does not clearly cover, or context that does not say how, stays a question; context passed by another skill or agent never counts. Step 5 opens with the rule: no conflicted design file is touched before you answer.
- Small work takes a light lane. For a plan with `Size: S` (a stub plan writes it too), `plan:scope` starts no agent: it researches the code and the baseline itself, and the plan's review is your approval. `plan:round` skips the triage check and the coordinator makes the changes itself; a fresh agent still reviews every round.

### Decisions and self-change

- The kit changes only through an approved plan or `/my:improve run`, and only with your yes.
- Push rule: in the kit's own repository, a plan's rounds push their work branch like any draft branch, but a push that would move `main` or a tag waits for the release gate (the full diff and your yes).
- `plan:scope` never assumes the approval: without the question tool it stops with `needs_you` and reason "Plan approval"; `--dry-run` skips the stop.
- `pr:review` on your own PR, at any size (and so at the ready-for-review gate, which runs it), splits the work across fresh read-only agents that also verify and grade; the coordinator drafts from their findings and drops none.
- Questions: every option carries its own labelled Pros and Cons, in your language ("Pro" / "Contro"); a shared header row does not count. `pr:sync` writes the shape inline: each option has its own Pros, Cons and Risk lines.

### Status

- The state file gains `name`, two or three words in the session-title format, and `reason` is two or three words. A file without `name` stays valid, and 3.2.x files still show, cut to fit.
- One writer per file: the round's executor writes item progress to a `.progress.json` sidecar, and `pr:*` modes and `improve run` write what they are doing to an `.activity.json` sidecar; the mod merges both with the state file. `plan:round` keeps `name` and the other unchanged fields when it rewrites the state file, and copies the round's "Comments read until" into `commentsReadUntil`.
- The band and the status line: name and reason cut with "…" to the width, buttons that never shrink, one label per state, "Round N done" after a round, `pr:*` modes and `improve run` shown while they run or wait for you. A planning, running or activity state untouched for 6 hours is ignored. New comments count only other people's, network data is tied to the PR, and a failed call shows nothing instead of zero.
- Mod tests: 17 → 33.

### Language and privacy

- `plan:round` and `plan:run` reports keep their labels and write their sentences in your language, with no fixed English sentence.
- Nothing published (PR text, comments, replies, commits, messages) cites, quotes or names study pages, readings, the glossary, reviewer profiles, `method.md` or the suite log.
- `scripts/check.sh` fails when the deny-word file is missing, unless `MY_AGENT_KIT_ALLOW_NO_DENY=1`; it reads the file from `$MY_AGENT_KIT_HOME` when set (`$MY_AGENT_KIT_DENY` still names another file). `scripts/check.test.sh` tests both.
- The data root is written once, in one order: a folder you name, else `$MY_AGENT_KIT_HOME`, else `~/.my-agent-kit/`. The project profile's path is written one way, `projects/<owner>-<repo>.md`.
- Shared rules (the data root, check-only items, finding grades, language) are each written once; prose in `skills/`, `docs/` and `templates/` goes from 1,418 to 1,414 lines.

### The method

- `<data root>/method.md` holds your decision kinds: `K<n>`, a generic judgement in one line ("For X, choose Y") with no repository, project, code or person names, a class, the matches in a row, a state (`asked`, `proposed`, `handed over`) and the last dates; at most 30 kinds. Only the coordinating session edits it.
- Only the gate decisions of the `plan:*` modes and `pr:sync` are learned: they record each gate answer in its kind, and other modes neither cite nor update kinds. A new kind starts `asked`, and its first answer counts like any other. The plan's Decisions table gains Kind, Recommended and Chosen, holding the options' text; plans with older columns stay valid. A recommendation cites the last choices of its kind.
- A match adds one; a mismatch rewrites the judgement, resets the count to 0, and sets a `proposed` or `handed over` kind back to `asked`. An assumption counts for no kind and creates none, and a hand-over is never assumed.
- After 5 matches in a row a `work` kind becomes `proposed`, and the next gate proposes handing it over: yes makes it `handed over`; no sets it back to `asked`, count 0. `kept` kinds are never proposed: architecture, design, speaking for you, plan approval, a boundary or rule crossing, anything published, ready for review, a release, someone else's code and moving the local stack. Every other kind is `work`. A merged kind keeps the lower count and the less autonomous state, and is `kept` if either kind was.
- A handed-over kind is decided alone, by its judgement, only when the decision clearly fits it and research does not point elsewhere, and is listed as "decided alone (handed over: K<n>)" in the round report, the plan and the `Decided alone:` line of `plan:run`'s end summary; such a decision does not stop the run. You take a kind back by saying so in chat: it goes back to `asked`, count 0.
- New `/my:improve:method` (`/my:improve method`): lists the kinds, handed-over ones first, and changes nothing.

### Evals

- New cases: `pr/design-conflict-decided-by-text` and `pr/own-pr-fresh-review` (both fail on 3.2.1), `plan/handed-over-decision` and `improve/method-shows-kinds` (both fail on 3.2.1), `plan/round-reviewed-by-fresh-agent` and `pr/review-keeps-study-private` (guards: 3.2.1 already passes them). The suite has 24 cases.
- New graders: `plan/small-task` checks that an S plan starts no subagent, `plan/skipped-item-caught` checks the report's language (it fails on 3.2.1), `pr/broken-promise` checks the activity sidecar, `plan/run-carries-blocks` checks the end summary's `Decided alone:` line (it failed before the change).
- The shell-write guard of `pr/design-conflict-decided-by-text` matches only writes to the conflicted file, relative paths included.

## [3.2.1] - 2026-10-20

### Changed

- Constitution, amended at the user's explicit request. Reason: the user wants the kit to automate as much of the workflow as it can, and to earn autonomy over time; the old text ("decisions are mine", "publishes without my yes") read as if every commit and push in the user's projects needed a yes, and did not say where the kit is heading. Clause 1 now says that decisions are the user's today, that the goal is for the user to decide only architecture, design and whatever speaks for them, and that the kit takes a kind of decision alone only after its recommendations for that kind have matched the user's choices and the user has handed it over. "What the kit must not become" now separates speaking for the user to other people (replies, PR descriptions, ready for review, messages: always the user's yes) from changing itself or pushing to its own repository (the user's yes); in the user's projects, committing and pushing are automation, not publishing.

## [3.2.0] - 2026-10-20

### Added

- `CONSTITUTION.md`: what the kit is for, nine clauses, what it must not become, and how it is amended. The user asked for it and approved the text in chat; it wins over every other rule, the principles included. It changes only by hand or at the user's explicit request, with the reason written down.
- `.githooks/commit-msg`: a commit that touches `CONSTITUTION.md` fails unless its message contains "Amend constitution"; merges pass. A guard against accidents, not a wall.
- `/my:improve run` reads the constitution before proposing: when a note asks for something it forbids, or a proposal would contradict it, the run names the clause and says that only the user can amend it, instead of proposing the change; for the cause behind such a note it proposes only what the constitution allows. It never edits the file.
- Pointers: `docs/principles.md` serves the constitution; `.claude/CLAUDE.md` states the amendment rule and that agents never write the phrase on their own; the README names it first among the principles.
- Eval `improve/run-respects-constitution` (it fails on 3.1.0).

## [3.1.0] - 2026-10-20

### Added

- The status is visible from the first step: `plan:scope` writes the state file as `planning`, with its step (research, interview, writing, review, approval), and the status line shows "Planning". `--dry-run` deletes it at the end.
- Principles, "the kit carries the plan it made": an approved plan runs only through `/my:plan:run` or `/my:plan:round`; a request to do part of it directly becomes a round with that part as its source; leaving the kit for a change is the user's call.
- Verification-only items: a round item can be "check only"; its summary row is `checked`, with no commit and the evidence in the note, and `verify-round.sh` accepts it.
- The plan's bar for done says what is checked every round and what once at the end, with the cost of each; rounds use the first, the ready-for-review gate the second.

### Changed

- One rule for the state file's name, from the session's folder and never from the project profile: `<owner>-<repo>-<branch>` from the git remote, or `none-<folder>`. The file follows the session into a worktree. The status mod also finds a state file by its `worktree` when the name differs.
- `plan:scope` research traces how the things the plan relies on really work: the callers of shared code, every field and rule of code or data it replaces, the order in which a measuring tool runs, each with `file:line` and checked against a scenario that runs today.
- Question format: explore in the chat on a mockup while a design takes shape, and ask with the tool once a real choice is left; show structural or visual cases as a small before/after; say which principle the recommended option rests on, and when it only keeps today's behaviour.
- At approval, `plan:scope` writes the worktree branch's state file (with `repo`, `branch` and `worktree`) and deletes the planning one, so the bar shows wherever the work continues; a cancelled plan deletes it, and an existing branch sets it to `needs_you`. The status mod ignores a `planning` state untouched for 6 hours.
- If the plan's end-of-work checks fail at the ready-for-review gate, their failures become the next round's items.
- Check-only items are exempt from "test first" and "one commit per item" in the round template, the executor and the triage check; the round report counts them.
- `plan:scope` lists the sections an S plan drops on one line, without headings.
- Eval `plan/small-task` checks that planning writes a state file (it fails on 3.0.0); mod tests cover the planning state, the fallback by worktree and stale planning states; the `pr/design-conflict-stops` options grader accepts Italian pros and cons.

## [3.0.0] - 2026-10-19

### Changed (breaking)

- Commands are grouped by object. `/my:scope-plan` is `/my:plan:scope`, `/my:pr-round` is `/my:plan:round`, `/my:learn:pr` is `/my:pr:learn`, `/my:learn:review` is `/my:pr:study`, `/my:review-lens` is `/my:pr:review`, `/my:explain-comment` is `/my:pr:comments`, `/my:merge-main` is `/my:pr:sync`. `/my:improve:*` is unchanged. Each mode keeps today's steps and outputs.
- Three skills with modes: `plan` (scope, round, run), `pr` (learn, study, review, comments, sync) and `improve`. Each command carries its own "Use for…" phrases; the private learning rules stay with `pr:learn` and `pr:study`.
- Log entries and signals name `skill:mode`. `improve` reads older entries and signals under the new names and shows only those.
- Eval cases moved to `evals/plan/` and `evals/pr/`.

### Added

- `/my:plan:run`: rounds one after another while each succeeds (verification passed, push done or disabled, no open question), across plan parts. It stops at a gate the plan or the principles name, failed verification, drift over budget, conflicts with main, new PR comments, red CI known at round start, anything to publish, the ready-for-review gate, or 5 consecutive rounds, with one notification and one summary at the end.
- Rounds write their review to `.plans/round-<N>-review.md`, so block findings reach the next round, and tick a plan part's checkboxes when its items are verified.
- The state file `<data root>/state/<owner-name>-<branch>.json`, written by `plan:scope` (ready), `plan:round` and `plan:run` at every step; its shape is in `docs/local-data.md`.
- A session chapter per round.
- `mods/my-status`, an optional mod installed from the repository's marketplace: one line above the prompt with the plan's parts as tiles that fill up, the percentage, the time left, what needs the user, and the next action as a button that fills the prompt; "Open plan" in a pane; a status line entry. It only reads (plus a `git fetch` at most every 10 minutes while a PR exists).
- Evals `plan/run-carries-blocks` and `plan/run-stops-before-publishing`; `improve/log-shows-problems` checks the new names. The suite has 17 cases.

### Fixed

- Eval graders that searched the trace for `git worktree add` and `git push` now check the commands actually run, not the instructions the agent read.
- `improve/run-finds-upstream-lesson` uses regex graders instead of an LLM judge on a long reply, and checks that only new names reach the user; `improve/digest-groups-signals` accepts the confirmation line in the user's language.
- `plan:scope`: a dropped plan section is one line with nothing under it.

## [2.4.1] - 2026-10-19

### Changed

- Principles, verify: "check every claim" now names the agent's own claims too: a ticket's premises, live state (flags, config, environment, a preview), the consequences written into an option, and "done", "it is live" or "it works". Each carries evidence or is marked unverified; the question format points option effects at this rule.
- Principles, worktree: the project profile can say how the user works in a repository (for example "work on `main`, no worktree"), and skills check what the profile names. `pr-round` preflight follows it. Building a profile now asks how the user works there and how the local stack runs; the profile template records the stack variant and the move and move-back commands.
- Question format: a term's plain meaning also covers ideas introduced earlier in the conversation; an answer that makes a pending question stale means dropping or rewriting it.
- Principles, links: the scratchpad is not openable from the app's file pane; a file the user must read goes in the working directory's `.plans/` or the data root.

## [2.4.0] - 2026-10-19

### Added

- The kit learns while it is used. Every skill records signals without interrupting: a free "Other" answer or a dismissed question (and why), a request for a simpler explanation, a reversed decision, a surprise gate or stop, a review finding or a reviewer or bot comment the plan should have caught, rework. They go to `<data root>/signals/`, so they survive the session and the worktree.
- `/my:improve digest` (and `/my:improve:digest`): turns pending signals into a few notes grouped by upstream cause. Withdrawn signals are marked dropped, and a cause that already has an open note gains `Evidence:` lines instead of a new note. Every skill runs it at the end.
- `pr-round` reads the PR comments that are new since the last round, without touching `explain-comment`'s state, and its report gains a `Lessons:` line. `explain-comment` records a real comment the plan should have caught as a signal.
- Log entries gain "Why it was a problem" and "Missing question". Their reasoning is in the user's language.
- `/my:improve run --propose-only` stops after the proposals.
- Evals `improve/note-explains-why`, `improve/digest-groups-signals` and `improve/run-finds-upstream-lesson`; `explain-comment/duplicates` also checks the signal. The suite has 15 cases.

### Changed

- `improve run` looks for the upstream lesson first: the missing question, and the existing rule that should have covered it and why it did not. It prefers refining, generalising or moving that rule to adding one.
- Principles, language: reasoning is in the user's language, in plain words. Repository and kit vocabulary is never translated, and a term gets a plain meaning the first time it appears. This replaces the "technical labels" rule; the question format keeps terms instead of paraphrasing them.
- The principles' closing step collects signals and runs the digest, instead of offering a note.

## [2.3.0] - 2026-10-16

### Added

- Principles: measure a check's baseline on `origin/main` before it enters the bar for done or a stop condition. When it already fails there, the bar reads "no new failures against the baseline". `scope-plan` records the baseline during research, the plan template's Verification asks for it, and `pr-round` keeps it in stop conditions.
- Principles: link only files the desktop app can open. Before linking a file under the data root, add the data root to the session with the directory-request tool; when the tool is missing, show the path as code.
- Principles: technical labels (states, ids, table headers) stay in English; explanations follow the user's language.
- Question format: one decision per question; every option has both pros and cons; for a rollout, say first what the deployed thing does and what users see when it is missing. A dismissed batch, or "I don't understand", means explain first and ask again with the tool, never options in plain text.
- `improve` list and log: each entry shows its problem in one line and a coloured state badge, with the detail on demand. Closed entries are folded away. Uses the app's visual widget when available, a Markdown table otherwise.
- Evals `scope-plan/baseline-and-callers` and `improve/log-shows-problems`; the suite has 12 cases.

### Changed

- `scope-plan` research lists every caller of each shared function or chokepoint the change extends, with what each reads, not only the entry points.
- `improve note` re-reads the log right before appending and takes the next free id, so two sessions cannot write the same one.
- The README and `improve` no longer hard-code the clone location.

### Fixed

- Eval `learn/pr-explains-not-judges`: the graders no longer fail on ordinary uses of "block" or on a question mark slightly further from "idempotency".

## [2.2.0] - 2026-10-15

### Added

- Principles: a skill that opens a fresh session renames it after the work with the app's session-title tool: `<ticket or PR id> <2-3 words>`, or two or three words naming the problem. It skips the rename when the tool is missing. Before, the title stayed the command name ("Scope plan <id>").

## [2.1.0] - 2026-10-14

### Added

- `scope-plan` moves the session into the new worktree with EnterWorktree, when the project profile says so. Worktrees can live in the editor's own folder (`<repo>/.claude/worktrees/`).
- Project profiles gain "Session follows the worktree" and "Manual testing". `pr-round` treats moving the local stack to the change's worktree as a gate.

## [2.0.0] - 2026-10-14

### Changed (breaking)

- `/my:study-review` is now `/my:learn review`. The skill has two modes and keeps the same study pages, glossary and index.

### Added

- `/my:learn pr <n>`: understand a PR before reviewing it. Gives what it does and why, the flow before and after, the reading order, its promise and the questions to keep in mind. A re-run covers only the commits since the last reading.
- Sub-commands for a navigable menu: `/my:learn:pr`, `/my:learn:review`, `/my:improve:note`, `/my:improve:run`, `/my:improve:log`.
- `/my:review-lens` reuses the `/my:learn pr` reading: its promise and map as the yardstick, its questions as starting hypotheses.
- Eval `learn/pr-explains-not-judges`; the suite has 10 cases, all passing.

## [1.0.0] - 2026-10-14

### Added

- `/my:pr-round` skill: plan-driven round with checked triage, background executor, verification against git, fresh conformance review with labelled findings, deep review at milestones, automatic draft push, five-line report and ready-for-review gate with a retrospective; evals for a silently skipped item and an out-of-scope finding.
- `/my:merge-main` skill: merge-tree preview, conflict classes, design-conflict gate informed by the conflicting PRs, pinned regeneration and post-merge checks; eval for a design conflict next to a lockfile conflict.
- `/my:explain-comment` skill: duplicate grouping, code-checked classification, proportional actions, reply drafts, and a triage file for the next round; eval for duplicates and a false positive.
- `/my:review-lens` skill: senior-style review with verified, graded findings, questions for the author, and pending-review, summary or local output; eval for a broken promise.
- `/my:scope-plan` skill: project profile setup, ticket reading, research, size-scaled interview, independent plan review, approval gate, worktree and ticket start; evals for a small task and a false premise.
- `/my:study-review` skill: three-layer Markdown study pages with a reading budget, cumulative glossary, reviewer profiles and index; eval for the budget and known terms.
- Shared foundation: principles extended (gates, push policy, review depth, notifications, project profiles, closing step), question format, review lenses, local data layout.
- Templates: plan, project profile, round, round summary, log entry, reviewer profile, study page.
- `/my:improve` skill: `note`, list, `run`, `log`, with its first eval case.
- Eval guide: how to run cases locally and which grader types to use.
- Scripts: `verify-round.sh` (summary versus git) and `drift.sh` (size, distance from main, conflict preview).

### Changed

- Local data root moved from `~/.claude/my` to `~/.my-agent-kit`: Claude Code protects `~/.claude`, so headless runs refused to write there (found in the real trials).
- README: gates updated (pushing a verified round to the draft branch is not a gate), end-to-end example, eval command.

### Verified

- 9 eval cases pass (`claude plugin eval`, local only, about $3.3 for the suite).
- Real read-only trials of all seven skills on a large private repository, including a full `pr-round` and `merge-main` on a scratch branch that was never pushed.

## [0.1.0] - 2026-10-14

### Added

- Repository base: plugin manifest (`my`), private marketplace manifest, README, shared principles, privacy check and pre-commit hook.
