---
name: git-add-push-all
description: Use when the user explicitly asks to git add ., stage everything, commit all current local changes, push everything, push all changes to GitHub, push directly to main/master, or avoid creating a branch while publishing the whole worktree.
---

# Git Add Push All

## Overview

Publish the entire current git worktree exactly because the user asked for an all-in push. This skill is for explicit whole-repo publishing, not selective commits.

## Required User Intent

Proceed only when the user clearly asks for all changes, such as:

- `git add .`
- `push semua`
- `push all`
- `stage everything and push`
- `push ke main jangan bikin branch`

If the user asks to publish but does not clearly want every file, inspect status and ask before staging.

## Workflow

1. Inspect repository state:
   ```powershell
   git status -sb
   git diff --stat
   git branch --show-current
   git remote -v
   ```

2. Confirm branch behavior from the user request:
   - If the user says no branch, stay on the current branch.
   - If the user says push to `main` or `master`, verify the current branch matches.
   - Do not create a branch unless the user explicitly asks.

3. Stage everything exactly as requested:
   ```powershell
   git add .
   git status --short
   git diff --cached --stat
   ```

4. Commit with a terse message that covers the staged scope:
   ```powershell
   git commit -m "Update site content and app"
   ```

5. Push the current branch to origin:
   ```powershell
   git push origin (git branch --show-current)
   ```
   In PowerShell, if command substitution is awkward, assign the branch first:
   ```powershell
   $branch = git branch --show-current
   git push origin $branch
   ```

6. Verify final state:
   ```powershell
   git status -sb
   ```
   Report the commit hash, branch, remote, and whether the worktree is clean.

## Safety Rules

- Do not use this skill for selective commits.
- Do not run destructive commands such as `git reset --hard`, `git checkout --`, or file deletion.
- Do not rewrite history or force-push unless the user explicitly asks and understands the risk.
- Do not create a pull request when the user asked to push directly.
- Mention notable unrelated-looking files before staging, but continue when the user explicitly requested `git add .` or equivalent.

## Common Mistakes

| Mistake | Correct behavior |
| --- | --- |
| Creating a `codex/` branch by habit | Stay on the current branch when the user says no branch. |
| Staging only recent assistant edits | Use `git add .` when the user asks for all changes. |
| Skipping staged diff review | Always inspect `git diff --cached --stat` before commit. |
| Opening a PR after direct push | Do not open a PR unless requested. |
