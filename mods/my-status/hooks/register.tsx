import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { MyStatusRun, MyStatusSnapshot } from '../types'
import { bandView, statusLine } from './view'
import type { Badge, Tile, Tone } from './view'

const PLUGIN = 'my-status'
const PANE = 'my-status-plan'
const POLL_MS = 60_000
const NETWORK_MS = 10 * 60_000
const TILE_CELLS = 3

export const snapAtom = atom({ plugin: 'my-status', key: 'snap' } as const, null)
export const planAtom = atom({ plugin: 'my-status', key: 'planText' } as const, null)

const COLOR: Record<Tone, string> = {
  neutral: 'gray',
  accent: 'blue',
  success: 'green',
  warning: 'yellow',
  danger: 'red',
}

type Network = { at: number; newComments: number; conflicts: number }

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

async function conflictsWithMain($: EngineInterface, dir: string, base: string): Promise<number> {
  try {
    const ran = await $.process.run(['git', 'merge-tree', '--write-tree', '--name-only', 'HEAD', base], { cwd: dir, timeoutMs: 20_000 })
    if (ran.exitCode === 0) return 0
    const [, ...rest] = ran.stdout.split('\n')
    const end = rest.indexOf('')
    return (end === -1 ? rest : rest.slice(0, end)).filter(Boolean).length
  } catch {
    return 0
  }
}

async function newComments($: EngineInterface, dir: string, run: MyStatusRun): Promise<number> {
  const since = run.commentsReadUntil ?? run.updatedAt
  if (!run.pr || !since) return 0
  const query = `[.[] | select(.created_at > "${since}")] | length`
  const count = async (path: string) => {
    const out = await sh($, ['gh', 'api', '--paginate', `${path}?per_page=100&since=${since}`, '--jq', query], dir)
    return (out ?? '').split('\n').reduce((sum, line) => sum + (Number(line) || 0), 0)
  }
  return (await count(`repos/{owner}/{repo}/pulls/${run.pr}/comments`)) + (await count(`repos/{owner}/{repo}/issues/${run.pr}/comments`))
}

let network: Network = { at: 0, newComments: 0, conflicts: 0 }
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
    const file = `${root}/state/${ownerName(remote, top)}-${branch.replace(/\//g, '-')}.json`
    const text = await readText($, file)
    let run: MyStatusRun | null = null
    try {
      run = text ? (JSON.parse(text) as MyStatusRun) : null
    } catch {
      run = null
    }
    const now = await $.clock.now()
    if (run?.pr && now - network.at >= NETWORK_MS) {
      const dir = run.worktree ?? top
      const base = (await sh($, ['git', 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD'], dir)) || 'origin/main'
      await sh($, ['git', 'fetch', '--quiet', 'origin', base.replace(/^origin\//, '')], dir)
      network = { at: now, conflicts: await conflictsWithMain($, dir, base), newComments: await newComments($, dir, run) }
    }
    const log = await readText($, `${root}/suite-log.md`)
    const openNotes = log ? (log.match(/^## \d{8}-\d{2} .* · open$/gm) ?? []).length : 0
    const snap: MyStatusSnapshot = {
      run,
      newComments: run?.pr ? network.newComments : 0,
      conflicts: run?.pr ? network.conflicts : 0,
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
    const { Box, Button, Text } = $.ui.resolve(e)

    const badge = (b: Badge) => (
      <Box key={b.key} flexShrink={0}>
        <Text color="black" backgroundColor={COLOR[b.tone]}>{` ${b.text} `}</Text>
      </Box>
    )
    const tile = (t: Tile, i: number) => {
      const filled = t.fill <= 0 ? 0 : Math.max(1, Math.round(t.fill * TILE_CELLS))
      return (
        <Box key={`tile-${i}`} flexShrink={0}>
          <Text color={COLOR[t.tone]}>{'█'.repeat(filled)}</Text>
          <Text color="gray">{'░'.repeat(TILE_CELLS - filled)}</Text>
        </Box>
      )
    }

    const children = [
      ...(view.title ? [<Box key="title" flexShrink={1}><Text dimColor wrap="truncate-end">{view.title}</Text></Box>] : []),
      ...(view.tiles.length > 0 ? [<Box key="tiles" flexDirection="row" gap={1} flexShrink={0}>{view.tiles.map(tile)}</Box>] : []),
      ...view.badges.map(badge),
      ...(view.detail ? [<Box key="detail" flexShrink={1}><Text dimColor wrap="truncate-end">{view.detail}</Text></Box>] : []),
      <Box key="spacer" flexGrow={1} />,
      ...(view.time ? [<Box key="time" flexShrink={0}><Text dimColor>{view.time}</Text></Box>] : []),
      ...view.actions.map(action => (
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
