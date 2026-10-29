---
name: handoff
description: Compact the current conversation into a sanitized handoff document (saved to a file, secrets redacted) for a genuinely different agent, machine, or tool to continue the work. Use when the user asks for a context transfer, continuation note, or "next agent" document meant to leave this session/tool; treat any user-provided arguments as the next session's intended focus. If the user instead says "session handoff" or "wrap up session" to /clear and keep going themselves in the same Claude Code window, use `session-handoff` instead — it's chat-only and skips the file/redaction overhead.
---

# Handoff

## Overview

Write a concise handoff document that lets a fresh agent resume the work without replaying the whole conversation. Save the document in the user's operating-system temporary directory, not in the current workspace, and report the saved path.

## Workflow

1. Identify the next-session focus. If the user supplied arguments after invoking the skill, treat them as the focus and tailor the handoff around that work.
2. Gather only the conversation and local context needed to continue safely: current goal, decisions, touched files, commands run, verification status, blockers, and user preferences.
3. Reference existing artifacts by path or URL instead of duplicating their contents. Prefer links to PRDs, plans, ADRs, issues, commits, diffs, logs, and generated files.
4. Redact secrets and sensitive personal data before writing. Never include API keys, passwords, tokens, cookies, private keys, session IDs, or unnecessary personally identifiable information.
5. Save the handoff as a Markdown file in the OS temp directory:
   - Windows PowerShell: use `$env:TEMP`.
   - macOS/Linux shell: use `${TMPDIR:-/tmp}`.
6. Name the file descriptively, for example `handoff-YYYYMMDD-HHMMSS.md`.
7. Tell the user the absolute path and briefly state what it covers.

## Document Shape

Use this structure unless the situation clearly calls for a shorter variant:

```markdown
# Handoff: <short title>

## Next Session Focus
<What the next agent should do first, especially if provided by the user.>

## Current State
<Brief factual summary of what has happened and where the work stands.>

## Key Decisions
- <Decision and rationale.>

## Files And Artifacts
- `<absolute-or-repo-relative-path>`: <why it matters>
- <URL>: <why it matters>

## Commands And Verification
- Ran: `<command>` -> <result>
- Not run: `<check>` -> <reason>

## Suggested Skills
- `$skill-name`: <why the next agent should invoke it>

## Risks Or Blockers
- <Known issue, missing input, flaky test, unresolved question, or none.>

## Resume Steps
1. <First concrete step.>
2. <Second concrete step.>
```

## Suggested Skills Section

Always include a `Suggested Skills` section. Suggest only skills that are likely useful for the next session, such as:

- Process skills needed by the continuation work, such as debugging, TDD, code review, or branch finishing.
- Domain skills relevant to the files or systems touched.
- Repo-local skills that the next agent should invoke before editing.

Do not pad this section. If no specialized skill is needed, include only the most generally useful continuation skill or write `None beyond standard repo instructions`.

## Redaction Rules

Before saving, scan the handoff for sensitive values and replace them with placeholders:

- `<REDACTED_API_KEY>`
- `<REDACTED_PASSWORD>`
- `<REDACTED_TOKEN>`
- `<REDACTED_PERSONAL_INFO>`

Keep enough surrounding context for the next agent to know where to re-check configuration without exposing the value.

## Quality Bar

- Make the handoff self-contained enough to resume work, but avoid duplicating large artifacts.
- Prefer factual bullets over narrative.
- Include exact dates and paths when they matter.
- Distinguish verified facts from assumptions.
- Mention dirty worktree state or user-owned changes when relevant.
