import type { MyStatusPart, MyStatusRun } from '../types'

const PLAN = { title: 'Learn from use', path: '/work/.plans/plan.md' }

const PARTS_MID: MyStatusRun['parts'] = [
  { title: 'Part A', status: 'done', done: 3, total: 3 },
  { title: 'Part B', status: 'running', done: 3, total: 6 },
  { title: 'Part C', status: 'todo', done: 0, total: 2 },
]

export const READY: MyStatusRun = {
  plan: PLAN,
  state: 'ready',
  parts: [
    { title: 'Part A', status: 'todo', done: 0, total: 3 },
    { title: 'Part B', status: 'todo', done: 0, total: 6 },
    { title: 'Part C', status: 'todo', done: 0, total: 2 },
  ],
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

export const WITH_PR: MyStatusRun = { ...READY, state: 'ready', pr: 456 }

export const PLANNING: MyStatusRun = {
  plan: { title: 'Discounts on carts', path: '' },
  state: 'planning',
  step: 'interview',
}

export const LONG_TITLE = 'Make checkout charging reliable across provider timeouts and retries'
const LONG_REASON = 'Verification failed: item 4 has no commit and the webhook retry tests are red'

export const OLD_NEEDS_YOU: MyStatusRun = { ...NEEDS_YOU, plan: { title: LONG_TITLE, path: '' }, reason: LONG_REASON }

export const NAMED: MyStatusRun = { ...RUNNING, name: 'Webhook retries', updatedAt: '2026-01-10T09:20:00Z' }

// ---------- state files as kit 5.7 writes them: start, short titles, steps with their status, rounds ----------

type Step = NonNullable<MyStatusPart['steps']>[number]
const S = (label: string, status: Step['status'] = 'done'): Step => ({ label, status })
function part(letter: string, heading: string, short: string, steps: Step[]): MyStatusPart {
  const done = steps.filter(s => s.status === 'done').length
  const status = done === steps.length ? 'done' : done > 0 || steps.some(s => s.status === 'running') ? 'running' : 'todo'
  return { title: `Part ${letter}: ${heading}`, short, status, done, total: steps.length, steps }
}

export const PLAN_FILE = '/work/.plans/plan.md'
const V2_PLAN = { title: 'Learn from use', path: PLAN_FILE }
const ROUNDS = [
  { n: 1, startedAt: '2026-01-10T08:20:00Z', endedAt: '2026-01-10T08:40:00Z', verdict: 'block 1' },
  { n: 2, startedAt: '2026-01-10T08:40:00Z', endedAt: '2026-01-10T09:00:00Z', verdict: 'block 1' },
]

const FOUR: MyStatusPart[] = [
  part('A', 'cart totals add up across currencies', 'Cart totals', [S('Totals'), S('Rounding'), S('Empty cart')]),
  part('B', 'the checkout page matches the design', 'Checkout page', [S('Cards'), S('Spacing'), S('Dark mode')]),
  part('C', 'the order badge counts live orders', 'Order badge', [S('Badge'), S('Live count')]),
  part('D', 'the old payment form is gone', 'Old form', [S('Hide form'), S('Remove form', 'running'), S('Final check', 'todo')]),
]

/** Running: parts A to C done, D on its second step; started 72 minutes before the tests' clock (09:25). */
export const V2_RUNNING: MyStatusRun = {
  plan: V2_PLAN,
  startedAt: '2026-01-10T08:13:00Z',
  state: 'running',
  round: 3,
  step: 'execute',
  parts: FOUR,
  rounds: [...ROUNDS, { n: 3, startedAt: '2026-01-10T09:00:00Z' }],
}

export const V2_NEEDS_YOU: MyStatusRun = {
  ...V2_RUNNING,
  state: 'needs_you',
  reason: 'PR description',
  parts: [...FOUR.slice(0, 3), part('D', 'the old payment form is gone', 'Old form', [S('Hide form'), S('Remove form'), S('Open the PR', 'running')])],
}

/** At a gate, with parts out of order: A and E done, B half done with nothing under way, C and D not started. */
export const V2_NEEDS_YOU_HALF: MyStatusRun = {
  ...V2_RUNNING,
  state: 'needs_you',
  reason: 'Field decision',
  parts: [
    part('A', 'the ledger', 'Ledger', [S('Write entry'), S('Replay entry')]),
    part('B', 'ledger telemetry', 'Telemetry', [S('Ledger events'), S('Region field', 'todo')]),
    part('C', 'the not-saved log', 'Not-saved log', [S('Typed error', 'todo')]),
    part('D', 'the lifecycle doc', 'Lifecycle doc', [S('Doc rule', 'todo'), S('Doc cost', 'todo'), S('Doc example', 'todo')]),
    part('E', 'the save retry', 'Save retry', [S('Retry save')]),
  ],
}

export const V2_STOPPED: MyStatusRun = {
  ...V2_RUNNING,
  state: 'stopped',
  reason: 'Tests failing',
  parts: [...FOUR.slice(0, 3), part('D', 'the old payment form is gone', 'Old form', [S('Hide form'), S('Remove form', 'failed'), S('Final check', 'todo')])],
  rounds: [...ROUNDS, { n: 3, startedAt: '2026-01-10T09:00:00Z', endedAt: '2026-01-10T09:20:00Z', verdict: 'failed: tests' }],
}

export const V2_DONE: MyStatusRun = {
  ...V2_RUNNING,
  startedAt: '2026-01-10T08:00:00Z',
  state: 'done',
  parts: FOUR.map(p => ({ ...p, status: 'done' as const, done: p.total, steps: p.steps?.map(s => S(s.label)) })),
  rounds: [...ROUNDS, { n: 3, startedAt: '2026-01-10T09:00:00Z', endedAt: '2026-01-10T09:31:00Z', verdict: 'none' }],
}

const SIX: MyStatusPart[] = [
  part('A', 'a settings toggle', 'Settings toggle', [S('Add toggle'), S('Persist choice')]),
  part('B', 'the query layer filters', 'Query layer', [S('Filter param'), S('Index column'), S('Backfill rows'), S('Wire query')]),
  part('C', 'the product grid', 'Product grid', [S('Cards'), S('Spacing'), S('Dark mode', 'todo'), S('Empty state', 'todo'), S('Loading skeletons', 'todo'), S('Keyboard focus rings', 'todo')]),
  part('D', 'the order badge', 'Order badge', [S('Badge', 'todo'), S('Live count', 'todo'), S('Tooltip copy', 'todo')]),
  part('E', 'the old panel', 'Old panel', [S('Hide panel', 'todo'), S('Remove panel', 'todo')]),
  part('F', 'a final pass', 'Final pass', [S('Accessibility audit', 'todo'), S('Final check', 'todo')]),
]

/** Ready after round 3, six parts, the next step to do being C's third. */
export const V2_READY: MyStatusRun = { ...V2_RUNNING, state: 'ready', step: 'report', parts: SIX, rounds: [...ROUNDS, { n: 3, startedAt: '2026-01-10T09:00:00Z', endedAt: '2026-01-10T09:20:00Z' }] }

/** Running with six parts, C on its fifth step, before any round ended. */
export const V2_RUNNING_SIX: MyStatusRun = {
  ...V2_RUNNING,
  parts: SIX.map(p => (p.short === 'Product grid' ? part('C', 'the product grid', 'Product grid', [S('Cards'), S('Spacing'), S('Dark mode'), S('Empty state'), S('Loading skeletons', 'running'), S('Keyboard focus rings', 'todo')]) : p)),
  rounds: [{ n: 1, startedAt: '2026-01-10T09:03:00Z' }],
}

export const V2_PLANNING: MyStatusRun = { plan: V2_PLAN, startedAt: '2026-01-10T09:21:00Z', state: 'planning', step: 'interview' }
