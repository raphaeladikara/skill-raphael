---
name: ai-paraphrase
description: Scan every word of human-readable text in a project and rewrite it so it reads like a person wrote it, not an LLM. This skill EDITS FILES BY DEFAULT — it does not merely report findings. In scope: code comments and docstrings, Jupyter/notebook markdown cells, UI strings, labels, button text, placeholders, user-facing error messages, READMEs, docs, and landing-page copy. Use whenever the user wants to humanize, de-slop, de-AI, or paraphrase text across a codebase or document set, or asks whether writing sounds AI-generated. Triggers on "humanize", "de-AI", "make it sound human", "remove AI tone", "paraphrase the project", "AI slop", "does this read like ChatGPT wrote it" — and also on bulk requests to clean up or rewrite comments, docs, or UI copy, even when the user never says "AI".
---

Finds the specific linguistic fingerprints of LLM writing across a whole project and rewrites them into prose a human would actually produce — without flattening voice, breaking code, or changing meaning.

## The core principle

**Density, not presence.** No single word proves AI authorship. `crucial`, an em dash, a Title Case heading — each is ordinary on its own. What marks LLM prose is many weak signals stacked in a small space, plus a handful of near-definitive artifacts.

So this skill never does find-and-replace. It scores passages, then rewrites the ones that are actually bad. Blind substitution ("replace every `delve`") makes text worse and harder to read while leaving the real problem — generic, padded, unspecific writing — untouched.

**The real defect behind the tells is vagueness.** LLM prose regresses toward the statistically average sentence: it swaps specific, unusual facts for generic important-sounding ones. "Inventor of the first train-coupling device" becomes "a revolutionary titan of industry." Fixing the vocabulary while keeping the vagueness is cosmetic. Fix the vagueness and most tells disappear on their own.

## Default posture: edit the files

When someone invokes this skill, they want their text changed — not a report about their
text. So **rewrite by default.** Scan, then edit, then tell them what you did.

Concretely:

- **Don't ask permission to start.** "Humanize the docs" is already the instruction. Asking
  "shall I proceed?" wastes a turn on a decision the user already made.
- **Don't stop at a findings list.** A table of 200 hits with no edits applied is a failed
  run, not a cautious one.
- **Don't ask which files** unless the request is genuinely ambiguous about *which project*.
  Scope is inferred from the rule below, not negotiated up front.
- **Bulk is expected.** Hundreds of small edits across dozens of files is the normal shape of
  this job. Work through them; don't sample a few and call it done.

Report *after* the work, not instead of it.

## Which text may be rewritten

Rather than memorize a list, apply one question:

> **Does anything other than a human being read this string?**

- **Only humans read it** → rewrite it. This is most text in a project.
- **A machine matches, parses, keys, or compares it** → leave it exactly as it is.

That single test generalizes to cases no list would cover. Worked examples:

| Text | Who reads it | Verdict |
|---|---|---|
| Code comment, block comment, docstring prose | Human | **Rewrite** |
| Notebook markdown cell; comments inside notebook code cells | Human | **Rewrite** |
| Button label, heading, tooltip, placeholder, empty-state copy | Human | **Rewrite** |
| User-facing error/toast/validation message | Human | **Rewrite** |
| README, docs, guides, landing-page and marketing copy | Human | **Rewrite** |
| Alt text, ARIA labels, meta descriptions | Human (and screen readers) | **Rewrite** |
| i18n *values* in the source locale (`en.json`) | Human | **Rewrite** — see note below |
| Pragma comments: `# noqa`, `// eslint-disable`, `# type: ignore`, `<!-- prettier-ignore -->`, `// @ts-expect-error` | Tooling | **Leave** |
| Docstring `@param`/`:returns:` tags, doctest lines (`>>>`) | Doc generator / test runner | **Leave the tag, rewrite the prose after it** |
| i18n **keys**, enum values, DB column values, route paths | Machine | **Leave** |
| CLI flags, env var names, API field names, error *codes* | Machine | **Leave** |
| String literals asserted in tests, snapshots, golden files | Test runner | **Leave** |
| Code identifiers (renaming is a refactor, not a paraphrase) | Compiler | **Leave** |
| License texts, SPDX headers, copyright lines | Lawyers | **Leave** |
| Direct quotations and citations | — | **Leave** (rewriting a quote falsifies it) |
| Prompts/system messages aimed at other LLMs | A model | **Leave** (phrasing is tuned behavior) |
| Changelog entries describing shipped wording | Human, but historical record | **Leave** |

Two cases that need care rather than avoidance:

- **A user-facing string that a test also asserts on.** It's display text, so it's in scope —
  but update the test in the same edit, or skip it and say which ones you skipped. Silently
  breaking the suite is the one outcome to avoid.
- **i18n source values.** Rewriting `en.json` strings is correct — they're display text — but
  it makes existing translations stale. Do it, then flag which locales need regeneration.

Directories always skipped: `node_modules` `.git` `dist` `build` `out` `vendor` `.next`
`target` `coverage`, plus lockfiles, minified and generated files, and vendored third-party
code. Those aren't yours to rewrite.

## Workflow

### 1. Scan

Because comments and UI strings are in scope, pass `-AllText` — the default without it only
covers `.md`-style prose files and will miss most of the job. Invoke through the **PowerShell
tool** (`&` handles the space in the profile path; `pwsh` is not installed on this machine,
and `~` does not expand in PowerShell):

```powershell
& "$HOME\.claude\skills\ai-paraphrase\scripts\Scan-AiTells.ps1" -Path . -AllText -Format table
```

On a large repo, size the job first, then go straight into editing — this is orientation, not
a checkpoint to stop at:

```powershell
& "$HOME\.claude\skills\ai-paraphrase\scripts\Scan-AiTells.ps1" -Path . -AllText -Summary
```

| Flag | Effect |
|---|---|
| `-AllText` | Include source files and notebooks, not just prose files |
| `-MinSeverity high` | Suppress `low`/`medium` noise on a first pass |
| `-Format csv` \| `json` | Machine-readable output |
| `-Path src/docs` | Narrow the scope |
| `-Summary` | Counts only |

Output columns are `Sev | Category | file:line | Match | Text`.

**On macOS/Linux**, call it as `pwsh -File <path> -Path . -AllText`. **If PowerShell is
unavailable entirely**, the scan is reproducible with the Grep tool — `references/ai-tells.md`
carries every pattern as a plain regex. Use that instead; do not skip the scan.

The scanner is a *spotlight, not a verdict*. It over-reports by design, and in `-AllText` mode
it will flag identifiers and code that merely contain a listed word. Read every hit in context.

### 2. Triage each hit

Sort into three buckets:

- **Definitive** — machine artifacts that can only come from a chatbot: `oaicite`, `contentReference`, `turn0search0`, `utm_source=chatgpt.com`, `[cite: 1]`, `grok_card`, `【12†L3-9】`, `:::writing{...}`, `[attached_file:1]`, unfilled placeholders like `[Your Name]` or `2025-XX-XX`, and leaked chat pleasantries ("Certainly!", "Would you like me to…"). **Delete or fix these unconditionally** — they are bugs, not style.
- **Real** — the passage is genuinely padded, vague, or promotional. Rewrite it.
- **Fine** — the word is load-bearing or the usage is correct. Leave it alone. `robust` in `robustParser`, an em dash a human deliberately placed, "underscore" meaning the `_` character, `key` as an adjective in a sentence that needs it.

Never edit a file solely because the scanner lit up on it.

### 3. Rewrite

Apply `references/rewrite-playbook.md`. Edit the files as you go — don't accumulate a plan.
The short version:

- **Restore the copula.** `serves as the entry point` → `is the entry point`. `boasts four modes` → `has four modes`.
- **Cut the participial tail.** `…, ensuring seamless integration across services.` → delete it, or state the actual consequence: `…, so a failed retry doesn't drop the job.`
- **Delete significance claims.** `stands as a testament to`, `plays a pivotal role in`, `marks a turning point in`, `reflects a broader shift toward` — say what the thing does instead.
- **Kill the closing summary.** LLMs restate the paragraph they just wrote. Cut it; the reader just read it.
- **Break the rule of three.** Three-item lists everywhere is a rhythm tell. If only two items are real, ship two. Padding a list to three invents facts.
- **Undo elegant variation.** LLMs rotate synonyms to dodge repetition penalties. Call one thing by one name throughout.
- **Replace generic praise with a specific fact.** This is the highest-value edit. `a powerful, flexible tool for modern workflows` → `parses 40 MB/s and takes config from stdin`.
- **Vary sentence length.** LLM paragraphs run 15–25 words per sentence with almost no variance. Humans write a long winding sentence and then a short one.

### 4. Do not over-correct

`references/ai-tells.md` § *Ineffective indicators* lists what is **not** evidence. Read it before a big rewrite pass. In particular:

- Don't strip every em dash, curly quote, or formal word. Correct grammar is not an AI tell, and neither is good vocabulary.
- Don't inject typos, slang, or forced casualness to "sound human." That's a different kind of bad writing, and it reads as fake.
- Don't rewrite text written before **30 November 2022** as if it were AI. Check `git log` on the file — pre-ChatGPT text cannot be AI-generated, however formulaic it looks.
- Don't flatten a house style. If the project's docs are deliberately formal, keep them formal; remove padding, not register.

### 5. Verify

Editing by default raises the stakes on verification — this is where the boldness gets paid
for, so don't skip it.

1. Re-run the scanner. Density should drop sharply; some hits will legitimately remain.
2. **Diff every change and confirm meaning is preserved.** Paraphrasing must not alter a
   technical claim, a version number, a flag name, or an API contract.
3. **Run the tests and the build** whenever you touched anything outside a pure-prose file.
   Comments can't break a build, but string edits can — and a syntax error introduced by a
   sloppy quote in an edited string is the most likely way this skill does damage.
4. Notebooks: confirm the JSON still parses and outputs are untouched.
5. Report what changed, what you deliberately left, and why.

## Notebooks

Notebooks (`.ipynb`) hold a lot of explanatory prose and are worth treating as a first-class
target, not an afterthought.

- **Markdown cells** are pure exposition — rewrite freely. They're usually the worst offenders,
  since notebook narration is exactly where "In this section, we'll delve into…" lives.
- **Comments inside code cells** — rewrite.
- **Cell outputs** — leave. They're execution artifacts; editing them makes the notebook lie
  about what the code produced.
- **`print()` strings that label output** — rewrite; they're display text.

Use the NotebookEdit tool rather than rewriting the raw JSON by hand, so cell IDs, execution
counts, and outputs stay intact.

## Coverage discipline

"Every word in the project" can mean thousands of files. Work through them — but be honest
about what you actually covered.

- Do the whole scope if you can. Bulk editing is the job.
- If something is genuinely out of reach — a file too large to process, a locale you can't
  regenerate, a string a test depends on — finish everything else and name the exceptions
  explicitly at the end.
- Never let a partial pass be reported as a complete one. "Rewrote 47 files; skipped
  `en-GB.json` because 4 tests assert on those strings" is a good report. "Done!" after
  editing eight of sixty files is not.

## References

- `references/ai-tells.md` — the full catalog: every tell, its regex, its severity, its era, and the false-positive traps. Load this when scanning or when asked to *detect* rather than rewrite.
- `references/rewrite-playbook.md` — before/after transformations for each tell class, plus the sentence-rhythm and specificity techniques. Load this when rewriting.
- `scripts/Scan-AiTells.ps1` — the scanner.

Source: patterns adapted from the Wikipedia WikiProject AI Cleanup field guide *Signs of AI writing* (CC BY-SA 4.0), plus the linguistics literature it cites.
