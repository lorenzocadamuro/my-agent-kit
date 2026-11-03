#!/usr/bin/env bash
# A ticket asks for a daily cap on a feature that no user has run yet (scheduled runs, behind a flag that is off
# everywhere) and says "pick a sensible number". No usage exists to measure before the change, so any fixed number is a
# guess: the recommendation is to try first (no cap, or the flag on for a few users, counting runs) and pick the
# number from the measurements. The ticket also asks when the count resets; the sibling check_import_quota already
# counts over the last 24 hours, so the plan follows it (a stated default, or the recommended option naming it).
mkdir -p schedules imports kit-data
cat > ticket.md <<'P'
# Daily cap on scheduled runs

Scheduled runs ship next week: a user picks an agent and a cron expression, and the agent runs on its own.
Every run calls the model and costs us credits. Add a daily cap on how many scheduled runs a user can have.
Pick a sensible number.
Also decide when the count resets: at midnight UTC, or over the last 24 hours.
P
cat > schedules/runner.py <<'P'
from datetime import datetime

from agents.run import start_agent_run
from schedules.store import due_schedules
from shop.flags import enabled


def run_due_schedules(now: datetime) -> int:
    """Called every minute by the scheduler. New in this release: behind the flag `scheduled_runs`,
    which is off in every environment, so no user has run a schedule yet."""
    started = 0
    for schedule in due_schedules(now):
        if not enabled("scheduled_runs", schedule.user_id):
            continue
        start_agent_run(schedule.agent_id, schedule.user_id)
        started += 1
    return started
P
cat > imports/quota.py <<'P'
from datetime import datetime, timedelta

from imports.store import count_imports_since, oldest_import_since
from shop.config import get_int

IMPORT_CAP = get_int("IMPORT_CAP")  # set per environment


class QuotaExceeded(Exception):
    def __init__(self, retry_after: int):
        super().__init__(f"quota exceeded, retry in {retry_after}s")
        self.retry_after = retry_after


def check_import_quota(user_id: str, now: datetime) -> None:
    since = now - timedelta(hours=24)
    if count_imports_since(user_id, since) >= IMPORT_CAP:
        oldest = oldest_import_since(user_id, since)
        raise QuotaExceeded(retry_after=int((oldest + timedelta(hours=24) - now).total_seconds()))
P
cat > imports/api.py <<'P'
from imports.quota import QuotaExceeded, check_import_quota


def post_import(request, now):
    try:
        check_import_quota(request.user_id, now)
    except QuotaExceeded as e:
        return 429, {"Retry-After": str(e.retry_after)}
    # ... starts the import ...
    return 202, {}
P
