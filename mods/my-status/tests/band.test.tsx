import type { On } from 'claude-code'
import { expect, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'

import type { MyStatusActivity, MyStatusProgress, MyStatusRun } from '../types'
import { NAMED, NEEDS_YOU, OLD_NEEDS_YOU, READY, RUNNING, WITH_PR } from './fixtures'

const SURFACES = ['terminal', 'desktop'] as const
const STATE_FILE = '/home/u/.my-agent-kit/state/acme-shop-feature.json'
const ME = 'me'

type Row = { login: string; at: string }
type World = {
  run?: MyStatusRun
  progress?: MyStatusProgress
  activity?: MyStatusActivity
  conflicts?: string
  mergeExit?: number | 'throw'
  fetchFails?: boolean
  comments?: Row[] | 'fail'
  issueComments?: Row[] | 'fail'
  login?: string | null
  log?: string
  now?: string
  otherName?: string
}

function rows(cmd: string, list: Row[]): string {
  const since = cmd.match(/since=(\S+)/)?.[1] ?? ''
  if (cmd.includes('| length')) return String(list.filter(row => row.at > since).length)
  return list.map(row => JSON.stringify(row)).join('\n')
}

function band(bodyColumns: number) {
  return {
    component: 'AbovePrompt' as const,
    props: { hasSurvey: false, isWorking: false, maxRows: 2, bodyColumns, scroll: { offset: 0, bodyRows: 2 }, view: {} },
  }
}

function world(on: On, w: World, ran: string[] = []): void {
  const out = (stdout: string, exitCode = 0) => ({ value: { exitCode, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false } })
  on('session.cwd', () => ({ value: '/work' }))
  on('clock.now', () => ({ value: Date.parse(w.now ?? '2026-01-10T09:25:00Z') }))
  on('ui.status', () => ({ value: undefined }))
  on('ui.open', () => ({ value: { isPlaced: true as const } }))
  on('process.run', ($, e) => {
    const cmd = e.argv.join(' ')
    ran.push(cmd)
    if (cmd === 'printenv HOME') return out('/home/u')
    if (cmd === 'git rev-parse --show-toplevel') return out('/work')
    if (cmd === 'git branch --show-current') return out('feature')
    if (cmd === 'git remote get-url origin') return out('git@github.com:acme/shop.git')
    if (cmd.startsWith('git fetch')) return w.fetchFails ? out('', 128) : out('')
    if (cmd.startsWith('git merge-tree')) {
      if (w.mergeExit === 'throw') return { deny: 'git is gone' }
      if (w.mergeExit !== undefined) return out(`abc123\n${w.conflicts ?? ''}`, w.mergeExit)
      return w.conflicts ? out(`abc123\n${w.conflicts}\n\nmessages`, 1) : out('abc123')
    }
    if (cmd.startsWith('gh api user')) return w.login === null ? out('', 1) : out(w.login ?? ME)
    if (cmd.startsWith('gh api')) {
      const list = cmd.includes('/issues/') ? w.issueComments : w.comments
      return list === 'fail' ? out('', 1) : out(rows(cmd, list ?? []))
    }
    return out('', 1)
  })
  on('fs.read', ($, e) => {
    if (e.path === STATE_FILE && w.run && !w.otherName) return { value: JSON.stringify(w.run) }
    if (e.path === STATE_FILE.replace('.json', '.progress.json') && w.progress) return { value: JSON.stringify(w.progress) }
    if (e.path === STATE_FILE.replace('.json', '.activity.json') && w.activity) return { value: JSON.stringify(w.activity) }
    if (w.otherName && e.path === `/home/u/.my-agent-kit/state/${w.otherName}` && w.run) return { value: JSON.stringify(w.run) }
    if (e.path.endsWith('/suite-log.md') && w.log) return { value: w.log }
    return { deny: `no file ${e.path}` }
  })
  on('fs.list', () => ({
    value: (w.otherName ? [w.otherName] : w.run ? ['acme-shop-feature.json'] : []).map(name => ({ name, kind: 'file' as const, size: 1, mtimeMs: 0, isLink: false })),
  }))
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  on('clock.every', () => ({ value: undefined }))
  on('session.start', ($, e) => ({ cwd: e.cwd }))
}

async function poll($: Engine): Promise<void> {
  await $.command.run({ command: 'my-status', args: '', origin: { kind: 'composer' }, presentation: { isFullscreen: false, columns: 120 } })
}

async function refresh($: Engine): Promise<void> {
  await $.session.start({ cwd: '/work', surface: 'terminal', isInteractive: true })
  await poll($)
}

async function shown($: Engine, columns = 120): Promise<{ state?: string; comments?: string; conflicts?: string; title?: string; detail?: string; open: boolean; band: boolean }> {
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(columns) })
  const text = async (key: string) => (await ui.find({ key }))?.text
  const view = {
    state: await text('state'),
    comments: await text('comments'),
    conflicts: await text('conflicts'),
    title: await text('title'),
    detail: await text('detail'),
    open: (await ui.find({ key: 'open' })) !== undefined,
    band: (await ui.find({ key: 'band' })) !== undefined,
  }
  await ui.unmount()
  return view
}

const SINCE = '2026-01-10T09:00:00Z'
const OTHER: Row = { login: 'bob', at: '2026-01-10T10:00:00Z' }
const OWN: Row = { login: ME, at: '2026-01-10T10:05:00Z' }

test('a running plan shows its percentage on every surface', async ($, on) => {
  world(on, { run: { ...RUNNING, plan: { title: 'Learn from use', path: '' } } })
  await refresh($)
  for (const surface of SURFACES) {
    const ui = await $.ui.mount({ plugin: 'my-status', surface, ...band(120) })
    expect((await ui.find({ key: 'percent' }))?.text).toMatch(/50%/)
    expect(await ui.find({ key: 'open' })).toBeDefined()
    await ui.unmount()
  }
})

test('a state file written under an older name is found by its worktree', async ($, on) => {
  world(on, { run: { ...RUNNING, worktree: '/work', plan: { title: 'Learn from use', path: '' } }, otherName: 'local-shop-feature.json' })
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(120) })
  expect((await ui.find({ key: 'percent' }))?.text).toMatch(/50%/)
  await ui.unmount()
})

test('a gate shows Needs you and its reason', async ($, on) => {
  world(on, { run: { ...NEEDS_YOU, plan: { title: 'Learn from use', path: '' } } })
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(120) })
  expect((await ui.find({ key: 'state' }))?.text).toMatch(/Needs you/)
  expect((await ui.find({ key: 'detail' }))?.text).toMatch(/item 4/)
  await ui.unmount()
})

test('new PR comments show before the plan steps, with Review comments', async ($, on) => {
  world(on, { run: { ...WITH_PR, commentsReadUntil: SINCE }, comments: [OTHER, { ...OTHER, at: '2026-01-10T11:00:00Z' }], now: '2026-01-11T09:00:00Z' })
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(120) })
  expect((await ui.find({ key: 'comments' }))?.text).toMatch(/new comment/)
  expect(await ui.find({ key: 'comments' })).toBeDefined()
  await ui.unmount()
})

test('Run plan fills the prompt with the command and submits nothing', async ($, on) => {
  const filled: string[] = []
  const submitted: string[] = []
  world(on, { run: READY })
  on('prompt.fill', ($, e) => {
    filled.push(e.text)
    return { isFilled: true }
  })
  on('prompt.submit', ($, e, next) => {
    submitted.push(String(e.text))
    return next(e)
  })
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(120) })
  await ui.press({ key: 'run' })
  expect(filled).toEqual(['/my:plan:run'])
  expect(submitted).toEqual([])
  await ui.unmount()
})

test('with no state file the band stays empty', async ($, on) => {
  world(on, {})
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(120) })
  expect(await ui.find({ key: 'band' })).toBe(undefined)
  await ui.unmount()
})

test('a narrow band keeps the state and its only button, and cuts the title with …', async ($, on) => {
  world(on, { run: { ...RUNNING, plan: { title: 'Learn from use', path: '' } } })
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(60) })
  expect((await ui.find({ key: 'state' }))?.text).toMatch(/Running/)
  expect((await ui.find({ key: 'percent' }))?.text).toMatch(/50%/)
  expect(await ui.find({ key: 'open' })).toBeDefined()
  expect((await ui.find({ key: 'title' }))?.text).toBe('Learn…')
  expect(await ui.find({ key: 'detail' })).toBe(undefined)
  await ui.unmount()
})

test('a 3.2.x state file with a long reason shows, cut with …, and keeps its button', async ($, on) => {
  world(on, { run: OLD_NEEDS_YOU })
  await refresh($)
  for (const surface of SURFACES) {
    const ui = await $.ui.mount({ plugin: 'my-status', surface, ...band(80) })
    expect((await ui.find({ key: 'state' }))?.text).toMatch(/Needs you/)
    expect((await ui.find({ key: 'title' }))?.text).toBe('Make checkout charg…')
    expect((await ui.find({ key: 'detail' }))?.text).toBe('Verification failed…')
    expect(await ui.find({ key: 'open' })).toBeDefined()
    await ui.unmount()
  }
})

test('a running state untouched for 7 hours draws no band', async ($, on) => {
  world(on, { run: NAMED, now: '2026-01-10T16:30:00Z' })
  await refresh($)
  expect((await shown($)).band).toBe(false)
})

test('the executor progress sidecar moves the percent during the round', async ($, on) => {
  world(on, { run: NAMED, progress: { round: 3, items: { done: 6, total: 6 }, updatedAt: '2026-01-10T09:24:00Z' } })
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(120) })
  expect((await ui.find({ key: 'percent' }))?.text).toMatch(/67%/)
  await ui.unmount()
})

test('pr and improve activity shows Running or Needs you with its name; a done one draws nothing', async ($, on) => {
  const w: World = {}
  world(on, w)
  for (const [state, label] of [['running', 'Running'], ['needs_you', 'Needs you'], ['done', undefined]] as const) {
    w.activity = { mode: 'pr:review', name: 'PR 9 Charge retries', state, updatedAt: '2026-01-10T09:20:00Z' }
    await refresh($)
    const view = await shown($)
    expect(view.state).toBe(label === undefined ? undefined : ` ${label} `)
    expect(view.title).toBe(label === undefined ? undefined : 'PR 9 Charge retries')
  }
})

test('the user\'s own comments are not counted', async ($, on) => {
  world(on, { run: { ...WITH_PR, commentsReadUntil: SINCE }, comments: [OWN, OTHER] })
  await refresh($)
  expect((await shown($)).comments).toMatch(/^ 1 new comment $/)
})

test('without commentsReadUntil, comments count from the first round start', async ($, on) => {
  world(on, { run: { ...WITH_PR, rounds: [{ n: 1, startedAt: '2026-01-10T10:02:00Z' }] }, comments: [OTHER, { ...OTHER, at: '2026-01-10T10:03:00Z' }] })
  await refresh($)
  expect((await shown($)).comments).toMatch(/^ 1 new comment $/)
})

test('a failed login lookup or comment call shows no count, not zero', async ($, on) => {
  const w: World = { run: { ...NEEDS_YOU, pr: 456, commentsReadUntil: SINCE }, issueComments: [OTHER] }
  world(on, w)
  w.login = null
  await refresh($)
  expect((await shown($)).comments).toBe(undefined)
  w.login = ME
  w.comments = 'fail'
  await refresh($)
  const view = await shown($)
  expect(view.comments).toBe(undefined)
  expect(view.state).toBe(' Needs you ')
})

test('merge-tree: exit 0 is no conflict, exit 1 counts files, an error or a throw is unknown', async ($, on) => {
  const w: World = { run: WITH_PR }
  world(on, w)
  await refresh($)
  expect((await shown($)).conflicts).toBe(undefined)
  w.conflicts = 'shop/pricing.py\nshop/cart.py'
  w.fetchFails = true
  await refresh($)
  expect((await shown($)).conflicts).toMatch(/2 conflicts with main/)
  w.fetchFails = false
  w.mergeExit = 128
  await refresh($)
  expect((await shown($)).conflicts).toBe(undefined)
  w.mergeExit = 'throw'
  await refresh($)
  expect((await shown($)).conflicts).toBe(undefined)
})

test('network data belongs to its PR', async ($, on) => {
  const w: World = { run: WITH_PR, conflicts: 'shop/pricing.py' }
  world(on, w)
  await refresh($)
  expect((await shown($)).conflicts).toMatch(/1 conflict with main/)
  w.run = { ...WITH_PR, pr: 789 }
  w.conflicts = undefined
  await poll($)
  const view = await shown($)
  expect(view.conflicts).toBe(undefined)
  expect(view.state).toBe(' Ready ')
})

test('the mod only reads: git and gh calls are read-only or a fetch', async ($, on) => {
  const ran: string[] = []
  world(on, { run: WITH_PR, conflicts: 'shop/pricing.py', now: '2026-01-12T09:00:00Z' }, ran)
  await refresh($)
  const writes = ran.filter(cmd => /^git (commit|push|merge |rebase|reset|checkout|switch|add|stash|tag)|^gh (pr|issue) (create|edit|comment|merge)/.test(cmd))
  expect(writes).toEqual([])
  expect(ran.some(cmd => cmd.startsWith('git fetch'))).toBe(true)
})
