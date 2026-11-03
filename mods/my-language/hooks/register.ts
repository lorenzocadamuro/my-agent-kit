import type { EngineInterface, Register } from 'claude-code'

// The my-language mod: `/language` switches the output style of this folder by writing `outputStyle`
// into <project root>/.claude/settings.local.json, the file `/output-style` writes; Claude Code picks
// the change up through its settings watcher, from the next message. Without an argument it lists the
// styles and the active one, read from every settings source. It hooks no prompt event.

const PLUGIN = 'my-language'
const OFF = 'off'
// The value that selects Claude Code's Default style; `/language default` is an alias of `off`.
const DEFAULT = 'default'

/** One output style this mod ships, as its front matter names it. */
type Style = { name: string; fullName: string; description: string }

// The `key: value` lines between a file's first two `---` lines, quotes removed.
function frontMatter(text: string): Record<string, string> {
  const lines = text.split(/\r?\n/)
  if (lines[0]?.trim() !== '---') return {}
  const fields: Record<string, string> = {}
  for (const line of lines.slice(1)) {
    if (line.trim() === '---') break
    const match = line.match(/^([A-Za-z0-9_-]+):\s*(.*?)\s*$/)
    if (match) fields[match[1]!] = match[2]!.replace(/^(["'])(.*)\1$/, '$2')
  }
  return fields
}

// Every style in the mod's output-styles/ folder, by its front matter name (packs.test.sh requires one).
async function loadStyles($: EngineInterface): Promise<Style[]> {
  const dir = `${$.plugin.root}/output-styles`
  let entries: Awaited<ReturnType<EngineInterface['fs']['list']>>
  try {
    entries = await $.fs.list(dir)
  } catch {
    return []
  }
  const styles: Style[] = []
  for (const entry of entries) {
    if (entry.kind !== 'file' || !entry.name.endsWith('.md')) continue
    let text: string
    try {
      text = String(await $.fs.read(`${dir}/${entry.name}`))
    } catch {
      continue
    }
    const { name, description } = frontMatter(text)
    if (!name) continue
    styles.push({ name, fullName: `${PLUGIN}:${name}`, description: description ?? '' })
  }
  return styles.sort((a, b) => a.name.localeCompare(b.name))
}

function isMissing(err: unknown): boolean {
  const code = (err as { code?: unknown } | null)?.code
  const message = (err as { message?: unknown } | null)?.message ?? err
  return code === 'ENOENT' || /ENOENT/.test(String(message))
}

function reasonOf(err: unknown): string {
  return String((err as { message?: unknown } | null)?.message ?? err)
}

type Loaded = { settings: Record<string, unknown> } | { error: string }

// Reads the folder's settings file. Only a file that does not exist counts as {}; any other failure,
// invalid JSON, or JSON that is not an object is an error, so nothing gets written over it.
async function loadSettings($: EngineInterface, path: string): Promise<Loaded> {
  try {
    await $.fs.stat(path)
  } catch (err) {
    if (isMissing(err)) return { settings: {} }
    return { error: `cannot stat ${path}: ${reasonOf(err)}` }
  }
  let text: string
  try {
    text = String(await $.fs.read(path))
  } catch (err) {
    return { error: `cannot read ${path}: ${reasonOf(err)}` }
  }
  let parsed: unknown
  try {
    parsed = JSON.parse(text)
  } catch (err) {
    return { error: `invalid JSON in ${path}: ${reasonOf(err)}` }
  }
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) return { error: `${path} holds valid JSON but not a JSON object` }
  return { settings: parsed as Record<string, unknown> }
}

async function settingsPath($: EngineInterface): Promise<string> {
  return `${await $.session.root()}/.claude/settings.local.json`
}

// The other settings sources, read through Claude Code: policy and flag win over the folder's file,
// project and user only fill in when it sets no style.
type Source = 'policy' | 'flag' | 'project' | 'user'
const ABOVE: Source[] = ['policy', 'flag']
const BELOW: Source[] = ['project', 'user']
const SOURCE_LABEL: Record<Source, string> = {
  policy: 'managed settings',
  flag: 'command-line settings',
  project: 'project settings',
  user: 'user default',
}

// The outputStyle one source sets (undefined when none), or why it could not be read.
async function styleIn($: EngineInterface, source: Source): Promise<{ value: unknown } | { error: string }> {
  try {
    return { value: (await $.settings.read({ source })).outputStyle }
  } catch (err) {
    return { error: `cannot read ${source} settings: ${reasonOf(err)}` }
  }
}

// The first source in order that sets a style, and the reasons of the sources that could not be read.
async function firstStyle($: EngineInterface, sources: Source[]): Promise<{ value?: unknown; from?: Source; errors: string[] }> {
  const errors: string[] = []
  for (const source of sources) {
    const found = await styleIn($, source)
    if ('error' in found) errors.push(found.error)
    else if (found.value !== undefined) return { value: found.value, from: source, errors }
  }
  return { errors }
}

const names = (styles: Style[]): string[] => [...styles.map(s => s.name), OFF]
const hintOf = (styles: Style[]): string => `[${names(styles).join(' | ')}]`

// The style a name means: a style's short or full name, `off` or `default`, in any case.
function resolve(styles: Style[], given: string): { label: string; value: string } | undefined {
  const key = given.toLowerCase()
  if (key === OFF || key === DEFAULT) return { label: OFF, value: DEFAULT }
  const style = styles.find(s => s.name.toLowerCase() === key || s.fullName.toLowerCase() === key)
  return style && { label: style.name, value: style.fullName }
}

// The styles and `off`, the active one marked, then the active style and the source that sets it.
async function list($: EngineInterface, styles: Style[]): Promise<string> {
  const loaded = await loadSettings($, await settingsPath($))
  let value: unknown
  let from: Source | undefined
  let errors: string[] = []
  if ('settings' in loaded) {
    const above = await firstStyle($, ABOVE)
    if (above.from) ({ value, from } = above)
    else {
      value = loaded.settings.outputStyle
      if (value === undefined) ({ value, from, errors } = await firstStyle($, BELOW))
      errors = [...above.errors, ...errors]
    }
  }
  const marked = value === DEFAULT ? OFF : styles.find(s => s.fullName === value)?.name
  let active: string
  if ('error' in loaded) active = `unknown (${loaded.error})`
  else if (value === undefined) active = errors.length ? `unknown (${errors.join('; ')})` : 'Default (no style)'
  else {
    // A value this mod did not write (a bare "STE", another plugin's style): Claude Code may not resolve it.
    active = marked ?? `${String(value)} (not a my-language style)`
    if (from) active += ` (${SOURCE_LABEL[from]})`
  }
  const rows = [...styles.map(s => ({ name: s.name, description: s.description })), { name: OFF, description: 'no language rule' }]
  const lines = rows.map(r => `${r.name === marked ? '*' : ' '} ${r.name} — ${r.description}`)
  // Claude Code prefixes the output with "my-language: ", so the list starts on the next line.
  return ['', ...lines, '', `active: ${active}`].join('\n')
}

async function switchTo($: EngineInterface, styles: Style[], given: string): Promise<{ text: string; exitCode?: number }> {
  const target = resolve(styles, given)
  if (!target) return { text: `Unknown language "${given}": nothing written. Choose one of: ${names(styles).join(', ')}.`, exitCode: 2 }
  const path = await settingsPath($)
  const loaded = await loadSettings($, path)
  if ('error' in loaded) return { text: `${loaded.error}: nothing written.`, exitCode: 1 }
  try {
    await $.fs.write(path, `${JSON.stringify({ ...loaded.settings, outputStyle: target.value }, null, 2)}\n`)
  } catch (err) {
    return { text: `cannot write ${path}: ${reasonOf(err)}`, exitCode: 1 }
  }
  return { text: `Language: ${target.label}, from your next message.` }
}

// Declares `/language` with the styles as its argument hint; registering the name again replaces it.
async function registerCommand($: EngineInterface, styles: Style[]): Promise<string> {
  const argumentHint = hintOf(styles)
  await $.command.register({ name: 'language', description: "Choose the language and style of Claude's replies", argumentHint })
  return argumentHint
}

export const register: Register = on => {
  // Read at session start; loaded again on first use when empty (a hot reload or a missed start).
  let styles: Style[] = []
  // The argument hint last registered.
  let hint: string | undefined

  on('session.start', async ($, e, next) => {
    styles = await loadStyles($)
    hint = await registerCommand($, styles)
    return next(e)
  })

  on('command.run', { command: 'language' }, async ($, e) => {
    if (styles.length === 0) {
      styles = await loadStyles($)
      if (hintOf(styles) !== hint) hint = await registerCommand($, styles)
    }
    const given = String(e.args ?? '').trim()
    if (!given) return { text: await list($, styles) }
    return switchTo($, styles, given)
  })
}
