from __future__ import annotations

import argparse
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
    parser = argparse.ArgumentParser(description="Apply a reviewed SQL file to Supabase via SUPABASE_DB_URL")
    parser.add_argument("repo", help="Path to the project repo")
    parser.add_argument("sql_file", help="Reviewed SQL file to apply")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    sql_file = Path(args.sql_file).resolve()
    if not sql_file.exists():
        raise SystemExit(f"SQL file not found: {sql_file}")
    sql = sql_file.read_text(encoding="utf-8-sig").strip()
    if not sql:
        raise SystemExit("SQL file is empty")

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
            cur.execute(sql)
        conn.commit()

    print(f"Applied SQL file: {sql_file}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
