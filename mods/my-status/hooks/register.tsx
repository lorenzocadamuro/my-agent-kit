import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, RenderElement } from 'claude-code'

import type { MyStatusActivity, MyStatusProgress, MyStatusRun, MyStatusSnapshot } from '../types'
import { bandModel } from './adapter'
import type { BandModel, Cta, State } from './adapter'
import { headerPic, litPic, notePic, padBottom, pillPic, pulseBegin, stepsPic, trackChevronY, trackPic } from './draw'
import type { Pic } from './draw'
import { statusLine } from './view'

// The my kit's status band, as the prototype approved on 2026-10-28 draws it, from the real state file. On the desktop
// every part of the band is an SVG picture laid out to the CSS px (after plan-progress, github.com/zycck/claude-mods,
// MIT): header, track, steps. The track is a control: a blank `plain` Button lies over its own picture and nothing
// else. The action row, at the bottom, is pills drawn as pictures under blank Buttons, Open plan in the corner. The
// terminal draws characters. The band folds the steps of the parts not under way only past the engine's maxRows.

const PANE = 'my-status-plan'
const POLL_MS = 60_000
const NETWORK_MS = 10 * 60_000
const COMMENT_ROW = '.[] | {login: .user.login, at: .created_at}'

export const snapAtom = atom({ plugin: 'my-status', key: 'snap' } as const, null)
export const planAtom = atom({ plugin: 'my-status', key: 'planText' } as const, null)
const showSteps = atom({ plugin: 'my-status', key: 'showSteps' } as const, false)
const tick = atom({ plugin: 'my-status', key: 'tick' } as const, 0)

// Calibration from the prototype's screenshots: px per app row and per column on the desktop
const ROW_PX = 24
const COL_PX = 8.33
// The desktop leaves the engine's five [-] columns empty, so pictures use them too
const MARK_COLS = 5
// the alignment line, in cells: the native row's padding and the pictures' x = A agree on it
const ALIGN_COLS = 2
// The action row: its height and the gap above it, in px
const ROW_H_PX = 26
const GAP_TO_ROW_PX = 12
// the band's width beyond the pictures (the app's padding), for the width thresholds
const FRAME_PX = 20
// A blank Button's label: figure spaces (a digit wide, ~8.6 px at the desktop's 14 px), since the desktop presses a
// Button on its label alone and collapses plain spaces; kept under the picture's width, a label wider than its box
// being cut with an ellipsis (plan-progress's notes)
const FIGURE_SPACE = ' '
const FIGURE_PX = 8.6
const blankLabel = (w: number) => FIGURE_SPACE.repeat(Math.max(1, Math.floor((w - 24) / FIGURE_PX)))
// the blank Button's own hover plate, cleared: the desktop writes a Button's hover as !important rules on the button
// itself, a raw colour only as hex or rgb() (plan-progress)
const NO_PLATE = { backgroundColor: '#0000' }

const TERM_COLOR: Record<State, string> = { planning: 'planMode', ready: 'text', running: 'suggestion', needs_you: 'warning', stopped: 'error', done: 'success' }

type Network = { at: number; newComments: number | null; conflicts: number | null }

async function sh($: EngineInterface, argv: string[], cwd?: string): Promise<string | null> {
  try {
    const ran = await $.process.run(argv, { cwd, timeoutMs: 20_000, env: { GIT_TERMINAL_PROMPT: '0' } })
    return ran.exitCode === 0 ? ran.stdout.trim() : null
  } catch {
    return null
  }
}

async function readText($: EngineInterface, path: string): Promise<string | null> {
  try {
    return await $.fs.read(path)
  } catch {
    return null
  }
}

async function exists($: EngineInterface, path: string | undefined): Promise<boolean> {
  if (!path) return false
  try {
    return (await $.fs.exists(path)) === true
  } catch {
    return false
  }
}

function ownerName(remote: string | null, top: string): string {
  const match = remote?.match(/[:/]([^/:]+)\/([^/]+?)(\.git)?$/)
  if (match) return `${match[1]}-${match[2]}`
  return `none-${top.split('/').pop() ?? 'repo'}`
}

async function dataRoot($: EngineInterface): Promise<string | null> {
  const custom = await sh($, ['printenv', 'MY_AGENT_KIT_HOME'])
  if (custom) return custom
  const home = await sh($, ['printenv', 'HOME'])
  return home ? `${home}/.my-agent-kit` : null
}

/** 0 on a clean merge (exit 0), the conflicted files on exit 1, unknown (null) on any other exit or a failed call. */
async function conflictsWithMain($: EngineInterface, dir: string, base: string): Promise<number | null> {
  try {
    const ran = await $.process.run(['git', 'merge-tree', '--write-tree', '--name-only', 'HEAD', base], { cwd: dir, timeoutMs: 20_000 })
    if (ran.exitCode === 0) return 0
    if (ran.exitCode !== 1) return null
    const [, ...rest] = ran.stdout.split('\n')
    const end = rest.indexOf('')
    return (end === -1 ? rest : rest.slice(0, end)).filter(Boolean).length
  } catch {
    return null
  }
}

/** Comments by others since the last read (or the first round's start); unknown (null) when that date, the login or a call is missing. */
async function newComments($: EngineInterface, dir: string, run: MyStatusRun): Promise<number | null> {
  const since = run.commentsReadUntil ?? run.rounds?.[0]?.startedAt
  const sinceMs = since ? Date.parse(since) : NaN
  if (!run.pr || !Number.isFinite(sinceMs)) return null
  const me = await sh($, ['gh', 'api', 'user', '--jq', '.login'], dir)
  if (!me) return null
  let count = 0
  for (const path of [`repos/{owner}/{repo}/pulls/${run.pr}/comments`, `repos/{owner}/{repo}/issues/${run.pr}/comments`]) {
    const out = await sh($, ['gh', 'api', '--paginate', `${path}?per_page=100&since=${since}`, '--jq', COMMENT_ROW], dir)
    if (out === null) return null
    for (const line of out.split('\n').filter(Boolean)) {
      const row = parseJson<{ login?: string; at?: string }>(line)
      if (!row) return null
      if (row.login !== me && row.at && Date.parse(row.at) > sinceMs) count += 1
    }
  }
  return count
}

function parseJson<T>(text: string | null): T | null {
  if (!text) return null
  try {
    return JSON.parse(text) as T
  } catch {
    return null
  }
}

const SIDECAR = /\.(progress|activity)\.json$/

/** This chat's id, or null when the engine cannot tell it (then only the folder's files count). */
async function sessionId($: EngineInterface): Promise<string | null> {
  try {
    const id = await $.session.id()
    return /^[\w-]+$/.test(id) ? id : null
  } catch {
    return null
  }
}

type Found = { run: MyStatusRun; file: string }

/** The newer of the chat's own planning file and the folder's file (on a tie, the chat's own); a missing date counts as oldest. */
async function findRun($: EngineInterface, root: string, own: string | null, file: string, top: string): Promise<Found | null> {
  const mine = own ? parseJson<MyStatusRun>(await readText($, `${own}.json`)) : null
  const folder = await findFolderRun($, root, file, top)
  if (mine && (!folder || (mine.updatedAt ?? '') >= (folder.run.updatedAt ?? ''))) return { run: mine, file: `${own}.json` }
  return folder
}

/** The folder and branch file, then an older name with this worktree; another chat's session files never. */
async function findFolderRun($: EngineInterface, root: string, file: string, top: string): Promise<Found | null> {
  const exact = parseJson<MyStatusRun>(await readText($, file))
  if (exact) return { run: exact, file }
  let names: string[] = []
  try {
    names = (await $.fs.list(`${root}/state`)).filter(entry => entry.kind === 'file' && entry.name.endsWith('.json') && !SIDECAR.test(entry.name) && !entry.name.startsWith('session-')).map(entry => entry.name)
  } catch {
    return null
  }
  let best: Found | null = null
  for (const name of names) {
    const path = `${root}/state/${name}`
    const run = parseJson<MyStatusRun>(await readText($, path))
    if (run?.worktree === top && (best === null || (run.updatedAt ?? '') > (best.run.updatedAt ?? ''))) best = { run, file: path }
  }
  return best
}

const network = new Map<string, Network>()
let inFlight: Promise<void> | null = null
// the activity under way and when the mod first saw it: its elapsed time counts from there
let activitySeen: { mode: string; at: number } | null = null

function poll($: EngineInterface): Promise<void> {
  if (inFlight === null) {
    inFlight = refresh($).finally(() => {
      inFlight = null
    })
  }
  return inFlight
}

async function refresh($: EngineInterface): Promise<void> {
  const cwd = await $.session.cwd()
  const top = await sh($, ['git', 'rev-parse', '--show-toplevel'], cwd)
  const root = await dataRoot($)
  if (!top || !root) {
    await update($, snapAtom, () => null)
    $.ui.status(undefined)
    return
  }
  const branch = (await sh($, ['git', 'branch', '--show-current'], top)) || 'detached'
  const remote = await sh($, ['git', 'remote', 'get-url', 'origin'], top)
  const base = `${root}/state/${ownerName(remote, top)}-${branch.replace(/\//g, '-')}`
  const session = await sessionId($)
  const own = session ? `${root}/state/session-${session}` : null
  const found = await findRun($, root, own, `${base}.json`, top)
  const run = found?.run ?? null
  const progress = found ? parseJson<MyStatusProgress>(await readText($, found.file.replace(/\.json$/, '.progress.json'))) : null
  const activity =
    (own ? parseJson<MyStatusActivity>(await readText($, `${own}.activity.json`)) : null) ?? parseJson<MyStatusActivity>(await readText($, `${base}.activity.json`))
  const now = await $.clock.now()
  const live = activity && (activity.state === 'running' || activity.state === 'needs_you') ? (activity.mode ?? '') : null
  if (live === null) activitySeen = null
  else if (activitySeen?.mode !== live) activitySeen = { mode: live, at: now }
  let net: Network | undefined
  if (run?.pr) {
    const dir = run.worktree ?? top
    const key = `${dir}#${run.pr}`
    net = network.get(key)
    if (!net || now - net.at >= NETWORK_MS) {
      const main = (await sh($, ['git', 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD'], dir)) || 'origin/main'
      await sh($, ['git', 'fetch', '--quiet', 'origin', main.replace(/^origin\//, '')], dir)
      net = { at: now, conflicts: await conflictsWithMain($, dir, main), newComments: await newComments($, dir, run) }
      network.set(key, net)
    }
  }
  const log = await readText($, `${root}/suite-log.md`)
  const openNotes = log ? (log.match(/^## \d{8}-\d{2} .* · open$/gm) ?? []).length : 0
  const snap: MyStatusSnapshot = {
    run,
    progress,
    activity,
    activitySince: activitySeen?.at,
    hasPlanFile: await exists($, run?.plan?.path),
    newComments: net ? net.newComments : 0,
    conflicts: net ? net.conflicts : 0,
    openNotes,
    now,
  }
  await update($, snapAtom, () => snap)
  $.ui.status(statusLine(snap))
}

async function openPlan($: EngineInterface, path: string, title: string): Promise<void> {
  const text = await readText($, path)
  await update($, planAtom, () => text ?? `Could not read ${path}.`)
  await $.ui.open({ id: PANE, title })
}

type Level = 0 | 2
// a picture of the band; a control's has the Button over it and `lit`, what lights up under the pointer
type Layout = { level: Level; pics: { key: string; pic: Pic; isToggle?: true; lit?: Pic }[]; hasRow: boolean; heightPx: number }

/**
 * The first height level whose band fits `budget` px: L2 shows the parts not started as one "to do" chip each. Nothing
 * else gives way: past L2 the engine scrolls.
 */
function layout(m: BandModel, W: number, A: number, wantsOpen: boolean, budget: number, now: number): Layout {
  const isNarrow = W + FRAME_PX < 560
  // the pulse means "working right now": Running alone
  const pulse = m.state === 'running' ? pulseBegin(now) : undefined
  const header = headerPic(m, W, A, isNarrow, pulse)
  const canOpen = !m.isPlanning && m.parts.length > 0
  const open = wantsOpen && canOpen
  const build = (level: Level) => {
    const pics: Layout['pics'] = [{ key: 'header', pic: header }]
    if (m.parts.length > 0) {
      const track = trackPic(m, W, A, open, canOpen, pulse)
      pics.push({ key: 'track', pic: track, ...(canOpen ? { isToggle: true as const, lit: litPic(m.state, W, track.h, A, trackChevronY(open), open) } : {}) })
    }
    if (open) pics.push({ key: 'steps', pic: stepsPic(m, W, A, level >= 2, isNarrow) })
    const hasRow = m.hasPlanFile || m.ctas.length > 0
    const heightPx = pics.reduce((a, p) => a + p.pic.h, 0) + (hasRow ? GAP_TO_ROW_PX + ROW_H_PX : 0)
    return { pics, hasRow, heightPx }
  }
  const levels: Level[] = open ? [0, 2] : [0]
  for (const level of levels) {
    const b = build(level)
    if (b.heightPx <= budget) return { level, ...b }
  }
  const last = levels[levels.length - 1]!
  return { level: last, ...build(last) }
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'my-status', description: 'Refresh the my status line and open the plan, if one is running' })
    network.clear()
    activitySeen = null
    $.clock.every(POLL_MS, () => void poll($))
    void poll($)
    // times are minutes: redraw on each minute boundary
    const now = await $.clock.now()
    $.clock.after(60_000 - (now % 60_000) + 50, () => {
      void update($, tick, n => n + 1).catch(() => {})
      $.clock.every(60_000, () => void update($, tick, n => n + 1).catch(() => {}))
    })
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    void poll($)
    return result
  })

  on('command.run', { command: 'my-status' }, async $ => {
    await poll($)
    const snap = await read($, snapAtom)
    if (snap?.run?.plan?.path) {
      await openPlan($, snap.run.plan.path, snap.run.plan.title)
      return { text: 'Plan opened.' }
    }
    return { text: 'No plan is running in this repository.' }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)
    const snap = await read($, snapAtom)
    await read($, tick)
    const now = await $.clock.now()
    const m = bandModel(snap, now)
    if (!m) return next(e)
    const wantsOpen = await read($, showSteps)
    const maxRows = e.props.maxRows
    const t = $.ui.resolve(e)
    const { Box, Button, Text } = t
    const canOpen = !m.isPlanning && m.parts.length > 0
    const hasRow = m.hasPlanFile || m.ctas.length > 0
    const toggle = () => update($, showSteps, v => !v)

    // the action row, all in the bottom-right corner: the signals and the state's actions, then Open plan in the corner
    // itself, where it never moves; the one primary action stays rightmost of the state's actions
    type Action = Cta | { kind: 'plan'; key: 'open-plan'; label: string }
    const actions: Action[] = [...m.ctas, ...(m.hasPlanFile ? [{ kind: 'plan', key: 'open-plan', label: 'Open plan' } as const] : [])]
    const act = (c: Action) =>
      c.kind === 'plan'
        ? async () => {
            const plan = snap?.run?.plan
            if (plan?.path) await openPlan($, plan.path, plan.title || 'Plan')
          }
        : c.kind === 'question' || c.kind === 'warning'
          ? () => {}
          : () => void $.prompt.fill({ text: c.command })
    // the terminal's row: native Buttons and the notes as warning text, right-aligned
    const terminalRow = () =>
      actions.length > 0 ? (
        <Box key="actions" flexDirection="row" justifyContent="flex-end" alignItems="center" gap={1}>
          {actions.map(c =>
            c.kind === 'warning' ? (
              <Box key={c.key} flexShrink={0}>
                <Text color="warning">{c.label}</Text>
              </Box>
            ) : (
              <Button key={c.key} label={c.label} {...(c.kind === 'primary' ? { variant: 'primary' as const } : {})} onPress={act(c)} />
            ),
          )}
        </Box>
      ) : null

    if ('Svg' in t && e.surface !== 'terminal') {
      const { Svg } = t
      // the whole width the band gives: bodyColumns plus the engine's [-] columns, which the desktop leaves empty
      const W = Math.max(320, Math.floor(((e.props.bodyColumns || 100) + MARK_COLS) * COL_PX) - 2)
      const A = ALIGN_COLS * COL_PX
      // the band may take what maxRows says, in the app's rows; only past that does anything fold
      const budget = maxRows > 0 ? maxRows * ROW_PX : Number.POSITIVE_INFINITY
      const lay = layout(m, W, A, wantsOpen, budget, now)
      // px gaps live in pictures, native spacing being whole cells: the last picture carries the 12 px above the row
      const pics = lay.hasRow ? lay.pics.map((p, i) => (i === lay.pics.length - 1 ? { ...p, pic: padBottom(p.pic, GAP_TO_ROW_PX) } : p)) : lay.pics
      // A picture that is a control: the picture; over it, what lights up, revealed by the keyed Box's own hover (a Box
      // drawn display none, hover display flex, inside an absolute wrapper that is not hidden itself, as plan-progress
      // shows its clock: a hidden absolute Box is lifted out as a hover card and did not show); on top, the blank Button
      // with its plate cleared, which takes the press. Nothing else lies over anything
      const control = (key: string, p: Pic, lit: Pic | undefined, button: RenderElement) => (
        <Box key={key} flexShrink={0}>
          <Svg source={p.source} alt={p.alt} width={p.w} height={p.h} />
          {lit ? (
            <Box position="absolute" top={0} left={0}>
              <Box display="none" hover={{ display: 'flex' }}>
                <Svg source={lit.source} alt="" width={lit.w} height={lit.h} />
              </Box>
            </Box>
          ) : null}
          <Box position="absolute" top={0} left={0} right={0} bottom={0} flexDirection="row" alignItems="center" justifyContent={p.w < 200 ? 'center' : 'flex-start'}>
            {button}
          </Box>
        </Box>
      )
      const blank = (key: string, w: number, onPress: () => unknown) => <Button key={key} plain hover={NO_PLATE} label={blankLabel(w)} onPress={onPress} />
      const pillsRow = lay.hasRow ? (
        <Box key="actions" flexDirection="row" justifyContent="flex-end" alignItems="center" gap={1}>
          {actions.map(c => {
            if (c.kind === 'warning') {
              const note = notePic(m.state, c.label)
              return (
                <Box key={`note-${c.key}`} flexShrink={0}>
                  <Svg source={note.source} alt={note.alt} width={note.w} height={note.h} />
                </Box>
              )
            }
            const kind = c.kind === 'primary' ? 'primary' : 'secondary'
            const pill = pillPic(m.state, c.label, kind, false)
            return control(`pill-${c.key}`, pill, pillPic(m.state, c.label, kind, true), blank(c.key, pill.w + 10, act(c)))
          })}
        </Box>
      ) : null
      return (
        <Box key="band" flexDirection="column">
          {pics.map(({ key, pic: p, isToggle, lit }) =>
            isToggle ? (
              control(key, p, lit, blank('toggle', p.w, toggle))
            ) : (
              // each picture in a keyed Box (an Svg keeps no key)
              <Box key={key} flexShrink={0}>
                <Svg source={p.source} alt={p.alt} width={p.w} height={p.h} />
              </Box>
            ),
          )}
          {pillsRow}
        </Box>
      )
    }

    // ---------- terminal: characters, on the same alignment line two cells in ----------
    const cols = Math.max(20, e.props.bodyColumns || 80)
    const color = TERM_COLOR[m.state]
    const n = m.parts.length
    const pw = n > 0 ? Math.max(3, Math.floor((cols - ALIGN_COLS - (n - 1)) / n)) : 0
    const open = wantsOpen && canOpen

    const stepColor = (status: string) => (status === 'done' ? 'success' : status === 'failed' ? 'error' : status === 'running' ? color : undefined)
    const gutter = (key: string, child: RenderElement | null) => (
      <Box key={key} width={ALIGN_COLS} flexShrink={0}>
        {child}
      </Box>
    )
    // a part's label: the letter and its short title when both fit the column whole, else the letter alone
    const label = (p: BandModel['parts'][number]) => p.name ?? (p.short && [...`${p.letter} ${p.short}`].length <= pw ? `${p.letter} ${p.short}` : p.letter)
    const rows = []
    rows.push(
      <Box key="head" flexDirection="row" gap={2}>
        <Box flexShrink={0}>
          <Text color={color} bold>{`${m.state === 'ready' ? '○' : m.state === 'done' ? '✓' : m.state === 'needs_you' || m.state === 'stopped' ? '▌' : '●'} ${m.word}`}</Text>
        </Box>
        <Box flexGrow={1} />
        <Box flexShrink={0}>
          <Text dimColor>{m.metrics.map(x => `${x.value} ${x.caption}`).join('  ·  ')}</Text>
        </Box>
      </Box>,
    )
    rows.push(
      <Box key="line2" paddingLeft={ALIGN_COLS}>
        <Text wrap="truncate-end">
          <Text bold>{m.line2[0]?.text ?? ''}</Text>
          <Text dimColor>{m.line2.slice(1).map(p => `  ·  ${p.text}`).join('')}</Text>
        </Text>
      </Box>,
    )
    if (n > 0) {
      rows.push(
        <Box key="track" flexDirection="row">
          {gutter('track-gutter', canOpen ? <Button key="toggle" plain dimColor label={open ? '▾' : '▸'} onPress={toggle} /> : null)}
          <Box key="track-caps" flexDirection="row" gap={1}>
            {m.parts.map((p, i) => {
              const k = p.steps.length
              const sw = Math.max(1, Math.floor(pw / Math.max(1, k)))
              return (
                <Box key={`cap-${i}`} width={pw} flexShrink={0}>
                  <Text>
                    {p.steps.map(s => (
                      <Text color={stepColor(s.status)} dimColor={s.status === 'todo' || s.status === 'next'}>
                        {(s.status === 'todo' || s.status === 'next' ? '─' : '━').repeat(sw)}
                      </Text>
                    ))}
                  </Text>
                </Box>
              )
            })}
          </Box>
        </Box>,
      )
      // the label row: the same in both states, in the same place
      rows.push(
        <Box key="letters" flexDirection="row" gap={1} paddingLeft={ALIGN_COLS}>
          {m.parts.map((p, i) => (
            <Box key={`letter-${i}`} width={pw} flexShrink={0}>
              <Text color={p.steps.some(s => s.status !== 'done' && s.status !== 'todo') ? color : undefined} dimColor={!p.steps.some(s => s.status !== 'done' && s.status !== 'todo')} wrap="truncate-end">
                {label(p)}
              </Text>
            </Box>
          ))}
        </Box>,
      )
      if (open)
        m.parts.forEach((p, i) =>
          rows.push(
            <Box key={`steps-${i}`} paddingLeft={ALIGN_COLS}>
              <Text wrap="truncate-end">
                <Text bold>{`${p.letter}  `}</Text>
                {p.steps.map(s => (
                  <Text color={stepColor(s.status)} dimColor={s.status === 'todo'}>{`${s.status === 'done' ? '✓' : s.status === 'failed' ? '✗' : s.status === 'running' ? '●' : '○'} ${s.label}  `}</Text>
                ))}
              </Text>
            </Box>,
          ),
        )
    }
    const row = hasRow ? terminalRow() : null
    if (row) rows.push(row)
    return (
      <Box key="band" flexDirection="column">
        {rows}
      </Box>
    )
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Markdown } = $.ui.resolve(e)
    const text = (await read($, planAtom)) ?? 'No plan loaded.'
    return (
      <Box key="plan" flexDirection="column">
        <Markdown key="plan-text" text={text} />
      </Box>
    )
  })
}
