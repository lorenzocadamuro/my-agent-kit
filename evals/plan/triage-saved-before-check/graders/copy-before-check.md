---
type: tool_order
before:
  tool: Bash
  input_match: '"command":\s*"(?:[^"\\]|\\.)*triage-before-check'
after:
  tool: Agent
  input_match: '"prompt":\s*"(?:[^"\\]|\\.)*(check a round''s triage|before anyone executes)'
weight: 3
---
