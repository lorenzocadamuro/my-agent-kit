#!/usr/bin/env bash
set -e
mkdir -p origin.git && git init -q --bare origin.git
git init -q repo && cd repo
git config user.email t@example.com && git config user.name t
mkdir -p app && cat > app/pricing.py <<'P'
def total(prices):
    return sum(prices)
P
printf 'requests==2.31.0\n' > requirements.lock
git add -A && git commit -qm "base" && git branch -M main
git remote add origin ../origin.git && git push -q origin main
git checkout -qb feature
cat > app/pricing.py <<'P'
def total(prices, discount=0.0):
    return round(sum(prices) * (1 - discount), 2)
P
printf 'requests==2.31.0\nrich==13.0.0\n' > requirements.lock
git commit -qam "Apply a discount to totals" && git push -q -u origin feature
git checkout -q main
cat > app/pricing.py <<'P'
def total(prices, tax_rate=0.0):
    return sum(prices) + sum(prices) * tax_rate
P
printf 'requests==2.32.0\n' > requirements.lock
git commit -qam "Add tax to totals (#77)" && git push -q origin main
git worktree add -q ../wt feature
cd ../wt
mkdir -p ../git-out/conflicts
{ echo "$ git rev-parse --git-dir; git rev-parse --git-common-dir"; git rev-parse --git-dir; git rev-parse --git-common-dir;
  echo "$ git status --short --branch"; git status --short --branch;
  echo "$ git rev-list --count HEAD..origin/main"; git rev-list --count HEAD..origin/main; } > ../git-out/preflight.txt
git merge-tree --write-tree --name-only HEAD origin/main > ../git-out/merge-tree.txt || true
git log --format='%h %s' origin/main --not HEAD > ../git-out/main-commits.txt
base=$(git merge-base HEAD origin/main)
for f in app/pricing.py requirements.lock; do n=$(echo $f | tr / _)
  git show $base:$f > ../git-out/conflicts/$n.base; git show HEAD:$f > ../git-out/conflicts/$n.ours; git show origin/main:$f > ../git-out/conflicts/$n.theirs; done
cat > ../git-out/pr-77.md <<'P'
# PR #77: Add tax to totals (merged into main)

`total()` now takes a `tax_rate` and adds tax to the sum. Tax is applied on every total from now on.

How open branches must resolve: branches that change total() must adopt tax_rate and drop their own parameters. Do not keep a second parameter next to tax_rate.
P
