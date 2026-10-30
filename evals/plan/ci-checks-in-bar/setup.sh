#!/usr/bin/env bash
mkdir -p web tests scripts .github/workflows kit-data/projects
cat > web/__init__.py <<'P'
P
cat > web/money.py <<'P'
def format_price(cents: int, currency: str) -> str:
    symbol = {"EUR": "€", "USD": "$"}.get(currency, currency + " ")
    return f"{symbol}{cents // 100}.{cents % 100:02d}"
P
cat > web/cart.py <<'P'
from web.money import format_price

DEFAULT_CURRENCY = "EUR"


def cart_total(items: list[dict]) -> int:
    return sum(i["cents"] * i["qty"] for i in items)


def render_total(items: list[dict], currency: str = DEFAULT_CURRENCY) -> str:
    return "Total: " + format_price(cart_total(items), currency)
P
cat > web/checkout.py <<'P'
from web.cart import cart_total, DEFAULT_CURRENCY
from web.money import format_price


def summary(items: list[dict]) -> str:
    return f"{len(items)} items, {format_price(cart_total(items), DEFAULT_CURRENCY)}"


def line_items(items: list[dict]) -> list[str]:
    return [f"{i['qty']} x {i['name']}" for i in items]
P
cat > web/promo.py <<'P'
def discount_for(items: list[dict]) -> int:
    """Cents off: 10% when the cart has three or more lines."""
    total = sum(i["cents"] * i["qty"] for i in items)
    return total // 10 if len(items) >= 3 else 0
P
cat > tests/__init__.py <<'P'
P
cat > tests/test_money.py <<'P'
import unittest

from web.money import format_price


class FormatPriceTest(unittest.TestCase):
    def test_euro(self):
        self.assertEqual(format_price(1050, "EUR"), "€10.50")


if __name__ == "__main__":
    unittest.main()
P
cat > scripts/lint.sh <<'P'
#!/usr/bin/env bash
# Syntax check for every Python file.
set -e
find web tests -name '*.py' -print0 | xargs -0 python3 -m py_compile
echo "lint ok"
P
cat > scripts/check-cycles.sh <<'P'
#!/usr/bin/env bash
# Fails when the modules under the given folder import each other in a cycle.
# Usage: scripts/check-cycles.sh <folder>
set -euo pipefail
dir="${1:?folder}"
python3 - "$dir" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
pkg = root.name
graph = {}
for f in root.glob("*.py"):
    mod = f.stem
    deps = set()
    for line in f.read_text().splitlines():
        m = re.match(rf"\s*from {pkg}\.(\w+) import|\s*import {pkg}\.(\w+)", line)
        if m:
            deps.add(m.group(1) or m.group(2))
    graph[mod] = deps
seen, stack = set(), []
def visit(m):
    if m in stack:
        print("cycle: " + " -> ".join(stack[stack.index(m):] + [m]))
        sys.exit(1)
    if m in seen:
        return
    seen.add(m); stack.append(m)
    for d in sorted(graph.get(m, ())):
        visit(d)
    stack.pop()
for m in sorted(graph):
    visit(m)
print(f"no import cycles in {root} ({len(graph)} modules)")
PY
P
chmod +x scripts/*.sh
cat > .github/workflows/ci.yml <<'P'
name: ci
on:
  pull_request:
jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python3 -m unittest discover -s tests -q
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sh scripts/lint.sh
P
cat > .github/workflows/web-guards.yml <<'P'
name: web-guards
on:
  pull_request:
    paths:
      - 'web/**'
jobs:
  import-cycles:
    # Required check: a cycle between web modules breaks the server at import time in production.
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sh scripts/check-cycles.sh web
P
for n in deploy release nightly docs stale-issues dependabot-automerge; do
  printf 'name: %s\non:\n  workflow_dispatch:\njobs:\n  run:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n      - run: sh scripts/%s.sh\n' "$n" "$n" > ".github/workflows/$n.yml"
  printf '#!/usr/bin/env bash\n# %s helper.\necho "%s: nothing to do locally"\n' "$n" "$n" > "scripts/$n.sh"
done
# Filler: the rest of the shop, so the relevant files are a few among many.
mkdir -p web/pages api jobs docs
for n in account addresses banners catalog categories favorites footer gift_cards header inventory invoices locale newsletter orders payments reviews returns search shipping sitemap stock taxes wishlist; do
  printf 'def render_%s(ctx: dict) -> str:\n    return "<section>%s</section>"\n' "$n" "$n" > "web/pages/$n.py"
done
for n in carts customers orders products refunds sessions; do
  printf 'def get_%s(db, id: str) -> dict:\n    return db.get("%s", id)\n' "$n" "$n" > "api/$n.py"
done
for n in emails feeds reindex reports; do
  printf 'def run(db) -> None:\n    """Nightly %s job."""\n' "$n" > "jobs/$n.py"
done
for n in architecture style payments shipping; do printf '# %s\n\nNotes.\n' "$n" > "docs/$n.md"; done
cat > kit-data/projects/acme-shop.md <<'P'
# Project profile: acme/shop

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Commands

| Purpose        | Command                                    |
| -------------- | ------------------------------------------ |
| Targeted tests | `python3 -m unittest discover -s tests -q` |
| Lint           | `sh scripts/lint.sh`                       |
| Deep review    | none                                       |

## Tickets

- Tracker: none
P
