---
name: context-discipline
description: Use when a session is getting long, before starting a large multi-step or multi-session project, when the user asks about tokens/context/session limits/cost, when an attempt just failed and you're about to retry, or when deciding whether to read a large external file (PDF/DOCX/HTML) directly. Applies token- and context-management habits (manual compaction before auto-compact, /rewind over "continue" on failed attempts, file-backed state, session chaining, markdown conversion, subagent delegation) so sessions stay fast, cheap, and accurate instead of degrading into context rot.
---

# Context Discipline

Claude Code rereads the entire conversation on every single message, so cost and error rate compound as a session grows, not just add up. Retrieval accuracy measurably drops as context fills (roughly 92% at 256K tokens down to 78% at 1M). The 1M-token window is insurance for the rare task that needs it, not a target to fill. Treat context the way a good editor treats prose: cut what isn't earning its place, before it becomes a fixed cost the whole rest of the session has to carry.

## Core habits, in priority order

1. **Prefer `/rewind` over "continue" after a failed attempt.** When Claude's approach didn't work and the user says "try this instead," the broken code and dead-end reasoning stay in context and pollute every later response unless rewound. Double-tap Escape or run `/rewind` to drop everything after the last good point, rather than piling a correction on top of the mistake.

2. **Compact manually well before auto-compaction fires.** Auto-compaction triggers at ~95% of the window — the model's least sharp point — and keeps only 20-30% of the original detail. Don't wait for it. As a rule of thumb, when a single session's context is climbing past roughly the 100-120K token mark (or ~60% of whatever window is active), proactively suggest wrapping up: produce a summary (or invoke `session-handoff` for a structured one), have the user run `/clear`, then paste the summary back in to continue. This is nearly always better than `/compact`.

3. **Push durable state into files, not just chat memory.** Tracking sheets, task lists, decision logs, and plan files mean a `/clear` doesn't erase progress — it's closing browser tabs while keeping the bookmarks. Before proposing a reset, make sure anything load-bearing (decisions, file paths, running state) is already written down, not just implied by prior chat turns.

4. **Chain sessions for big projects instead of doing everything in one.** A natural split for large work: one pass to read source material and produce a summary/plan doc, a second pass that reads that doc and produces a plan, a third that reads the plan and executes. Each stage starts fresh and reads only the previous stage's output — not the raw material again.

5. **Delegate bulk reading/research to subagents.** A subagent gets its own fresh context window, does the reading, and returns only the synthesized result — like a research intern you don't watch read fifty articles. Reach for the `Agent` tool for broad exploration, multi-file research, or repetitive lookups instead of reading everything into the main session directly. Cheaper models are a good fit for pure summarization subtasks when the harness offers a choice.

6. **Convert dense formats to Markdown before ingesting them, when fidelity allows.** Rough savings: HTML→Markdown ~90% fewer tokens, PDF→Markdown ~65-70%, DOCX→Markdown ~33%. If a large PDF/HTML/DOCX is about to be read wholesale and OCR/visual layout isn't actually needed, converting first (on this machine: the `markitdown` skill) before reading is worth the extra step. Skip this when the visual layout or embedded images are the point.

7. **Don't chase savings by trimming response length.** Telling Claude to "be concise" saves less than people expect, because a lot of output tokens are invisible (file writes, tool calls). The actual lever is context/input management — the habits above — not shorter prose.

8. **Keep CLAUDE.md and always-loaded config lean.** It loads every single session. Anything project-specific-but-rare belongs in a skill or reference file that loads on demand instead. If asked to add a new standing rule, prefer a skill over growing CLAUDE.md when the rule only applies to a subset of tasks.

## When to speak up proactively

- The conversation has clearly grown large (many tool calls, long history, or the user mentions lag/slowness/repetition) → suggest `session-handoff` + `/clear`, don't just wait for auto-compaction.
- A fix attempt just failed and the user is about to ask for another try → suggest `/rewind` to the last good point instead of layering a new attempt on the failed one.
- A task is about to involve reading a large PDF/HTML/DOCX in full → check whether a markdown conversion would preserve what's needed at a fraction of the tokens.
- A request is actually 3+ largely-independent lookups or a big read-heavy investigation → delegate to subagent(s) rather than doing it all inline.

Don't narrate this skill when it doesn't change what you'd do anyway — apply the habit and move on, the same as any other skill.
