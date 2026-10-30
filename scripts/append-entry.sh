#!/usr/bin/env bash
# Appends a suite-log entry or a method kind under a lock, and numbers it inside the lock, so two
# sessions writing at once never share an id. Also lists the ids a file already holds twice.
# Usage:
#   append-entry.sh log   <suite-log.md> <entry file>   heading "## <id> · ...": prints the id given
#   append-entry.sh kind  <method.md>    <row file>     row "| <id> | ...": prints the id given
#   append-entry.sh check <file>                        prints each duplicate id; exit 1 when there is one
set -euo pipefail

mode="${1:-}"
file="${2:-}"
if [[ -z "$mode" || -z "$file" ]]; then
  sed -n '4,7p' "$0" >&2
  exit 2
fi

# Every id in the file, one per line: YYYYMMDD-NN headings in the log, K<n> rows in the method.
ids() {
  case "$1" in
    log) grep -oE '^## [0-9]{8}-[0-9]{2} ' "$2" | cut -c4-14 || true ;;
    kind) grep -oE '^\| *K[0-9]+ *\|' "$2" | tr -d '| ' || true ;;
  esac
}
dups() { ids "$1" "$2" | sort | uniq -d; }

if [[ "$mode" == check ]]; then
  [[ -f "$file" ]] || exit 0
  kind=log
  grep -qE '^\| *K[0-9]+ *\|' "$file" && kind=kind
  found="$(dups "$kind" "$file")"
  [[ -z "$found" ]] || { echo "$found"; exit 1; }
  exit 0
fi

entry="${3:-}"
if [[ "$mode" != log && "$mode" != kind ]] || [[ ! -f "$entry" ]]; then
  sed -n '4,7p' "$0" >&2
  exit 2
fi
if [[ "$mode" == log ]] && ! head -1 "$entry" | grep -q '^## <id> · '; then
  echo "append-entry.sh: the entry's first line must read '## <id> · ...'" >&2
  exit 2
fi
if [[ "$mode" == kind ]] && ! head -1 "$entry" | grep -q '^| <id> |'; then
  echo "append-entry.sh: the row must read '| <id> | ...'" >&2
  exit 2
fi
if [[ "$mode" == kind ]] && ! grep -q '^| Kind' "$file" 2>/dev/null; then
  echo "append-entry.sh: $file has no kinds table" >&2
  exit 2
fi

# The lock is a folder: mkdir either creates it or fails, in one step. A lock older than 10 seconds
# was left by a session that died (an append takes milliseconds); a writer waits up to 30 seconds.
lock="$file.lock"
held=0
for _ in $(seq 1 300); do
  if mkdir "$lock" 2>/dev/null; then
    held=1
    trap 'rmdir "$lock" 2>/dev/null || true' EXIT
    break
  fi
  if [[ -d "$lock" ]] && (($(date +%s) - $(stat -f %m "$lock" 2>/dev/null || stat -c %Y "$lock" 2>/dev/null || date +%s) > 10)); then
    rmdir "$lock" 2>/dev/null || true
  fi
  sleep 0.1
done
if [[ "$held" != 1 ]]; then
  echo "append-entry.sh: could not take $lock" >&2
  exit 1
fi

case "$mode" in
  log)
    today="$(date +%Y%m%d)"
    last="$(ids log "$file" 2>/dev/null | grep "^$today-" | cut -d- -f2 | sort -n | tail -1 || true)"
    id="$today-$(printf '%02d' $((10#${last:-0} + 1)))"
    [[ -s "$file" ]] || printf '# Suite log\n' > "$file"
    { printf '\n'; sed "1s/<id>/$id/" "$entry"; } >> "$file"
    ;;
  kind)
    last="$(ids kind "$file" | tr -d K | sort -n | tail -1)"
    id="K$((${last:-0} + 1))"
    # the kinds table ends the file
    if ! grep -v '^[[:space:]]*$' "$file" | tail -1 | grep -q '^|'; then
      echo "append-entry.sh: $file does not end with its kinds table" >&2
      exit 2
    fi
    [[ -z "$(tail -c 1 "$file")" ]] || printf '\n' >> "$file"
    sed "1s/<id>/$id/" "$entry" >> "$file"
    ;;
esac

found="$(dups "$mode" "$file")"
[[ -z "$found" ]] || echo "append-entry.sh: $file already holds these ids twice: $(echo $found)" >&2
echo "$id"
