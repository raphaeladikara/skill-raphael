#!/usr/bin/env python3
"""Keep repo-root content/now to a maximum number of date folders."""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path

DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


GUIDES = {
    "reference": """# Content References

Add visual direction, brand notes, example post screenshots, tone, typography, layout notes, and do/don't references here.
Use this as inspiration and quality direction, not as a folder to copy designs exactly.
""",
    "past": """# Past Content

Archived finished campaigns live here after they leave content/now.
Review this folder before creating new content so social posts improve over time and stay consistent.
""",
    "now": """# Current Content

Keep active social content here, grouped by date: YYYY-MM-DD/<campaign-slug>.
This folder should contain at most 5 date folders; older dates move to content/past.
""",
}


def ensure_structure(repo_root: Path) -> None:
    content = repo_root / "content"
    for name, guide in GUIDES.items():
        folder = content / name
        folder.mkdir(parents=True, exist_ok=True)
        readme = folder / "README.md"
        if not readme.exists():
            readme.write_text(guide, encoding="utf-8")


def unique_destination(past_root: Path, folder_name: str) -> Path:
    dest = past_root / folder_name
    if not dest.exists():
        return dest

    index = 2
    while True:
        candidate = past_root / f"{folder_name}-{index}"
        if not candidate.exists():
            return candidate
        index += 1


def rotate(repo_root: Path, max_days: int, dry_run: bool) -> list[tuple[Path, Path]]:
    ensure_structure(repo_root)

    now_root = repo_root / "content" / "now"
    past_root = repo_root / "content" / "past"
    date_folders = sorted(
        [path for path in now_root.iterdir() if path.is_dir() and DATE_RE.match(path.name)],
        key=lambda path: path.name,
    )
    overflow = max(0, len(date_folders) - max_days)
    moves: list[tuple[Path, Path]] = []

    for source in date_folders[:overflow]:
        destination = unique_destination(past_root, source.name)
        moves.append((source, destination))
        if not dry_run:
            shutil.move(str(source), str(destination))

    return moves


def main() -> int:
    parser = argparse.ArgumentParser(description="Rotate social content folders.")
    parser.add_argument("--repo-root", default=".", help="Repository root that contains or should contain content/.")
    parser.add_argument("--max-days", type=int, default=5, help="Maximum YYYY-MM-DD folders to keep in content/now.")
    parser.add_argument("--dry-run", action="store_true", help="Print planned moves without moving folders.")
    args = parser.parse_args()

    if args.max_days < 1:
        parser.error("--max-days must be at least 1")

    repo_root = Path(args.repo_root).expanduser().resolve()
    moves = rotate(repo_root, args.max_days, args.dry_run)

    if not moves:
        print("No rotation needed.")
        return 0

    prefix = "Would move" if args.dry_run else "Moved"
    for source, destination in moves:
        print(f"{prefix}: {source} -> {destination}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
