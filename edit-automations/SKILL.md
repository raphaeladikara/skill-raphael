---
name: edit-automations
description: Safely create, repair, or update Codex automation TOML files under .codex/automations. Use when editing automation.toml prompts, schedules, statuses, models, cwds, or deploy instructions; when automations disappear from the UI after an edit; when changing multiple scheduled automation prompts such as 08:00/12:00/20:00 jobs; or when validating automation TOML parsing before finishing.
---

# Edit Automations

## Core Rule

Treat `automation.toml` as a fragile config file, not freeform text. Never paste raw multi-line prompt text directly inside `prompt = "..."`; encode it through a TOML/JSON string writer and validate every automation after editing.

## Workflow

1. Locate automation folders.
   - Default root: `%CODEX_HOME%\automations` when `CODEX_HOME` is set, otherwise `%USERPROFILE%\.codex\automations`.
   - Confirm target folders by `id`, `name`, `status`, and `rrule`.

2. Read before editing.
   - Inspect the current `automation.toml`.
   - Preserve unrelated fields: `version`, `id`, `kind`, `name`, `status`, `rrule`, `model`, `reasoning_effort`, `execution_environment`, `cwds`, `created_at`, and memory files.
   - Preserve `status = "PAUSED"` unless the user explicitly asks to activate it.

3. Build TOML values safely.
   - Use a serializer for long text fields. In Python, use `json.dumps(value, ensure_ascii=False)` for TOML basic strings because valid JSON strings are valid TOML strings for this use case.
   - The prompt value in the file must remain one physical TOML line, with embedded newlines represented as `\n`.
   - The `rrule` file source must contain escaped `\n`, so the parsed value becomes two lines:

```toml
rrule = "DTSTART;TZID=Asia/Jakarta:20260429T080000\nRRULE:FREQ=DAILY;BYHOUR=8;BYMINUTE=0"
```

   - Do not write this invalid form:

```toml
rrule = "DTSTART;TZID=Asia/Jakarta:20260429T080000
RRULE:FREQ=DAILY;BYHOUR=8;BYMINUTE=0"
```

4. Prefer whole-file regeneration for heavily edited automation TOML.
   - For fragile prompt edits, reconstruct the file from parsed/known fields using serialized string values.
   - Set `updated_at` to current epoch milliseconds after intentional edits.
   - Keep `created_at` unchanged.

5. Validate immediately.
   - Run the bundled validator:

```powershell
python %USERPROFILE%\.codex\skills\edit-automations\scripts\validate_automations.py
```

   - For target-only validation:

```powershell
python %USERPROFILE%\.codex\skills\edit-automations\scripts\validate_automations.py %USERPROFILE%\.codex\automations\example-daily-job
```

   - All touched automations must parse, show expected `status`, and show expected `rrule` line count.

6. If automations disappeared from UI.
   - Validate all automation folders, not only the one the user mentioned. One bad TOML can poison a broad loader.
   - Fix malformed TOML first; then refresh the Automations page or restart Codex if the UI is cached.

## Safe Python Pattern

Use this pattern when updating prompt text in one or more automation TOML files:

```python
from pathlib import Path
import json, time

path = Path.home() / ".codex" / "automations" / "example" / "automation.toml"
prompt = "Line one\n\nLine two"
rrule = "DTSTART;TZID=Asia/Jakarta:20260429T080000\nRRULE:FREQ=DAILY;BYHOUR=8;BYMINUTE=0"

text = "\n".join([
    "version = 1",
    f"id = {json.dumps('example')}",
    'kind = "cron"',
    f"name = {json.dumps('Example Automation')}",
    f"prompt = {json.dumps(prompt, ensure_ascii=False)}",
    'status = "ACTIVE"',
    f"rrule = {json.dumps(rrule)}",
    'model = "gpt-5.5"',
    'reasoning_effort = "medium"',
    'execution_environment = "local"',
    'cwds = ["C:\\\\path\\\\to\\\\repo"]',
    "created_at = 1777468500000",
    f"updated_at = {int(time.time() * 1000)}",
    "",
])

path.write_text(text, encoding="utf-8")
```

## Final Checklist

- `tomllib` parse succeeds for every automation under the automation root.
- Touched prompts contain the requested new text.
- Touched prompts do not contain stale removed text.
- `rrule` parses into the expected line count and schedule.
- `status` is correct and not accidentally changed.
- `cwds` remains a valid Windows path string with escaped backslashes.
- If the UI was open, tell the user to refresh/restart Codex only after validation passes.
