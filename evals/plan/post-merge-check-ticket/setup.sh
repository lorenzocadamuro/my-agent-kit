#!/usr/bin/env bash
mkdir -p alerts scripts kit-data/projects
cat > ticket.md <<'P'
# ALR-12 Page the on-call team from production monitors

Every production monitor in `alerts/monitors.yaml` must also notify `pager-oncall`, besides its current notifier.

Done when:
- every monitor with `env: production` lists `pager-oncall` in `notify`;
- the change is synced to production (the sync job runs on the first deploy after the merge).
P
cat > alerts/notifiers.yaml <<'P'
notifiers:
  - name: chat-alerts
  - name: pager-oncall
P
cat > alerts/monitors.yaml <<'P'
monitors:
  - name: api-errors
    env: production
    query: "status >= 500"
    notify: [chat-alerts]
  - name: queue-depth
    env: production
    query: "queue.depth > 1000"
    notify: [chat-alerts]
  - name: staging-errors
    env: staging
    query: "status >= 500"
    notify: [chat-alerts]
P
cat > scripts/validate.sh <<'P'
#!/usr/bin/env bash
# Checks that every monitor has a name, an env and a query.
set -e
f=alerts/monitors.yaml
for key in name env query; do
  want=$(grep -c "^  - name:" "$f")
  got=$(grep -cE "^    ${key}:|^  - ${key}:" "$f")
  [ "$got" -ge "$want" ] || { echo "missing $key"; exit 1; }
done
echo "monitors.yaml: ok"
P
chmod +x scripts/validate.sh
cat > scripts/sync.sh <<'P'
#!/usr/bin/env bash
# Run by the deploy pipeline after a merge: pushes monitors to the monitoring service.
echo "sync runs only in the deploy pipeline" >&2
exit 2
P
chmod +x scripts/sync.sh
cat > kit-data/projects/acme-alerts.md <<'P'
# Project profile: acme/alerts

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Commands

| Purpose        | Command                |
| -------------- | ---------------------- |
| Validate       | `scripts/validate.sh`  |
| Deep review    | none                   |

## Post-merge checks

- `scripts/sync.sh` runs in the deploy pipeline after the merge; it cannot run locally.

## Tickets

- Tracker: none (tickets are files)
P
