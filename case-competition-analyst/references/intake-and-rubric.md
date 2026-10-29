# Intake & Rubric Mapping

Goal of intake: by the end, you know what the judges will score, what the case explicitly forbids, and what must be delivered, so that later work is spent where the points are.

## 1. Read everything, in this order
1. **Guidebook / booklet**: rules, rounds, deliverables, format, rubric, timeline, disqualification triggers.
2. **Casebook**: company context, data, the management question, required questions/workstreams, case conventions.
3. **Supporting data** (xlsx, csv, PDFs): open every file, record the shape (rows, columns, period, gaps) and note what can and cannot be computed.
4. FAQ, technical briefing notes, kickoff webinar notes and organiser emails. These often change the rules ("deck max 7 slides incl. cover", "only the first submission counts").

Write the results to `docs/01_KETENTUAN_DAN_RUBRIK.md` and `docs/02_PEMAHAMAN_KASUS.md` (or a single `penjelasan_lomba.md` for small cases). Cite page numbers, because disputes later are settled by "casebook p. 11 says...".

## 2. Turn the rubric into an effort budget
List every criterion with its weight, then add two columns:
- **Where it is won**: which section, slide or bab earns it.
- **What "excellent" looks like**: concrete and checkable.

Example (M3C preliminary):
| Criterion | Weight | Won in | Excellent = |
|---|---|---|---|
| Problem identification & analysis | 30% | Bab 1 | Core problem + root cause backed by case data and a named framework, not company description |
| Strategic recommendation | 25% | Bab 2 | Flows from the root cause; specific to the client, not generic |
| Implementation direction | 15% | Bab 3 | Phases, owners, timeline |
| Expected impact | 20% | Bab 4 | Quantified with logic chain to strategy |
| Clarity & format | 10% | All | Format rules met, concise |

Then derive the **page/slide budget**. With 6 pages and 30% on problem analysis, give it about 1.8 pages. Teams that spend 2 pages on company background are spending points on nothing.

**Read the weights strategically** and write the reading down. For example: "prelim is won on diagnosis; semifinal on feasibility + quantified impact (45% combined); final 35% solution/feasibility/impact + 40% delivery/Q&A". This tells the team what to over-invest in at each stage.

## 3. Extract the traps and must-answers
Casebooks embed tests. Find them and list them explicitly:
- **Prohibitions**: e.g. ASiQ's "don't reprice mechanically after one bad period" and "don't stay idle because history looks fine". Each product or sub-case is usually designed to test one trap.
- **Mandatory questions/workstreams**: e.g. CALIBER's 3 Key Questions, which must be answered explicitly on the Solution/Impact slides, or ASiQ's 9 workstreams with bullet-level asks. Make a checklist with one line per bullet.
- **Case conventions**: simplifications the base case must follow (no discounting, revenue recognised evenly, etc.). Extra assumptions are allowed only if they are labelled, justified, sensitivity-tested and kept separate from the base case.
- **Choice rules**: "choose ONE case", "extended solution allowed but focus stays".
- **Data gaps**: things the case asks for but doesn't give data on (e.g. energy forecasting with no energy data). Plan up front how to cover each gap (proxy, public benchmark, clearly labelled synthetic data), because judges will ask.

## 4. Format & compliance table
Capture every rule: paper size, font and size per element, spacing, margins, page or slide limits (and what is excluded: cover, references, appendix), file type and size cap, file name pattern, mandatory cover elements (logos, registration code), **anonymity rules** (no team or university names, and remember PDF metadata, headers and links to personal GitHub), language rule, and the citation style. Where a rule isn't specified, note the safe default and draft a question to the organiser (`docs/NN_DRAF_EMAIL_PANITIA.md`). Use these defaults until they answer:
- deadline at 23:59 local time (WIB), with submission planned for D-1;
- the language of the guidebook;
- APA citations;
- 2.5 cm margins and 1.15–1.5 line spacing;
- the page limit excludes the cover, references and appendices.
Send the questions on day 1, because answers take days.

## 5. Judges
Identify who judges each round and what each persona probes:
- **Academic** (lecturer): methodological correctness, formulas, citing theory, internal consistency.
- **Practitioner / client** (e.g. Tugu Insurance, Chandra Asri, TMMIN/AKTI staff): commercial and operational realism, regulatory constraints, "would this work in our plant", cost and integration with existing systems, safety.
- **Organiser students**: rubric compliance, clarity.

Use the client's own vocabulary and philosophy (Toyota: Jidoka, Kaizen, Yokoten, Genchi Genbutsu; a petrochemical plant: reliability, HSE, MOC, SIL). Practitioner judges trust teams that speak their language.

## 6. Round continuity
Many competitions require later rounds to *deepen* the earlier submission rather than replace it (M3C semifinal has 15% "Strategic Relevance" that punishes a new idea). Therefore:
- The round-1 big idea must be broad enough to hold a full proposal (roadmap, feasibility, financials) and a pitch.
- Keep a `docs/08_DECISION_LOG.md` (ID, decision, alternatives, reason, date) so later rounds and Q&A can defend why.
- Plan which numbers are "illustrative" in round 1 and which get validated in round 2.

## 7. Timeline back-planning
Work backwards from the deadline: submit at D-1 (or D-2 for formal papers, so there is time for PDF/format accidents), freeze content at D-3, run QA from D-3 to D-1, and lock the storyline about 60% of the way through the available time. Note when the case allows only one submission, so there is no fixing after upload.
