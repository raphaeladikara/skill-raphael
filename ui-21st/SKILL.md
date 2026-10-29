---
name: ui-21st
description: Improve an existing web app's UI by first understanding the app, then picking matching pieces from Raphael's saved 21st.dev prompt library (landing heroes, SaaS templates, testimonials, bento grids, carousels, dashboard sidebars/shells, gradients, WebGL shader backgrounds, themes) and integrating them adapted to the app's real content and stack. Use whenever the task is improving, redesigning, polishing, or re-evaluating the UI/UX of a web app, dashboard, or its landing page ("improve UI-UXnya", "perbaiki tampilan", "rombak design", "bikinin landing page", "visual cue", "dashboard biar enak dilihat"), and whenever the user pastes a 21st.dev prompt ("You are given a task to integrate an existing React component", "Add an animated WebGL shader background", "Recreate the ... gradient from 21st.dev", a 21st.dev link) so it can be used and offered for saving.
---

# ui-21st

A personal library of 21st.dev prompts, plus the workflow for using them. The library lives at
`C:/Users/Raphael Angelo/.claude/skills/ui-21st/library/`. Claude Code and Codex share this path.

## Workflow when improving a UI

### 1. Understand the app before you touch anything
Read just enough to answer each of these in one line. Don't dump files.
- **What it is:** the product, who uses it (e.g. company analysts, judges, end users), and the one job each main page does.
- **Stack:** framework (Next/Vite/plain HTML), Tailwind?, shadcn (`components.json`)?, TypeScript?, where components live, icon set, and chart library.
- **Current design system:** tokens and palette, fonts, dark/light mode, and what already looks good (keep that).
- **Pain points:** what the user complained about, plus what you see (cramped forms, long scrolling sections, cards that aren't interpretable, AI-looking fonts, broken layout, weak visual cues).

If the app is running, look at it in the browser. A screenshot beats guessing.

### 2. Match against the library
Read `library/INDEX.md` only. Don't read the entry files yet. For each pain point or page, look for an entry whose
*use when* fits. Matching is by **job**, not by name. For example, `stagger-testimonials` already worked as a
sliding stepper for a long verification form, and the coverflow carousel can show case files or reports.

Then present a short mapping to the user before building:

| Page / section | Problem | Library entry | How it'll be adapted |
|---|---|---|---|

Also list sections that have **no** good match, and say what you'd do there instead. Wait for a go-ahead unless the
user already said to just do it.

### 3. Integrate: adapt, don't paste
Now open the chosen entry files. Each has notes plus the verbatim original prompt.
- **Real content only:** replace the demo copy, avatars, Unsplash images, and "COMPANY" placeholders with the app's real data, labels, and language. Never ship demo testimonials.
- **Match the stack:** if the app isn't shadcn/Tailwind/TS, port the component (keep the behaviour and motion, rewrite the markup and styles) instead of bolting on a second styling system. If it is shadcn, put the file in `components/ui/` and add only the deps it really needs.
- **Match the design system:** recolour the component with the app's tokens. One accent system per app, not one per component. If a gradient, shader, or theme entry was picked, it *defines* the tokens, so derive the palette from it.
- **Backgrounds and shaders:** honour the prompt's motion rules (rAF clock, no quantising, modulations at 0 when ph=0). Respect `prefers-reduced-motion`. Keep text contrast readable on top.
- **Several entries together:** unify radius, spacing scale, shadows, and fonts across them so the result doesn't look like a collage.

### 4. Verify
Run it. Check desktop and mobile widths, dark and light if both exist, no overlapping or broken layout, no console errors,
and reduced-motion. Report what changed per page.

## Saving new prompts (ask first)
When the user's message contains a 21st.dev-style prompt (a hook flags it with `[ui-21st]`, or you spot one yourself),
first do what the user asked. Then ask once, listing each new prompt with a proposed **slug, category, title, use-when,
and tags**. Only after a yes, save each one.

1. Write the raw prompt text (exactly as pasted) to a temp file.
2. Run:
```bash
py -I "C:/Users/Raphael Angelo/.claude/skills/ui-21st/scripts/library.py" add --file "<tmp>" --category <cat> --slug <slug> --title "<title>" --use-when "<when to reach for it>" --kind <component|gradient|shader|theme|reference> --tags "a,b" --source "<project, date>" --notes "<how it was used / adaptation tips>"
```
Categories: `landing, sections, dashboard, navigation, data-viz, forms, backgrounds, themes, motion, misc`.
For a bare 21st.dev link with no prompt text, save the link as `--kind reference` with `--url`.
The script dedupes, writes the entry, rebuilds `INDEX.md`, and syncs this SKILL.md into Codex.

`check --file <tmp>` reports whether a prompt is already saved. `index` rebuilds the index after a hand edit.

## Don'ts
- Don't auto-drop other design skills either. If one complements this skill (e.g. `impeccable` for a typography/spacing/hierarchy/a11y polish or audit pass after the library pieces are in), use both. Skip only skills that would repeat a job already covered.
- Don't integrate every entry that "kind of" fits. Two or three strong matches beat seven.
- Don't paste the full prompt texts into chat.
