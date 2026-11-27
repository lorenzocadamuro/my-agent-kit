import type { MyStatusActivity, MyStatusPart, MyStatusProgress, MyStatusRun, MyStatusSnapshot, Part, Step } from '../types'

// From what the kit writes (the state file, its sidecars, the PR's comments and conflicts) to the scene the approved
// prototype draws: the state that leads, its header (word, line 2, figures), the parts with their steps, and the
// action row. Nothing here names the work, the plan or the PR: only state, part letters and short titles, step labels.

export type State = 'planning' | 'ready' | 'running' | 'needs_you' | 'stopped' | 'done'
export type Role = 't1' | 't2' | 't3'
// A piece of line 2; `rank` is the order pieces drop in when line 2 meets the figures, lowest first (0 never drops)
export type Piece = { text: string; role: Role; rank: number }
export type Metric = { value: string; caption: string; muted?: boolean }
export type Cta =
  | { kind: 'primary' | 'secondary'; key: string; label: string; command: string }
  | { kind: 'question'; key: string; label: string }
  | { kind: 'warning'; key: string; label: string }
export type BandModel = {
  state: State
  word: string
  line2: Piece[]
  metrics: Metric[]
  parts: Part[]
  isPlanning: boolean
  hasPlanFile: boolean
  ctas: Cta[]
}

const STALE_MS = 6 * 60 * 60_000
const MINUTE = 60_000

const WORD: Record<State, string> = { planning: 'Planning', ready: 'Ready', running: 'Running', needs_you: 'Needs you', stopped: 'Stopped', done: 'Done' }
const PLANNING_STEPS = [
  ['research', 'Research'],
  ['interview', 'Interview'],
  ['write', 'Write'],
  ['review', 'Review'],
  ['approval', 'Approval'],
] as const
// a part's letter and, after the colon, its heading text: only a "Part X:" heading gives a short title
const HEADING = /^Part\s+([A-Za-z0-9]{1,3})\s*(?::\s*(.*))?$/

/** Minutes, as every time in the band reads: "<1m", "22m", "1h 12m". */
export function minutes(ms: number): string {
  const m = Math.floor(Math.max(0, ms) / 60_000)
  if (m < 1) return '<1m'
  return m < 60 ? `${m}m` : `${Math.floor(m / 60)}h ${String(m % 60).padStart(2, '0')}m`
}

function isStale(updatedAt: string | undefined, now: number, newer?: string): boolean {
  if (!updatedAt) return false
  const at = Math.max(Date.parse(updatedAt), newer ? Date.parse(newer) || 0 : 0)
  return Number.isFinite(at) && now - at > STALE_MS
}

/** The lane sidecars of the open round (the last without endedAt, else `round`): a failed round leaves its own behind. */
function openLanes(snap: MyStatusSnapshot): MyStatusProgress[] {
  const open = [...(snap.run?.rounds ?? [])].reverse().find(r => !r.endedAt)?.n ?? snap.run?.round
  return open === undefined ? [] : (snap.lanes ?? []).filter(lane => lane.round === open)
}

/** The newest of the progress sidecar's and the open round's lane sidecars' updatedAt: a sign the run is alive. */
function newestSidecar(snap: MyStatusSnapshot): string | undefined {
  const times = [snap.progress?.updatedAt, ...openLanes(snap).map(lane => lane.updatedAt)].filter((t): t is string => Number.isFinite(Date.parse(t ?? '')))
  return times.sort((a, b) => Date.parse(b) - Date.parse(a))[0]
}

type Lead = { state: State; run: MyStatusRun; activity?: undefined } | { state: 'running' | 'needs_you'; activity: MyStatusActivity; run?: undefined }

/**
 * The one state that leads, in today's order: the plan's gates and runs, then a `pr:*` or `improve run` activity, then
 * the plan stopped, done or ready. A planning or running file, or an activity, untouched for 6 hours counts as gone.
 * New comments and conflicts are never a state: they are signals beside it.
 */
function lead(snap: MyStatusSnapshot): Lead | null {
  const stored = snap.run
  const mayAge = stored?.state === 'planning' || stored?.state === 'running'
  const run = stored && !(mayAge && isStale(stored.updatedAt, snap.now, newestSidecar(snap))) ? stored : null
  const act = snap.activity
  const activity = act && (act.state === 'running' || act.state === 'needs_you') && !isStale(act.updatedAt, snap.now) ? act : null
  if (run && (run.state === 'planning' || run.state === 'needs_you' || run.state === 'running')) return { state: run.state, run }
  if (activity?.state === 'needs_you' || activity?.state === 'running') return { state: activity.state, activity }
  if (run && (run.state === 'stopped' || run.state === 'done' || run.state === 'ready')) return { state: run.state, run }
  return null
}

const STEP_STATUS = new Set(['todo', 'running', 'done', 'failed'])

/** A file without step labels (kit 5.6.0): numbered segments from done and total, labelled from `left` where it has them. */
function oldSteps(p: MyStatusPart): Step[] {
  const total = Math.max(0, Math.floor(Number(p.total) || 0))
  const done = p.status === 'done' ? total : Math.min(total, Math.max(0, Math.floor(Number(p.done) || 0)))
  const left = (p.left ?? []).filter(label => typeof label === 'string')
  return Array.from({ length: total }, (_, j) => (j < done ? { label: '', status: 'done' } : { label: left[j - done] ?? '', status: 'todo' }))
}

/** The parts as the band draws them; in Ready the first step to do is the next one. */
function partsOf(run: MyStatusRun, state: State): Part[] {
  const parts = (run.parts ?? []).map((p, i): Part => {
    const head = String(p.title ?? '').trim().match(HEADING)
    const letter = head?.[1] ?? String.fromCharCode(65 + (i % 26))
    const short = head ? String(p.short ?? head[2] ?? '').trim() : ''
    const steps: Step[] =
      Array.isArray(p.steps) && p.steps.length > 0
        ? p.steps.map(s => ({ label: String(s?.label ?? ''), status: STEP_STATUS.has(s?.status) ? s.status : 'todo' }))
        : oldSteps(p)
    return { letter, short, steps }
  })
  if (state === 'ready') {
    const at = find(parts, s => s.status === 'todo')
    if (at) parts[at.i]!.steps[at.j] = { ...parts[at.i]!.steps[at.j]!, status: 'next' }
  }
  return parts
}

type At = { i: number; j: number }
function find(parts: Part[], test: (s: Step) => boolean): At | null {
  for (let i = 0; i < parts.length; i++) {
    const j = parts[i]!.steps.findIndex(test)
    if (j !== -1) return { i, j }
  }
  return null
}

const stepAt = (parts: Part[], at: At) => parts[at.i]!.steps[at.j]!
const position = (parts: Part[], at: At) => `Part ${parts[at.i]!.letter}, step ${at.j + 1} of ${parts[at.i]!.steps.length}`
function nextPiece(parts: Part[]): Piece | null {
  const at = find(parts, s => s.status === 'todo' || s.status === 'next')
  if (!at) return null
  const label = stepAt(parts, at).label
  return { text: `next: Part ${parts[at.i]!.letter}${label ? `, ${label}` : ''}`, role: 't2', rank: 2 }
}

/** Where a gate or a stop stands: the step under way or failed, else the next one to do. */
function where(parts: Part[]): Piece | null {
  const at = find(parts, s => s.status === 'running' || s.status === 'failed')
  return at ? { text: position(parts, at), role: 't3', rank: 1 } : nextPiece(parts)
}

function line2(run: MyStatusRun, state: State, parts: Part[], lanes: MyStatusProgress[]): Piece[] {
  const pieces: (Piece | null)[] = []
  if (state === 'running') {
    const at = find(parts, s => s.status === 'running' || s.status === 'failed') ?? find(parts, s => s.status !== 'done')
    if (at) {
      pieces.push({ text: `Part ${parts[at.i]!.letter}`, role: 't1', rank: 0 })
      pieces.push({ text: stepAt(parts, at).label, role: 't2', rank: 3 })
      const done = lanes.filter(lane => (lane.items?.total ?? 0) > 0 && (lane.items?.done ?? 0) >= (lane.items?.total ?? 0)).length
      // the lanes of a parallel round: the first piece to drop when the band is narrow
      if (lanes.length > 0) pieces.push({ text: `lanes ${done}/${lanes.length} done`, role: 't3', rank: 0.5 })
      pieces.push({ text: `step ${at.j + 1} of ${parts[at.i]!.steps.length}`, role: 't3', rank: 1 })
    }
  } else if (state === 'needs_you' || state === 'stopped') {
    pieces.push(run.reason ? { text: run.reason, role: 't1', rank: 0 } : null, where(parts))
  } else if (state === 'ready') {
    pieces.push({ text: run.round && run.round > 0 ? `Round ${run.round} done` : 'Plan approved', role: 't1', rank: 0 }, nextPiece(parts))
  } else if (state === 'done') {
    pieces.push({ text: 'Bar met', role: 't1', rank: 0 }, { text: 'all steps verified', role: 't2', rank: 2 })
  }
  return pieces.filter((p): p is Piece => p !== null && p.text !== '')
}

function roundMs(round: { startedAt?: string; endedAt?: string }): number | null {
  if (!round.startedAt || !round.endedAt) return null
  const ms = Date.parse(round.endedAt) - Date.parse(round.startedAt)
  return Number.isFinite(ms) && ms > 0 ? ms : null
}

function partShare(part: MyStatusPart): number {
  if (part.status === 'done') return 1
  if (part.total <= 0) return 0
  return Math.min(1, Math.max(0, part.done / part.total))
}

function span(ms: number): string {
  const m = Math.max(1, Math.round(ms / MINUTE))
  return m >= 90 ? `${Math.round(m / 60)} h` : `${m} min`
}

/** Time left, as the mod has estimated it since 5.3: finished rounds' mean length times the rounds the parts left need. */
export function timeLeft(run: MyStatusRun): string {
  const finished = (run.rounds ?? []).map(roundMs).filter((ms): ms is number => ms !== null)
  const parts = run.parts ?? []
  const doneShare = parts.reduce((acc, part) => acc + partShare(part), 0)
  if (finished.length === 0 || doneShare <= 0) return 'estimating…'
  const perRound = finished.reduce((a, b) => a + b, 0) / finished.length
  const left = perRound * (finished.length / doneShare) * (parts.length - doneShare)
  const low = Math.max(MINUTE, left * 0.7)
  const high = Math.max(low + MINUTE, left * 1.3)
  const [from, to] = [span(low), span(high)]
  const unit = / (min|h)$/
  return `${from.match(unit)?.[1] === to.match(unit)?.[1] ? from.replace(unit, '') : from}–${to}`
}

function startOf(run: MyStatusRun): number | null {
  const at = Date.parse(run.startedAt ?? run.rounds?.[0]?.startedAt ?? '')
  return Number.isFinite(at) ? at : null
}

function progress(parts: Part[]): Metric | null {
  const total = parts.reduce((n, p) => n + p.steps.length, 0)
  if (total === 0) return null
  const done = parts.reduce((n, p) => n + p.steps.filter(s => s.status === 'done').length, 0)
  return { value: `${Math.round((done / total) * 100)}%`, caption: `${done} of ${total} steps` }
}

function metrics(run: MyStatusRun, state: State, parts: Part[], now: number): Metric[] {
  const start = startOf(run)
  const elapsed: Metric | null = start === null ? null : { value: minutes(now - start), caption: 'elapsed' }
  if (state === 'planning') return elapsed ? [elapsed] : []
  const out: (Metric | null)[] = [progress(parts)]
  if (state === 'done') {
    const end = Date.parse([...(run.rounds ?? [])].reverse().find(r => r.endedAt)?.endedAt ?? '')
    out.push(start !== null && Number.isFinite(end) ? { value: minutes(end - start), caption: 'total time' } : null)
  } else {
    if (parts.length > 0) {
      const left = timeLeft(run)
      out.push(
        state === 'stopped'
          ? { value: 'on hold', caption: 'time left', muted: true }
          : left === 'estimating…'
            ? { value: left, caption: 'time left', muted: true }
            : { value: left, caption: 'left (estimate)' },
      )
    }
    out.push(elapsed)
  }
  return out.filter((m): m is Metric => m !== null)
}

function signals(snap: MyStatusSnapshot): Cta[] {
  const comments = snap.newComments ?? 0
  const conflicts = snap.conflicts ?? 0
  return [
    ...(comments > 0 ? [{ kind: 'secondary', key: 'comments', label: `Review comments (${comments})`, command: '/my:comments' } as const] : []),
    ...(conflicts > 0
      ? [{ kind: 'warning', key: 'conflicts-text', label: 'Conflicts with main' } as const, { kind: 'secondary', key: 'merge-main', label: 'Merge main', command: '/my:sync' } as const]
      : []),
  ]
}

const RUN_PLAN: Cta = { kind: 'primary', key: 'run-plan', label: 'Run plan', command: '/my:run' }

/**
 * The band's scene, or null when there is nothing to show. `now` is the clock at the draw (elapsed times);
 * `isQuestionAway` whether the gate's question has left the screen (Needs you offers Show question then).
 */
export function bandModel(snap: MyStatusSnapshot | null, now: number, isQuestionAway = false): BandModel | null {
  const top = snap && lead(snap)
  if (!snap || !top) return null
  if (top.activity) {
    const since = snap.activitySince
    return {
      state: top.state,
      word: WORD[top.state],
      line2: top.activity.mode ? [{ text: top.activity.mode, role: 't1', rank: 0 }] : [],
      metrics: since === undefined ? [] : [{ value: minutes(now - since), caption: 'elapsed' }],
      parts: [],
      isPlanning: false,
      hasPlanFile: false,
      ctas: [],
    }
  }
  const { run, state } = top
  if (state === 'planning') {
    const at = Math.max(0, PLANNING_STEPS.findIndex(([key]) => key === (run.step ?? 'research')))
    const parts = PLANNING_STEPS.map(([, name], i): Part => ({ letter: name[0]!, short: '', name, steps: [{ label: name, status: i < at ? 'done' : i === at ? 'running' : 'todo' }] }))
    return {
      state,
      word: WORD[state],
      line2: [
        { text: PLANNING_STEPS[at]![1], role: 't1', rank: 0 },
        { text: `step ${at + 1} of ${PLANNING_STEPS.length}`, role: 't3', rank: 1 },
      ],
      metrics: metrics(run, state, parts, now),
      parts,
      isPlanning: true,
      hasPlanFile: snap.hasPlanFile === true,
      ctas: signals(snap),
    }
  }
  const parts = partsOf(run, state)
  const ctas: Cta[] = [...signals(snap)]
  if (state === 'ready' || state === 'stopped') ctas.push(RUN_PLAN)
  if (state === 'needs_you')
    ctas.push(isQuestionAway ? { kind: 'question', key: 'show-question', label: 'Show question' } : { kind: 'warning', key: 'answer-below', label: 'Answer in the chat below ↓' })
  return { state, word: WORD[state], line2: line2(run, state, parts, openLanes(snap)), metrics: metrics(run, state, parts, now), parts, isPlanning: false, hasPlanFile: true, ctas }
}

const plural = (n: number, word: string) => `${n} ${word}${n === 1 ? '' : 's'}`

/**
 * The status line: `my: <state>[ · extras] · <n> kit notes`, in the band's words. Extras: Planning's step, Running's
 * percent and time left, an activity's mode, then new comments and conflicts with main.
 */
export function statusLine(snap: MyStatusSnapshot | null): string | undefined {
  if (!snap) return undefined
  const notes = snap.openNotes > 0 ? `${snap.openNotes} kit notes` : null
  const top = lead(snap)
  if (!top) return notes ? `my: ${notes}` : undefined
  const bits: (string | null | undefined)[] = [WORD[top.state]]
  if (top.activity) bits.push(top.activity.mode)
  else if (top.state === 'planning') bits.push(PLANNING_STEPS.find(([key]) => key === (top.run.step ?? 'research'))?.[1] ?? 'Research')
  else if (top.state === 'running') bits.push(progress(partsOf(top.run, top.state))?.value, (top.run.parts ?? []).length > 0 ? timeLeft(top.run) : null)
  if (!top.activity) {
    if ((snap.newComments ?? 0) > 0) bits.push(plural(snap.newComments ?? 0, 'comment'))
    if ((snap.conflicts ?? 0) > 0) bits.push(plural(snap.conflicts ?? 0, 'conflict'))
  }
  bits.push(notes)
  return `my: ${bits.filter(Boolean).join(' · ')}`
}
