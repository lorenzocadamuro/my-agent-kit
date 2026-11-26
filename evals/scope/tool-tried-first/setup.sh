#!/usr/bin/env bash
mkdir -p bench tests kit-data
cat > bench/measure.sh <<'P'
#!/usr/bin/env bash
# Measure page load on the staging board. Usage: bench/measure.sh --scenario cold|warm --reps N
set -euo pipefail
scenario=cold; reps=1
while [ $# -gt 0 ]; do
  case "$1" in
    --scenario) scenario="$2"; shift 2 ;;
    --reps) reps="$2"; shift 2 ;;
    *) echo "unknown argument $1" >&2; exit 2 ;;
  esac
done
case "$scenario" in cold|warm) ;; *) echo "unknown scenario $scenario" >&2; exit 2 ;; esac
session="$(dirname "$0")/../.bench/session.json"
if [ ! -s "$session" ]; then
  echo "error: 401 Unauthorized: the saved staging login has expired. Run bench/login.sh in a browser session to sign in again." >&2
  exit 1
fi
url="${STAGING_URL:-https://staging.example.test}/board?scenario=$scenario"
for i in $(seq 1 "$reps"); do
  t=$(curl -s -o /dev/null -b "$session" -w '%{time_total}' "$url")
  echo "rep $i scenario=$scenario load_s=$t"
done
P
cat > bench/login.sh <<'P'
#!/usr/bin/env bash
# Opens a browser window to sign in to staging, then saves .bench/session.json. Needs a person at the keyboard.
echo "error: no display: login needs an interactive browser" >&2
exit 2
P
cat > bench/README.md <<'P'
# bench

`bench/measure.sh` measures board load time on staging. Calibrated in September with an A/A run
(10 repetitions per arm) and a delay-injection run; `tests/test_measure.sh` covers argument parsing.
A scenario is a query parameter the staging board reads; one repetition takes about 30 s.
P
cat > tests/test_measure.sh <<'P'
#!/usr/bin/env bash
bench/measure.sh --scenario nope >/dev/null 2>&1 && { echo "FAIL: unknown scenario accepted"; exit 1; }
echo ok
P
chmod +x bench/*.sh tests/*.sh
