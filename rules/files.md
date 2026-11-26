## Where files go

- **Per-change files** (plans, rounds, summaries, comment triage) live in the worktree's git-ignored `.plans/` folder, and disappear with the worktree.
- **Lasting personal material** lives in the data root: a root the user names, else `$MY_AGENT_KIT_HOME`, else `~/.my-agent-kit/`; never in this repository. The layout is in [local-data.md](local-data.md).
- **Personal material stays private.** Study pages, readings, the glossary, reviewer profiles, `method.md`, the suite log and the content of saved trials stay under the data root, never in a repository, artifact, doc or gist. They shape what the kit looks for, but nothing published (PR text, comments, replies, commits, messages) cites, quotes or names them.
- **Throwaway files** go in the session scratchpad.
- **Present a file the user must read** by opening it in the app's file pane (`show_pane`, pane `file`, absolute path). The pane opens files inside the session's working directory and added folders, not the scratchpad: such a file goes in the working directory (a git-ignored `.plans/`) or the data root, and a folder outside the working directory (the data root, a worktree entered later) is added first with `request_directory`, once per session. When the pane cannot open it (no window, a tool missing), give the absolute path as code and say why. A text the user must approve before it is published is pasted in chat, always.
- **Nothing employer-specific enters this repository.**
