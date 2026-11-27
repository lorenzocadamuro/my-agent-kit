---
type: llm
focus: last_message
weight: 2
---

The user asked for two unrelated plans in one message (ENG-123, expired coupons; ENG-456, a CSV export). Pass only if the reply sends each of the two to a new session of its own, each with its own worktree (sessions the reply started, or sessions it tells the user to start), so that neither request is planned in this session. Fail if the reply keeps one of them for this session (for example "this session: scope one ticket, a new session for the other"), asks which one to take first or here, starts planning either one here (research findings, interview questions, a plan), or hands them to background agents.
