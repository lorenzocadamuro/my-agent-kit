#!/usr/bin/env bash
set -e
mkdir -p origin.git && git init -q --bare origin.git
git init -q repo && cd repo
git config user.email t@example.com && git config user.name t
mkdir -p app && cat > app/pricing.py <<'P'
def total(prices):
    return sum(prices)
P
cat > app/orders.py <<'P'
def cancel(order):
    order["status"] = "cancelled"
    return order
P
git add -A && git commit -qm "base" && git branch -M main
git remote add origin ../origin.git && git push -q origin main
git checkout -qb feature
cat > app/pricing.py <<'P'
def total(prices, discount=0.0):
    return round(sum(prices) * (1 - discount), 2)
P
cat > app/orders.py <<'P'
def cancel(order):
    if order["status"] == "shipped":
        return False
    order["status"] = "cancelled"
    return True
P
git commit -qam "Apply a discount to totals; cancel() says whether it cancelled" && git push -q -u origin feature
git checkout -q main
cat > app/pricing.py <<'P'
def total(prices, tax_rate=0.0):
    return sum(prices) + sum(prices) * tax_rate
P
git commit -qam "Add tax to totals (#77)"
cat > app/orders.py <<'P'
def cancel(order):
    order["status"] = "cancelled"
    return {"order_id": order["id"], "refund": order["total"]}
P
git commit -qam "cancel() returns a refund receipt (#78)" && git push -q origin main
git worktree add -q ../wt feature
cd ../wt
mkdir -p ../git-out/conflicts
{ echo "$ git rev-parse --git-dir; git rev-parse --git-common-dir"; git rev-parse --git-dir; git rev-parse --git-common-dir;
  echo "$ git status --short --branch"; git status --short --branch;
  echo "$ git rev-list --count HEAD..origin/main"; git rev-list --count HEAD..origin/main; } > ../git-out/preflight.txt
git merge-tree --write-tree --name-only HEAD origin/main > ../git-out/merge-tree.txt || true
git log --format='%h %s' origin/main --not HEAD > ../git-out/main-commits.txt
base=$(git merge-base HEAD origin/main)
for f in app/pricing.py app/orders.py; do n=$(echo $f | tr / _)
  git show $base:$f > ../git-out/conflicts/$n.base; git show HEAD:$f > ../git-out/conflicts/$n.ours; git show origin/main:$f > ../git-out/conflicts/$n.theirs; done
