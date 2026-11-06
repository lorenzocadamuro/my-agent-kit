---
type: tool_order
before:
  tool: Bash
  input_match: '"command":\s*"(?=(?:[^"\\]|\\.)*(?:\b|\\[nt])cp\b)(?:[^"\\]|\\.)*review-before-check'
after:
  tool: Agent
  input_match: '"prompt":\s*"(?:[^"\\]|\\.)*(You review round|reviewer\.md)'
weight: 3
---
