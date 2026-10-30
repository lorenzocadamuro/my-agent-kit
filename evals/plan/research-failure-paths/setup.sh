#!/usr/bin/env bash
mkdir -p server runner deploy tests kit-data/projects
cat > server/__init__.py <<'P'
P
cat > runner/__init__.py <<'P'
P
cat > server/transport.py <<'P'
class RunnerBusy(Exception):
    """The runner answered 503: all its slots are taken."""


class RunnerRejected(Exception):
    """The runner answered 422: it refused the payload."""


def post(url: str, payload: dict, timeout: float) -> dict:
    """POST `payload` as JSON to `url`. Raises RunnerBusy on 503, RunnerRejected on 422,
    TimeoutError when no answer comes within `timeout` seconds."""
    raise NotImplementedError("network call, replaced in tests")
P
cat > server/dispatch.py <<'P'
from server import transport

RUNNER_URL = "http://runner.internal/jobs"


def build_payload(job: dict) -> dict:
    return {
        "job_id": job["id"],
        "kind": job["kind"],
        "input_url": job["input_url"],
    }


def send_job(job: dict) -> dict:
    """Hand a job to the runner. On any failure the job is marked failed."""
    try:
        answer = transport.post(RUNNER_URL, build_payload(job), timeout=10)
    except (transport.RunnerBusy, transport.RunnerRejected, TimeoutError) as exc:
        job["status"] = "failed"
        job["error"] = type(exc).__name__
        return job
    job["status"] = "queued"
    job["runner_ref"] = answer["ref"]
    return job
P
cat > server/api.py <<'P'
from server.dispatch import send_job


def create_job(request: dict, db) -> dict:
    """POST /jobs. Saves the job and hands it to the runner inside the same request."""
    job = db.insert("jobs", {"kind": request["kind"], "input_url": request["input_url"],
                             "priority": request.get("priority", 0), "status": "new"})
    job = send_job(job)
    db.update("jobs", job)
    return job
P
cat > runner/schema.py <<'P'
from pydantic import BaseModel, ConfigDict


class JobPayload(BaseModel):
    """What the runner accepts on POST /jobs. Any unknown field is refused with a 422."""

    model_config = ConfigDict(extra="forbid")

    job_id: str
    kind: str
    input_url: str
    priority: int = 0
P
mkdir -p docs/releases deploy/environments deploy/gateway
cat > docs/releases/runner.md <<'P'
# Runner changelog

The runner is built and deployed by the runner team on its own schedule (usually Thursdays),
independently of the server, which deploys on every merge to main.

## Unreleased

- Accept an optional `priority` field in `JobPayload`.

## 1.4.0 — deployed to production 2026-09-03

- Refuse unknown payload fields with a 422 (`extra="forbid"`), to catch server bugs early.
P
cat > deploy/environments/production.yaml <<'P'
region: eu-west-1
replicas:
  server: 6
  runner: 12
images:
  server: continuous   # deployed on every merge to main
  runner: 1.4.0        # released by the runner team, next release not scheduled
  scheduler: 2.0.3
P
cat > deploy/environments/staging.yaml <<'P'
region: eu-west-1
replicas:
  server: 1
  runner: 2
images:
  server: continuous
  runner: 1.4.0
  scheduler: 2.0.3
P
cat > deploy/gateway/routes.yaml <<'P'
defaults:
  timeout_seconds: 30   # every request is cut here unless a route overrides it
routes:
  - path: /jobs
    service: server
  - path: /reports
    service: reports
    timeout_seconds: 120
  - path: /health
    service: server
P
cat > tests/__init__.py <<'P'
P
cat > tests/test_dispatch.py <<'P'
import unittest
from unittest import mock

from server import dispatch, transport


class SendJobTest(unittest.TestCase):
    def test_busy_runner_marks_job_failed(self):
        job = {"id": "j1", "kind": "render", "input_url": "s3://in/1"}
        with mock.patch.object(transport, "post", side_effect=transport.RunnerBusy()):
            self.assertEqual(dispatch.send_job(job)["status"], "failed")

    def test_queued_on_success(self):
        job = {"id": "j1", "kind": "render", "input_url": "s3://in/1"}
        with mock.patch.object(transport, "post", return_value={"ref": "r1"}):
            self.assertEqual(dispatch.send_job(job)["status"], "queued")


if __name__ == "__main__":
    unittest.main()
P
# Filler: the rest of the service, so the relevant files are a few among many.
mkdir -p server/billing server/reports runner/steps deploy/k8s docs/adr
for n in invoices refunds taxes plans usage coupons; do
  printf 'def %s_total(rows: list[dict]) -> int:\n    return sum(r["cents"] for r in rows)\n' "$n" > "server/billing/$n.py"
done
for n in daily weekly monthly export usage errors; do
  printf 'def build_%s(db) -> list[dict]:\n    return db.select("jobs", group_by="kind")\n' "$n" > "server/reports/$n.py"
done
for n in fetch decode render encode upload notify cleanup; do
  printf 'def run(job: dict) -> dict:\n    """Step %s of a render job."""\n    return job\n' "$n" > "runner/steps/$n.py"
done
for n in server runner scheduler reports; do
  printf 'apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: %s\n' "$n" > "deploy/k8s/$n.yaml"
done
for n in 0001-queue 0002-storage 0003-auth 0004-metrics 0005-regions; do
  printf '# %s\n\nAccepted.\n' "$n" > "docs/adr/$n.md"
done
for n in server scheduler reports; do
  printf '# %s releases\n\n## 2.0.3\n\n- Internal fixes.\n' "$n" > "docs/releases/$n.md"
done
mkdir -p server/handlers runner/codecs
for n in accounts assets audit auth boards captions comments credits exports feeds folders invites keys labels limits locales media members notes orgs previews projects quotas search sessions shares tags teams thumbnails webhooks; do
  printf 'def handle_%s(request: dict, db) -> dict:\n    """GET and POST /%s."""\n    return {"status": 200, "items": db.select("%s")}\n' "$n" "$n" "$n" > "server/handlers/$n.py"
done
for n in av1 h264 h265 vp9 png jpeg webp gif exr tiff; do
  printf 'def encode(frames: list) -> bytes:\n    """%s encoder."""\n    return b""\n' "$n" > "runner/codecs/$n.py"
done
cat > ticket.md <<'P'
# JOB-212: Send the job priority to the runner, and retry when it is busy

Two small server-side changes in server/dispatch.py:

1. The jobs table already stores `priority`. Add it to the payload `build_payload` sends, so the
   runner can schedule urgent jobs first. The runner already accepts the field (see
   runner/schema.py), so this is a server-only change.
2. When the runner answers 503 (busy), do not fail the job: retry the dispatch until the runner
   takes it.
P
cat > kit-data/projects/acme-jobs.md <<'P'
# Project profile: acme/jobs

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Rules to load

| Area (path glob) | Guide       |
| ---------------- | ----------- |
| `**`             | `README.md` |

## Commands

| Purpose        | Command                                    |
| -------------- | ------------------------------------------ |
| Targeted tests | `python3 -m unittest discover -s tests -q` |
| Deep review    | none                                       |

## Tickets

- Tracker: Linear, team JOB
P
