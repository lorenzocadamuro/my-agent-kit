#!/usr/bin/env bash
mkdir -p app kit-data
cat > app/cache.py <<'P'
import threading

_lock = threading.Lock()
_cache: dict[str, str] = {}


def get(key: str) -> str | None:
    with _lock:
        return _cache.get(key)


def put(key: str, value: str) -> None:
    with _lock:
        _cache[key] = value


def clear() -> None:
    _cache.clear()
P
cat > comments.md <<'P'
Comments on PR acme/app#5 (unresolved):

C1 (bugbot, app/cache.py line 17): `clear()` mutates `_cache` without holding `_lock`, so a concurrent `put` can race with it.
C2 (review-bot, app/cache.py line 16): Thread-safety: the cache is cleared outside the lock; take `_lock` in `clear()` like `get` and `put` do.
C3 (bugbot, app/cache.py line 8): `get` reads `_cache` without the lock, which can return a stale value.
P
