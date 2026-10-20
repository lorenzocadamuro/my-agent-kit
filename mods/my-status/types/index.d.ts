export type MyStatusPart = {
  title: string
  status: 'todo' | 'running' | 'done'
  done: number
  total: number
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

export type MyStatusSnapshot = {
  run: MyStatusRun | null
  newComments: number
  conflicts: number
  openNotes: number
  now: number
}

declare module 'claude-code' {
  interface PluginState {
    'my-status': { snap: MyStatusSnapshot | null; planText: string | null }
  }
}
