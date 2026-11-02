import type { EngineInterface, Register } from 'claude-code'

// The my-language mod: `/language` switches the output style of this folder. It hooks no prompt event.

const PLUGIN = 'my-language'

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

export const register: Register = on => {
  // Read at session start; loaded again on first use when empty (a hot reload or a missed start).
  let styles: Style[] = []

  on('session.start', async ($, e, next) => {
    styles = await loadStyles($)
    await $.command.register({ name: 'language', description: "Choose the language and style of Claude's replies" })
    return next(e)
  })

  on('command.run', { command: 'language' }, async $ => {
    if (styles.length === 0) styles = await loadStyles($)
    return { text: styles.map(s => `${s.name} — ${s.description}`).join('\n') }
  })
}
