#!/usr/bin/env python3
"""Splits a round's items into parallel lanes (rules/parallel.md) and refuses an unsafe split.

Each item of round-N.md (a `### <k>.` heading) goes to its own `Lanes:` line, else to the lane of
the plan step whose bullet line its heading copies, else to lane `a`. Its files are its `Files:`
line, else that step's, else its `Owning code point:` line. A plan step without `Lanes:` is in
lane `a`; its id is its part letter and position (`B2`), a bare position in a plan without parts.

Refused (exit 1, the reasons on stderr): a lane other than a, b or c; with two or more lanes, a
file (or a folder holding it) in two lanes, or an item with no files that is not check-only; a
`Depends on:` naming a missing step, a step of another lane, or closing a cycle.
Printed (exit 0): `lanes: <n>`, then one line per lane, `<id>: <item>, <item>`.
Usage: lanes.py <round-N.md> <plan.md>
"""
import os, re, sys

LANES = ("a", "b", "c")


def labels(body):
    """The `- Label: value` lines of a block, at any indent, as {label: value}."""
    out = {}
    for line in body:
        m = re.match(r"^\s*- \**([A-Z][A-Za-z ]*?)\**:\**\s*(.*)$", line)
        if m and m.group(1) not in out:
            out[m.group(1)] = m.group(2).strip()
    return out


def paths(value):
    if not value or value.lower().startswith("none"):
        return set()
    found = re.findall(r"`([^`\s]+)`", value)
    if not found:
        found = [t for t in re.split(r"[,\s]+", value.split("·")[0]) if "/" in t or "." in t]
    out = set()
    for p in found:
        p = re.sub(r":\d+(-\d+)?$", "", p.rstrip(":,"))
        if p.endswith("()"):
            continue
        p = os.path.normpath(p)
        out.add(p[2:] if p.startswith("./") else p)
    return out


def lane_id(value):
    words = re.findall(r"[A-Za-z0-9]+", value or "")
    return words[0].lower() if words else "a"


def norm(text):
    return re.sub(r"\s+", " ", re.sub(r"[`*_]", "", text)).strip().lower()


def read_plan(path):
    lines = open(path, encoding="utf-8").read().splitlines()
    has_parts = any(re.match(r"^#{2,4}\s+Part [A-Z]:", l) for l in lines)
    steps, letter, level, section, count, cur = [], None, 0, "", {}, None
    for line in lines:
        head = re.match(r"^(#{2,4})\s+(.*?)\s*$", line)
        if head:
            section, cur = head.group(2), None
            m = re.match(r"Part ([A-Z]):", section)
            if m:
                letter, level = m.group(1), len(head.group(1))
            elif letter is not None and len(head.group(1)) <= level:
                letter = None
            continue
        box = re.match(r"^- \[[ xX]\]\s+(.*)", line)
        if box:
            cur = None
            if has_parts and letter is None or not has_parts and section.lower().startswith("bar for done"):
                continue
            key = letter or ""
            count[key] = count.get(key, 0) + 1
            cur = {"id": f"{key}{count[key]}", "text": box.group(1), "body": []}
            steps.append(cur)
        elif cur is not None:
            if line.strip() and not line.startswith((" ", "\t")):
                cur = None
            else:
                cur["body"].append(line)
    for s in steps:
        lab = labels(s["body"])
        s["lane"] = lane_id(lab.get("Lanes"))
        s["files"] = paths(lab.get("Files"))
        deps = lab.get("Depends on", "")
        s["deps"] = [] if deps.lower().startswith("none") else [d.upper() for d in re.findall(r"\b[A-Z]?\d+\b", deps, re.I)]
    return steps


def read_round(path):
    items, cur = [], None
    for line in open(path, encoding="utf-8").read().splitlines():
        m = re.match(r"^### (\d+)\.\s*(.*)$", line)
        if m:
            cur = {"k": int(m.group(1)), "title": m.group(2), "body": []}
            items.append(cur)
        elif re.match(r"^#{1,3}\s", line):
            cur = None
        elif cur is not None:
            cur["body"].append(line)
    return items


def overlap(a, b):
    return a == b or a.startswith(b.rstrip("/") + "/") or b.startswith(a.rstrip("/") + "/")


def main(argv):
    if len(argv) != 3 or not all(os.path.isfile(p) for p in argv[1:]):
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    items, steps = read_round(argv[1]), read_plan(argv[2])
    by_text = {norm(s["text"]): s for s in steps}
    by_id = {s["id"]: s for s in steps}
    errors = []

    lanes = {}
    for it in items:
        lab = labels(it["body"])
        step = by_text.get(norm(it["title"]))
        lane = lane_id(lab.get("Lanes")) if lab.get("Lanes") else (step["lane"] if step else "a")
        files = paths(lab.get("Files")) or (step["files"] if step else set()) or paths(lab.get("Owning code point"))
        check_only = "check only" in lab.get("Change", "").lower()
        lanes.setdefault(lane, []).append({"k": it["k"], "files": files, "check_only": check_only})

    for s in steps:
        if s["lane"] not in LANES:
            errors.append(f"step {s['id']} is in lane {s['lane']}: lanes are a, b and c")
    for lane in lanes:
        if lane not in LANES:
            errors.append(f"lane {lane}: lanes are a, b and c")

    if len(lanes) > 1:
        for lane, its in lanes.items():
            for it in its:
                if not it["files"] and not it["check_only"]:
                    errors.append(f"item {it['k']} (lane {lane}) names no files")
        names = sorted(lanes)
        for i, la in enumerate(names):
            for lb in names[i + 1:]:
                for x in lanes[la]:
                    for y in lanes[lb]:
                        for fa in sorted(x["files"]):
                            for fb in sorted(y["files"]):
                                if overlap(fa, fb):
                                    errors.append(f"{fa} is in lane {la} (item {x['k']}) and {fb} in lane {lb} (item {y['k']})")

    for s in steps:
        for d in s["deps"]:
            if d not in by_id:
                errors.append(f"{s['id']} depends on {d}, which is no step of the plan")
            elif by_id[d]["lane"] != s["lane"]:
                errors.append(f"{s['id']} (lane {s['lane']}) depends on {d} (lane {by_id[d]['lane']}): a step and the steps it depends on share a lane")
    state = {}
    def visit(sid, trail):
        state[sid] = "open"
        for d in by_id[sid]["deps"]:
            if d not in by_id:
                continue
            if state.get(d) == "open":
                errors.append("dependency cycle: " + " -> ".join(trail[trail.index(d):] + [d]) if d in trail else f"dependency cycle through {d}")
            elif d not in state:
                visit(d, trail + [d])
        state[sid] = "done"
    for s in steps:
        if s["id"] not in state:
            visit(s["id"], [s["id"]])

    if errors:
        for e in dict.fromkeys(errors):
            print(f"lanes.py: refused: {e}", file=sys.stderr)
        return 1
    print(f"lanes: {len(lanes)}")
    for lane in sorted(lanes):
        print(f"{lane}: " + ", ".join(str(it["k"]) for it in sorted(lanes[lane], key=lambda i: i["k"])))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
