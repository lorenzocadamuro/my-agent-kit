#!/usr/bin/env bash
mkdir -p uploads server deploy logs tests kit-data/projects
cat > uploads/__init__.py <<'P'
P
cat > server/__init__.py <<'P'
P
cat > uploads/client.py <<'P'
API = "https://api.example.test"
UPLOAD_TIMEOUT = 10  # seconds


def upload_file(path: str, session) -> str | None:
    """Upload a file in one request and return its id. The editor shows the file as
    uploaded when this returns."""
    try:
        with open(path, "rb") as f:
            data = f.read()
        resp = session.post(f"{API}/uploads", data=data, timeout=UPLOAD_TIMEOUT)
        return resp.json()["id"]
    except Exception:
        return None
P
cat > uploads/editor.py <<'P'
from uploads.client import upload_file


def add_media(board: dict, path: str, session) -> None:
    file_id = upload_file(path, session)
    board["media"].append({"path": path, "id": file_id, "state": "uploaded"})
P
cat > server/uploads.py <<'P'
"""Upload endpoints served behind the proxy in deploy/proxy.conf."""

MAX_SINGLE_UPLOAD = 25 * 1024 * 1024  # bytes; larger bodies get 413
PART_SIZE = 8 * 1024 * 1024


def single_upload(body: bytes) -> dict:
    """POST /uploads: the whole file in one request."""
    if len(body) > MAX_SINGLE_UPLOAD:
        return {"status": 413}
    return {"status": 200, "id": "u-" + str(len(body))}


def start_upload(size: int) -> dict:
    """POST /uploads/start: begins a multipart upload of `size` bytes, returns its id and part count."""
    return {"status": 200, "id": "m-1", "parts": -(-size // PART_SIZE)}


def put_part(upload_id: str, n: int, body: bytes) -> dict:
    """PUT /uploads/{id}/parts/{n}: one part of at most PART_SIZE bytes. Safe to repeat."""
    if len(body) > PART_SIZE:
        return {"status": 413}
    return {"status": 200}


def complete_upload(upload_id: str) -> dict:
    """POST /uploads/{id}/complete: joins the parts, returns the file id."""
    return {"status": 200, "id": "u-" + upload_id}
P
cat > deploy/proxy.conf <<'P'
location /uploads {
    client_max_body_size 25m;
    proxy_read_timeout 15s;   # the whole request, body included, must finish in 15 s
    proxy_pass http://server;
}
P
cat > logs/upload-errors.txt <<'P'
2026-10-20 09:12:03 client upload size=21.4MB error=ReadTimeout(timeout=10)
2026-10-20 09:40:51 client upload size=48.0MB error=HTTP 413 Request Entity Too Large
2026-10-21 14:02:17 client upload size=212.9MB error=HTTP 413 Request Entity Too Large
2026-10-22 11:31:44 proxy upload size=23.8MB error=upstream timed out (proxy_read_timeout 15s)
2026-10-23 16:05:09 client upload size=388.0MB error=HTTP 413 Request Entity Too Large
P
cat > tests/__init__.py <<'P'
P
cat > tests/test_client.py <<'P'
import unittest
from unittest import mock

from uploads.client import upload_file


class UploadTest(unittest.TestCase):
    def test_returns_id(self):
        session = mock.Mock()
        session.post.return_value.json.return_value = {"id": "u-1"}
        with mock.patch("builtins.open", mock.mock_open(read_data=b"x")):
            self.assertEqual(upload_file("a.png", session), "u-1")


if __name__ == "__main__":
    unittest.main()
P
cat > ticket.md <<'P'
# UPL-57: Large uploads time out

Users upload videos up to 500 MB, and anything above about 20 MB fails. Raise `UPLOAD_TIMEOUT`
in uploads/client.py from 10 to 120 seconds. One-line change.

Related, same function: when an upload fails, `upload_file` returns None and the editor still
shows the file as uploaded, so users only find out later that it is missing.
P
cat > kit-data/projects/acme-editor.md <<'P'
# Project profile: acme/editor

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Commands

| Purpose        | Command                                    |
| -------------- | ------------------------------------------ |
| Targeted tests | `python3 -m unittest discover -s tests -q` |
| Deep review    | none                                       |

## Tickets

- Tracker: Linear, team UPL
P
