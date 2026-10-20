import type { MyStatusPart, MyStatusRun, MyStatusSnapshot } from '../types'

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

const STALE_PLANNING_MS = 6 * 60 * 60_000
const WIDE = 90
const NARROW = 70
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

export function planPercent(parts: MyStatusPart[]): number {
  if (parts.length === 0) return 0
  const sum = parts.reduce((acc, part) => acc + partFraction(part), 0)
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

function fit(view: BandView, columns: number): BandView {
  if (columns >= WIDE) return view
  const narrowed: BandView = { ...view, detail: undefined }
  if (columns >= NARROW) return narrowed
  const actions = view.actions.filter(action => !action.opensPlan).slice(0, 1)
  return { ...narrowed, actions }
}

export function bandView(snap: MyStatusSnapshot | null, columns: number): BandView | null {
  if (snap === null) return null
  const isStalePlanning = snap.run?.state === 'planning' && !!snap.run.updatedAt && snap.now - Date.parse(snap.run.updatedAt) > STALE_PLANNING_MS
  const run = isStalePlanning ? null : snap.run
  const title = run?.plan?.title
  const notes = snap.openNotes > 0 ? ` · ${snap.openNotes} kit notes` : ''

  if (run && run.state === 'planning') {
    const at = Math.max(0, PLANNING_STEPS.indexOf((run.step ?? 'research') as (typeof PLANNING_STEPS)[number]))
    const label = STEPS[PLANNING_STEPS[at] ?? 'research'] ?? 'Research'
    return fit({
      title,
      tiles: PLANNING_STEPS.map((_, k) => (k < at ? { fill: 1, tone: 'success' as Tone } : k === at ? { fill: 0.5, tone: 'accent' as Tone } : { fill: 0, tone: 'neutral' as Tone })),
      badges: [{ key: 'state', text: 'Planning', tone: 'accent' }],
      detail: label,
      actions: [],
      status: `Planning · ${label}${notes}`,
    }, columns)
  }

  if (run && (run.state === 'needs_you' || run.state === 'stopped')) {
    const isStopped = run.state === 'stopped'
    return fit({
      title,
      tiles: tiles(run, 'warning'),
      badges: [{ key: 'state', text: isStopped ? 'Stopped' : 'Needs you', tone: isStopped ? 'danger' : 'warning' }],
      detail: run.reason ?? undefined,
      actions: snap.newComments > 0 ? [REVIEW_COMMENTS, OPEN_PLAN] : snap.conflicts > 0 ? [MERGE_MAIN, OPEN_PLAN] : isStopped ? [ONE_ROUND, OPEN_PLAN] : [OPEN_PLAN],
      status: `${isStopped ? 'Stopped' : 'Waiting for you'}${notes}`,
    }, columns)
  }

  if (run && run.state === 'running') {
    const pct = planPercent(run.parts ?? [])
    const time = timeLeft(run)
    return fit({
      title,
      tiles: tiles(run, 'accent'),
      badges: [{ key: 'percent', text: `${pct}%`, tone: 'accent' }],
      detail: detail(run),
      time,
      actions: [OPEN_PLAN],
      status: `${pct}% · ${time}${notes}`,
    }, columns)
  }

  if (snap.newComments > 0) {
    const label = run?.pr ? `PR ${run.pr}` : title
    const text = `${snap.newComments} new comment${snap.newComments === 1 ? '' : 's'}`
    return fit({ title: label, tiles: [], badges: [{ key: 'comments', text, tone: 'warning' }], actions: [REVIEW_COMMENTS], status: `${text}${notes}` }, columns)
  }

  if (snap.conflicts > 0) {
    const text = `${snap.conflicts} conflict${snap.conflicts === 1 ? '' : 's'} with main`
    return fit({ title, tiles: [], badges: [{ key: 'conflicts', text, tone: 'danger' }], actions: [MERGE_MAIN], status: `${text}${notes}` }, columns)
  }

  if (run && run.state === 'done') {
    const total = totalTime(run)
    const rounds = run.rounds?.length ?? 0
    return fit({
      title,
      tiles: tiles(run, 'success'),
      badges: [{ key: 'state', text: 'Bar met', tone: 'success' }],
      time: total ? `${rounds} rounds · ${total}` : undefined,
      actions: [],
      status: `Bar met${notes}`,
    }, columns)
  }

  if (run && run.state === 'ready') {
    const parts = run.parts?.length ?? 1
    return fit({
      title,
      tiles: tiles(run, 'accent'),
      badges: [{ key: 'state', text: 'Plan approved', tone: 'success' }],
      detail: `${parts} part${parts === 1 ? '' : 's'}`,
      actions: [RUN_PLAN, ONE_ROUND],
      status: `Plan ready${notes}`,
    }, columns)
  }

  return null
}

export function statusLine(snap: MyStatusSnapshot | null): string | undefined {
  const view = bandView(snap, WIDE)
  if (view) return `my: ${view.status}`
  if (snap && snap.openNotes > 0) return `my: ${snap.openNotes} kit notes`
  return undefined
}
