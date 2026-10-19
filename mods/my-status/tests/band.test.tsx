import type { On } from 'claude-code'
import { expect, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'

import type { MyStatusRun } from '../types'
import { NEEDS_YOU, READY, RUNNING, WITH_PR } from './fixtures'

const SURFACES = ['terminal', 'desktop'] as const
const STATE_FILE = '/home/u/.my-agent-kit/state/acme-shop-feature.json'

type World = { run?: MyStatusRun; conflicts?: string; comments?: string; log?: string; now?: string }

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
    if (cmd.startsWith('git fetch')) return out('')
    if (cmd.startsWith('git merge-tree')) return w.conflicts ? out(`abc123\n${w.conflicts}\n\nmessages`, 1) : out('abc123')
    if (cmd.startsWith('gh api')) return out(w.comments ?? '0')
    return out('', 1)
  })
  on('fs.read', ($, e) => {
    if (e.path === STATE_FILE && w.run) return { value: JSON.stringify(w.run) }
    if (e.path.endsWith('/suite-log.md') && w.log) return { value: w.log }
    return { deny: `no file ${e.path}` }
  })
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  on('clock.every', () => ({ value: undefined }))
  on('session.start', ($, e) => ({ cwd: e.cwd }))
}

async function refresh($: Engine): Promise<void> {
  await $.session.start({ cwd: '/work', surface: 'terminal', isInteractive: true })
  await $.command.run({ command: 'my-status', args: '', origin: { kind: 'composer' }, presentation: { isFullscreen: false, columns: 120 } })
}

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

test('a gate shows Needs you and its reason', async ($, on) => {
  world(on, { run: { ...NEEDS_YOU, plan: { title: 'Learn from use', path: '' } } })
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(120) })
  expect((await ui.find({ key: 'state' }))?.text).toMatch(/Needs you/)
  expect((await ui.find({ key: 'detail' }))?.text).toMatch(/item 4/)
  await ui.unmount()
})

test('new PR comments show before the plan steps, with Review comments', async ($, on) => {
  world(on, { run: { ...WITH_PR, commentsReadUntil: '2026-01-10T09:00:00Z' }, comments: '2', now: '2026-01-11T09:00:00Z' })
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

test('a narrow band keeps the state but drops Open plan and the detail', async ($, on) => {
  world(on, { run: { ...RUNNING, plan: { title: 'Learn from use', path: '' } } })
  await refresh($)
  const ui = await $.ui.mount({ plugin: 'my-status', surface: 'terminal', ...band(60) })
  expect((await ui.find({ key: 'percent' }))?.text).toMatch(/50%/)
  expect(await ui.find({ key: 'open' })).toBe(undefined)
  expect(await ui.find({ key: 'detail' })).toBe(undefined)
  await ui.unmount()
})

test('the mod only reads: git and gh calls are read-only or a fetch', async ($, on) => {
  const ran: string[] = []
  world(on, { run: WITH_PR, conflicts: 'shop/pricing.py', now: '2026-01-12T09:00:00Z' }, ran)
  await refresh($)
  const writes = ran.filter(cmd => /^git (commit|push|merge |rebase|reset|checkout|switch|add|stash|tag)|^gh (pr|issue) (create|edit|comment|merge)/.test(cmd))
  expect(writes).toEqual([])
  expect(ran.some(cmd => cmd.startsWith('git fetch'))).toBe(true)
})
