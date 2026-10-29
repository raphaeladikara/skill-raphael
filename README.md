# skill-raphael

Raphael's personal Claude Code skills (from `~/.claude/skills`).

Install: copy any folder into `~/.claude/skills/`.

## Skills

- **academic-pptx** — Use this skill whenever the user wants to create or improve a presentation for an academic context — conference papers, seminar talks, thesis defenses, grant 
- **ai-paraphrase** — Scan every word of human-readable text in a project and rewrite it so it reads like a person wrote it, not an LLM. This skill EDITS FILES BY DEFAULT — it does
- **animation-vocabulary** — Reverse-lookup glossary that turns a vague description of a web animation or motion effect into its exact term ("the bouncy thing when a popover opens" → Pop 
- **apple-design** — Apple's approach to interface design and fluid, physical motion, translated for the web. Use when building or reviewing gesture-driven UI, spring animations, dr
- **arena** — Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Use for /arena, 'arena this', 'throw it in the arena
- **bahasa-mahasiswa** — Gaya bahasa dan identitas Raphael untuk semua tugas kuliah, laporan praktikum, artikel tugas, esai, dan dokumen akademik berbahasa Indonesia. Pakai setiap kali 
- **brainstorming** — You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirem
- **case-competition-analyst** — End-to-end analyst for business case competitions and case-based papers. It reads the casebook and guidebook, maps the scoring rubric, diagnoses root causes fro
- **context-discipline** — Use when a session is getting long, before starting a large multi-step or multi-session project, when the user asks about tokens/context/session limits/cost, wh
- **defuddle** — Extract clean markdown content from web pages using Defuddle CLI, removing clutter and navigation to save tokens. Use instead of WebFetch when the user provides
- **deploy-detector-judol** — Use when deploying, releasing, restarting, debugging, or checking production for the Detector Judol / Detector Judi project (repo raphaeladikara/detector-judol,
- **deploy-vps** — Use when deploying a web application to a VPS with SSH, release directories, PM2, and local/remote verification. Use when the user says deploy-vps, deploy to VP
- **deploying-laravel-cloud** — Deploys and manages Laravel applications on Laravel Cloud using the `cloud` CLI. Use when the user wants to deploy an app, ship to cloud, create/manage environm
- **dispatching-parallel-agents** — Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
- **edit-automations** — Safely create, repair, or update Codex automation TOML files under .codex/automations. Use when editing automation.toml prompts, schedules, statuses, models, cw
- **edit-supabase** — Safe Supabase schema/data edits for any project. Use when Codex needs to inspect, migrate, backfill, verify, or document Supabase tables/columns/policies using 
- **emil-design-eng** — This skill encodes Emil Kowalski's philosophy on UI polish, component design, animation decisions, and the invisible details that make software feel great.
- **executing-plans** — Use when you have a written implementation plan to execute in a separate session with review checkpoints
- **find-animation-opportunities** — Search a codebase or UI for places that don't animate but should, and reject everything that shouldn't. Read-only; it proposes motion with exact values, it does
- **finishing-a-development-branch** — Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting stru
- **git-add-push-all** — Use when the user explicitly asks to git add ., stage everything, commit all current local changes, push everything, push all changes to GitHub, push directly t
- **git-branch-pr** — Use when starting Git-backed work that should happen on a named branch, or when finishing completed work that should be pushed as a branch and proposed with a p
- **grill-me** — Interview the user before implementation, design, planning, debugging, refactoring, or product work to resolve ambiguity and reach shared understanding. Use whe
- **handoff** — Compact the current conversation into a sanitized handoff document (saved to a file, secrets redacted) for a genuinely different agent, machine, or tool to cont
- **huashu-design** — HTML-based hi-fi prototypes, interactive demos, slide decks, animation demos, design-variant exploration, design-direction advice, and expert design review — 
- **hyperframes-animation** — All animation knowledge for HyperFrames — atomic motion rules, multi-phase scene blueprints, scene transitions, broader motion-design techniques, AND the seve
- **hyperframes-audio** — >
- **hyperframes-cli** — >
- **hyperframes-core** — The HyperFrames composition contract — build one renderable project. Use for composition structure, the `data-*` timing attributes, `class="clip"`, tracks, su
- **hyperframes-creative** — Non-animation creative direction for HyperFrames videos. Use for design spec (frame.md / design.md) handling, palettes, typography, narration, beat planning, au
- **hyperframes-keyframes** — >
- **hyperframes-registry** — Search, install, and wire registry blocks and components into HyperFrames compositions. Use BEFORE hand-building any named visual — whenever a brief, a user, 
- **hyperframes-studio** — >
- **hyperframes** — >
- **impeccable** — Use when the user wants to design, redesign, shape, critique, audit, polish, clarify, distill, harden, optimize, adapt, animate, colorize, extract, or otherwise
- **improve-animations** — Survey a codebase's animation and motion code as a senior motion advisor, then produce a prioritized audit and self-contained implementation plans for other age
- **json-canvas** — Create and edit JSON Canvas files (.canvas) with nodes, edges, groups, and connections. Use when working with .canvas files, creating visual canvases, mind maps
- **markitdown** — Use when a PDF, DOCX, PPTX, XLSX, EPUB, ZIP or other binary document is about to be read, searched, summarized, or quoted from — including large, scanned-look
- **media-use** — Agent Media OS for a HyperFrames project. Resolve BGM, SFX, image, icon, brand logo, voice, color grade, or LUT into a frozen local file or paste-ready block + 
- **obsidian-bases** — Create and edit Obsidian Bases (.base files) with views, filters, formulas, and summaries. Use when working with .base files, creating database-like views of no
- **obsidian-cli** — Interact with Obsidian vaults using the Obsidian CLI to read, create, search, and manage notes, tasks, properties, and more. Also supports plugin and theme deve
- **obsidian-markdown** — Create and edit Obsidian Flavored Markdown with wikilinks, embeds, callouts, properties, and other Obsidian-specific syntax. Use when working with .md files in 
- **pick-ui-library** — Pick the right library for a given frontend task from a curated, opinionated list — numbers, OTP inputs, charts, command menus, virtualization, drag and drop,
- **prototype** — Build multiple genuinely different versions of a UI piece you describe, rendered behind a visual picker so you can flip through them live and promote the one th
- **receiving-code-review** — Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable - requires technical 
- **requesting-code-review** — Use when completing tasks, implementing major features, or before merging to verify work meets requirements
- **review-animations** — Reviews animation and motion code against a high craft bar derived from Emil Kowalski's design engineering philosophy. Default to flagging; approval is earned.
- **scroll-craft** — >
- **session-handoff** — Use when the user says "session handoff", "wrap up session", "handoff summary", or wants a structured end-of-session summary before running /clear to continue i
- **social-content-workflow** — Create and manage social media content for any brand, especially editorial images, captions, carousels, visual-direction-driven batches, and content archiving. 
- **subagent-driven-development** — Use when executing implementation plans with independent tasks in the current session
- **systematic-debugging** — Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
- **test-driven-development** — Use when implementing any feature or bugfix, before writing implementation code
- **ui-21st** — Improve an existing web app's UI by first understanding the app, then picking matching pieces from Raphael's saved 21st.dev prompt library (landing heroes, SaaS
- **using-git-worktrees** — Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via n
- **vercel-deploy** — Deploy applications and websites to Vercel. Use when the user requests deployment actions like "deploy my app", "deploy and give me the link", "push this live",
- **verification-before-completion** — Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output be
- **vibe-security** — Audits codebases for common security vulnerabilities that AI coding assistants introduce in "vibe-coded" applications. Checks for exposed API keys, broken acces
- **writing-plans** — Use when you have a spec or requirements for a multi-step task, before touching code
- **writing-skills** — Use when creating new skills, editing existing skills, or verifying skills work before deployment
