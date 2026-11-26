#!/usr/bin/env bash
mkdir -p wt/.plans wt/shop wt/tests git-out kit-data
cat > wt/shop/pricing.py <<'P'
def apply_discount(total: float, discount: float) -> float:
    if not 0 <= discount <= 1:
        raise ValueError("discount out of range")
    return round(total * (1 - discount), 2)
P
cat > wt/tests/test_pricing.py <<'P'
import pytest

from shop.pricing import apply_discount


def test_no_discount_keeps_total():
    assert apply_discount(10.0, 0) == 10.0


@pytest.mark.parametrize("discount", [-0.1, 1.5])
def test_out_of_range_discount_is_rejected(discount):
    with pytest.raises(ValueError):
        apply_discount(10.0, discount)
P
cat > wt/.plans/plan.md <<'P'
# Validate discounts

Size: S · Type: bug fix

## Goal
Discounts outside [0, 1] are rejected.

## Boundary
Totals without a discount stay exactly as today.

## Bar for done
- [ ] out-of-range discounts rejected, with a test
- [ ] the receipt shows the discount applied, with a test
- [ ] no block finding open

## Gates
- Plan approval (given).
- Before Part B is triaged: the user checks the receipt layout by hand and says go.

## Parts

### Part A: reject out-of-range discounts
- [ ] Reject discounts outside [0, 1] in apply_discount() — test: `test_out_of_range_discount_is_rejected`

### Part B: the receipt shows the discount
- [ ] a "Discount: <n>%" line on the receipt — test: `test_receipt_shows_discount`
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: validate discounts
Plan: `.plans/plan.md` · Trigger: plan part A
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
## Items
### 1. Reject discounts outside [0, 1] in apply_discount()
- Owning code point: shop/pricing.py apply_discount(); test tests/test_pricing.py drives it.
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: c0ffee1 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
## Verification
- Tests: pytest tests/test_pricing.py → 3 passed
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 1]
$ git log --oneline origin/feature..HEAD
c0ffee1 Round 1 item 1: reject out-of-range discounts
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number
no pull requests found for branch "feature"
$ scripts/verify-round.sh .plans 1
HEAD c0ffee1 · upstream 7d1e2f0 · items: 1
verify-round: OK
$ scripts/drift.sh
size: 2 files, +14 -0 (14 lines) since merge-base 9f8e7d6c5b4
production: 1 files, +2 -0 (2 lines)
tests: 1 files, +12 -0 (12 lines), outside the budget
commits: 1 ahead, 0 behind origin/main
merge preview: clean
$ git diff a1b2c3d..HEAD
diff --git a/shop/pricing.py b/shop/pricing.py
--- a/shop/pricing.py
+++ b/shop/pricing.py
@@ -1,2 +1,4 @@
 def apply_discount(total: float, discount: float) -> float:
+    if not 0 <= discount <= 1:
+        raise ValueError("discount out of range")
     return round(total * (1 - discount), 2)
diff --git a/tests/test_pricing.py b/tests/test_pricing.py
new file mode 100644
--- /dev/null
+++ b/tests/test_pricing.py
@@ -0,0 +1,12 @@
+import pytest
+
+from shop.pricing import apply_discount
+
+
+def test_no_discount_keeps_total():
+    assert apply_discount(10.0, 0) == 10.0
+
+
+@pytest.mark.parametrize("discount", [-0.1, 1.5])
+def test_out_of_range_discount_is_rejected(discount):
+    with pytest.raises(ValueError):
+        apply_discount(10.0, discount)
P
mkdir -p kit-data/state
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T09:00:00Z","mode":"run","plan":{"title":"Validate discounts","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: reject out-of-range discounts","short":"Discount range","status":"running","done":0,"total":1,"steps":[{"label":"Reject bad discounts","status":"running"}]},{"title":"Part B: the receipt shows the discount","short":"Receipt discount","status":"todo","done":0,"total":1,"steps":[{"label":"Discount line","status":"todo"}]}],"round":1,"step":"execute","items":{"done":1,"total":1},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z"}],"pr":null}
P
