#!/usr/bin/env bash
# A repository whose CI lint command changed after its profile recorded its sources, where the
# profile's lint command is one the user answered, marked (user).
set -euo pipefail
mkdir -p .github/workflows src kit-data/projects
printf '# acme/shop\n\nTypeScript service. Tests live next to the code.\n' > CLAUDE.md
printf 'export const add = (a: number, b: number) => a + b;\n' > src/sum.ts
printf 'name: ci\non: [pull_request]\njobs:\n  lint:\n    runs-on: ubuntu-latest\n    steps:\n      - run: npm ci\n      - run: npm run lint\n' > .github/workflows/ci.yml
blob() { { printf 'blob %d\0' "$(wc -c < "$1" | tr -d ' ')"; cat "$1"; } | shasum -a 1 | cut -d' ' -f1; }
cat > kit-data/projects/acme-shop.md <<P
# Project profile: acme/shop

Confirmed by the user on 2026-11-20.

## Repository

- Default branch: \`main\` · New branches from: \`origin/main\`
- Worktree root: none: work on \`main\` (one task at a time) (user)

## Commands

| Purpose        | Command                                                       |
| -------------- | ------------------------------------------------------------- |
| Targeted tests | \`npm test\`                                                    |
| Lint / format  | \`npm run lint\` (user)                                        |

## Sources

The files this profile was built from, each with its git blob hash on \`origin/<default>\`:

- \`CLAUDE.md\`: \`$(blob CLAUDE.md)\`
- \`.github/workflows/ci.yml\`: \`$(blob .github/workflows/ci.yml)\`
P
printf 'name: ci\non: [pull_request]\njobs:\n  lint:\n    runs-on: ubuntu-latest\n    steps:\n      - run: npm ci\n      - run: npx biome check .\n' > .github/workflows/ci.yml
