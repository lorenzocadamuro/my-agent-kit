import { expect, test } from 'claude-code/testing'

import { bandView, planPercent, statusLine, timeLeft } from '../hooks/view'
import { DONE, FIRST_ROUND, NEEDS_YOU, PLANNING, READY, RUNNING, WITH_PR, snap } from './fixtures'

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
  expect(bandView(snap(RUNNING, { newComments: 3 }), 120)?.badges[0]?.text).toBe('50%')
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

test('narrow widths drop the detail, then Open plan and the second action', async () => {
  const wide = bandView(snap(RUNNING), 120)
  const mid = bandView(snap(RUNNING), 80)
  const narrow = bandView(snap(READY), 60)
  expect(wide?.detail).toBe('Part 2 of 3 · round 3 · Execute 3/6')
  expect(mid?.detail).toBe(undefined)
  expect(mid?.actions.map(a => a.label)).toEqual(['Open plan'])
  expect(bandView(snap(RUNNING), 60)?.actions).toEqual([])
  expect(narrow?.actions.map(a => a.label)).toEqual(['Run plan'])
})

test('buttons carry names, and commands only behind them', async () => {
  const labels = bandView(snap(READY), 120)?.actions.map(a => a.label).join(' ') ?? ''
  expect(labels.includes('/my:')).toBe(false)
})
