from __future__ import annotations

import argparse
import json
import os
from pathlib import Path


def load_env(repo: Path) -> None:
    for path in (repo / ".env", repo / ".env.local", repo / "frontend" / ".env", repo / "frontend" / ".env.local"):
        if not path.exists():
            continue
        for raw in path.read_text(encoding="utf-8-sig").splitlines():
            line = raw.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def main() -> int:
    parser = argparse.ArgumentParser(description="Check a Supabase connection without printing secrets")
    parser.add_argument("repo", help="Path to the project repo")
    parser.add_argument("--table-like", default="%", help="SQL LIKE pattern for public table names")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    load_env(repo)
    db_url = os.getenv("SUPABASE_DB_URL")
    if not db_url:
        raise SystemExit("SUPABASE_DB_URL is missing")

    try:
        import psycopg
    except ModuleNotFoundError as exc:
        raise SystemExit("Missing psycopg. Install psycopg[binary] in this environment.") from exc

    with psycopg.connect(db_url) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                select table_name
                from information_schema.tables
                where table_schema = 'public' and table_name like %s
                order by table_name
                """,
                (args.table_like,),
            )
            tables = [row[0] for row in cur.fetchall()]
            cur.execute("select current_database(), current_user")
            database, user = cur.fetchone()

    print(json.dumps({"status": "ok", "database": database, "user": user, "tables": tables}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
