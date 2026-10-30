/** A step's status as the kit writes it in `parts[].steps`. */
export type MyStatusStepStatus = 'todo' | 'running' | 'done' | 'failed'

export type MyStatusStep = { label: string; status: MyStatusStepStatus }

export type MyStatusPart = {
  title: string
  /** The part's title in two or three words and at most 16 characters, from its heading after "Part X:". */
  short?: string
  status: 'todo' | 'running' | 'done'
  done: number
  total: number
  /** The part's steps in the plan's order, each with its status. */
  steps?: MyStatusStep[]
  /** Written by kit 5.6.0 and before: the part's steps not done yet, two or three words each. Read only when `steps` is missing. */
  left?: string[]
}

export type MyStatusRound = {
  n: number
  startedAt?: string
  endedAt?: string
  verdict?: string
}

export type MyStatusRun = {
  repo?: string
  branch?: string
  worktree?: string
  /** When the work started. */
  startedAt?: string
  updatedAt?: string
  mode?: string
  /** Written by 4.0.x; no longer written, and never shown. */
  name?: string
  plan?: { title: string; path: string }
  parts?: MyStatusPart[]
  round?: number
  step?: string
  items?: { done: number; total: number }
  state?: 'planning' | 'ready' | 'running' | 'needs_you' | 'stopped' | 'done'
  reason?: string | null
  rounds?: MyStatusRound[]
  pr?: number | null
  commentsReadUntil?: string | null
}

export type MyStatusProgress = {
  round?: number
  items?: { done: number; total: number }
  updatedAt?: string
}

export type MyStatusActivity = {
  mode?: string
  /** Written by 4.0.x; no longer written, and never shown. */
  name?: string
  state?: 'running' | 'needs_you' | 'done'
  updatedAt?: string
}

export type MyStatusSnapshot = {
  run: MyStatusRun | null
  progress?: MyStatusProgress | null
  activity?: MyStatusActivity | null
  /** When the mod first saw the current activity: its elapsed time counts from there. */
  activitySince?: number
  /** Whether the plan file exists: Planning shows Open plan only then. */
  hasPlanFile?: boolean
  newComments: number | null
  conflicts: number | null
  openNotes: number
  /** The poll's time: staleness is judged on it. */
  now: number
}

// The band's own model, after the approved prototype: parts with a letter, a short title and steps; `next` is the
// step Ready starts with, derived by the mod.
export type StepStatus = 'todo' | 'next' | 'running' | 'done' | 'failed'
export type Step = { label: string; status: StepStatus }
// One part of the plan: its letter, its short title (two or three words, at most 16 characters) and its steps; `name` replaces the letter in Planning.
export type Part = { letter: string; short: string; steps: Step[]; name?: string }

// how the person left the agents' fold this session: 'auto' lets the height decide
export type AgentsFold = 'auto' | 'open' | 'folded'

export type AgentView = {
  id: string
  description: string
  type: string
  model: string
  effort?: string
  tool: string
  status: 'running' | 'waiting' | 'done'
  startedAt: number
  endedAt?: number
}

declare module 'claude-code' {
  interface PluginState {
    'my-status': {
      snap: MyStatusSnapshot | null
      planText: string | null
      showSteps: boolean
      agentsFold: AgentsFold
      agents: AgentView[]
      tick: number
    }
  }
}
