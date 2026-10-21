import type { MyStatusActivity, MyStatusPart, MyStatusProgress, MyStatusRun, MyStatusSnapshot } from '../types'

export type Tone = 'neutral' | 'accent' | 'success' | 'warning' | 'danger'

export type Badge = { key: string; text: string; tone: Tone }

export type Tile = { fill: number; tone: Tone }

export type Action = { key: string; label: string; command?: string; opensPlan?: true }

export type BandView = {
  title?: string
  tiles: Tile[]
  badges: Badge[]
  detail?: string
  time?: string
  actions: Action[]
  status: string
}

export const TILE_CELLS = 3

const STALE_MS = 6 * 60 * 60_000
const MIN_TEXT = 4
const MIN_TITLE = 8
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

function tiles(run: MyStatusRun, currentTone: Tone): Tile[] {
  return (run.parts ?? []).map(part => {
    const fill = partFraction(part)
    if (fill >= 1) return { fill: 1, tone: 'success' as Tone }
    if (part.status === 'running' || fill > 0) return { fill: Math.max(fill, 0.1), tone: currentTone }
    return { fill: 0, tone: 'neutral' as Tone }
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

function cut(text: string, room: number): string | undefined {
  if (room < MIN_TEXT) return undefined
  if (width(text) <= room) return text
  return `${[...text].slice(0, room - 1).join('').trimEnd()}…`
}

/** The columns the band takes, child by child as register.tsx draws them, with a gap of 1 between children. */
export function bandWidth(view: BandView): number {
  const n = view.tiles.length
  const widths = [
    ...(view.title ? [width(view.title)] : []),
    ...(n > 0 ? [n * TILE_CELLS + (n - 1)] : []),
    ...view.badges.map(badge => width(badge.text) + 2),
    ...(view.detail ? [width(view.detail)] : []),
    0,
    ...(view.time ? [width(view.time)] : []),
    ...view.actions.map(action => width(action.label) + 4),
  ]
  return widths.reduce((a, b) => a + b, 0) + widths.length - 1
}

const DROPS: ((view: BandView) => BandView)[] = [
  view => ({ ...view, time: undefined }),
  view => ({ ...view, actions: view.actions.filter((action, i) => i === 0 || !action.opensPlan) }),
  view => ({ ...view, tiles: [] }),
  view => ({ ...view, badges: view.badges.slice(0, 1) }),
  view => ({ ...view, actions: view.actions.slice(0, 1) }),
]

function fit(view: BandView, columns: number): BandView {
  let fixed: BandView = { ...view, title: undefined, detail: undefined }
  for (const drop of DROPS) {
    if (bandWidth(fixed) <= columns) break
    fixed = drop(fixed)
  }
  let left = columns - bandWidth(fixed)
  let title: string | undefined
  if (view.title) {
    const room = left - 1
    const share = view.detail ? Math.max(MIN_TITLE, Math.floor(room / 2), room - width(view.detail) - 1) : room
    title = cut(view.title, Math.min(room, share))
    if (title) left -= width(title) + 1
  }
  const detail = view.detail ? cut(view.detail, left - 1) : undefined
  return { ...fixed, title, detail }
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
  const name = activity.name ?? activity.mode
  return {
    title: name,
    tiles: [],
    badges: [{ key: 'state', text: label, tone: waiting ? 'warning' : 'accent' }],
    actions: [],
    status: [label, name].filter(Boolean).join(' · ') + notes,
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
  const title = run?.name ?? run?.plan?.title
  const notes = snap.openNotes > 0 ? ` · ${snap.openNotes} kit notes` : ''
  const comments = snap.newComments ?? 0
  const conflicts = snap.conflicts ?? 0

  if (run && run.state === 'planning') {
    const at = Math.max(0, PLANNING_STEPS.indexOf((run.step ?? 'research') as (typeof PLANNING_STEPS)[number]))
    const label = STEPS[PLANNING_STEPS[at] ?? 'research'] ?? 'Research'
    return {
      title,
      tiles: PLANNING_STEPS.map((_, k) => (k < at ? { fill: 1, tone: 'success' as Tone } : k === at ? { fill: 0.5, tone: 'accent' as Tone } : { fill: 0, tone: 'neutral' as Tone })),
      badges: [{ key: 'state', text: 'Planning', tone: 'accent' }],
      detail: label,
      actions: [],
      status: `Planning · ${label}${notes}`,
    }
  }

  if (run && run.state === 'needs_you') {
    return {
      title,
      tiles: tiles(run, 'warning'),
      badges: [{ key: 'state', text: 'Needs you', tone: 'warning' }],
      detail: run.reason ?? undefined,
      actions: blockedActions(snap, [OPEN_PLAN]),
      status: `Needs you${notes}`,
    }
  }

  if (run && run.state === 'running') {
    const pct = planPercent(run.parts ?? [], run.items)
    const time = timeLeft(run)
    return {
      title,
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
      title,
      tiles: tiles(run, 'warning'),
      badges: [{ key: 'state', text: 'Stopped', tone: 'danger' }],
      detail: run.reason ?? undefined,
      actions: blockedActions(snap, [ONE_ROUND, OPEN_PLAN]),
      status: `Stopped${notes}`,
    }
  }

  if (comments > 0) {
    const label = run?.pr ? `PR ${run.pr}` : title
    const text = `${comments} new comment${comments === 1 ? '' : 's'}`
    return { title: label, tiles: [], badges: [{ key: 'comments', text, tone: 'warning' }], actions: [REVIEW_COMMENTS], status: `${text}${notes}` }
  }

  if (conflicts > 0) {
    const text = `${conflicts} conflict${conflicts === 1 ? '' : 's'} with main`
    return { title, tiles: [], badges: [{ key: 'conflicts', text, tone: 'danger' }], actions: [MERGE_MAIN], status: `${text}${notes}` }
  }

  if (run && run.state === 'done') {
    const total = totalTime(run)
    const rounds = run.rounds?.length ?? 0
    return {
      title,
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
      title,
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
