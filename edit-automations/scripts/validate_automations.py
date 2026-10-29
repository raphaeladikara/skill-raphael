#!/usr/bin/env python3
"""Validate Codex automation.toml files after edits."""

from __future__ import annotations

import os
import sys
import tomllib
from pathlib import Path


REQUIRED_KEYS = {
    "version",
    "id",
    "kind",
    "name",
    "prompt",
    "status",
    "rrule",
    "model",
    "reasoning_effort",
    "execution_environment",
    "cwds",
    "created_at",
    "updated_at",
}


def default_root() -> Path:
    codex_home = os.environ.get("CODEX_HOME")
    if codex_home:
        return Path(codex_home) / "automations"
    return Path.home() / ".codex" / "automations"


def automation_files(args: list[str]) -> list[Path]:
    roots = [Path(arg) for arg in args] if args else [default_root()]
    files: list[Path] = []
    for root in roots:
        if root.is_file():
            files.append(root)
        elif (root / "automation.toml").is_file():
            files.append(root / "automation.toml")
        elif root.is_dir():
            files.extend(sorted(root.glob("*/automation.toml")))
        else:
            raise FileNotFoundError(f"No automation file or directory found: {root}")
    return sorted(set(files))


def validate_file(path: Path) -> tuple[bool, str]:
    try:
        raw = path.read_text(encoding="utf-8-sig")
        data = tomllib.loads(raw)
    except Exception as error:  # noqa: BLE001 - report parser details verbatim.
        return False, f"BAD {path}: TOML parse failed: {error}"

    missing = sorted(REQUIRED_KEYS - data.keys())
    if missing:
        return False, f"BAD {path}: missing required keys: {', '.join(missing)}"

    problems: list[str] = []
    if data["kind"] != "cron":
        problems.append(f"kind is {data['kind']!r}, expected 'cron'")
    if data["status"] not in {"ACTIVE", "PAUSED"}:
        problems.append(f"status is {data['status']!r}, expected ACTIVE or PAUSED")
    if not isinstance(data["prompt"], str) or not data["prompt"].strip():
        problems.append("prompt is empty or not a string")
    if not isinstance(data["rrule"], str) or "RRULE:" not in data["rrule"]:
        problems.append("rrule is missing RRULE line")
    if "\\nRRULE:" in data["rrule"]:
        problems.append("rrule parsed with literal '\\n'; file likely has double-escaped newline")
    if "\n" in raw.split('prompt = "', 1)[0] and 'prompt = "' not in raw:
        problems.append("prompt line is not a TOML basic string assignment")
    if not isinstance(data["cwds"], list) or not all(isinstance(item, str) for item in data["cwds"]):
        problems.append("cwds must be a list of strings")

    if problems:
        return False, f"BAD {path}: {'; '.join(problems)}"

    rrule_lines = data["rrule"].splitlines()
    prompt_lines = data["prompt"].splitlines()
    cwd_count = len(data["cwds"])
    return (
        True,
        "OK "
        f"{path.parent.name}: status={data['status']} "
        f"name={data['name']!r} "
        f"rrule_lines={len(rrule_lines)} "
        f"prompt_chars={len(data['prompt'])} "
        f"prompt_lines={len(prompt_lines)} "
        f"cwd_count={cwd_count}",
    )


def main() -> int:
    try:
        files = automation_files(sys.argv[1:])
    except Exception as error:  # noqa: BLE001
        print(f"BAD automation discovery: {error}", file=sys.stderr)
        return 2

    if not files:
        print("BAD no automation.toml files found", file=sys.stderr)
        return 2

    failed = False
    for path in files:
        ok, message = validate_file(path)
        print(message)
        failed = failed or not ok

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
