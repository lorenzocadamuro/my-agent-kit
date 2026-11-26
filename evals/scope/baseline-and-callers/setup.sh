#!/usr/bin/env bash
mkdir -p billing tests scripts kit-data/projects
cat > billing/limits.py <<'P'
IMAGE_QUOTA = 100


def check_quota(team_usage: int, kind: str) -> bool:
    if kind != "image":
        return False
    return team_usage < IMAGE_QUOTA
P
cat > billing/jobs.py <<'P'
from billing.limits import check_quota


def create_job(team_usage: int, kind: str) -> dict:
    if not check_quota(team_usage, kind):
        raise ValueError("quota exceeded")
    return {"kind": kind, "state": "admitted"}
P
cat > billing/startup.py <<'P'
from billing import limits

PENDING: list[dict] = []


def resume_pending(team_usage: int) -> list[dict]:
    resumed = []
    for job in PENDING:
        if limits.check_quota(team_usage, "image"):
            job["state"] = "admitted"
            resumed.append(job)
        else:
            job["state"] = "failed"
    return resumed
P
cat > tests/test_jobs.py <<'P'
import unittest

from billing.jobs import create_job


class CreateJobTest(unittest.TestCase):
    def test_image_job_admitted(self):
        self.assertEqual(create_job(1, "image")["state"], "admitted")


if __name__ == "__main__":
    unittest.main()
P
cat > scripts/lint-contracts.sh <<'P'
#!/usr/bin/env bash
set -e
contractlint billing/
P
chmod +x scripts/lint-contracts.sh
cat > kit-data/projects/acme-billing.md <<'P'
# Project profile: acme/billing

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Rules to load

| Area (path glob) | Guide       |
| ---------------- | ----------- |
| `**`             | `README.md` |

## Commands

| Purpose        | Command                                       |
| -------------- | --------------------------------------------- |
| Targeted tests | `python3 -m unittest discover -s tests -q`    |
| Lint / format  | `scripts/lint-contracts.sh`                   |
| Deep review    | none                                          |

## Tickets

- Tracker: none
P
