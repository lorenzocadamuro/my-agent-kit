---
type: tool_order
before:
  tool: Write
  input_match: '"file_path":\s*"[^"]*\.plans/round-1\.md'
after:
  tool: Edit
  input_match: '"file_path":\s*"[^"]*shop/orders\.py'
weight: 3
---
