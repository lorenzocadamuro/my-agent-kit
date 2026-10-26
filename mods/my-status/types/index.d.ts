export type MyStatusPart = {
  title: string
  status: 'todo' | 'running' | 'done'
  done: number
  total: number
  /** The part's steps not done yet, two or three words each. */
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
  newComments: number | null
  conflicts: number | null
  openNotes: number
  now: number
}

declare module 'claude-code' {
  interface PluginState {
    'my-status': { snap: MyStatusSnapshot | null; planText: string | null }
  }
}
