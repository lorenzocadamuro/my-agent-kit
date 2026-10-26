import type { MyStatusActivity, MyStatusPart, MyStatusProgress, MyStatusRun, MyStatusSnapshot } from '../types'

export type Tone = 'neutral' | 'accent' | 'success' | 'warning' | 'danger'

export type Badge = { key: string; text: string; tone: Tone }

/** `hint` is what the pointer on the tile shows: the part and what it still needs. */
export type Tile = { fill: number; tone: Tone; hint?: { full: string; short?: string } }

/** A hint drawn over the band at `left`, revealed while the pointer is on tile `index`. */
export type HintCard = { index: number; left: number; text: string; tone: Tone }

export type Action = { key: string; label: string; command?: string; opensPlan?: true }

/** What the band shows: no text about the work itself (its name, the plan title, the PR), only state, progress, a reason and actions. */
export type BandView = {
  tiles: Tile[]
  badges: Badge[]
  reason?: string
  detail?: string
  time?: string
  actions: Action[]
  status: string
}

export const TILE_CELLS = 3

const STALE_MS = 6 * 60 * 60_000
const MINUTE = 60_000

const RUN_PLAN: Action = { key: 'run', label: 'Run plan', command: '/my:plan:run' }
const ONE_ROUND: Action = { key: 'round', label: 'One round', command: '/my:plan:round' }
const OPEN_PLAN: Action = { key: 'open', label: 'Open plan', opensPlan: true }
const REVIEW_COMMENTS: Action = { key: 'comments', label: 'Review comments', command: '/my:pr:comments' }
const MERGE_MAIN: Action = { key: 'sync', label: 'Merge main', command: '/my:pr:sync' }

const PLANNING_STEPS = ['research', 'interview', 'write', 'review', 'approval'] as const

const STEPS: Record<string, string> = {
  research: 'Research',
  interview: 'Interview',
  write: 'Writing the plan',
  approval: 'Waiting for approval',
  triage: 'Triage',
  check: 'Triage check',
  execute: 'Execute',
  verify: 'Verify',
  review: 'Review',
  push: 'Push',
  report: 'Report',
}

export function partFraction(part: MyStatusPart): number {
  if (part.status === 'done') return 1
  if (part.total <= 0) return 0
  return Math.min(1, Math.max(0, part.done / part.total))
}

export function planPercent(parts: MyStatusPart[], items?: { done: number; total: number }): number {
  if (parts.length === 0) return 0
  const itemShare = items && items.total > 0 ? Math.min(1, Math.max(0, items.done / items.total)) : 0
  const share = (part: MyStatusPart) => (part.status === 'running' ? Math.max(partFraction(part), itemShare) : partFraction(part))
  const sum = parts.reduce((acc, part) => acc + share(part), 0)
  return Math.round((sum / parts.length) * 100)
}

function roundMs(round: { startedAt?: string; endedAt?: string }): number | null {
  if (!round.startedAt || !round.endedAt) return null
  const ms = Date.parse(round.endedAt) - Date.parse(round.startedAt)
  return Number.isFinite(ms) && ms > 0 ? ms : null
}

function minutes(ms: number): string {
  const m = Math.max(1, Math.round(ms / MINUTE))
  return m >= 90 ? `${Math.round(m / 60)} h` : `${m} min`
}

export function timeLeft(run: MyStatusRun): string {
  const finished = (run.rounds ?? []).map(roundMs).filter((ms): ms is number => ms !== null)
  const parts = run.parts ?? []
  const doneShare = parts.reduce((acc, part) => acc + partFraction(part), 0)
  if (finished.length === 0 || doneShare <= 0) return 'estimating…'
  const perRound = finished.reduce((a, b) => a + b, 0) / finished.length
  const roundsPerPart = finished.length / doneShare
  const left = perRound * roundsPerPart * (parts.length - doneShare)
  const low = Math.max(MINUTE, left * 0.7)
  const high = Math.max(low + MINUTE, left * 1.3)
  const lowText = minutes(low).replace(/ (min|h)$/, '')
  return `~${lowText}–${minutes(high)}`
}

export function totalTime(run: MyStatusRun): string | undefined {
  const all = (run.rounds ?? []).map(roundMs).filter((ms): ms is number => ms !== null)
  if (all.length === 0) return undefined
  return minutes(all.reduce((a, b) => a + b, 0))
}

function hint(part: MyStatusPart, index: number): Tile['hint'] {
  const head = part.title.split(':')[0]?.trim() ?? ''
  const label = /^(\S+\s+)?[A-Za-z0-9]{1,3}$/.test(head) ? head : `Part ${index + 1}`
  if (partFraction(part) >= 1) return { full: `${label} · done` }
  const left = (part.left ?? []).filter(Boolean)
  if (left.length > 0) return { full: `${label} · left: ${left.join(', ')}`, short: `${label} · ${left.length} left` }
  return { full: `${label} · ${part.done} of ${part.total} done` }
}

function tiles(run: MyStatusRun, currentTone: Tone): Tile[] {
  return (run.parts ?? []).map((part, index) => {
    const fill = partFraction(part)
    const tile = (t: Tile): Tile => ({ ...t, hint: hint(part, index) })
    if (fill >= 1) return tile({ fill: 1, tone: 'success' })
    if (part.status === 'running' || fill > 0) return tile({ fill: Math.max(fill, 0.1), tone: currentTone })
    return tile({ fill: 0, tone: 'neutral' })
  })
}

function currentPart(run: MyStatusRun): { index: number; total: number } {
  const parts = run.parts ?? []
  const index = parts.findIndex(part => part.status !== 'done')
  return { index: index === -1 ? parts.length : index + 1, total: parts.length }
}

function detail(run: MyStatusRun): string {
  const { index, total } = currentPart(run)
  const bits = [`Part ${index} of ${total}`]
  if (run.round) bits.push(`round ${run.round}`)
  const step = run.step ? STEPS[run.step] ?? run.step : undefined
  if (step) bits.push(run.items && run.step === 'execute' ? `${step} ${run.items.done}/${run.items.total}` : step)
  return bits.join(' · ')
}

const width = (text: string) => [...text].length

/** The columns the band takes, child by child as register.tsx draws them, with a gap of 1 between children. */
export function bandWidth(view: BandView): number {
  const n = view.tiles.length
  const widths = [
    ...(n > 0 ? [n * TILE_CELLS + (n - 1)] : []),
    ...view.badges.map(badge => width(badge.text) + 2),
    ...(view.reason ? [width(view.reason)] : []),
    ...(view.detail ? [width(view.detail)] : []),
    0,
    ...(view.time ? [width(view.time)] : []),
    ...view.actions.map(action => width(action.label) + 4),
  ]
  return widths.reduce((a, b) => a + b, 0) + widths.length - 1
}

/**
 * One card per tile with a hint, from right after the tiles to the band's end, so it covers every other element whole
 * and leaves no piece of one showing. The full hint, else the short one, only when it fits whole; else no card.
 */
export function hintCards(view: BandView, columns: number): HintCard[] {
  const n = view.tiles.length
  if (n === 0) return []
  const left = n * TILE_CELLS + (n - 1) + 1
  return view.tiles.flatMap((tile, index) => {
    const text = [tile.hint?.full, tile.hint?.short].find(t => t !== undefined && left + width(t) + 2 <= columns)
    if (text === undefined) return []
    const shown = ` ${text} `
    return [{ index, left, text: shown + ' '.repeat(columns - left - width(shown)), tone: tile.tone }]
  })
}

/**
 * Nothing is ever cut. The state badge and the first button always show; every other element is added whole, in this
 * fixed order, only while the band still fits: the reason, the other buttons except Open plan, the percent, the tiles,
 * Open plan, the detail, the time.
 */
function fit(view: BandView, columns: number): BandView {
  const [state, ...percent] = view.badges
  const [first, ...more] = view.actions
  const withAction = (action: Action) => (v: BandView): BandView => ({ ...v, actions: view.actions.filter(a => a === action || v.actions.includes(a)) })
  const adds: ((v: BandView) => BandView)[] = [
    v => ({ ...v, reason: view.reason }),
    ...more.filter(action => !action.opensPlan).map(withAction),
    ...percent.map(badge => (v: BandView): BandView => ({ ...v, badges: [...v.badges, badge] })),
    v => ({ ...v, tiles: view.tiles }),
    ...more.filter(action => action.opensPlan).map(withAction),
    v => ({ ...v, detail: view.detail }),
    v => ({ ...v, time: view.time }),
  ]
  let fitted: BandView = { ...view, tiles: [], badges: state ? [state] : [], reason: undefined, detail: undefined, time: undefined, actions: first ? [first] : [] }
  for (const add of adds) {
    const next = add(fitted)
    if (bandWidth(next) <= columns) fitted = next
  }
  return fitted
}

function isStale(updatedAt: string | undefined, now: number, newer?: string): boolean {
  if (!updatedAt) return false
  const at = Math.max(Date.parse(updatedAt), newer ? Date.parse(newer) || 0 : 0)
  return Number.isFinite(at) && now - at > STALE_MS
}

export function withProgress(run: MyStatusRun, progress: MyStatusProgress | null | undefined): MyStatusRun {
  if (!progress?.items || !progress.updatedAt || progress.round !== run.round || run.step !== 'execute') return run
  if (run.updatedAt && !(Date.parse(progress.updatedAt) > Date.parse(run.updatedAt))) return run
  return { ...run, items: progress.items }
}

function readyLabel(run: MyStatusRun): string {
  return run.round && run.round > 0 ? `Round ${run.round} done` : 'Ready'
}

function activityView(activity: MyStatusActivity, notes: string): BandView {
  const waiting = activity.state === 'needs_you'
  const label = waiting ? 'Needs you' : 'Running'
  return {
    tiles: [],
    badges: [{ key: 'state', text: label, tone: waiting ? 'warning' : 'accent' }],
    detail: activity.mode,
    actions: [],
    status: [label, activity.mode].filter(Boolean).join(' · ') + notes,
  }
}

function blockedActions(snap: MyStatusSnapshot, fallback: Action[]): Action[] {
  if ((snap.newComments ?? 0) > 0) return [REVIEW_COMMENTS, OPEN_PLAN]
  if ((snap.conflicts ?? 0) > 0) return [MERGE_MAIN, OPEN_PLAN]
  return fallback
}

function view(snap: MyStatusSnapshot): BandView | null {
  const stored = snap.run
  const mayAge = stored && (stored.state === 'planning' || stored.state === 'running')
  const run = stored && mayAge && isStale(stored.updatedAt, snap.now, snap.progress?.updatedAt) ? null : stored && withProgress(stored, snap.progress)
  const activity = snap.activity && (snap.activity.state === 'running' || snap.activity.state === 'needs_you') && !isStale(snap.activity.updatedAt, snap.now) ? snap.activity : null
  const notes = snap.openNotes > 0 ? ` · ${snap.openNotes} kit notes` : ''
  const comments = snap.newComments ?? 0
  const conflicts = snap.conflicts ?? 0

  if (run && run.state === 'planning') {
    const at = Math.max(0, PLANNING_STEPS.indexOf((run.step ?? 'research') as (typeof PLANNING_STEPS)[number]))
    const label = STEPS[PLANNING_STEPS[at] ?? 'research'] ?? 'Research'
    return {
      tiles: PLANNING_STEPS.map((_, k) => (k < at ? { fill: 1, tone: 'success' as Tone } : k === at ? { fill: 0.5, tone: 'accent' as Tone } : { fill: 0, tone: 'neutral' as Tone })),
      badges: [{ key: 'state', text: 'Planning', tone: 'accent' }],
      detail: label,
      actions: [],
      status: `Planning · ${label}${notes}`,
    }
  }

  if (run && run.state === 'needs_you') {
    return {
      tiles: tiles(run, 'warning'),
      badges: [{ key: 'state', text: 'Needs you', tone: 'warning' }],
      reason: run.reason ?? undefined,
      actions: blockedActions(snap, [OPEN_PLAN]),
      status: `Needs you${notes}`,
    }
  }

  if (run && run.state === 'running') {
    const pct = planPercent(run.parts ?? [], run.items)
    const time = timeLeft(run)
    return {
      tiles: tiles(run, 'accent'),
      badges: [
        { key: 'state', text: 'Running', tone: 'accent' },
        { key: 'percent', text: `${pct}%`, tone: 'accent' },
      ],
      detail: detail(run),
      time,
      actions: [OPEN_PLAN],
      status: `Running · ${pct}% · ${time}${notes}`,
    }
  }

  if (activity?.state === 'needs_you') return activityView(activity, notes)
  if (activity?.state === 'running') return activityView(activity, notes)

  if (run && run.state === 'stopped') {
    return {
      tiles: tiles(run, 'warning'),
      badges: [{ key: 'state', text: 'Stopped', tone: 'danger' }],
      reason: run.reason ?? undefined,
      actions: blockedActions(snap, [ONE_ROUND, OPEN_PLAN]),
      status: `Stopped${notes}`,
    }
  }

  if (comments > 0) {
    const text = `${comments} new comment${comments === 1 ? '' : 's'}`
    return { tiles: [], badges: [{ key: 'comments', text, tone: 'warning' }], actions: [REVIEW_COMMENTS], status: `${text}${notes}` }
  }

  if (conflicts > 0) {
    const text = `${conflicts} conflict${conflicts === 1 ? '' : 's'} with main`
    return { tiles: [], badges: [{ key: 'conflicts', text, tone: 'danger' }], actions: [MERGE_MAIN], status: `${text}${notes}` }
  }

  if (run && run.state === 'done') {
    const total = totalTime(run)
    const rounds = run.rounds?.length ?? 0
    return {
      tiles: tiles(run, 'success'),
      badges: [{ key: 'state', text: 'Bar met', tone: 'success' }],
      time: total ? `${rounds} rounds · ${total}` : undefined,
      actions: [],
      status: `Bar met${notes}`,
    }
  }

  if (run && run.state === 'ready') {
    const parts = run.parts?.length ?? 1
    const label = readyLabel(run)
    return {
      tiles: tiles(run, 'accent'),
      badges: [{ key: 'state', text: label, tone: 'success' }],
      detail: `${parts} part${parts === 1 ? '' : 's'}`,
      actions: [RUN_PLAN, ONE_ROUND],
      status: `${label}${notes}`,
    }
  }

  return null
}

export function bandView(snap: MyStatusSnapshot | null, columns: number): BandView | null {
  if (snap === null) return null
  const full = view(snap)
  return full && fit(full, columns)
}

export function statusLine(snap: MyStatusSnapshot | null): string | undefined {
  const full = snap && view(snap)
  if (full) return `my: ${full.status}`
  if (snap && snap.openNotes > 0) return `my: ${snap.openNotes} kit notes`
  return undefined
}
