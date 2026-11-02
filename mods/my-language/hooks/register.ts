import type { Register } from 'claude-code'

// The my-language mod: `/language` switches the output style of this folder. It hooks no prompt event.

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'language', description: "Choose the language and style of Claude's replies" })
    return next(e)
  })

  on('command.run', { command: 'language' }, async () => ({ text: 'language: not available yet', exitCode: 1 }))
}
