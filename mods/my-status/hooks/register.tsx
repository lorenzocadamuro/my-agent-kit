import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { MyStatusActivity, MyStatusProgress, MyStatusRun, MyStatusSnapshot } from '../types'
import { bandView, hintCards, statusLine, TILE_CELLS } from './view'
import type { Badge, Tile, Tone } from './view'

const PLUGIN = 'my-status'
const PANE = 'my-status-plan'
const POLL_MS = 60_000
const NETWORK_MS = 10 * 60_000
const COMMENT_ROW = '.[] | {login: .user.login, at: .created_at}'

export const snapAtom = atom({ plugin: 'my-status', key: 'snap' } as const, null)
export const planAtom = atom({ plugin: 'my-status', key: 'planText' } as const, null)

const COLOR: Record<Tone, string> = {
  neutral: 'gray',
  accent: 'blue',
  success: 'green',
  warning: 'yellow',
  danger: 'red',
}

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

function poll($: EngineInterface): Promise<void> {
  if (inFlight === null) {
    inFlight = refresh($).finally(() => {
      inFlight = null
    })
  }
  return inFlight
}

async function refresh($: EngineInterface): Promise<void> {
  {
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
      newComments: net ? net.newComments : 0,
      conflicts: net ? net.conflicts : 0,
      openNotes,
      now,
    }
    await update($, snapAtom, () => snap)
    $.ui.status(statusLine(snap))
  }
}

async function openPlan($: EngineInterface, path: string, title: string): Promise<void> {
  const text = await readText($, path)
  await update($, planAtom, () => text ?? `Could not read ${path}.`)
  await $.ui.open({ id: PANE, title })
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'my-status', description: 'Refresh the my status line and open the plan, if one is running' })
    network.clear()
    $.clock.every(POLL_MS, () => void poll($))
    void poll($)
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
    const view = bandView(snap, e.props.bodyColumns)
    if (!view) return next(e)
    const cards = hintCards(view, e.props.bodyColumns)
    const scope = (index: number) => `my-status-part-${index}`
    const { Box, Button, Text } = $.ui.resolve(e)

    const badge = (b: Badge) => (
      <Box key={b.key} flexShrink={0}>
        <Text color="black" backgroundColor={COLOR[b.tone]}>{` ${b.text} `}</Text>
      </Box>
    )
    const tile = (t: Tile, i: number) => {
      const filled = t.fill <= 0 ? 0 : Math.max(1, Math.round(t.fill * TILE_CELLS))
      return (
        <Box key={`tile-${i}`} flexShrink={0} hover={cards.some(card => card.index === i) ? { scope: scope(i) } : undefined}>
          <Text color={COLOR[t.tone]}>{'█'.repeat(filled)}</Text>
          <Text color="gray">{'░'.repeat(TILE_CELLS - filled)}</Text>
        </Box>
      )
    }

    const children = [
      ...(view.tiles.length > 0 ? [<Box key="tiles" flexDirection="row" gap={1} flexShrink={0}>{view.tiles.map(tile)}</Box>] : []),
      ...view.badges.map(badge),
      ...(view.reason ? [<Box key="reason" flexShrink={0}><Text>{view.reason}</Text></Box>] : []),
      ...(view.detail ? [<Box key="detail" flexShrink={0}><Text dimColor>{view.detail}</Text></Box>] : []),
      <Box key="spacer" flexGrow={1} />,
      ...(view.time ? [<Box key="time" flexShrink={0}><Text dimColor>{view.time}</Text></Box>] : []),
      ...view.actions.map(action => (
        <Box key={`action-${action.key}`} flexShrink={0}>
          <Button
            key={action.key}
            label={action.label}
            onPress={async () => {
              if (action.opensPlan) {
                const path = snap?.run?.plan?.path
                if (path) await openPlan($, path, snap?.run?.plan?.title ?? 'Plan')
                return
              }
              if (action.command) await $.prompt.fill({ text: action.command })
            }}
          />
        </Box>
      )),
      ...cards.map(card => (
        <Box key={`hint-${card.index}`} position="absolute" top={0} left={card.left} display="none" hover={{ scope: scope(card.index), display: 'flex' }}>
          <Text color="black" backgroundColor={COLOR[card.tone]}>{card.text}</Text>
        </Box>
      )),
    ]

    return (
      <Box key="band" flexDirection="row" flexWrap="nowrap" overflow="hidden" gap={1}>
        {children}
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
