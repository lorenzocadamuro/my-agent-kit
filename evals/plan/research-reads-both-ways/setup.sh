#!/usr/bin/env bash
mkdir -p cards shared app kit-data
cat > ticket.md <<'P'
# Rename the job card to "run card" and restyle it

Rename `cards/job_card.py` to `cards/run_card.py` and the class `JobCard` to `RunCard`, and give it the new look (rounded, a status pill).
Everything user-facing says "run" instead of "job" on the new card.
The rename and the new look sit behind the flag `run_card`. With the flag off, users see today's screens exactly.
P
cat > cards/job_card.py <<'P'
from shared.labels import status_label

# Off on purpose: a Cancel shown before the server confirmed it led to double refunds when the
# request failed. Keep the card waiting for the server.
OPTIMISTIC_CANCEL = False


class JobCard:
    def __init__(self, job):
        self.job = job

    def title(self) -> str:
        return f"Job {self.job.id}: {status_label(self.job.status)}"

    def cancel(self, api):
        if OPTIMISTIC_CANCEL:
            self.job.status = "cancelled"
        api.cancel(self.job.id)
P
cat > shared/labels.py <<'P'
def status_label(status: str) -> str:
    return {"queued": "Job queued", "running": "Job running", "done": "Job done"}.get(status, status)
P
cat > cards/classic_list.py <<'P'
# The list users see when the flag `run_card` is off.
from shared.labels import status_label


def render(jobs):
    return [status_label(j.status) for j in jobs]
P
cat > app/panel.py <<'P'
from cards.job_card import JobCard


def panel(jobs, flags):
    if flags.get("run_card"):
        return [JobCard(j) for j in jobs]
    from cards.classic_list import render
    return render(jobs)
P
cat > app/history.py <<'P'
import cards.job_card as jc


def history_row(job) -> "jc.JobCard":
    return jc.JobCard(job)
P
