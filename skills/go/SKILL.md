# /my:go

| Request | Skill |
| --- | --- |
| a plan request with no mode | `round` when a plan exists in the worktree; otherwise `scope`, said in one line |
| a PR request with no mode, or pasted comments | `comments` if the text is comments to answer, `learn` with a comment focus if the user wants to learn from them; otherwise ask which mode in one line |
