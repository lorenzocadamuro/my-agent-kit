import type { On } from 'claude-code'
import { expect, mock, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'

import type { MyStatusActivity, MyStatusProgress, MyStatusRun } from '../types'
import {
  LONG_TITLE,
  NAMED,
  NEEDS_YOU,
  OLD_NEEDS_YOU,
  PLAN_FILE,
  PLANNING,
  READY,
  RUNNING,
  V2_DONE,
  V2_NEEDS_YOU,
  V2_PLANNING,
  V2_READY,
  V2_RUNNING,
  V2_RUNNING_SIX,
  V2_STOPPED,
  WITH_PR,
} from './fixtures'

// The band above the prompt, from state files read through the mod's own lookup, on the terminal and the desktop: the
// pictures it draws (desktop only, by the key of the Box around each), its Buttons by key, and what it says in words.

const SURFACES = ['terminal', 'desktop'] as const
type Surface = (typeof SURFACES)[number]
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
  /** This chat's session id; null when the engine cannot tell it. */
  sessionId?: string | null
  /** Other files in the state folder, by name. */
  files?: Record<string, object>
  /** Whether the plan file exists. */
  planExists?: boolean
  /** The plan file's text. */
  planText?: string
  /** The panes opened, by id. */
  opened?: string[]
  /** Every status line the mod set, in order. */
  status?: (string | undefined)[]
  /** The test moves the clock itself (mock.clock) instead of the world's fixed one. */
  isClockMocked?: boolean
}

function rows(cmd: string, list: Row[]): string {
  const since = cmd.match(/since=(\S+)/)?.[1] ?? ''
  if (cmd.includes('| length')) return String(list.filter(row => row.at > since).length)
  return list.map(row => JSON.stringify(row)).join('\n')
}

function band(surface: Surface, maxRows = 400, bodyColumns = 110) {
  return {
    plugin: 'my-status',
    surface,
    component: 'AbovePrompt' as const,
    requestId: 'band',
    props: { hasSurvey: false, isWorking: false, maxRows, bodyColumns, scroll: { offset: 0, bodyRows: maxRows - 1 }, view: {} },
  }
}

function world(on: On, w: World, ran: string[] = []): void {
  const out = (stdout: string, exitCode = 0) => ({ value: { exitCode, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false } })
  on('session.cwd', () => ({ value: '/work' }))
  on('session.id', () => (w.sessionId === null ? { deny: 'no session id' } : { value: w.sessionId ?? 'chat-a' }))
  if (!w.isClockMocked) on('clock.now', () => ({ value: Date.parse(w.now ?? '2026-01-10T09:25:00Z') }))
  on('ui.status', ($, e) => {
    w.status?.push(e.text)
    return { value: undefined }
  })
  on('ui.open', ($, e) => {
    w.opened?.push(e.id)
    return { value: { isPlaced: true as const } }
  })
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
    const extra = w.files?.[e.path.replace('/home/u/.my-agent-kit/state/', '')]
    if (extra) return { value: JSON.stringify(extra) }
    if (e.path.endsWith('/suite-log.md') && w.log) return { value: w.log }
    if (e.path === PLAN_FILE && w.planText) return { value: w.planText }
    return { deny: `no file ${e.path}` }
  })
  on('fs.exists', ($, e) => ({ value: e.path === PLAN_FILE && w.planExists === true }))
  on('fs.list', () => ({
    value: [...(w.otherName ? [w.otherName] : w.run ? ['acme-shop-feature.json'] : []), ...Object.keys(w.files ?? {})].map(name => ({ name, kind: 'file' as const, size: 1, mtimeMs: 0, isLink: false })),
  }))
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  if (!w.isClockMocked) {
    on('clock.every', () => ({ value: undefined }))
    on('clock.after', () => ({ value: undefined }))
  }
  on('session.start', ($, e) => ({ cwd: e.cwd }))
}

async function poll($: Engine): Promise<void> {
  await $.command.run({ command: 'my-status', args: '', origin: { kind: 'composer' }, presentation: { isFullscreen: false, columns: 120 } })
}

async function refresh($: Engine): Promise<void> {
  await $.session.start({ cwd: '/work', surface: 'terminal', isInteractive: true })
  await poll($)
}

type El = { type: string; props?: Record<string, unknown>; hover?: Record<string, unknown>; children?: unknown[] }
const isEl = (x: unknown): x is El => typeof x === 'object' && x !== null && 'type' in x
const kids = (el: El) => (el.children ?? []).filter(isEl)
const all = (el: El): El[] => [el, ...kids(el).flatMap(all)]
type Drawing = { drawn: () => Promise<unknown> }

// the desktop's band pictures, by the key of the Box around each (an Svg keeps no key), with their heights
const PIC_KEYS = ['header', 'track', 'steps', 'agents-head', 'agents']
async function pictures(ui: Drawing) {
  const tree = (await ui.drawn()) as El
  return Object.fromEntries(
    kids(tree)
      .filter(b => PIC_KEYS.includes(String(b.props?.key)))
      .map(b => [String(b.props?.key), Number(kids(b).find(k => k.type === 'Svg')?.props?.height)]),
  ) as Record<string, number>
}
// what the drawing says in words: the Texts', the Buttons' labels and the pictures' (an Svg's alt)
async function words(ui: Drawing) {
  return all((await ui.drawn()) as El)
    .flatMap(el =>
      el.type === 'Svg' ? [String(el.props?.alt ?? '')] : el.type === 'Text' ? (el.children ?? []).filter(c => typeof c === 'string') : el.type === 'Button' ? [String(el.props?.label ?? '')] : [],
    )
    .join(' | ')
}
// everything drawn as text, the pictures' markup included
async function everything(ui: Drawing) {
  return `${await words(ui)} | ${all((await ui.drawn()) as El)
    .filter(el => el.type === 'Svg')
    .map(el => String(el.props?.source ?? ''))
    .join(' | ')}`
}
// a picture's markup, by the key of the Box around it
async function source(ui: Drawing, key: string) {
  const box = kids((await ui.drawn()) as El).find(b => b.props?.key === key)
  return String(box && kids(box).find(k => k.type === 'Svg')?.props?.source)
}
const labelRow = (svg: string) => svg.match(/<g class="labels">.*?<\/g>/)?.[0] ?? ''
// every Button the desktop draws is blank: its label only figure spaces (U+2007), never a plain space, which the
// desktop collapses, pressing a Button on its label alone
async function expectBlankLabels(ui: Drawing) {
  const buttons = all((await ui.drawn()) as El).filter(el => el.type === 'Button')
  expect(buttons.length).toBeGreaterThan(0)
  for (const b of buttons) expect(String(b.props?.label)).toMatch(/^\u2007+$/)
}

type Seen = { band: boolean; words: string; buttons: (string | undefined)[] }
/** The band as each surface draws it. */
async function seen($: Engine, surface: Surface = 'terminal', maxRows = 400, bodyColumns = 110): Promise<Seen> {
  const ui = await $.ui.mount(band(surface, maxRows, bodyColumns))
  const view = {
    band: (await ui.find({ key: 'band' })) !== undefined,
    words: await words(ui),
    buttons: (await ui.findAll({ type: 'Button' })).map(b => b.key),
  }
  await ui.unmount()
  return view
}

const SINCE = '2026-01-10T09:00:00Z'
const OTHER: Row = { login: 'bob', at: '2026-01-10T10:00:00Z' }
const OWN: Row = { login: ME, at: '2026-01-10T10:05:00Z' }

// ---------- the prototype's states, from real state files ----------

type Case = { name: string; w: World; svgs: string[]; buttons: string[]; text?: RegExp }
const CASES: Case[] = [
  { name: 'planning, no plan file yet', w: { run: V2_PLANNING }, svgs: ['header', 'track'], buttons: [], text: /Planning: Interview, step 2 of 5; 4m elapsed/ },
  { name: 'planning, plan file written', w: { run: { ...V2_PLANNING, step: 'write' }, planExists: true }, svgs: ['header', 'track'], buttons: ['open-plan'], text: /Planning: Write, step 3 of 5/ },
  {
    name: 'ready with new comments',
    w: { run: { ...V2_READY, pr: 456, commentsReadUntil: SINCE }, comments: [OTHER, OTHER, { ...OTHER, at: '2026-01-10T11:00:00Z' }] },
    svgs: ['header', 'track'],
    buttons: ['toggle', 'comments', 'one-round', 'run-plan', 'open-plan'],
    text: /Ready: Round 3 done, next: Part C, Dark mode; 42% 8 of 19 steps, .*left \(estimate\), 1h 12m elapsed.*Review comments \(3\)/,
  },
  { name: 'running', w: { run: V2_RUNNING }, svgs: ['header', 'track'], buttons: ['toggle', 'open-plan'], text: /Running: Part D, Remove form, step 2 of 3; 82% 9 of 11 steps, \d+–\d+ min left \(estimate\), 1h 12m elapsed/ },
  {
    name: 'running six with conflicts',
    w: { run: { ...V2_RUNNING_SIX, pr: 456 }, conflicts: 'shop/pricing.py' },
    svgs: ['header', 'track'],
    buttons: ['toggle', 'merge-main', 'open-plan'],
    text: /Part C, Loading skeletons, step 5 of 6; .*estimating… time left.*Conflicts with main/,
  },
  { name: 'needs you', w: { run: V2_NEEDS_YOU }, svgs: ['header', 'track'], buttons: ['toggle', 'open-plan'], text: /Needs you: PR description, Part D, step 3 of 3.*Answer in the chat below/ },
  { name: 'stopped', w: { run: V2_STOPPED }, svgs: ['header', 'track'], buttons: ['toggle', 'one-round', 'open-plan'], text: /Stopped: Tests failing, Part D, step 2 of 3; .*on hold time left/ },
  { name: 'done', w: { run: V2_DONE }, svgs: ['header', 'track'], buttons: ['toggle', 'open-plan'], text: /Done: Bar met, all steps verified; 100% 11 of 11 steps, 1h 31m total time/ },
]

for (const c of CASES) {
  test(`${c.name}: the band draws its pictures, buttons and words on both surfaces`, async ($, on) => {
    world(on, c.w)
    await refresh($)
    for (const surface of SURFACES) {
      const ui = await $.ui.mount(band(surface))
      const svgs = surface === 'desktop' ? Object.keys(await pictures(ui)) : (await ui.findAll({ type: 'Svg' })).map(x => String(x.key))
      expect(svgs).toEqual(surface === 'desktop' ? c.svgs : [])
      expect((await ui.findAll({ type: 'Button' })).map(x => x.key)).toEqual(c.buttons)
      if (c.text && surface === 'desktop') expect(await words(ui)).toMatch(c.text)
      await ui.unmount()
    }
  })
}

test('the terminal says the same in characters: the state, line 2, the figures and the part labels', async ($, on) => {
  world(on, { run: V2_RUNNING })
  await refresh($)
  const view = await seen($, 'terminal')
  expect(view.words).toMatch(/● Running/)
  expect(view.words).toMatch(/82% 9 of 11 steps {2}· {2}\d+–\d+ min left \(estimate\) {2}· {2}1h 12m elapsed/)
  expect(view.words).toMatch(/Part D.* {2}· {2}Remove form {2}· {2}step 2 of 3/)
  expect(view.words).toMatch(/A Cart totals.*D Old form/)
})

test('the capsule strip opens the steps under it and closes them', async ($, on) => {
  world(on, { run: V2_RUNNING })
  await refresh($)
  for (const surface of SURFACES) {
    const ui = await $.ui.mount(band(surface))
    if (surface === 'desktop') expect(Object.keys(await pictures(ui))).toEqual(['header', 'track'])
    await ui.press({ key: 'toggle' })
    if (surface === 'desktop') expect(Object.keys(await pictures(ui))).toEqual(['header', 'track', 'steps'])
    else expect(await ui.find({ type: 'Box', key: 'steps-0' })).toBeDefined()
    await ui.press({ key: 'toggle' })
    if (surface === 'desktop') expect(Object.keys(await pictures(ui))).toEqual(['header', 'track'])
    else expect(await ui.find({ type: 'Box', key: 'steps-0' })).toBeUndefined()
    await ui.unmount()
  }
})

test('expanded, nothing lies over anything but its own lit picture and blank Button, and the controls come in band order', async ($, on) => {
  world(on, { run: { ...V2_RUNNING_SIX, pr: 456 }, conflicts: 'shop/pricing.py' })
  await refresh($)
  const ui = await $.ui.mount(band('desktop'))
  await expectBlankLabels(ui)
  await ui.press({ key: 'toggle' })
  await expectBlankLabels(ui)
  const tree = (await ui.drawn()) as El
  // the band is a column of keyed pieces, the action row last
  expect(kids(tree).map(k => k.props?.key)).toEqual(['header', 'track', 'steps', 'actions'])
  const placed: string[] = []
  const lit: string[] = []
  const walk = (el: El, parent: El | null) => {
    if (el.props?.position === 'absolute') {
      // over a picture, and only over its own: the Box it sits in starts with that picture
      expect(parent && kids(parent)[0]?.type).toBe('Svg')
      const [only, ...rest] = kids(el)
      expect(rest).toHaveLength(0)
      if (only?.type === 'Button') {
        // the press: a plain Button, blank, its own hover plate cleared
        expect(only.props?.plain).toBe(true)
        expect(String(only.props?.label)).toMatch(/^\u2007+$/)
        expect(only.hover?.backgroundColor).toBe('#0000')
        placed.push(String(only.props?.key))
      } else {
        // what lights up: hidden until the keyed Box around it is hovered, one picture
        expect(only?.props?.display).toBe('none')
        expect(only?.hover?.display).toBe('flex')
        expect(kids(only!).map(k => k.type)).toEqual(['Svg'])
        lit.push(String(parent?.props?.key))
      }
      return
    }
    // every Button on the desktop is a blank one over its picture
    expect(el.type).not.toBe('Button')
    for (const k of kids(el)) walk(k, el)
  }
  walk(tree, null)
  expect(placed).toEqual(['toggle', 'merge-main', 'open-plan'])
  expect(lit).toEqual(['track', 'pill-merge-main', 'pill-open-plan'])
  expect((await ui.findAll({ type: 'Button' })).map(b => b.key)).toEqual(['toggle', 'merge-main', 'open-plan'])
  await ui.unmount()
})

test('opening the steps keeps the label row, grows the capsules, and lists every step of a done part', async ($, on) => {
  world(on, { run: V2_RUNNING_SIX })
  await refresh($)
  const ui = await $.ui.mount(band('desktop'))
  const closed = await source(ui, 'track')
  await ui.press({ key: 'toggle' })
  const open = await source(ui, 'track')
  // the same label row, letter and short title, in the same place; the track as tall in both states
  expect(labelRow(closed)).toContain('Query layer')
  expect(labelRow(open)).toBe(labelRow(closed))
  expect((await pictures(ui)).track).toBe(48)
  // closed: thin capsules with no numbers; open: 16 px capsules with them
  expect(closed).toContain('height="8"')
  expect(closed).not.toMatch(/class="f-num(Empty)?"/)
  expect(open).toContain('height="16"')
  expect(open).toMatch(/class="f-num"/)
  // parts A and B are done: every step listed, at L0 and at L2 alike, never a summary
  const done = ['Add toggle', 'Persist choice', 'Filter param', 'Index', 'Backfill', 'Wire query']
  for (const label of done) expect(await source(ui, 'steps')).toContain(label)
  await ui.unmount()
  // 6 rows of 24 px leave no room for the open columns: L2, the parts not started as one "to do" chip each
  const tight = await $.ui.mount(band('desktop', 6))
  const steps = await source(tight, 'steps')
  for (const label of done) expect(steps).toContain(label)
  expect(steps).not.toContain('done</text>')
  expect(steps).toContain('to do')
  await tight.unmount()
})

test('the pulse is in Running alone, on the state dot and the step under way, with a still copy', async ($, on) => {
  const w: World = { now: '2026-01-10T09:25:01.300Z' }
  world(on, w)
  for (const run of [V2_RUNNING, V2_PLANNING, V2_READY, V2_NEEDS_YOU, V2_STOPPED, V2_DONE]) {
    w.run = run
    await refresh($)
    const ui = await $.ui.mount(band('desktop'))
    for (const key of ['header', 'track']) {
      const svg = await source(ui, key)
      const pulses = (svg.match(/<animate attributeName="opacity"/g) ?? []).length
      expect(pulses).toBe(run.state === 'running' ? 1 : 0)
      if (pulses > 0) {
        // each moving copy has a still twin, shown only under reduced motion; the cycle starts where the clock has it
        expect((svg.match(/<g class="sv">/g) ?? []).length).toBe(pulses)
        expect(svg).toContain('@media (prefers-reduced-motion: reduce){.mv{display:none}.sv{display:inline}}')
        expect(svg).toContain('begin="-1.300s"')
      }
    }
    await ui.unmount()
  }
})

test('Open plan opens the plan pane with the plan file', async ($, on) => {
  const opened: string[] = []
  world(on, { run: V2_RUNNING, planText: '# The plan', opened })
  await refresh($)
  opened.length = 0
  for (const surface of SURFACES) {
    const ui = await $.ui.mount(band(surface))
    await ui.press({ key: 'open-plan' })
    await ui.unmount()
  }
  expect(opened).toEqual(['my-status-plan', 'my-status-plan'])
  const scroll = { offset: 0, bodyRows: 20 }
  const pane = await $.ui.mount({ plugin: 'my-status', surface: 'desktop', component: 'Pane', requestId: 'my-status-plan', props: { title: 'Plan', isFocused: false, bodyColumns: 80, placement: 'dock', scroll, view: {} } })
  expect((await pane.find({ key: 'plan-text' }))?.text).toBe('# The plan')
  await pane.unmount()
})

// ---------- what the band never shows, the 5.6.0 file, the order of states ----------

const WORK_TEXTS = ['Learn from use', 'Webhook retries', 'PR 9', 'Charge retries', 'Discounts on carts', 'Make checkout', 'cart totals add up']

test('no work name, plan title or PR title anywhere in the band or the status line: named plans, an activity, a plan without parts', async ($, on) => {
  const w: World = { status: [] }
  world(on, w)
  const noParts: MyStatusRun = {
    ...V2_RUNNING,
    name: 'Webhook retries',
    parts: [{ title: 'Learn from use', short: 'Learn from use', status: 'running', done: 1, total: 2, steps: [{ label: 'Totals', status: 'done' }, { label: 'Rounding', status: 'running' }] }],
  }
  const worlds: World[] = [
    { run: { ...V2_RUNNING, name: 'Webhook retries' } },
    { run: { ...V2_NEEDS_YOU, plan: { title: LONG_TITLE, path: PLAN_FILE } } },
    { run: noParts },
    { run: OLD_NEEDS_YOU },
    { activity: { mode: 'pr:review', name: 'PR 9 Charge retries', state: 'running', updatedAt: '2026-01-10T09:20:00Z' } },
    { run: { ...PLANNING, plan: { title: 'Discounts on carts', path: PLAN_FILE } }, planExists: true },
  ]
  for (const next of worlds) {
    Object.assign(w, { run: undefined, activity: undefined, planExists: undefined }, next)
    await refresh($)
    for (const surface of SURFACES) {
      for (const open of [false, true]) {
        const ui = await $.ui.mount(band(surface))
        if (open && (await ui.find({ key: 'toggle' }))) await ui.press({ key: 'toggle' })
        const shown = await everything(ui)
        expect(shown.length > 10).toBe(true)
        for (const work of WORK_TEXTS) expect(shown.includes(work), `${work} on ${surface}`).toBe(false)
        await ui.unmount()
      }
    }
    const line = w.status?.at(-1) ?? ''
    expect(line).toMatch(/^my: /)
    for (const work of WORK_TEXTS) expect(line.includes(work), `${work} in the status line`).toBe(false)
  }
})

const OLD_PARTS: MyStatusRun['parts'] = [
  { title: 'Part A: the cart totals add up across currencies', status: 'done', done: 3, total: 3 },
  { title: 'Part B: checkout retries', status: 'running', done: 1, total: 3, left: ['Retry timer', 'Final report'] },
  { title: 'Part C', status: 'todo', done: 0, total: 2 },
]

test('a state file written by kit 5.6.0 draws: numbered segments, labels from left, short titles from the heading, time estimating', async ($, on) => {
  world(on, { run: { ...READY, state: 'running', round: 1, parts: OLD_PARTS, rounds: [{ n: 1, startedAt: '2026-01-10T09:00:00Z' }] } })
  await refresh($)
  for (const surface of SURFACES) {
    const ui = await $.ui.mount(band(surface))
    // the steps open once, for both surfaces: the choice is the session's
    if (surface === 'terminal') await ui.press({ key: 'toggle' })
    const shown = await everything(ui)
    expect(shown).toMatch(/Running/)
    expect(shown).toMatch(/50% 4 of 8 steps/)
    expect(shown).toMatch(/estimating…/)
    expect(shown).toMatch(/25m elapsed/)
    expect(shown).toContain('Retry timer')
    expect(shown).toContain('Final report')
    // the heading's text after "Part X:" ("Part C" has none)
    if (surface === 'desktop') expect(labelRow(await source(ui, 'track'))).toContain('checkout retries')
    else expect(shown).toMatch(/B checkout retries/)
    await ui.unmount()
  }
  // a heading too long for its column leaves the letter alone, on the terminal too
  expect((await seen($, 'terminal')).words).not.toMatch(/cart totals add up/)
  const narrow = await $.ui.mount(band('desktop', 400, 40))
  expect(labelRow(await source(narrow, 'track'))).not.toContain('cart totals add up')
  await narrow.unmount()
})

test('one state leads, in today\'s order; comments and conflicts are signals beside it', async ($, on) => {
  const w: World = {}
  world(on, w)
  const running: MyStatusActivity = { mode: 'pr:review', state: 'running', updatedAt: '2026-01-10T09:20:00Z' }
  const waiting: MyStatusActivity = { ...running, state: 'needs_you' }
  const cases: [World, RegExp, string[]][] = [
    [{ run: V2_RUNNING, activity: waiting }, /^Running: Part D/, ['toggle', 'open-plan']],
    [{ run: V2_STOPPED, activity: running }, /^Running: pr:review/, []],
    [{ run: { ...V2_READY, pr: 451, commentsReadUntil: SINCE }, activity: running, comments: [OTHER] }, /^Running: pr:review/, []],
    [{ run: { ...V2_STOPPED, pr: 452, commentsReadUntil: SINCE }, comments: [OTHER] }, /^Stopped: Tests failing/, ['toggle', 'comments', 'one-round', 'open-plan']],
    [{ run: { ...V2_DONE, pr: 453 }, conflicts: 'shop/pricing.py' }, /^Done: Bar met/, ['toggle', 'merge-main', 'open-plan']],
    [{ activity: { ...running, state: 'done' } }, /^$/, []],
  ]
  for (const [next, head, buttons] of cases) {
    Object.assign(w, { run: undefined, activity: undefined, comments: undefined, conflicts: undefined }, next)
    await refresh($)
    const view = await seen($, 'desktop')
    expect(view.words).toMatch(head)
    expect(view.buttons).toEqual(buttons)
  }
})

test('elapsed counts from startedAt, else the first round\'s start, at the clock of the draw; Done\'s total time stays', async ($, on) => {
  const w: World = { run: V2_RUNNING }
  world(on, w)
  await refresh($)
  expect((await seen($, 'desktop')).words).toMatch(/1h 12m elapsed/)
  w.now = '2026-01-10T09:40:00Z'
  expect((await seen($, 'desktop')).words).toMatch(/1h 27m elapsed/)
  w.now = undefined
  w.run = { ...V2_RUNNING, startedAt: undefined }
  await refresh($)
  expect((await seen($, 'desktop')).words).toMatch(/1h 05m elapsed/)
  w.run = V2_DONE
  await refresh($)
  expect((await seen($, 'desktop')).words).toMatch(/1h 31m total time/)
  w.now = '2026-01-10T11:00:00Z'
  expect((await seen($, 'desktop')).words).toMatch(/1h 31m total time/)
})

test('a needs-you header with no step under way shows the next step', async ($, on) => {
  const parts = V2_READY.parts
  world(on, { run: { ...V2_READY, state: 'needs_you', reason: 'Plan approval', parts } })
  await refresh($)
  expect((await seen($, 'desktop')).words).toMatch(/Needs you: Plan approval, next: Part C, Dark mode;/)
})

// ---------- today's lookup, network and buttons, against the new band ----------

test('a state file written under an older name is found by its worktree', async ($, on) => {
  world(on, { run: { ...V2_RUNNING, worktree: '/work' }, otherName: 'local-shop-feature.json' })
  await refresh($)
  expect((await seen($, 'desktop')).words).toMatch(/Running: .*82% 9 of 11 steps/)
})

test('a gate shows Needs you and its reason', async ($, on) => {
  world(on, { run: { ...NEEDS_YOU, plan: { title: 'Learn from use', path: '' } } })
  await refresh($)
  for (const surface of SURFACES) expect((await seen($, surface)).words).toMatch(/Needs you.*Verification failed: item 4 has no commit/)
})

test('Run plan fills the prompt with the command and submits nothing', async ($, on) => {
  const filled: string[] = []
  const submitted: string[] = []
  world(on, { run: V2_READY })
  on('prompt.fill', ($, e) => {
    filled.push(e.text)
    return { isFilled: true }
  })
  on('prompt.submit', ($, e, next) => {
    submitted.push(String(e.text))
    return next(e)
  })
  await refresh($)
  for (const surface of SURFACES) {
    const ui = await $.ui.mount(band(surface))
    await ui.press({ key: 'run-plan' })
    await ui.unmount()
  }
  expect(filled).toEqual(['/my:plan:run', '/my:plan:run'])
  expect(submitted).toEqual([])
})

test('with no state file the band stays empty', async ($, on) => {
  world(on, {})
  await refresh($)
  for (const surface of SURFACES) expect((await seen($, surface)).band).toBe(false)
})

test('a running state untouched for 7 hours draws no band', async ($, on) => {
  world(on, { run: NAMED, now: '2026-01-10T16:30:00Z' })
  await refresh($)
  expect((await seen($)).band).toBe(false)
})

test('a fresh progress sidecar keeps a running state untouched for 7 hours', async ($, on) => {
  world(on, { run: NAMED, now: '2026-01-10T16:30:00Z', progress: { round: 3, items: { done: 4, total: 6 }, updatedAt: '2026-01-10T15:00:00Z' } })
  await refresh($)
  expect((await seen($, 'desktop')).words).toMatch(/^Running/)
})

test('pr and improve activity shows Running or Needs you with its mode, not its name; a done one draws nothing', async ($, on) => {
  const w: World = {}
  world(on, w)
  for (const [state, label] of [['running', 'Running'], ['needs_you', 'Needs you'], ['done', undefined]] as const) {
    w.activity = { mode: 'pr:review', name: 'PR 9 Charge retries', state, updatedAt: '2026-01-10T09:20:00Z' }
    await refresh($)
    for (const surface of SURFACES) {
      const view = await seen($, surface)
      expect(view.band).toBe(label !== undefined)
      if (label) expect(view.words).toMatch(new RegExp(`${label}.*pr:review`))
      expect(view.words.includes('Charge retries')).toBe(false)
    }
  }
})

test('an activity\'s elapsed time counts from when the mod first saw it', async ($, on) => {
  const w: World = { activity: { mode: 'improve:run', state: 'running', updatedAt: '2026-01-10T09:20:00Z' } }
  world(on, w)
  await refresh($)
  expect((await seen($, 'desktop')).words).toMatch(/<1m elapsed/)
  w.now = '2026-01-10T09:30:00Z'
  await poll($)
  expect((await seen($, 'desktop')).words).toMatch(/5m elapsed/)
})

test('the user\'s own comments are not counted', async ($, on) => {
  world(on, { run: { ...WITH_PR, commentsReadUntil: SINCE }, comments: [OWN, OTHER] })
  await refresh($)
  expect((await seen($)).words).toMatch(/Review comments \(1\)/)
})

test('without commentsReadUntil, comments count from the first round start', async ($, on) => {
  world(on, { run: { ...WITH_PR, rounds: [{ n: 1, startedAt: '2026-01-10T10:02:00Z' }] }, comments: [OTHER, { ...OTHER, at: '2026-01-10T10:03:00Z' }] })
  await refresh($)
  expect((await seen($)).words).toMatch(/Review comments \(1\)/)
})

test('a failed login lookup or comment call shows no count, not zero', async ($, on) => {
  const w: World = { run: { ...NEEDS_YOU, pr: 456, commentsReadUntil: SINCE }, issueComments: [OTHER] }
  world(on, w)
  w.login = null
  await refresh($)
  expect((await seen($)).buttons).not.toContain('comments')
  w.login = ME
  w.comments = 'fail'
  await refresh($)
  const view = await seen($)
  expect(view.buttons).not.toContain('comments')
  expect(view.words).toMatch(/Needs you/)
})

test('merge-tree: exit 0 is no conflict, exit 1 counts files, an error or a throw is unknown', async ($, on) => {
  const w: World = { run: WITH_PR }
  world(on, w)
  const hasConflicts = async () => (await seen($)).buttons.includes('merge-main')
  await refresh($)
  expect(await hasConflicts()).toBe(false)
  w.conflicts = 'shop/pricing.py\nshop/cart.py'
  w.fetchFails = true
  await refresh($)
  expect(await hasConflicts()).toBe(true)
  expect((await seen($)).words).toMatch(/Conflicts with main/)
  w.fetchFails = false
  w.mergeExit = 128
  await refresh($)
  expect(await hasConflicts()).toBe(false)
  w.mergeExit = 'throw'
  await refresh($)
  expect(await hasConflicts()).toBe(false)
})

test('network data belongs to its PR', async ($, on) => {
  const w: World = { run: WITH_PR, conflicts: 'shop/pricing.py' }
  world(on, w)
  await refresh($)
  expect((await seen($)).buttons).toContain('merge-main')
  w.run = { ...WITH_PR, pr: 789 }
  w.conflicts = undefined
  await poll($)
  const view = await seen($)
  expect(view.buttons).not.toContain('merge-main')
  expect(view.words).toMatch(/Ready/)
})

test('the mod only reads: git and gh calls are read-only or a fetch', async ($, on) => {
  const ran: string[] = []
  world(on, { run: WITH_PR, conflicts: 'shop/pricing.py', now: '2026-01-12T09:00:00Z' }, ran)
  await refresh($)
  const writes = ran.filter(cmd => /^git (commit|push|merge |rebase|reset|checkout|switch|add|stash|tag)|^gh (pr|issue) (create|edit|comment|merge)/.test(cmd))
  expect(writes).toEqual([])
  expect(ran.some(cmd => cmd.startsWith('git fetch'))).toBe(true)
})

const AT = '2026-01-10T09:20:00Z'
const PLAN_A: MyStatusRun = { ...PLANNING, worktree: '/work', step: 'research', updatedAt: AT }
const PLAN_B: MyStatusRun = { ...PLANNING, worktree: '/work', step: 'approval', updatedAt: '2026-01-10T09:22:00Z' }
const CHATS = { 'session-chat-a.json': PLAN_A, 'session-chat-b.json': PLAN_B }
const planningStep = (view: Seen) => view.words.match(/Planning: (\w+)/)?.[1]

test('two chats planning in the same folder each see only their own plan; a third sees none', async ($, on) => {
  const w: World = { files: CHATS }
  world(on, w)
  for (const [chat, step] of [['chat-a', 'Research'], ['chat-b', 'Approval'], ['chat-c', undefined]] as const) {
    w.sessionId = chat
    await refresh($)
    const view = await seen($, 'desktop')
    expect(view.band).toBe(step !== undefined)
    expect(planningStep(view)).toBe(step)
  }
})

test('a chat shows its own activity, never another chat\'s', async ($, on) => {
  const w: World = {
    files: {
      'session-chat-a.activity.json': { mode: 'pr:review', state: 'running', updatedAt: AT },
      'session-chat-b.activity.json': { mode: 'improve:run', state: 'needs_you', updatedAt: AT },
    },
  }
  world(on, w)
  for (const [chat, mode] of [['chat-a', 'pr:review'], ['chat-b', 'improve:run'], ['chat-c', undefined]] as const) {
    w.sessionId = chat
    await refresh($)
    const view = await seen($, 'desktop')
    expect(view.words.match(/(pr:review|improve:run)/)?.[1]).toBe(mode)
  }
})

test('a folder-named planning file still shows, without a session id too; the chat\'s own session file comes first', async ($, on) => {
  const w: World = { run: { ...PLANNING, step: 'interview', updatedAt: AT } }
  world(on, w)
  for (const id of ['chat-c', null]) {
    w.sessionId = id
    await refresh($)
    expect(planningStep(await seen($, 'desktop'))).toBe('Interview')
  }
  w.sessionId = 'chat-a'
  w.files = CHATS
  await refresh($)
  expect(planningStep(await seen($, 'desktop'))).toBe('Research')
})

test('a session planning file untouched for 7 hours draws no band', async ($, on) => {
  world(on, { files: CHATS, now: '2026-01-10T16:30:00Z' })
  await refresh($)
  expect((await seen($)).band).toBe(false)
})

test('a leftover session planning file older than the folder\'s running file does not hide the run; a newer one still shows', async ($, on) => {
  const live: MyStatusRun = { ...RUNNING, plan: { title: 'Learn from use', path: '' }, updatedAt: '2026-01-10T09:20:00Z' }
  const leftovers: MyStatusRun[] = [
    { ...PLANNING, step: 'research', updatedAt: '2026-01-10T09:10:00Z' },
    { ...PLANNING, state: 'needs_you', reason: 'Plan approval', updatedAt: '2026-01-10T09:10:00Z' },
    { ...PLANNING, step: 'research' },
  ]
  const w: World = { run: live }
  world(on, w)
  for (const leftover of leftovers) {
    w.files = { 'session-chat-a.json': leftover }
    await refresh($)
    expect((await seen($, 'desktop')).words).toMatch(/^Running: Part B/)
  }
  w.files = { 'session-chat-a.json': { ...PLANNING, step: 'approval', updatedAt: '2026-01-10T09:22:00Z' } }
  await refresh($)
  expect(planningStep(await seen($, 'desktop'))).toBe('Approval')
})

// ---------- the status line and the calibration reading ----------

const NOTES = '## 20261028-01 Kit note one · open\n## 20261028-02 Kit note two · open\n## 20261027-01 Old note · fixed\n'

test('the status line is my: <state>[ · extras] · <n> kit notes, comments and conflicts among the extras', async ($, on) => {
  const status: (string | undefined)[] = []
  const w: World = { status }
  world(on, w)
  const activity: MyStatusActivity = { mode: 'pr:review', state: 'running', updatedAt: '2026-01-10T09:20:00Z' }
  const cases: [World, string | undefined][] = [
    [{ run: { ...V2_READY, pr: 461, commentsReadUntil: SINCE }, comments: [OTHER, OTHER, OTHER], log: NOTES }, 'my: Ready · 3 comments · 2 kit notes'],
    [{ run: V2_NEEDS_YOU, log: NOTES }, 'my: Needs you · 2 kit notes'],
    [{ run: V2_PLANNING, log: '## 20261028-01 Kit note one · open\n' }, 'my: Planning · Interview · 1 kit notes'],
    [{ activity, log: NOTES }, 'my: Running · pr:review · 2 kit notes'],
    [{ run: V2_RUNNING }, 'my: Running · 82% · 6–10 min'],
    [{ run: V2_RUNNING_SIX }, 'my: Running · 53% · estimating…'],
    [{ run: V2_STOPPED }, 'my: Stopped'],
    [{ run: { ...V2_DONE, pr: 462 }, conflicts: 'shop/pricing.py' }, 'my: Done · 1 conflict'],
    [{ run: { ...V2_RUNNING, pr: 463, commentsReadUntil: SINCE }, comments: [OTHER], conflicts: 'a.py\nb.py' }, 'my: Running · 82% · 6–10 min · 1 comment · 2 conflicts'],
    [{ log: NOTES }, 'my: 2 kit notes'],
    [{}, undefined],
  ]
  for (const [next, line] of cases) {
    Object.assign(w, { run: undefined, activity: undefined, comments: undefined, conflicts: undefined, log: undefined }, next)
    await refresh($)
    expect(status.at(-1)).toBe(line)
  }
})

test('/my-status measure reports the calibration and what the band last measured', async ($, on) => {
  world(on, { run: V2_RUNNING })
  await refresh($)
  const measure = async () =>
    JSON.stringify(await $.command.run({ command: 'my-status', args: 'measure', origin: { kind: 'composer' }, presentation: { isFullscreen: false, columns: 120 } }))
  const ui = await $.ui.mount(band('desktop', 10, 90))
  await ui.unmount()
  const text = await measure()
  expect(text).toMatch(/px per row: 24; px per column: 8.33/)
  expect(text).toMatch(/last draw \(desktop\): maxRows 10, scroll.bodyRows 9, bodyColumns 90/)
  expect(text).toMatch(/level L0, band \d+ px of 240/)
  const term = await $.ui.mount(band('terminal', 12, 80))
  await term.unmount()
  expect(await measure()).toMatch(/last draw \(terminal\): maxRows 12, .*band \d+ rows of 12/)
})

// ---------- the session's background agents, only with kit work ----------

type AgentStatusNow = 'running' | 'waiting' | 'completed'
/** The engine's agents: a spawn answers its id and model, `$.agent.list()` their status now, a tool call passes. */
function agentsWorld(on: On, status: Record<string, AgentStatusNow>) {
  on('agent.spawn', ($, e) => ({ model: e.description.startsWith('Reviewer') ? 'claude-sonnet-4-5' : 'claude-opus-4-5', agentId: `id-${e.description.split(' ')[0]!.toLowerCase()}` }))
  on('agent.list', () => ({
    value: Object.entries(status).map(([id, now]) => ({ id, description: id, type: 'general-purpose', status: now })),
  }))
  on('tool.call', () => ({ result: '' }))
}

async function spawn($: Engine, description: string, tool?: { tool: string; command?: string; file_path?: string }) {
  const started = await $.agent.spawn({
    tool_use_id: `t-${description}`,
    prompt: 'Do the work',
    description,
    subagentType: 'general-purpose',
    provider: { plugin: 'engine', tier: 'core' },
    parentModel: 'claude-opus-4-5',
    background: true,
    fork: false,
  })
  const id = 'agentId' in started ? String(started.agentId) : ''
  if (tool) await $.tool.call({ ...tool, agentId: id } as Parameters<Engine['tool']['call']>[0])
  return id
}

const FOUR_AGENTS: [string, { tool: string; command?: string; file_path?: string }][] = [
  ['Executor round 6', { tool: 'Edit', file_path: '/work/src/grid/CardGrid.tsx' }],
  ['Second executor', { tool: 'Edit', file_path: '/work/src/grid/Skeleton.tsx' }],
  ['Reviewer fresh', { tool: 'Bash', command: 'pnpm test' }],
  ['Researcher', { tool: 'Grep' }],
]

test('a spawned agent and its tool call appear in the agents rows, on both surfaces', async ($, on) => {
  const status: Record<string, AgentStatusNow> = {}
  world(on, { run: V2_RUNNING })
  agentsWorld(on, status)
  await refresh($)
  const id = await spawn($, 'Executor round 4', { tool: 'Bash', command: 'pnpm test --filter cart' })
  status[id] = 'running'
  for (const surface of SURFACES) {
    const ui = await $.ui.mount(band(surface))
    if (surface === 'desktop') expect(Object.keys(await pictures(ui))).toEqual(['header', 'track', 'agents-head', 'agents'])
    const shown = await words(ui)
    expect(shown).toMatch(/Background agents.*1 running/)
    expect(shown).toContain('Executor round 4')
    expect(shown).toContain('Bash pnpm test --filter cart')
    expect((await ui.findAll({ type: 'Button' })).map(b => b.key)).toEqual(['toggle', 'agents-fold', 'open-plan'])
    if (surface === 'desktop') {
      await expectBlankLabels(ui)
      await ui.press({ key: 'agents-fold' })
      await expectBlankLabels(ui)
    }
    await ui.unmount()
  }
})

test('no agents section without kit work, even when agents run', async ($, on) => {
  const w: World = {}
  world(on, w)
  agentsWorld(on, {})
  await refresh($)
  await spawn($, 'Executor round 4', { tool: 'Bash', command: 'pnpm test' })
  for (const surface of SURFACES) expect((await seen($, surface)).band).toBe(false)
  w.activity = { mode: 'pr:review', state: 'done', updatedAt: '2026-01-10T09:20:00Z' }
  await refresh($)
  for (const surface of SURFACES) expect((await seen($, surface)).band).toBe(false)
  // a pr:* activity under way is kit work: the agents show under its header
  w.activity = { ...w.activity, state: 'running' }
  await refresh($)
  for (const surface of SURFACES) expect((await seen($, surface)).words).toMatch(/Running.*pr:review.*Background agents/)
})

test('the agents fold to their head only past maxRows; the head opens and folds them', async ($, on) => {
  world(on, { run: V2_RUNNING })
  agentsWorld(on, {})
  await refresh($)
  await spawn($, 'Executor round 4', { tool: 'Edit', file_path: '/work/src/ui/ChatPanel.tsx' })
  await spawn($, 'Reviewer fresh', { tool: 'Bash', command: 'pnpm test' })
  // desktop at 24 px a row: 400 rows hold everything; 8 rows (192 px) hold the band with the agents folded
  const roomy = await $.ui.mount(band('desktop', 400))
  expect(Object.keys(await pictures(roomy))).toEqual(['header', 'track', 'agents-head', 'agents'])
  await roomy.unmount()

  // terminal, in rows: running closed with 2 agents takes 8 rows, so 6 fold them to the head
  const term = await $.ui.mount(band('terminal', 6))
  expect((await term.find({ type: 'Button', key: 'agents-fold' }))?.text).toMatch(/Background agents {2}· {2}2 running/)
  expect(await term.find({ type: 'Box', key: 'agent-id-executor' })).toBeUndefined()
  await term.unmount()

  const tight = await $.ui.mount(band('desktop', 8))
  expect(Object.keys(await pictures(tight))).toEqual(['header', 'track', 'agents-head'])
  expect((await tight.findAll({ type: 'Button' })).map(b => b.key)).toEqual(['toggle', 'agents-fold', 'open-plan'])
  await tight.press({ key: 'agents-fold' })
  // opened by the person, the agents stay whole: the band may scroll, the person asked for them
  expect(Object.keys(await pictures(tight))).toEqual(['header', 'track', 'agents-head', 'agents'])
  await tight.press({ key: 'agents-fold' })
  expect(Object.keys(await pictures(tight))).toEqual(['header', 'track', 'agents-head'])
  await tight.unmount()
})

test('four agents show whole, a fifth as "+ 1 more"; the running ones pulse in Running alone', async ($, on) => {
  const w: World = { run: V2_RUNNING, now: '2026-01-10T09:25:01.300Z' }
  world(on, w)
  agentsWorld(on, {})
  await refresh($)
  for (const [description, tool] of FOUR_AGENTS) await spawn($, description, tool)
  const ui = await $.ui.mount(band('desktop'))
  const rows = await source(ui, 'agents')
  for (const [description] of FOUR_AGENTS) expect(rows).toContain(description)
  expect(rows).not.toContain('more')
  expect((rows.match(/<animate attributeName="opacity"/g) ?? []).length).toBe(4)
  expect(rows).toContain('begin="-1.300s"')
  await ui.unmount()
  await spawn($, 'Fifth helper', { tool: 'Read', file_path: '/work/README.md' })
  const five = await $.ui.mount(band('desktop'))
  expect(await source(five, 'agents')).toContain('+ 1 more')
  expect(await source(five, 'agents')).not.toContain('Fifth helper')
  await five.unmount()
  w.run = V2_NEEDS_YOU
  await refresh($)
  const still = await $.ui.mount(band('desktop'))
  expect((await source(still, 'agents')).match(/<animate attributeName="opacity"/g) ?? []).toHaveLength(0)
  await still.unmount()
})

test('the agents poll: a waiting one reads "Waiting for your answer" in Needs you, a finished one fades after 10 s', async ($, on) => {
  const clock = mock.clock(on, { now: Date.parse('2026-01-10T09:25:00Z') })
  const status: Record<string, AgentStatusNow> = {}
  world(on, { run: V2_NEEDS_YOU, isClockMocked: true })
  agentsWorld(on, status)
  await refresh($)
  const a = await spawn($, 'Executor round 4', { tool: 'Bash', command: 'pnpm test' })
  const b = await spawn($, 'Reviewer fresh', { tool: 'Grep' })
  status[a] = 'waiting'
  status[b] = 'completed'
  await clock.advance(5_000)
  const shown = (await seen($, 'desktop')).words
  expect(shown).toMatch(/Background agents.*1 waiting, 1 finished/)
  expect(shown).toContain('Executor round 4, waiting')
  const rows = await $.ui.mount(band('desktop'))
  expect(await source(rows, 'agents')).toContain('Waiting for your answer')
  await rows.unmount()
  await clock.advance(10_000)
  const later = (await seen($, 'desktop')).words
  expect(later).not.toContain('Reviewer fresh')
  expect(later).toMatch(/1 waiting/)
})

test('the effort shows after an agent\'s first model request', async ($, on) => {
  world(on, { run: V2_RUNNING })
  agentsWorld(on, {})
  on('turn.step', async function* ($, e) {
    return { turnId: e.turnId, index: e.index, answer: '', toolUses: [], stopReason: 'end_turn', usage: null }
  })
  await refresh($)
  const id = await spawn($, 'Executor round 4', { tool: 'Bash', command: 'pnpm test' })
  const before = await $.ui.mount(band('desktop'))
  expect(await source(before, 'agents')).not.toContain('high')
  await before.unmount()
  const stream = $.turn.step({ turnId: 'turn-1', index: 0, model: 'claude-opus-4-5', effort: 'high', messageCount: 1, agentId: id })
  for await (const _ of stream) void _
  const ui = await $.ui.mount(band('desktop'))
  expect(await source(ui, 'agents')).toContain('opus · high')
  await ui.unmount()
})

// ---------- Show question ----------

/** An assistant message as the transcript draws it, on screen (its rows) or off it (null). */
function message(surface: Surface, requestId: string, onScreen: { first: number; last: number; of: number } | null) {
  return { plugin: 'my-status', surface, component: 'AssistantMessage' as const, requestId, props: { text: 'Shall I open the PR?', isFirstOfReply: true, onScreen } }
}

test('in Needs you, the newest assistant message off screen gives Show question, which scrolls to it; on screen, the band says to answer below', async ($, on) => {
  const toasts: string[] = []
  world(on, { run: V2_NEEDS_YOU })
  on('ui.toast', ($, e) => {
    toasts.push(e.text)
    return { value: undefined }
  })
  await refresh($)
  for (const surface of SURFACES) {
    // the question in view: the note, no control
    const shown = await $.ui.mount(message(surface, `m-${surface}`, { first: 0, last: 3, of: 4 }))
    let view = await seen($, surface)
    expect(view.words).toMatch(/Answer in the chat below/)
    expect(view.buttons).not.toContain('show-question')
    await shown.unmount()
    // scrolled out of view: Show question, and pressing it scrolls the transcript to that message
    const away = await $.ui.mount(message(surface, `m-${surface}`, null))
    view = await seen($, surface)
    expect(view.words).not.toMatch(/Answer in the chat below/)
    expect(view.buttons).toEqual(['toggle', 'show-question', 'open-plan'])
    // the kit has no transcript to scroll and no hook beneath `$.ui.scroll`: the press reaching it is what a test can
    // see; with no question seen, it would toast instead and never scroll
    const ui = await $.ui.mount(band(surface))
    await expect(ui.press({ key: 'show-question' })).rejects.toThrow('no implementation for ui.scroll')
    await ui.unmount()
    await away.unmount()
    expect(toasts).toEqual([])
  }
})

test('Show question with no message to scroll to says so, in the prototype\'s words, and does not scroll', async ($, on) => {
  const toasts: string[] = []
  world(on, { run: V2_NEEDS_YOU })
  on('ui.toast', ($, e) => {
    toasts.push(e.text)
    return { value: undefined }
  })
  await refresh($)
  // a message the transcript draws without an id leaves nothing to scroll to
  const away = await $.ui.mount(message('desktop', '', null))
  const ui = await $.ui.mount(band('desktop'))
  await ui.press({ key: 'show-question' })
  expect(toasts).toEqual(['No assistant message seen yet to scroll to.'])
  await ui.unmount()
  await away.unmount()
})

test('outside Needs you a message off screen changes nothing', async ($, on) => {
  world(on, { run: V2_RUNNING })
  await refresh($)
  const away = await $.ui.mount(message('desktop', 'm-1', null))
  expect((await seen($, 'desktop')).buttons).toEqual(['toggle', 'open-plan'])
  await away.unmount()
})
