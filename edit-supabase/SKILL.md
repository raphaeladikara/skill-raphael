---
name: edit-supabase
description: Safe Supabase schema/data edits for any project. Use when Codex needs to inspect, migrate, backfill, verify, or document Supabase tables/columns/policies using local env credentials, SQL files, or live data fixes that must avoid breaking app-facing fields.
---

# Edit Supabase

## Workflow

Use this skill for Supabase schema and data work. Keep production changes narrow, auditable, and reversible.

1. Read local project docs first:
   - database docs such as `docs/database*.md`, `docs/schema*.md`, or `docs/supabase*.sql`
   - the code path that reads/writes the table, usually files matching `*supabase*`, `*data*`, API routes, backend services, or scripts
2. Load credentials only from local env files. Never print secret values. Accept these env keys:
   - `SUPABASE_DB_URL` for direct Postgres schema/data maintenance.
   - `SUPABASE_SERVICE_ROLE_KEY` plus `SUPABASE_URL` or `NEXT_PUBLIC_SUPABASE_URL` for REST maintenance.
3. Before mutating live data:
   - run a read-only query/check first,
   - identify exact table, columns, row filters, and row count,
   - prefer additive schema changes such as `add column if not exists`,
   - avoid changing frontend-facing columns unless the user explicitly asks.
4. For backfills:
   - derive data from the local source of truth when available, such as seed files, JSON exports, CSVs, SQLite snapshots, or generated run artifacts,
   - dry-run first and report expected row counts,
   - update only the intended columns,
   - verify with a post-change query.
5. After code or SQL changes, update the matching docs/migrations and run lightweight validation.

## Helper Scripts

Use these scripts from the skill directory when useful:

- `scripts/check_connection.py <repo>`: load local env files, connect via `SUPABASE_DB_URL`, and list matching `public` tables/columns without printing secrets.
- `scripts/apply_sql_file.py <repo> <sql-file>`: apply a SQL file with `SUPABASE_DB_URL`. Read the SQL first and ensure it is intentionally scoped.

If `psycopg` is missing, install or add `psycopg[binary]` to the project dev dependencies before using direct Postgres helpers.

## Guardrails

- Do not alter stored source-of-truth fields just to change UI labels; format display labels in the app layer when possible.
- Prefer separate audit columns or JSON fields for extra references, for example `url_name jsonb` and `url jsonb`.
- Do not expose `SUPABASE_SERVICE_ROLE_KEY`, database passwords, or full env files in chat.
- Do not run destructive SQL such as `drop table`, broad `delete`, or broad `update` without an exact row filter and explicit user intent.
- Keep RLS policies intact unless the task is specifically about access control.
