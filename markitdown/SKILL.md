---
name: markitdown
description: Use when a PDF, DOCX, PPTX, XLSX, EPUB, ZIP or other binary document is about to be read, searched, summarized, or quoted from — including large, scanned-looking, or multi-hundred-page files, and any ".pdf"/".docx"/".pptx" path the user mentions or drops into chat. Also use when a document read failed, returned garbage, blew up the context, or when the user complains about tokens, cost, or context limits while working with documents.
---

# MarkItDown

## Overview

`markitdown` is Microsoft's offline document-to-Markdown converter, installed on this machine
as a CLI. It turns a binary document into plain Markdown **on disk** so the document can be
grepped and read in slices instead of being ingested whole.

**Core principle: convert to a file, then read only the part you need.** A 200-page PDF read
directly can cost tens of thousands of tokens for a question that one `grep` would answer.

## When to Use

Use it for any binary or dense document: `.pdf`, `.docx`, `.pptx`, `.xlsx`, `.xls`, `.epub`,
`.zip`, `.msg`, `.ipynb`, `.html`, and audio files (`.mp3`, `.wav`, via transcription).

**Do NOT use it when:**
- The visual layout, page design, figures, charts, or embedded images are the actual subject —
  read the file directly so the pages can be seen.
- The file is already plain text or Markdown.
- The source is a web page — use the `defuddle` skill instead.
- The task is to *produce* or *edit* an Office/PDF file — use the `docx`, `pptx`, `xlsx`, or
  `pdf` skills. MarkItDown is read-only and one-way.

## Workflow

1. **Convert to a file in the scratchpad.** Never let output reach stdout.

   ```bash
   markitdown "Downloads/Some Report.pdf" -o "$TEMP/claude-md/some-report.md"
   ```

2. **Check the size before reading anything.**

   ```bash
   wc -c -l "$TEMP/claude-md/some-report.md"
   ```

   Rough rule: bytes ÷ 4 ≈ tokens. Under ~8 KB, just read the whole file. Over that, slice.

3. **Slice, don't slurp.** Locate first, then read the neighbourhood.

   ```bash
   grep -n -i "payment terms" "$TEMP/claude-md/some-report.md"
   sed -n '340,400p' "$TEMP/claude-md/some-report.md"
   ```

   For structure, read the headings first: `grep -n '^#' file.md`.

4. **Keep the `.md` for the rest of the session** and reuse it. Re-converting the same file
   twice is wasted time; tell the user where it landed if they may want it.

## Quick Reference

| Need | Command |
|---|---|
| Convert to file | `markitdown in.pdf -o out.md` |
| From stdin (needs a hint) | `cat in.pdf \| markitdown -x .pdf -o out.md` |
| Size check | `wc -c -l out.md` |
| Outline | `grep -n '^#' out.md` |
| Find a term | `grep -n -i "term" out.md` |
| Read a range | `sed -n '100,160p' out.md` |
| Scanned PDF (needs Azure) | `markitdown in.pdf -d -e "$MARKITDOWN_DOCINTEL_ENDPOINT" -o out.md` |

Run `markitdown --help` for the remaining flags.

## Common Mistakes

**Omitting `-o`.** Without it, markitdown writes the entire document to stdout and the whole
thing lands in context — the exact cost the tool exists to avoid. Always pass `-o`.

**Piping to `head` to "peek cheaply".** `markitdown big.pdf | head -50` still converts the
whole file and the pipe can hang on Windows. Convert to a file, then `head` the file.

**Reading the whole `.md` anyway.** Converting a 300-page PDF and then reading all of it saves
maybe 65% — real savings come from step 3.

**Assuming OCR.** Offline conversion extracts the embedded text layer only. A scanned or
photographed PDF converts to an empty or near-empty file. If the output is suspiciously short
for the page count, say so and read the PDF directly instead of reporting the document as blank.

**Paths with spaces.** This machine's paths are full of them. Quote every argument.

**Expecting it to be instant.** The first run in a session takes ~20s while the file-type
detection model loads; later runs are quicker. Allow a generous timeout on big files.

## Fidelity Notes

Tables survive as Markdown tables. Headings, lists, and links survive. Lost in conversion:
page numbers, headers/footers, footnote anchoring, multi-column reading order (occasionally
scrambled), and all images. Never quote a converted document as if it were the page layout —
if the user needs an exact visual quote, verify against the original.
