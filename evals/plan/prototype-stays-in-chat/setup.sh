#!/usr/bin/env bash
mkdir -p cards kit-data
cat > ticket.md <<'P'
# Redesign the job card

The job card in the side panel looks dated. Give it a new look: how the status is shown (text, a pill, an icon), where the Stop action sits, and what the title says.
P
cat > cards/job_card.py <<'P'
class JobCard:
    def __init__(self, job):
        self.job = job

    def render(self) -> str:
        return f"[{self.job.status}] Job {self.job.id}  (Stop)"
P
