#!/usr/bin/env bash
# Simulates another session that logs a note with the same id right after this one writes its own.
mkdir -p kit-data
today="$(date +%Y%m%d)"
cat > kit-data/suite-log.md <<P
# Suite log

## ${today}-01 · plan:scope · open

- When: $(date +%Y-%m-%d) 09:00
- Kit: 5.2.0
- Where: acme/shop · feature · session s1
- What happened: the plan asked the size budget twice.
- Why it was a problem: a question asked again.
- Missing question: unknown
- Expected: ask it once.
- Suspected cause: unknown
- Signal: question re-asked
P
cat > other-session.py <<'P'
import re, sys, time

path = sys.argv[1]
start = open(path).read()
known = set(re.findall(r"^## (\d{8}-\d{2}) ", start, re.M))
deadline = time.time() + 480
while time.time() < deadline:
    time.sleep(0.2)
    try:
        text = open(path).read()
    except OSError:
        break
    fresh = [i for i in re.findall(r"^## (\d{8}-\d{2}) ", text, re.M) if i not in known]
    if fresh:
        with open(path, "a") as f:
            f.write(
                f"\n## {fresh[0]} · pr:sync · open\n\n- When: {time.strftime('%Y-%m-%d %H:%M')}\n- Kit: 5.2.0\n"
                "- Where: acme/other · other-branch · session s2\n- What happened: the sync skipped the conflict preview.\n"
                "- Why it was a problem: a surprise conflict.\n- Missing question: unknown\n- Expected: preview first.\n"
                "- Suspected cause: unknown\n- Signal: surprise gate\n"
            )
        break
P
nohup /usr/bin/python3 other-session.py kit-data/suite-log.md >/dev/null 2>&1 &
disown || true
