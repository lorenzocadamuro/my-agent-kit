---
type: tool_order
before:
  tool: Bash
  input_match: '"command":\s*"(?=(?:[^"\\]|\\.)*\bcp\b)(?:[^"\\]|\\.)*triage-before-check'
after:
  tool: Agent
  input_match: '"prompt":\s*"(?:[^"\\]|\\.)*(check a round.s triage|before anyone executes|triage-check\.md)'
weight: 3
---
