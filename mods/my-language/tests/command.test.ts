import type { On } from 'claude-code'
import { expect, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'

// `/language`, driven through command.run with every fs call stubbed by path: the styles under the
// mod's output-styles/ folder are fake files, never the real placeholders; the settings file is
// <session root>/.claude/settings.local.json.

const ROOT = '/proj'
const SETTINGS = `${ROOT}/.claude/settings.local.json`
const STYLES_DIR = '/output-styles'

type Style = { file: string; name: string; description: string }
const ITE: Style = { file: 'ITE.md', name: 'ITE', description: 'Simplified technical Italian' }
const STE: Style = { file: 'STE.md', name: 'STE', description: 'Simplified technical English' }

type World = {
  styles?: Style[]
  /** The settings file: its text; or missing, or a stat or read failure. */
  settings?: string | { missing: true } | { statDenied: true } | { readDenied: true }
}

type Seen = {
  /** Every write the command made: path and text. */
  writes: { path: string; text: string }[]
  /** Every command registered, with its argument hint. */
  registered: { name: string; argumentHint?: string }[]
}

function styleText(s: Style): string {
  return `---\nname: ${s.name}\ndescription: ${s.description}\nkeep-coding-instructions: true\n---\n\nRules.\n`
}

// Stubs the calls beneath the plugin, dispatching by path; returns what the mod did.
function world(on: On, w: World = {}): Seen {
  const styles = w.styles ?? [ITE, STE]
  const settings = w.settings ?? { missing: true }
  const seen: Seen = { writes: [], registered: [] }
  on('session.root', () => ({ value: ROOT }))
  on('command.register', ($, e) => {
    seen.registered.push({ name: e.name, argumentHint: e.argumentHint })
    return { value: { command: e.name } }
  })
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('fs.list', ($, e) => {
    if (!e.path.endsWith(STYLES_DIR)) return { deny: `ENOENT: no folder ${e.path}` }
    const files = styles.map(s => ({ name: s.file, kind: 'file' as const, size: 1, mtimeMs: 0, isLink: false }))
    return { value: [...files, { name: 'notes', kind: 'dir' as const, size: 0, mtimeMs: 0, isLink: false }] }
  })
  on('fs.read', ($, e) => {
    if (e.path.includes(`${STYLES_DIR}/`)) {
      const s = styles.find(x => e.path.endsWith(`${STYLES_DIR}/${x.file}`))
      return s ? { value: styleText(s) } : { deny: `ENOENT: no file ${e.path}` }
    }
    if (e.path !== SETTINGS || typeof settings === 'object' && 'missing' in settings) return { deny: `ENOENT: no file ${e.path}` }
    if (typeof settings === 'object') return { deny: 'EACCES: permission denied' }
    return { value: settings }
  })
  on('fs.stat', ($, e) => {
    if (e.path !== SETTINGS || typeof settings === 'object' && 'missing' in settings) return { deny: 'ENOENT: no such file or directory' }
    if (typeof settings === 'object' && 'statDenied' in settings) return { deny: 'EACCES: permission denied' }
    return { value: { kind: 'file' as const, size: 10, mtimeMs: 0, isLink: false } }
  })
  on('fs.write', ($, e) => {
    seen.writes.push({ path: e.path, text: e.text })
    return { value: undefined }
  })
  return seen
}

async function language($: Engine, args = ''): Promise<{ text: string; exitCode?: number }> {
  const { text, exitCode } = await $.command.run({ command: 'language', args })
  return { text: String(text ?? ''), exitCode }
}

async function start($: Engine): Promise<void> {
  await $.session.start({ cwd: ROOT, surface: 'terminal', isInteractive: true })
}

// The single write's settings object.
function written(seen: Seen): unknown {
  expect(seen.writes.length).toBe(1)
  expect(seen.writes[0]!.path).toBe(SETTINGS)
  return JSON.parse(seen.writes[0]!.text)
}

// Discovery (I3)

test('a new style file appears with no code change', async ($, on) => {
  const FRA: Style = { file: 'FRA.md', name: 'FRA', description: 'Simplified technical French' }
  world(on, { styles: [ITE, STE, FRA] })
  await start($)
  const { text } = await language($)
  expect(text).toContain('ITE — Simplified technical Italian')
  expect(text).toContain('STE — Simplified technical English')
  expect(text).toContain('FRA — Simplified technical French')
})

test('the styles load on first use when the session start was missed', async ($, on) => {
  world(on, { styles: [STE] })
  const { text } = await language($)
  expect(text).toContain('STE — Simplified technical English')
  expect(text).not.toContain('ITE')
})

test('the hint lists the styles found', async ($, on) => {
  const FRA: Style = { file: 'FRA.md', name: 'FRA', description: 'Simplified technical French' }
  const seen = world(on, { styles: [STE, FRA, ITE] })
  await start($)
  const language = seen.registered.find(r => r.name === 'language')
  expect(language?.argumentHint).toBe('[FRA | ITE | STE | off]')
})

test('the hint follows the styles loaded again on first use', async ($, on) => {
  const FRA: Style = { file: 'FRA.md', name: 'FRA', description: 'Simplified technical French' }
  // The folder is empty at session start, then gains two styles, as after a hot reload.
  const folder: Style[] = []
  const seen = world(on, { styles: folder })
  await start($)
  expect(seen.registered.map(r => r.argumentHint)).toEqual(['[off]'])
  folder.push(STE, FRA)
  await language($)
  expect(seen.registered.map(r => r.argumentHint)).toEqual(['[off]', '[FRA | STE | off]'])
  await language($)
  expect(seen.registered.length).toBe(2)
})

// Switching (I1, I2)

test('a switch keeps every other key', async ($, on) => {
  const seen = world(on, { settings: '{"permissions":{"allow":["Bash(ls)"]},"outputStyle":"Explanatory","x":1}' })
  const { text } = await language($, 'STE')
  expect(text).toBe('Language: STE, from your next message.')
  expect(written(seen)).toEqual({ permissions: { allow: ['Bash(ls)'] }, outputStyle: 'my-language:STE', x: 1 })
})

test('a short name in any case and the full name both write the full name', async ($, on) => {
  const seen = world(on, { settings: '{}' })
  await language($, 'ste')
  await language($, 'my-language:STE')
  await language($, 'My-Language:ite')
  expect(seen.writes.map(w => JSON.parse(w.text).outputStyle)).toEqual(['my-language:STE', 'my-language:STE', 'my-language:ITE'])
})

test('off and default write default', async ($, on) => {
  const seen = world(on, { settings: '{"outputStyle":"my-language:ITE"}' })
  const off = await language($, 'off')
  await language($, 'DEFAULT')
  expect(off.text).toBe('Language: off, from your next message.')
  expect(seen.writes.map(w => JSON.parse(w.text))).toEqual([{ outputStyle: 'default' }, { outputStyle: 'default' }])
})

test('a missing file is created with the one key', async ($, on) => {
  const seen = world(on, { settings: { missing: true } })
  await language($, 'ITE')
  expect(written(seen)).toEqual({ outputStyle: 'my-language:ITE' })
})

test('an unknown name writes nothing and lists the valid names', async ($, on) => {
  const seen = world(on, { settings: '{}' })
  const { text, exitCode } = await language($, 'FRA')
  expect(seen.writes.length).toBe(0)
  expect(exitCode).not.toBe(0)
  expect(text).toContain('FRA')
  expect(text).toContain('ITE, STE, off')
})

test('invalid JSON writes nothing and says why', async ($, on) => {
  const seen = world(on, { settings: '{"a":1,' })
  const { text, exitCode } = await language($, 'STE')
  expect(seen.writes.length).toBe(0)
  expect(exitCode).not.toBe(0)
  expect(text).toContain('invalid JSON')
})

for (const settings of ['[1,2]', 'null', '"STE"']) {
  test(`valid JSON that is not an object writes nothing: ${settings}`, async ($, on) => {
    const seen = world(on, { settings })
    const { text } = await language($, 'STE')
    expect(seen.writes.length).toBe(0)
    expect(text).toContain('not a JSON object')
  })
}

test('a stat error other than a missing file writes nothing', async ($, on) => {
  const seen = world(on, { settings: { statDenied: true } })
  const { text } = await language($, 'STE')
  expect(seen.writes.length).toBe(0)
  expect(text).toContain('EACCES')
})

test('a read error writes nothing', async ($, on) => {
  const seen = world(on, { settings: { readDenied: true } })
  const { text } = await language($, 'STE')
  expect(seen.writes.length).toBe(0)
  expect(text).toContain('cannot read')
  expect(text).toContain('EACCES')
})

// Listing (I3)

test('the list marks the active style', async ($, on) => {
  const seen = world(on, { settings: '{"outputStyle":"my-language:STE"}' })
  const { text } = await language($)
  const lines = text.split('\n')
  expect(lines).toContain('* STE — Simplified technical English')
  expect(lines).toContain('  ITE — Simplified technical Italian')
  expect(lines).toContain('  off — no language rule')
  expect(text).toContain('active: STE')
  expect(seen.writes.length).toBe(0)
})

test('the list marks off when the folder says default', async ($, on) => {
  world(on, { settings: '{"outputStyle":"default"}' })
  const lines = (await language($)).text.split('\n')
  expect(lines).toContain('* off — no language rule')
  expect(lines.filter(l => l.startsWith('*')).length).toBe(1)
})

test('the list shows another style unmarked, by its name', async ($, on) => {
  world(on, { settings: '{"outputStyle":"Explanatory"}' })
  const { text } = await language($)
  expect(text.split('\n').filter(l => l.startsWith('*')).length).toBe(0)
  expect(text).toContain('active: Explanatory (not a my-language style)')
})

test('a bare style name in the file is not a my-language style', async ($, on) => {
  world(on, { settings: '{"outputStyle":"STE"}' })
  const { text } = await language($)
  expect(text.split('\n').filter(l => l.startsWith('*')).length).toBe(0)
  expect(text).toContain('active: STE (not a my-language style)')
})

test('the list starts on its own line, after the prefix Claude Code prints', async ($, on) => {
  world(on, { settings: '{"outputStyle":"my-language:STE"}' })
  const { text } = await language($)
  expect(text.startsWith('\n  ITE — Simplified technical Italian\n')).toBe(true)
})

test('the list says user default when the folder sets no style', async ($, on) => {
  world(on, { settings: '{"x":1}' })
  const { text } = await language($)
  expect(text.split('\n').filter(l => l.startsWith('*')).length).toBe(0)
  expect(text).toContain('active: user default')
})

test('the list says unknown when the settings file is not valid JSON', async ($, on) => {
  world(on, { settings: '{"outputStyle":' })
  const { text } = await language($)
  expect(text).toContain('  ITE — Simplified technical Italian')
  expect(text).toContain('active: unknown (invalid JSON')
})
