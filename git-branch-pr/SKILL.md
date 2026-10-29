---
name: git-branch-pr
description: Use when starting Git-backed work that should happen on a named branch, or when finishing completed work that should be pushed as a branch and proposed with a pull request instead of pushing directly to main. Also use when Git push or PR creation may need GitHub CLI fallback.
---

# Git Branch PR

## Overview

Use a branch-first Git workflow so local work is saved, reviewed, and proposed through a pull request. Never push directly to `main` or `master` from this skill unless the user explicitly rejects the PR workflow.

## Core Rule

Local files come first. Inspect the worktree, create or use a purpose-named branch, make the requested changes locally, verify them, then push the branch and open a PR only when the user asks to publish.

## Start Of Work

Use this path when the user invokes the skill at the beginning of a task or asks to prepare a branch before edits.

1. Inspect the current repository state:
   ```powershell
   git status -sb
   git branch --show-current
   git remote -v
   ```

2. If the worktree has unrelated existing changes, do not stage, revert, or move them. Mention them briefly and work around them.

3. Derive a branch name from the requested target, using this shape:
   ```text
   codex/<short-action-summary>
   ```
   Examples: `codex/add-pricing-faq`, `codex/fix-login-layout`, `codex/update-readme`.

4. Create and switch to the branch unless already on a suitable non-main branch:
   ```powershell
   git switch -c codex/<short-action-summary>
   ```

5. Make and verify all requested changes locally before any push or deploy action.

## End Of Work

Use this path when the user invokes the skill after changes are complete, or says to push, publish, create a PR, finish the branch, or prepare handoff.

1. Inspect what changed:
   ```powershell
   git status -sb
   git diff --stat
   git diff
   ```

2. Run the relevant local checks for the touched project. If checks are not practical, say why and at least inspect the diff.

3. Ask the user which target branch the PR should go into. Offer `main` as the default only when that matches the repo convention:
   ```text
   Mau PR ini diarahkan ke `main`, atau branch lain?
   ```

4. Stage only the intended files unless the user explicitly asks to include everything:
   ```powershell
   git add -- <file1> <file2>
   git diff --cached --stat
   ```

5. Commit with a specific message:
   ```powershell
   git commit -m "<type>: <summary>"
   ```

6. Push the current branch, not the target branch. Try normal Git first:
   ```powershell
   $branch = git branch --show-current
   git push -u origin $branch
   ```

7. If `git push` fails because of GitHub authentication, missing credentials, remote permission, or upstream setup, use GitHub CLI as the fallback path:
   ```powershell
   gh auth status
   gh auth setup-git
   $branch = git branch --show-current
   git push -u origin $branch
   ```
   If `gh auth status` says the user is not logged in, ask before starting login. If `gh` is unavailable or the fallback still cannot push, stop and report the exact failure instead of pushing to another branch or remote.

8. Create a pull request from the current branch into the target branch. Prefer `gh` after the branch is pushed:
   ```powershell
   gh pr create --base <target-branch> --head <current-branch> --title "<plain title>" --body "<body>"
   ```

   Use a human-readable title that describes the change directly, such as `Add pricing FAQ` or `Fix login layout`.
   Do not prefix PR titles with agent labels like `[codex]`, `[bot]`, `[ai]`, or the branch prefix.

9. If `gh pr create` fails, inspect the reason with:
   ```powershell
   gh auth status
   gh repo view
   gh pr status
   ```
   Retry with explicit `--repo <owner>/<repo>` or `--head <owner>:<current-branch>` only when those values are known. If PR creation still fails, give the user the pushed branch and exact command or URL needed to open the PR manually.

10. Verify and report the PR URL, source branch, target branch, commit hash, checks run, and remaining worktree state.

## Git And GitHub CLI Fallback

Use both tools deliberately:

| Situation | First try | Fallback |
| --- | --- | --- |
| Local status, branch, diff, commit | `git` | No `gh` fallback; local Git is required. |
| Push branch | `git push -u origin <branch>` | `gh auth status`, `gh auth setup-git`, then retry `git push`. |
| Find GitHub repo identity | `git remote -v` | `gh repo view`. |
| Create PR | `gh pr create` | Retry with explicit `--repo`, `--base`, and `--head`; otherwise report manual PR path. |

Do not pretend `gh` can replace every Git operation. Use `gh` to repair GitHub auth/context and create the PR, while keeping local commit and push semantics explicit.

## Target Branch Choice

Always ask before creating the PR unless the user already gave an explicit target branch in the same request. Do not assume `main` when the repo uses another integration branch.

## Safety Rules

- Do not push directly to `main`, `master`, or a protected integration branch unless the user explicitly asks for direct push after being told a PR is safer.
- Do not run `git add .` unless the user explicitly asks to stage every change.
- Do not revert, reset, delete, or overwrite user changes.
- Do not create a PR before local files are saved and checked.
- Do not deploy before the local commit exists unless the user explicitly requests an emergency path.

## Common Mistakes

| Mistake | Correct behavior |
| --- | --- |
| Starting edits on `main` | Create `codex/<task-name>` first when possible. |
| Pushing current branch to `main` | Push the feature branch, then create a PR. |
| Giving up after GitHub auth failure | Use `gh auth status` and `gh auth setup-git`, then retry the branch push. |
| Staging unrelated files | Stage only files that belong to the requested work. |
| Assuming PR target | Ask whether the base should be `main` or another branch. |
| Treating push as deploy | Keep push/PR separate from deploy unless requested. |
| Prefixing PR titles with `[codex]` | Use a plain title that starts with the actual change, for example `Add grill-me skill`. |
