#!/usr/bin/env bash
# A small diff: invalidate() now drops every key that starts with the prefix, so clearing
# tenant "acme" also drops the entries of tenant "acme2".
mkdir -p app tests git-out
touch app/__init__.py
cat > app/cache.py <<'P'
_store: dict[str, object] = {}


def put(key: str, value: object) -> None:
    _store[key] = value


def get(key: str):
    return _store.get(key)


def invalidate(prefix: str) -> int:
    """Drop every entry whose key starts with prefix; return how many were dropped."""
    dead = [k for k in _store if k.startswith(prefix)]
    for k in dead:
        del _store[k]
    return len(dead)
P
cat > app/orders.py <<'P'
from app import cache


def order_key(tenant: str, order_id: int) -> str:
    return f"{tenant}:{order_id}"


def save_order(tenant: str, order_id: int, total: float) -> None:
    cache.put(order_key(tenant, order_id), total)


def clear_tenant(tenant: str) -> int:
    return cache.invalidate(tenant)
P
cat > tests/test_orders.py <<'P'
from app import cache, orders


def test_clear_tenant():
    orders.save_order("acme", 1, 10.0)
    assert orders.clear_tenant("acme") == 1
    assert cache.get("acme:1") is None
P
cat > git-out/diff.txt <<'P'
$ git diff origin/main...HEAD
diff --git a/app/cache.py b/app/cache.py
@@ -12,6 +12,7 @@ def get(key: str):
 def invalidate(prefix: str) -> int:
-    """Drop every entry whose key is prefix + ":" + something; return how many were dropped."""
-    dead = [k for k in _store if k.split(":", 1)[0] == prefix]
+    """Drop every entry whose key starts with prefix; return how many were dropped."""
+    dead = [k for k in _store if k.startswith(prefix)]
     for k in dead:
         del _store[k]
     return len(dead)
P
