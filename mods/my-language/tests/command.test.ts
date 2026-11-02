import type { On } from 'claude-code'
import { expect, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'

// `/language`, driven through command.run with every fs call stubbed by path: the styles under the
// mod's output-styles/ folder are fake files, never the real placeholders.

const ROOT = '/proj'
const SETTINGS = `${ROOT}/.claude/settings.local.json`
const STYLES_DIR = '/output-styles'

type Style = { file: string; name: string; description: string }
const ITE: Style = { file: 'ITE.md', name: 'ITE', description: 'Simplified technical Italian' }
const STE: Style = { file: 'STE.md', name: 'STE', description: 'Simplified technical English' }

type World = {
  styles?: Style[]
  /** The settings file: its text; 'missing'; or a stat or read failure. */
  settings?: string | 'missing' | 'stat-denied' | 'read-denied'
}

function styleText(s: Style): string {
  return `---\nname: ${s.name}\ndescription: ${s.description}\nkeep-coding-instructions: true\n---\n\nRules.\n`
}

// Stubs the calls beneath the plugin; returns the settings writes the command made.
function world(on: On, w: World): { path: string; text: string }[] {
  const styles = w.styles ?? [ITE, STE]
  const settings = w.settings ?? 'missing'
  const writes: { path: string; text: string }[] = []
  on('session.root', () => ({ value: ROOT }))
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('fs.list', ($, e) => {
    if (!e.path.endsWith(STYLES_DIR)) return { deny: `ENOENT: no folder ${e.path}` }
    return { value: [...styles.map(s => ({ name: s.file, kind: 'file' as const, size: 1, mtimeMs: 0, isLink: false })), { name: 'notes', kind: 'dir' as const, size: 0, mtimeMs: 0, isLink: false }] }
  })
  on('fs.read', ($, e) => {
    if (e.path.includes(`${STYLES_DIR}/`)) {
      const s = styles.find(x => e.path.endsWith(`${STYLES_DIR}/${x.file}`))
      return s ? { value: styleText(s) } : { deny: `ENOENT: no file ${e.path}` }
    }
    if (e.path === SETTINGS && typeof settings === 'string' && !['missing', 'stat-denied', 'read-denied'].includes(settings)) return { value: settings }
    if (e.path === SETTINGS && settings === 'read-denied') return { deny: 'EACCES: permission denied' }
    return { deny: `ENOENT: no file ${e.path}` }
  })
  on('fs.stat', ($, e) => {
    if (e.path !== SETTINGS || settings === 'missing') return { deny: 'ENOENT: no such file or directory' }
    if (settings === 'stat-denied') return { deny: 'EACCES: permission denied' }
    return { value: { kind: 'file' as const, size: 10, mtimeMs: 0, isLink: false } }
  })
  on('fs.write', ($, e) => {
    writes.push({ path: e.path, text: e.text })
    return { value: undefined }
  })
  return writes
}

async function language($: Engine, args = ''): Promise<string> {
  const { text } = await $.command.run({ command: 'language', args })
  return String(text ?? '')
}

test('a new style file appears with no code change', async ($, on) => {
  const FRA: Style = { file: 'FRA.md', name: 'FRA', description: 'Simplified technical French' }
  world(on, { styles: [ITE, STE, FRA] })
  await $.session.start({ cwd: ROOT, surface: 'terminal', isInteractive: true })
  const text = await language($)
  expect(text).toContain('ITE — Simplified technical Italian')
  expect(text).toContain('STE — Simplified technical English')
  expect(text).toContain('FRA — Simplified technical French')
})

test('the styles load on first use when the session start was missed', async ($, on) => {
  world(on, { styles: [STE] })
  const text = await language($)
  expect(text).toContain('STE — Simplified technical English')
  expect(text).not.toContain('ITE')
})
