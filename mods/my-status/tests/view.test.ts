import { expect, test } from 'claude-code/testing'

import { bandView, bandWidth, planPercent, statusLine, timeLeft } from '../hooks/view'
import { AFTER_ROUND, DONE, FIRST_ROUND, NAMED, NEEDS_YOU, OLD_NEEDS_YOU, PLANNING, READY, RUNNING, STOPPED, WITH_PR, snap } from './fixtures'

test('the plan percentage gives each part an equal share', async () => {
  expect(planPercent(RUNNING.parts ?? [])).toBe(50)
  expect(planPercent(DONE.parts ?? [])).toBe(100)
})

test('time left waits for a finished round, then gives a range', async () => {
  expect(timeLeft(FIRST_ROUND)).toBe('estimating…')
  expect(timeLeft(RUNNING)).toMatch(/^~\d+–\d+ (min|h)$/)
})

test('one state at a time, in priority order', async () => {
  expect(bandView(snap(NEEDS_YOU, { newComments: 3 }), 120)?.badges[0]?.text).toBe('Needs you')
  expect(bandView(snap(RUNNING, { newComments: 3 }), 120)?.badges.map(b => b.text)).toEqual(['Running', '50%'])
  expect(bandView(snap(WITH_PR, { newComments: 3, conflicts: 2 }), 120)?.badges[0]?.text).toBe('3 new comments')
  expect(bandView(snap(WITH_PR, { conflicts: 2 }), 120)?.badges[0]?.text).toBe('2 conflicts with main')
  expect(bandView(snap(DONE), 120)?.badges[0]?.text).toBe('Bar met')
  expect(bandView(snap(READY), 120)?.actions.map(a => a.label)).toEqual(['Run plan', 'One round'])
})

test('a run stopped by comments or conflicts offers the action that unblocks it', async () => {
  expect(bandView(snap(NEEDS_YOU, { newComments: 2 }), 120)?.actions.map(a => a.label)).toEqual(['Review comments', 'Open plan'])
  expect(bandView(snap(NEEDS_YOU, { conflicts: 1 }), 120)?.actions.map(a => a.label)).toEqual(['Merge main', 'Open plan'])
})

test('while the plan is being made the band says Planning and where it is', async () => {
  const view = bandView(snap(PLANNING), 120)
  expect(view?.badges[0]?.text).toBe('Planning')
  expect(view?.detail).toBe('Interview')
  expect(view?.tiles.length).toBe(5)
  expect(view?.actions).toEqual([])
})

test('a planning state left untouched for hours is ignored', async () => {
  const old = { ...PLANNING, updatedAt: '2026-01-10T00:00:00Z' }
  expect(bandView(snap(old, { now: Date.parse('2026-01-10T07:00:00Z') }), 120)).toBe(null)
  expect(bandView(snap(old, { now: Date.parse('2026-01-10T01:00:00Z') }), 120)?.badges[0]?.text).toBe('Planning')
})

test('nothing to show draws no band', async () => {
  expect(bandView(null, 120)).toBe(null)
  expect(bandView(snap(null), 120)).toBe(null)
  expect(statusLine(snap(null, { openNotes: 2 }))).toBe('my: 2 kit notes')
})

test('a long title and reason are cut with … and the band fits at 120 and 80 columns', async () => {
  const wide = bandView(snap(OLD_NEEDS_YOU), 120)
  const mid = bandView(snap(OLD_NEEDS_YOU), 80)
  expect(wide?.title).toBe('Make checkout charging reliable across…')
  expect(wide?.detail).toBe('Verification failed: item 4 has no commi…')
  expect(mid?.title).toBe('Make checkout charg…')
  expect(mid?.detail).toBe('Verification failed…')
  for (const [view, columns] of [[wide, 120], [mid, 80]] as const) {
    expect(view && bandWidth(view) <= columns).toBe(true)
    expect(view?.actions.map(a => a.label)).toEqual(['Open plan'])
    expect(view?.badges[0]?.text).toBe('Needs you')
  }
})

test('a narrow band drops the time, then tiles, never the state or the first button', async () => {
  const at = (columns: number) => bandView(snap({ ...NAMED, plan: { title: 'Learn from use', path: '' } }), columns)
  expect(at(120)?.time).toBeDefined()
  expect(at(45)?.time).toBe(undefined)
  expect(at(45)?.tiles.length).toBe(3)
  expect(at(30)?.tiles).toEqual([])
  for (const columns of [120, 80, 60, 45, 30]) {
    const view = at(columns)
    expect(view?.badges[0]?.text).toBe('Running')
    expect(view?.actions.map(a => a.label)).toEqual(['Open plan'])
    expect(view && bandWidth(view) <= columns).toBe(true)
    for (const [text, full] of [[view?.title, 'Webhook retries'], [view?.detail, 'Part 2 of 3 · round 3 · Execute 3/6']] as const) {
      if (text && text !== full) expect(text.endsWith('…') && full.startsWith(text.slice(0, -1))).toBe(true)
    }
  }
})

test('one label per state, the same on the badge and the status line', async () => {
  const cases = [
    [snap(PLANNING), 'Planning'],
    [snap(READY), 'Ready'],
    [snap(AFTER_ROUND), 'Round 3 done'],
    [snap(RUNNING), 'Running'],
    [snap(NEEDS_YOU), 'Needs you'],
    [snap(STOPPED), 'Stopped'],
    [snap(DONE), 'Bar met'],
    [snap(null, { activity: { mode: 'pr:review', name: 'PR 9 Charge retries', state: 'running' } }), 'Running'],
    [snap(null, { activity: { mode: 'pr:sync', name: 'PR 9 Charge retries', state: 'needs_you' } }), 'Needs you'],
  ] as const
  for (const [s, label] of cases) {
    expect(bandView(s, 120)?.badges[0]?.text).toBe(label)
    expect(statusLine(s)?.startsWith(`my: ${label}`)).toBe(true)
  }
})

test('a planning or running state untouched for 6 hours is ignored; no date is never stale', async () => {
  const now = Date.parse('2026-01-10T16:30:00Z')
  expect(bandView(snap(NAMED, { now }), 120)).toBe(null)
  expect(bandView(snap(NAMED, { now, progress: { round: 3, items: { done: 4, total: 6 }, updatedAt: '2026-01-10T15:00:00Z' } }), 120)?.badges[0]?.text).toBe('Running')
  expect(bandView(snap(RUNNING, { now }), 120)?.badges[0]?.text).toBe('Running')
  expect(bandView(snap(null, { now, activity: { mode: 'pr:review', name: 'PR 9', state: 'running', updatedAt: '2026-01-10T09:00:00Z' } }), 120)).toBe(null)
})

test('the progress sidecar of this round moves the percent; an older one is ignored', async () => {
  const now = Date.parse('2026-01-10T09:30:00Z')
  const fresh = { round: 3, items: { done: 6, total: 6 }, updatedAt: '2026-01-10T09:25:00Z' }
  expect(bandView(snap(NAMED, { now, progress: fresh }), 120)?.badges[1]?.text).toBe('67%')
  expect(bandView(snap(NAMED, { now, progress: fresh }), 120)?.detail).toBe('Part 2 of 3 · round 3 · Execute 6/6')
  expect(bandView(snap(NAMED, { now, progress: { ...fresh, round: 2 } }), 120)?.badges[1]?.text).toBe('50%')
  expect(bandView(snap(NAMED, { now, progress: { ...fresh, updatedAt: '2026-01-10T09:00:00Z' } }), 120)?.badges[1]?.text).toBe('50%')
  expect(bandView(snap({ ...NAMED, step: 'verify' }, { now, progress: fresh }), 120)?.badges[1]?.text).toBe('50%')
})

test('views follow the order: plan gates and runs, then activity, then stopped, comments, conflicts, done, ready', async () => {
  const running = { mode: 'pr:review', name: 'PR 9 Charge retries', state: 'running' as const }
  const waiting = { ...running, state: 'needs_you' as const }
  expect(bandView(snap(RUNNING, { activity: waiting }), 120)?.title).toBe('Learn from use')
  expect(bandView(snap(STOPPED, { activity: running }), 120)?.title).toBe('PR 9 Charge retries')
  expect(bandView(snap(READY, { activity: running, newComments: 2 }), 120)?.title).toBe('PR 9 Charge retries')
  expect(bandView(snap(null, { activity: { ...running, state: 'done' } }), 120)).toBe(null)
  expect(bandView(snap({ ...STOPPED, pr: 9 }, { newComments: 2 }), 120)?.badges[0]?.text).toBe('Stopped')
  expect(bandView(snap(DONE, { conflicts: 1 }), 120)?.badges[0]?.text).toBe('1 conflict with main')
})

test('unknown comments or conflicts show no badge and no action', async () => {
  expect(bandView(snap(NEEDS_YOU, { newComments: null, conflicts: null }), 120)?.actions.map(a => a.label)).toEqual(['Open plan'])
  expect(bandView(snap(WITH_PR, { newComments: null, conflicts: null }), 120)?.badges[0]?.text).toBe('Ready')
})

test('the name replaces the plan title; a file without one falls back to it', async () => {
  expect(bandView(snap(NAMED), 120)?.title).toBe('Webhook retries')
  expect(bandView(snap(RUNNING), 120)?.title).toBe('Learn from use')
})

test('buttons carry names, and commands only behind them', async () => {
  const labels = bandView(snap(READY), 120)?.actions.map(a => a.label).join(' ') ?? ''
  expect(labels.includes('/my:')).toBe(false)
})
