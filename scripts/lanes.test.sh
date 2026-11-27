#!/usr/bin/env bash
# Tests lanes.py: a round's items split into the lanes of their plan steps (rules/parallel.md);
# files shared by two lanes, a dependency cycle, a dependency across lanes and a fourth lane are
# refused; a plan without Lanes: is one lane a with every item; a block fix takes its own Lanes: line.
# Usage: bash scripts/lanes.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/lanes.py"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
run() { python3 "$script" "$tmp/round.md" "$tmp/plan.md" > "$tmp/out" 2> "$tmp/err"; echo $?; }
expect() { if [[ "$2" == "$3" ]]; then echo "ok: $1"; else echo "FAIL: $1: expected '$3', got '$2'"; sed 's/^/  /' "$tmp/out" "$tmp/err"; fail=1; fi; }
has() { grep -qF -- "$2" "$tmp/$1" && echo yes || echo no; }

# A plan in the template's shape: two parts, lanes a and b, a dependency inside lane a.
plan() { # <B1's Lanes> <B1's Files> <A2's Depends on> <B1's Depends on>
  cat > "$tmp/plan.md" <<P
# Coupons

## Bar for done
- [ ] parts A and B done

## Parts

### Part A: Expired coupons
- [ ] Reject expired coupons in redeem()
  - Files: \`src/redeem.py\` · redeem()
  - Lanes: a
  - Estimate: 20
- [ ] Drive checkout() with one
  - Files: \`src/checkout.py\`, \`tests/test_checkout.py\`
  - Lanes: a
  - Depends on: $3

### Part B: Coupon telemetry
- [ ] Count rejections
  - Files: $2
  - Lanes: $1
  - Depends on: $4
P
}
round() { # items: the three plan steps as ready steps, then a block fix
  cat > "$tmp/round.md" <<'R'
# Round 2: coupons

## Items

### 1. Reject expired coupons in redeem()

- Ready from plan: yes (Searches rerun at HEAD: 1)

### 2. Drive checkout() with one

- Ready from plan: yes

### 3. Count rejections

- Ready from plan: yes

### 4. Block fix: the redeem() message names the coupon

- Owning code point: `src/redeem.py` · redeem()
- Change: say which coupon expired (~3 production lines)

## Not this round
R
}

plan b '`src/telemetry.py`' A1 none; round
expect "disjoint lanes are accepted" "$(run)" "0"
expect "lane a holds its steps and the block fix" "$(grep '^a:' "$tmp/out")" "a: 1, 2, 4"
expect "lane b holds its step" "$(grep '^b:' "$tmp/out")" "b: 3"
expect "the lane count is printed" "$(head -1 "$tmp/out")" "lanes: 2"

plan b '`src/redeem.py`' A1 none; round
expect "a file shared by two lanes is refused" "$(run)" "1"
expect "the refusal names the shared file" "$(has err 'src/redeem.py')" "yes"

plan b '`src/redeem.py:120`' A1 none; round
expect "a file with a :line suffix shared by two lanes is refused" "$(run)" "1"
expect "that refusal names the file without the suffix" "$(has err 'and src/redeem.py in lane b')" "yes"

plan b '`src/redeem.py:12-40`' A1 none; round
expect "a file with a :line-line suffix shared by two lanes is refused" "$(run)" "1"

plan b '`src/`' A1 none; round
expect "a folder that holds another lane's file is refused" "$(run)" "1"

plan b '`src/telemetry.py`' A1 A2; round
expect "a dependency across lanes is refused" "$(run)" "1"
expect "the refusal names both steps" "$(has err 'B1') $(has err 'A2')" "yes yes"

plan a '`src/telemetry.py`' B1 A2; round
expect "a dependency cycle is refused" "$(run)" "1"
expect "the refusal says cycle" "$(has err 'cycle')" "yes"

plan b '`src/telemetry.py`' A9 none; round
expect "a dependency on a missing step is refused" "$(run)" "1"

plan d '`src/telemetry.py`' A1 none; round
expect "a lane past c is refused" "$(run)" "1"

# A block fix with its own Lanes: line goes there; its files then count in that lane.
plan b '`src/telemetry.py`' A1 none; round
perl -pi -e 's/^- Owning code point: `src\/redeem.py`/- Lanes: b\n- Owning code point: `src\/telemetry.py`/' "$tmp/round.md"
expect "a block fix takes its own Lanes: line" "$(run) $(grep '^b:' "$tmp/out")" "0 b: 3, 4"

# A plan without Lanes: is one lane a with every item, files shared or not.
plan b '`src/redeem.py`' A1 none; round
perl -ni -e 'print unless /Lanes:/' "$tmp/plan.md"
expect "a plan without Lanes: is one lane" "$(run) $(head -1 "$tmp/out")" "0 lanes: 1"
expect "that lane holds every item" "$(grep '^a:' "$tmp/out")" "a: 1, 2, 3, 4"

# A plan without parts numbers its steps 1, 2, …
printf '# Fix\n\n## Steps\n- [ ] Parse dates\n  - Files: `a.py`\n  - Lanes: a\n- [ ] Add docs\n  - Files: `README.md`\n  - Lanes: b\n  - Depends on: 1\n' > "$tmp/plan.md"
printf '## Items\n\n### 1. Parse dates\n\n### 2. Add docs\n' > "$tmp/round.md"
expect "a plan without parts names steps by number" "$(run)" "1"
expect "its refusal names the bare step ids" "$(has err '2 (lane b) depends on 1 (lane a)')" "yes"

# With two lanes, an item that names no files cannot be placed.
plan b '`src/telemetry.py`' A1 none; round
perl -pi -e 's/^- Owning code point: .*$/- Owning code point: redeem()/' "$tmp/round.md"
expect "an item without files is refused when there are two lanes" "$(run)" "1"

expect "a missing file is a usage error" "$(python3 "$script" "$tmp/none.md" "$tmp/plan.md" > /dev/null 2>&1; echo $?)" "2"
exit "$fail"
