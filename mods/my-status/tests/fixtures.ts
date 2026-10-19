import type { MyStatusRun, MyStatusSnapshot } from '../types'

const PLAN = { title: 'Learn from use', path: '/work/.plans/plan.md' }

const PARTS_MID: MyStatusRun['parts'] = [
  { title: 'Part A', status: 'done', done: 3, total: 3 },
  { title: 'Part B', status: 'running', done: 3, total: 6 },
  { title: 'Part C', status: 'todo', done: 0, total: 2 },
]

export function snap(run: MyStatusRun | null, extra: Partial<MyStatusSnapshot> = {}): MyStatusSnapshot {
  return { run, newComments: 0, conflicts: 0, openNotes: 0, now: 0, ...extra }
}

export const READY: MyStatusRun = {
  plan: PLAN,
  state: 'ready',
  parts: [
    { title: 'Part A', status: 'todo', done: 0, total: 3 },
    { title: 'Part B', status: 'todo', done: 0, total: 6 },
    { title: 'Part C', status: 'todo', done: 0, total: 2 },
  ],
}

export const FIRST_ROUND: MyStatusRun = {
  plan: PLAN,
  state: 'running',
  round: 1,
  step: 'execute',
  items: { done: 2, total: 4 },
  parts: [
    { title: 'Part A', status: 'running', done: 1, total: 2 },
    { title: 'Part B', status: 'todo', done: 0, total: 6 },
    { title: 'Part C', status: 'todo', done: 0, total: 2 },
  ],
  rounds: [{ n: 1, startedAt: '2026-01-10T09:00:00Z' }],
}

export const RUNNING: MyStatusRun = {
  plan: PLAN,
  state: 'running',
  round: 3,
  step: 'execute',
  items: { done: 3, total: 6 },
  parts: PARTS_MID,
  rounds: [
    { n: 1, startedAt: '2026-01-10T09:00:00Z', endedAt: '2026-01-10T09:10:00Z' },
    { n: 2, startedAt: '2026-01-10T09:10:00Z', endedAt: '2026-01-10T09:20:00Z' },
    { n: 3, startedAt: '2026-01-10T09:20:00Z' },
  ],
}

export const NEEDS_YOU: MyStatusRun = { ...RUNNING, state: 'needs_you', reason: 'Verification failed: item 4 has no commit' }

export const DONE: MyStatusRun = {
  ...RUNNING,
  state: 'done',
  parts: PARTS_MID?.map(part => ({ ...part, status: 'done' as const, done: part.total })),
  rounds: RUNNING.rounds?.map(round => ({ ...round, endedAt: round.endedAt ?? '2026-01-10T09:31:00Z' })),
}

export const WITH_PR: MyStatusRun = { ...READY, state: 'ready', pr: 456 }
