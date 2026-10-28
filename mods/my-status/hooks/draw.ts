import type { AgentView, Part, Step } from '../types'
import type { BandModel, State } from './adapter'
import { minutes } from './adapter'

// The band's pictures on the desktop, after band-design/spec.md (round 2 and the R3 changes) and tools/gen.py:
// header, track, steps, agents' head, agents. Each is one SVG with a transparent background, laid out to the CSS px, its gap to
// the picture above as its own top padding; colours switch with prefers-color-scheme inside the picture. Text is the
// system font. Every picture is `W` wide and shares one alignment line at x = `A`: the state word, line 2, the
// capsules and their letters, the agents' text and (natively) the buttons start there; marks hang left of it.

export type Pic = { source: string; w: number; h: number; alt: string }

const FONT = "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', system-ui, sans-serif"
const MONO = "'SF Mono', ui-monospace, Menlo, monospace"
const SEP = '  ·  '
// widths are estimated (no measuring call): a crude advance table, then this margin before deciding a text fits
const FIT = 1.07

// t1-t3 text; green..violet the state colours (word, dots, wash); the deeper segment and chip fills (R3) sDone..sEmpty,
// with the numbers on them (num, numEmpty); the agents divider (rule) and the disclosure chevrons (chev)
type Tok = 't1' | 't2' | 't3' | 'green' | 'blue' | 'amber' | 'red' | 'violet' | 'sDone' | 'sRun' | 'sNeeds' | 'sStop' | 'sPlan' | 'sEmpty' | 'num' | 'numEmpty' | 'rule' | 'chev' | 'pPri' | 'pPriText' | 'pPriH' | 'pSec' | 'pSecText' | 'pSecLine' | 'pSecH' | 'sc' | 'sf'
const DARK: Record<Exclude<Tok, 'sc' | 'sf'>, string> = {
  t1: '#ECEAE3',
  t2: '#ABA89F',
  t3: '#7F7C75',
  green: '#5BAA80',
  blue: '#5E9BF2',
  amber: '#E4A84C',
  red: '#E5695D',
  violet: '#A897F2',
  sDone: '#3F8A63',
  sRun: '#3D7BD9',
  sNeeds: '#A8761F',
  sStop: '#C24E45',
  sPlan: '#7B68D6',
  sEmpty: '#383836',
  num: 'rgba(255,255,255,0.9)',
  numEmpty: '#8A877F',
  rule: 'rgba(255,255,255,0.08)',
  chev: '#9C998F',
  pPri: '#E8E6E0',
  pPriText: '#1F1E1D',
  pPriH: '#FFFFFF',
  pSec: '#383837',
  pSecText: '#ECEAE3',
  pSecLine: '#383837',
  pSecH: '#444442',
}
const LIGHT: typeof DARK = {
  t1: '#1F1E1D',
  t2: '#5F5E5A',
  t3: '#8D8B84',
  green: '#2E8A5C',
  blue: '#2F6FD6',
  amber: '#B7700A',
  red: '#C4402F',
  violet: '#6B55C9',
  sDone: '#2E8A5C',
  sRun: '#2F6FD6',
  sNeeds: '#B7700A',
  sStop: '#C4402F',
  sPlan: '#6B55C9',
  sEmpty: '#ECE9E1',
  num: 'rgba(255,255,255,0.95)',
  numEmpty: '#8D8B84',
  rule: 'rgba(0,0,0,0.09)',
  chev: '#7A7872',
  pPri: '#1F1E1D',
  pPriText: '#FFFFFF',
  pPriH: '#000000',
  pSec: '#FFFFFF',
  pSecText: '#1F1E1D',
  pSecLine: '#D9D6CC',
  pSecH: '#F5F4EE',
}
type Base = Exclude<Tok, 'sc' | 'sf'>
const STATE_TOK: Record<State, Base> = { planning: 'violet', ready: 't1', running: 'blue', needs_you: 'amber', stopped: 'red', done: 'green' }
// the current segment's fill per state (Ready has no current segment: its next step is outlined)
const STATE_FILL: Record<State, Base> = { planning: 'sPlan', ready: 'sRun', running: 'sRun', needs_you: 'sNeeds', stopped: 'sStop', done: 'sDone' }

function style(state: State): string {
  const css = (pal: typeof DARK) =>
    Object.entries({ ...pal, sc: pal[STATE_TOK[state]], sf: pal[STATE_FILL[state]] })
      .map(([k, v]) => `.f-${k}{fill:${v}}.s-${k}{stroke:${v}}.c-${k}{stop-color:${v}}`)
      .join('')
  return `<style>${css(DARK)}@media (prefers-color-scheme: light){${css(LIGHT)}}.tn{font-variant-numeric:tabular-nums}${STILL_CSS}</style>`
}

// The "working now" pulse (round 6): opacity 1 -> 0.45 -> 1 over 2 s, ease-in-out, SMIL, as plan-progress twinkles its
// dots in plain pictures (MIT). A pulsing element is drawn twice, a moving copy (mv) and a still one (sv), shown only
// under reduced motion, in its place. `pulse` is the begin offset in seconds, -(now mod 2 s), so every picture drawn
// at one moment shares a phase and a redraw continues the cycle where the clock has it rather than restarting it.
export const PULSE_MS = 2000
export const pulseBegin = (now: number) => -((now % PULSE_MS) / 1000)
const STILL_CSS = '.sv{display:none}@media (prefers-reduced-motion: reduce){.mv{display:none}.sv{display:inline}}'
function pulsed(markup: string, pulse: number | undefined): string {
  if (pulse === undefined) return markup
  const anim = `<animate attributeName="opacity" values="1;0.45;1" keyTimes="0;0.5;1" calcMode="spline" keySplines=".42 0 .58 1;.42 0 .58 1" dur="${PULSE_MS / 1000}s" begin="${pulse.toFixed(3)}s" repeatCount="indefinite"/>`
  return `<g class="mv">${anim}${markup}</g><g class="sv">${markup}</g>`
}

const esc = (t: string) => t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
const r1 = (n: number) => Math.round(n * 10) / 10

/** Estimated advance of a text in the system UI font, as gen.py's table. */
export function tw(text: string, size: number, weight = 400): number {
  let w = 0
  for (const ch of text) {
    const k =
      "iljtfr.,:;'|!·".includes(ch) ? 0.3
      : ch === ' ' ? 0.28
      : 'mwMW'.includes(ch) ? 0.85
      : ch >= 'A' && ch <= 'Z' ? 0.66
      : ch >= '0' && ch <= '9' ? 0.6
      : '–—…<'.includes(ch) ? 0.7
      : 0.54
    w += k * size
  }
  return w * (weight >= 600 ? 1.05 : 1)
}
const fits = (text: string, size: number, room: number, weight = 400) => tw(text, size, weight) * FIT <= room

/** Lines of `text` within `room` px, broken at spaces only; a word wider than the room stays whole on its line. */
export function wrap(text: string, size: number, room: number, weight = 400): string[] {
  const lines: string[] = []
  let cur = ''
  for (const word of text.split(/\s+/).filter(Boolean)) {
    const cand = cur ? `${cur} ${word}` : word
    if (!cur || fits(cand, size, room, weight)) cur = cand
    else {
      lines.push(cur)
      cur = word
    }
  }
  if (cur) lines.push(cur)
  return lines.length ? lines : ['']
}

type TextOpts = { weight?: number; anchor?: 'start' | 'middle' | 'end'; family?: string; tabular?: boolean; opacity?: number }
function txt(x: number, y: number, s: string, size: number, tok: Tok, o: TextOpts = {}): string {
  return (
    `<text x="${r1(x)}" y="${r1(y)}" font-family="${o.family ?? FONT}" font-size="${size}" font-weight="${o.weight ?? 400}"` +
    `${o.anchor && o.anchor !== 'start' ? ` text-anchor="${o.anchor}"` : ''} class="f-${tok}${o.tabular ? ' tn' : ''}">${esc(s)}</text>`
  )
}

function svg(state: State, w: number, h: number, body: string, defs = ''): string {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${style(state)}${defs ? `<defs>${defs}</defs>` : ''}${body}</svg>`
}

/** The same picture with `px` more transparent room at its bottom: the gap to a native row below it. */
export function padBottom(pic: Pic, px: number): Pic {
  const h = pic.h + px
  const source = pic.source.replace(/^<svg ([^>]*?)height="\d+(\.\d+)?" viewBox="0 0 (\S+) \S+">/, `<svg $1height="${h}" viewBox="0 0 $3 ${h}">`)
  return { ...pic, source, h }
}

// ---------- header ----------

/**
 * Picture 1: state mark and word, line 2, the figures; 48 px, more when line 2 wraps or the figures go under it. The
 * figures are as large as the state word (14 / 600), their captions 11.
 */
export function headerPic(m: BandModel, W: number, A: number, isNarrowBand: boolean, pulse?: number): Pic {
  const out: string[] = []
  const defs: string[] = []
  const stacks = m.metrics.map(x => ({ ...x, w: Math.max(tw(x.value, 14, 600), tw(x.caption, 11)) * FIT }))
  const metricsW = stacks.reduce((a, s) => a + s.w, 0) + 28 * Math.max(0, stacks.length - 1)
  const room = isNarrowBand ? W - A : W - A - metricsW - 24

  // line 2: drop the trailing pieces by rank until it fits; the bold first piece stays, wrapping if it must
  const width = (ps: BandModel['line2']) => ps.reduce((a, p, i) => a + tw((i ? SEP : '') + p.text, 12.5, p.role === 't1' ? 600 : 400) * FIT, 0)
  let pieces = m.line2
  for (const rank of [1, 2, 3]) if (width(pieces) > room) pieces = pieces.filter(p => p.rank !== rank)
  let lines: string[] = []
  if (width(pieces) > room) {
    pieces = pieces.slice(0, 1)
    lines = wrap(pieces[0]?.text ?? '', 12.5, room, 600)
  }
  let H = 48 + 16 * Math.max(0, lines.length - 1)

  const attention = m.state === 'needs_you' || m.state === 'stopped'
  if (attention) {
    defs.push(`<linearGradient id="wash" x1="0" x2="1" y1="0" y2="0"><stop offset="0" class="c-sc" stop-opacity="0.16"/><stop offset="1" class="c-sc" stop-opacity="0"/></linearGradient>`)
    const x0 = Math.max(0, A - 14)
    out.push(`<rect x="${r1(x0)}" y="0" width="${r1((W - x0) * 0.62)}" height="${H}" rx="8" fill="url(#wash)"/>`)
    out.push(`<rect x="${r1(A - 11.5)}" y="8" width="3" height="32" rx="1.5" class="f-sc"/>`)
  } else if (m.state === 'ready') {
    out.push(`<circle cx="${r1(A - 10)}" cy="17" r="3.6" fill="none" class="s-sc" stroke-width="1.6"/>`)
  } else if (m.state === 'done') {
    out.push(`<circle cx="${r1(A - 10)}" cy="17" r="5" class="f-sc"/><path d="M${r1(A - 12.4)} 17 l1.7 1.8 l3 -3.4" fill="none" class="s-num" stroke-width="1.4" stroke-linecap="round"/>`)
  } else {
    out.push(pulsed(`<circle cx="${r1(A - 10)}" cy="17" r="4" class="f-sc"/>`, m.state === 'running' ? pulse : undefined))
  }
  out.push(txt(A, 22, m.word, 14, 'sc', { weight: 600 }))
  if (lines.length > 0) {
    lines.forEach((ln, i) => out.push(txt(A, 40 + i * 16, ln, 12.5, 't1', { weight: 600 })))
  } else {
    const spans = pieces.map((p, i) => `<tspan class="f-${p.role}" font-weight="${p.role === 't1' ? 600 : 400}">${esc((i ? SEP : '') + p.text)}</tspan>`).join('')
    out.push(`<text xml:space="preserve" x="${r1(A)}" y="40" font-family="${FONT}" font-size="12.5">${spans}</text>`)
  }
  if (isNarrowBand) {
    let x = A
    const y = H
    for (const s of stacks) {
      out.push(txt(x, y + 16, s.value, 14, s.muted ? 't2' : 't1', { weight: 600, tabular: true }))
      out.push(txt(x, y + 32, s.caption, 11, 't3'))
      x += s.w + 28
    }
    H += 38
  } else {
    let cur = W
    for (const s of [...stacks].reverse()) {
      out.push(txt(cur, 22, s.value, 14, s.muted ? 't2' : 't1', { weight: 600, anchor: 'end', tabular: true }))
      out.push(txt(cur, 40, s.caption, 11, 't3', { anchor: 'end' }))
      cur -= s.w + 28
    }
  }
  const alt = `${m.word}: ${m.line2.map(p => p.text).join(', ')}; ${m.metrics.map(x => `${x.value} ${x.caption}`).join(', ')}`
  return { source: svg(m.state, W, H, out.join(''), defs.join('')), w: W, h: H, alt }
}

// ---------- plan: the track (capsules) and, when open, the steps under them ----------

type Role = 'done' | 'cur' | 'todo'
function roleOf(p: Part): Role {
  if (p.steps.every(s => s.status === 'done')) return 'done'
  if (p.steps.some(s => s.status === 'running' || s.status === 'failed' || s.status === 'next')) return 'cur'
  return 'todo'
}
const segTok = (s: Step): Tok => (s.status === 'done' ? 'sDone' : s.status === 'running' ? 'sf' : s.status === 'failed' ? 'sStop' : 'sEmpty')
const isFilled = (s: Step) => s.status === 'done' || s.status === 'running' || s.status === 'failed'
const num = (x: number, y: number, n: string, filled: boolean) => txt(x, y, n, 10, filled ? 'num' : 'numEmpty', { weight: 600, anchor: 'middle' })
const CAP_H = 16

/** The disclosure chevron, 8 x 8, centred on (cx, cy): down when open, right when closed. */
function chevron(cx: number, cy: number, isOpen: boolean, tok: Tok = 'chev'): string {
  const d = isOpen ? `M${r1(cx - 4)} ${r1(cy - 2)} l4 4 l4 -4` : `M${r1(cx - 2)} ${r1(cy - 4)} l4 4 l-4 4`
  return `<path d="${d}" fill="none" class="s-${tok}" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>`
}

/**
 * What lights up under the pointer, drawn alone on a transparent picture of the same size, to lie over the picture it
 * lights: the chevron in `t1` (the track), or the chevron and "Background agents" (the agents' head). The keyed Box
 * around both reveals it while hovered (round 4); the rest of the picture stays as it is.
 */
export function litPic(state: State, W: number, h: number, A: number, cy: number, isOpen: boolean, words?: { text: string; baseline: number }): Pic {
  const body = chevron(A - 10, cy, isOpen, 't1') + (words ? txt(A, words.baseline, words.text, 11.5, 't1', { weight: 600 }) : '')
  return { source: svg(state, W, h, body), w: W, h, alt: '' }
}

/**
 * A small button drawn as a picture (round 4): 24 px tall, radius 7, the label 12.5 / 500 with 12 px a side, in the
 * secondary or primary look, `isLit` the look under the pointer. A blank Button lies over it and takes the press.
 */
export function pillPic(state: State, label: string, kind: 'primary' | 'secondary', isLit: boolean): Pic {
  const w = Math.ceil(tw(label, 12.5, 500) * FIT + 24)
  const h = 26
  const fill: Tok = kind === 'primary' ? (isLit ? 'pPriH' : 'pPri') : isLit ? 'pSecH' : 'pSec'
  const text: Tok = kind === 'primary' ? 'pPriText' : 'pSecText'
  const body =
    `<rect x="0.5" y="1.5" width="${w - 1}" height="23" rx="7" class="f-${fill}${kind === 'secondary' ? ' s-pSecLine' : ''}"/>` +
    txt(w / 2, 17.4, label, 12.5, text, { weight: 500, anchor: 'middle' })
  return { source: svg(state, w, h, body), w, h, alt: isLit ? '' : label }
}

/** A note in the action row, amber, as a picture beside the pills: "Conflicts with main", "Answer in the chat below ↓". */
export function notePic(state: State, label: string): Pic {
  const w = Math.ceil(tw(label, 12.5) * FIT + 4)
  return { source: svg(state, w, 26, txt(0, 17.4, label, 12.5, 'amber')), w, h: 26, alt: label }
}

/**
 * One capsule: a segment per step, 2 px apart, split whether done or not. Steps closed it is a thin 8 px bar with no
 * numbers; open, 16 px with each step's number (none under 12 px). Its bottom stays put: it grows upward (round 5).
 */
function capsule(id: string, x: number, top: number, w: number, p: Part, isOpen: boolean, defs: string[], pulse?: number): string {
  const h = isOpen ? CAP_H : 8
  const y = top + CAP_H - h
  defs.push(`<clipPath id="${id}"><rect x="${r1(x)}" y="${y}" width="${r1(w)}" height="${h}" rx="4"/></clipPath>`)
  const k = p.steps.length
  const sw = (w - 2 * (k - 1)) / k
  const g = [`<g clip-path="url(#${id})">`]
  p.steps.forEach((s, j) => {
    const sx = x + j * (sw + 2)
    // the step under way pulses, with its number (only in Running: `pulse` is set then alone)
    const seg =
      `<rect x="${r1(sx)}" y="${y}" width="${r1(sw)}" height="${h}" class="f-${segTok(s)}"/>` +
      (isOpen && sw >= 12 && !p.name ? num(sx + sw / 2, y + 11.6, String(j + 1), isFilled(s)) : '')
    g.push(pulsed(seg, s.status === 'running' ? pulse : undefined))
    if (s.status === 'next') g.push(`<rect x="${r1(sx + 0.75)}" y="${y + 0.75}" width="${r1(sw - 1.5)}" height="${h - 1.5}" rx="${isOpen ? 3 : 2.5}" fill="none" class="s-t1" stroke-width="1.5"/>`)
  })
  g.push('</g>')
  return g.join('')
}

/** A 16 px chip: the same fill and number as its segment, the segment large; or a later part's chip at L2. */
function chip(x: number, y: number, n: string, s: Step | 'todo-all'): string {
  if (s === 'todo-all') return `<rect x="${r1(x)}" y="${r1(y)}" width="16" height="16" rx="4" class="f-sEmpty"/>${num(x + 8, y + 11.6, n, false)}`
  const outline = s.status === 'next' ? `<rect x="${r1(x + 0.75)}" y="${r1(y + 0.75)}" width="14.5" height="14.5" rx="3.5" fill="none" class="s-t1" stroke-width="1.5"/>` : ''
  return `<rect x="${r1(x)}" y="${r1(y)}" width="16" height="16" rx="4" class="f-${segTok(s)}"/>${outline}${num(x + 8, y + 11.6, n, isFilled(s))}`
}
const labelTok = (s: Step): Tok => (s.status === 'done' ? 't2' : s.status === 'todo' ? 't3' : 't1')
const labelWeight = (s: Step) => (s.status === 'running' || s.status === 'failed' || s.status === 'next' ? 600 : 400)
const columnWidth = (m: BandModel, W: number, A: number) => (W - A - 12 * (m.parts.length - 1)) / m.parts.length
/** Whether the open steps are one row per part: under 88 px a column, or in a band under 560 px. */
export const isRowsView = (m: BandModel, W: number, A: number, isNarrowBand: boolean) => isNarrowBand || columnWidth(m, W, A) < 88

/** Where the track's chevron sits: centred on the capsules, thin (closed) or tall (open). */
export const trackChevronY = (isOpen: boolean) => 10 + (isOpen ? 8 : 12)

/**
 * Picture 2, the track: the capsules from A to the right edge, the parts sharing it equally, 10 px under the header,
 * then the label row under them: each part's letter (in the state colour for the current part) and its short title,
 * or Planning's step names. The label row is one element, the same text in the same place whether the steps are
 * open or not (round 5); only the capsules change, growing upward from 8 to 16 px and showing their numbers. 48 px.
 * The steps chevron hangs left of the capsules when there are steps to open; the picture is the toggle's hit area.
 */
export function trackPic(m: BandModel, W: number, A: number, isOpen: boolean, hasToggle: boolean, pulse?: number): Pic {
  const TOP = 10
  const out: string[] = []
  const defs: string[] = []
  const n = m.parts.length
  const pw = columnWidth(m, W, A)
  const open = isOpen && !m.isPlanning
  if (hasToggle) out.push(chevron(A - 10, trackChevronY(open), open))
  m.parts.forEach((p, i) => out.push(capsule(`c${i}`, A + i * (pw + 12), TOP, pw, p, open, defs, m.state === 'running' ? pulse : undefined)))
  out.push(`<g class="labels">${m.parts.map((p, i) => partLabel(p, A + i * (pw + 12), TOP + CAP_H + 16, pw)).join('')}</g>`)
  const H = TOP + CAP_H + 22
  const alt = `Plan: ${m.parts.map(p => `${p.name ?? `Part ${p.letter}`} ${p.steps.filter(s => s.status === 'done').length} of ${p.steps.length}`).join(', ')}`
  return { source: svg(m.state, W, H, out.join(''), defs.join('')), w: W, h: H, alt: n > 0 ? alt : 'Plan' }
}

/** A part's label under its capsule: letter 12 / 650 and short title 12 `t3` when it fits whole, else the letter. */
function partLabel(p: Part, x: number, y: number, room: number): string {
  const isCur = roleOf(p) === 'cur'
  if (p.name) return txt(x, y, p.name, 12, isCur ? 'sc' : 't3', { weight: isCur ? 650 : 500 })
  const headW = tw(p.letter, 12, 650) + 8
  const title = p.short && headW + tw(p.short, 12) * FIT <= room ? txt(x + headW, y, p.short, 12, 't3') : ''
  return txt(x, y, p.letter, 12, isCur ? 'sc' : 't1', { weight: 650 }) + title
}

/**
 * Picture 3, the open steps, right under the label row: under each capsule a chip and label per step, every step of
 * every part listed, done parts included (round 5); or one row per part (`isRowsView`). `fold` is height level L2:
 * parts not started yet show one "3 to do" chip.
 */
export function stepsPic(m: BandModel, W: number, A: number, fold: boolean, isNarrowBand: boolean): Pic {
  const alt = `Steps: ${m.parts.map(p => `${p.letter} ${p.steps.map(s => `${s.label} ${s.status}`).join(', ')}`).join('; ')}`
  if (isRowsView(m, W, A, isNarrowBand)) return { ...rowsSteps(m, W, A, fold), alt }
  const out: string[] = []
  const pw = columnWidth(m, W, A)
  let bottom = 0
  m.parts.forEach((p, i) => {
    const px = A + i * (pw + 12)
    let y = 6
    if (fold && roleOf(p) === 'todo') {
      const k = p.steps.length
      out.push(chip(px, y, String(k), 'todo-all'))
      out.push(txt(px + 24, y + 12, `${k} to do`, 12.5, 't3'))
      y += 22
    } else {
      p.steps.forEach((s, j) => {
        out.push(chip(px, y, String(j + 1), s))
        const lines = wrap(s.label, 12.5, pw - 24, labelWeight(s))
        lines.forEach((ln, li) => out.push(txt(px + 24, y + 12 + li * 16, ln, 12.5, labelTok(s), { weight: labelWeight(s) })))
        y += 16 * lines.length + 6
      })
    }
    bottom = Math.max(bottom, y)
  })
  const H = Math.ceil(bottom)
  return { source: svg(m.state, W, H, out.join('')), w: W, h: H, alt }
}

/** The open steps one row per part: the part's letter, its steps' chips and labels flowing right, wrapping. */
function rowsSteps(m: BandModel, W: number, A: number, fold: boolean): Omit<Pic, 'alt'> {
  const out: string[] = []
  const X0 = A + 24
  let y = 4
  m.parts.forEach(p => {
    const r = roleOf(p)
    out.push(txt(A, y + 13, p.letter, 12, r === 'cur' ? 'sc' : 't1', { weight: 650 }))
    let x = X0
    let line = y
    const items: { w: number; draw: (x: number, y: number) => string }[] =
      fold && r === 'todo'
        ? [
            {
              w: 24 + tw(`${p.steps.length} to do`, 12.5) * FIT,
              draw: (x, y) => chip(x, y + 1, String(p.steps.length), 'todo-all') + txt(x + 24, y + 13, `${p.steps.length} to do`, 12.5, 't3'),
            },
          ]
        : p.steps.map((s, j) => ({
            w: 24 + tw(s.label, 12.5, labelWeight(s)) * FIT,
            draw: (x, y) => chip(x, y + 1, String(j + 1), s) + txt(x + 24, y + 13, s.label, 12.5, labelTok(s), { weight: labelWeight(s) }),
          }))
    for (const it of items) {
      if (x > X0 && x + it.w > W) {
        x = X0
        line += 24
      }
      out.push(it.draw(x, line))
      x += it.w + 16
    }
    y = line + 24 + 4
  })
  const H = Math.ceil(y)
  return { source: svg(m.state, W, H, out.join('')), w: W, h: H }
}

// ---------- background agents ----------

const shortModel = (model: string) => model.match(/opus|sonnet|haiku|fable/i)?.[0]?.toLowerCase() ?? model

/** The tool text in `room` px: whole, then without the argument's folders, then without the argument. */
function fitTool(tool: string, room: number, size: number, family: string): string {
  const k = family === MONO ? 0.6 * size : 0
  const width = (t: string) => (k ? [...t].length * k : tw(t, size))
  if (width(tool) <= room) return tool
  const [name, ...rest] = tool.split(' ')
  const arg = rest.join(' ')
  const base = arg.includes('/') && !arg.includes(' ') ? arg.split('/').pop() ?? arg : arg
  if (base !== arg && width(`${name} ${base}`) <= room) return `${name} ${base}`
  return name ?? tool
}

/** Words of `text` from the start while they fit `room`; never a cut word. */
function fitWords(text: string, size: number, room: number): string {
  if (fits(text, size, room)) return text
  const words = text.split(' ')
  while (words.length > 1 && !fits(words.join(' '), size, room)) words.pop()
  return words.join(' ')
}

/** "2 running, 1 finished": what the agents line says when they are collapsed. */
export function agentCounts(list: AgentView[]): string {
  const running = list.filter(a => a.status === 'running').length
  const waiting = list.filter(a => a.status === 'waiting').length
  const finished = list.filter(a => a.status === 'done').length
  return [running ? `${running} running` : '', waiting ? `${waiting} waiting` : '', finished ? `${finished} finished` : ''].filter(Boolean).join(', ')
}

/**
 * Picture 4, the agents' head: a 1 px divider 16 px under the plan, then a 30 px row with the fold chevron hanging
 * left of A and "Background agents · 2 running" on A. The whole picture is the fold control's hit area. No box.
 */
export function agentsHeadPic(state: State, list: AgentView[], W: number, A: number, isOpen: boolean): Pic {
  const TOP = 16
  const out = [
    `<rect x="0" y="${TOP}" width="${W}" height="1" class="f-rule"/>`,
    chevron(A - 10, TOP + 17, isOpen),
    `<text xml:space="preserve" x="${r1(A)}" y="${TOP + 21}" font-family="${FONT}" font-size="11.5"><tspan class="f-t2" font-weight="600">Background agents</tspan><tspan class="f-t3">${esc(`  ·  ${agentCounts(list)}`)}</tspan></text>`,
  ]
  const H = TOP + 30
  return { source: svg(state, W, H, out.join('')), w: W, h: H, alt: `Background agents, ${agentCounts(list)}, ${isOpen ? 'shown' : 'folded'}` }
}

/**
 * Picture 5, the agents' rows, right under the head: status dot hanging at A - 10, task on A, model at 40 % and tool at
 * 58 % of the content, time at the right edge; two lines a row in a band under 800 px. `isNeedsYou` decides the
 * waiting copy: "Waiting for your answer" only then, else "Waiting".
 */
export function agentsPic(state: State, list: AgentView[], W: number, A: number, isTwoLine: boolean, isNeedsYou: boolean, now: number, pulse?: number): Pic {
  const out: string[] = []
  const C = W - A
  const pitch = isTwoLine ? 40 : 24
  let y = 0
  const mx = A - 10
  for (const a of list.slice(0, 4)) {
    const dy = y + 11.5
    if (a.status === 'running') out.push(pulsed(`<circle cx="${r1(mx)}" cy="${dy}" r="3.5" class="f-blue"/>`, state === 'running' ? pulse : undefined))
    else if (a.status === 'waiting') out.push(`<circle cx="${r1(mx)}" cy="${dy}" r="3.2" fill="none" class="s-amber" stroke-width="1.5"/>`)
    else out.push(`<path d="M${r1(mx - 3.5)} ${dy} l2.2 2.4 l4 -4.6" fill="none" class="s-green" stroke-width="1.6" stroke-linecap="round"/>`)
    const isPlain = a.status !== 'running'
    const tool = a.status === 'waiting' ? (isNeedsYou ? 'Waiting for your answer' : 'Waiting') : a.status === 'done' ? 'Finished' : a.tool
    const family = isPlain ? FONT : MONO
    const toolSize = isPlain ? 12.5 : 12
    const model = [shortModel(a.model), a.effort].filter(Boolean).join(' · ')
    const time = minutes((a.endedAt ?? now) - a.startedAt)
    const timeW = tw(time, 12.5) * FIT
    const bl = y + 16
    out.push(txt(W, bl, time, 12.5, 't3', { anchor: 'end', tabular: true }))
    if (!isTwoLine) {
      out.push(txt(A, bl, fitWords(a.description, 12.5, C * 0.4 - 12), 12.5, a.status === 'done' ? 't3' : 't1'))
      if (model) out.push(txt(A + C * 0.4, bl, fitWords(model, 12.5, C * 0.18 - 12), 12.5, 't3'))
      out.push(txt(A + C * 0.58, bl, fitTool(tool, C * 0.42 - timeW - 16, toolSize, family), toolSize, 't2', { family }))
    } else {
      out.push(txt(A, bl, fitWords(a.description, 12.5, C - timeW - 16), 12.5, a.status === 'done' ? 't3' : 't1'))
      const lead = model ? `${model}  ·  ` : ''
      const toolText = fitTool(tool, C - tw(lead, 12) * FIT, toolSize, family)
      out.push(
        `<text xml:space="preserve" x="${r1(A)}" y="${bl + 17}" font-family="${FONT}" font-size="12" class="f-t3">${esc(lead)}<tspan font-family="${family}" class="f-t2">${esc(toolText)}</tspan></text>`,
      )
    }
    y += pitch
  }
  if (list.length > 4) {
    out.push(txt(A, y + 14, `+ ${list.length - 4} more`, 12, 't3'))
    y += 22
  }
  const H = Math.ceil(y)
  const alt = `Background agents: ${list.map(a => `${a.description}, ${a.status === 'running' ? a.tool : a.status}`).join('; ')}`
  return { source: svg(state, W, H, out.join('')), w: W, h: H, alt }
}

/** A transparent picture `h` px tall: an exact gap between two native rows, which space in whole cells. */
export function spacerPic(W: number, h: number): Pic {
  return { source: `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${h}" viewBox="0 0 ${W} ${h}"></svg>`, w: W, h, alt: '' }
}
