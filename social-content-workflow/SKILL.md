---
name: social-content-workflow
description: Create and manage social media content for any brand, especially editorial images, captions, carousels, visual-direction-driven batches, and content archiving. Use when the user asks to make social content, Instagram posts, carousel captions, news visual posts, or to organize content/reference/past/now folders.
---

# Social Content Workflow

## Overview

Use this skill to create social media content as a local-first content workflow. Keep social content separate from production app assets unless the user explicitly asks otherwise: use the repo-root `content/` folder by default.

## Required Folder Workflow

At the start of every task:

1. Find the repo root from the current working directory.
2. Ensure these folders exist:
   - `content/reference`
   - `content/past`
   - `content/now`
3. If any folder is newly created, add a short local guidance note in that folder:
   - `content/reference/README.md`: put visual direction, brand notes, example post screenshots, tone, typography, layout notes, do/don't references.
   - `content/past/README.md`: archived finished campaigns moved from `now`; use as quality memory and consistency reference.
   - `content/now/README.md`: active campaigns only; keep maximum 5 date folders.
4. Run or follow `scripts/rotate_content_now.py` so `content/now` keeps at most 5 date folders named `YYYY-MM-DD`. Move older date folders to `content/past`.

If `content/reference` is empty, tell the user what to add, but still proceed with available brand/context from the repo and prompt.

## Before Creating Content

Read compactly, using `rg`, `find`, and thumbnails/file names first:

- `content/reference` for design references and visual direction.
- Recent folders under `content/past` for prior tone, layout, and quality.
- Existing `content/now` folders to avoid duplicate campaign names.
- brand/app/project context in the repo when relevant.

For news/current-events content, verify current facts using reliable sources or local data before writing claims. For regulated domains such as finance, health, or legal topics, keep wording educational, avoid hype, and include an appropriate disclaimer.

## Production Workflow

For a typical Instagram editorial batch:

1. Define the campaign folder:
   - `content/now/YYYY-MM-DD/<campaign-slug>/`
   - Use lower-case kebab-case slugs, for example `product-launch-update` or `weekly-editorial`.
2. Draft the content plan:
   - 3-5 post angles unless the user specifies otherwise.
   - Each post needs headline, highlight word/phrase, tags, source/date, short subline, caption angle, and disclaimer.
3. Generate backgrounds first:
   - Make text-free visuals only.
   - Use references for mood, not as exact copies.
   - Use the brand direction from `content/reference`; if none exists, choose a restrained style that fits the topic and explain what reference material would improve consistency.
4. Compose final post locally:
   - Use deterministic local rendering for all text, logos, dates, tags, source labels, and disclaimers.
   - Do not rely on image generation for readable text.
   - Use 4:5 Instagram ratio, default `1080x1350`.
   - Keep tickers/tags near the top metadata cluster unless a specific layout asks otherwise.
   - Use a subtle dark/translucent backplate behind dates when the background is busy.
   - Keep the strongest headline in the lower-middle/lower-third with strong contrast.
5. Write deliverables:
   - final PNGs in campaign folder
   - `captions.md` with one caption per post
   - `README.md` with sources, specs, workflow notes, and disclaimers
6. Verify:
   - all final PNGs are `1080x1350`
   - text is readable and not cut off
   - folder is under `content/now` unless the user explicitly chose another content root
   - captions match the image topics and cite sources/dates when relevant

## Caption Style

Use the user's requested language, or infer it from existing content/reference files. Match the brand voice in `content/reference`; if no voice exists, write clearly, specifically, and without exaggerated claims.

For educational or regulated topics, include a short disclaimer such as:

```text
Source: <source>, <date>.
Disclaimer: Educational content, not personalized advice.
```

## Script

Use `scripts/rotate_content_now.py` to maintain the archive:

```bash
python3 ~/.codex/skills/social-content-workflow/scripts/rotate_content_now.py --repo-root /path/to/repo --dry-run
python3 ~/.codex/skills/social-content-workflow/scripts/rotate_content_now.py --repo-root /path/to/repo
```

The script only manages date folders directly inside `content/now`.
