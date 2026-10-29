---
name: case-competition-analyst
description: End-to-end analyst for business case competitions and case-based papers. It reads the casebook and guidebook, maps the scoring rubric, diagnoses root causes from the case data, designs a solution that traces back to the findings, quantifies business impact (NPV/IRR/payback, KPI targets, sensitivity), plans the roadmap and risks, then drafts and QA-checks the executive summary, proposal, paper or pitch deck and prepares for judge Q&A. Use it for consulting-style cases (strategy, operations, kaizen, market entry), technical-quantitative cases (actuarial pricing, finance, risk) and AI/tech-solution cases that need a prototype or hackathon pitch. Trigger it whenever the user mentions a lomba, case competition, business case, casebook, guidebook, booklet, executive summary, proposal, pitch deck, penyisihan/semifinal/final, juri, rubrik penilaian, or root cause / rekomendasi for a company case, even if they never say "skill" or "framework". Not for pure Kaggle/datathon modeling with no business deliverable.
---

# Case Competition Analyst

Built for one job: winning case competitions such as M3C (MTI Consulting x AKTI/TMMIN), CALIBER (Chandra Asri) and ASiQ (Tugu Insurance actuarial case). It combines three sources:
- MBB consulting method (structuring, hypothesis-driven, Pyramid, value creation). The library is in `references/mbb/`.
- Business-case financials (ROI/NPV/IRR/TCO/sensitivity), in `references/financial-impact.md` and `scripts/fin_calc.py`.
- Use-case discipline for AI/tech solutions (actor, goal, normal flow, exceptions), in `references/ai-solution-design.md`.

The core belief behind this skill: **judges score against a rubric, and they reward a chain they can follow** (data → root cause → recommendation → impact → roadmap). Most losing teams fail on the links between steps, not on any single step. A generic solution, an impact number with no assumptions behind it, or a recommendation that ignores the diagnosis will each break that chain.

## Working rules

- **Talk to the user in their language** (usually casual Indonesian). The deliverable follows the competition's language rule (EYD V Indonesian, English pitch, and so on).
- **Persist work as files in the competition folder**, not only in chat, because competitions run for weeks across many sessions. Follow whatever naming already exists in the folder. If there is none, use numbered docs (`docs/00_INDEX.md`, `01_KETENTUAN_DAN_RUBRIK.md`, `02_PEMAHAMAN_KASUS.md`, ..., `08_DECISION_LOG.md`). If the user specifies different file names or locations, or says to keep the folder read-only, follow that.
- **Every number comes from a source**: the casebook, a dataset you computed from, a cited public source, or an explicitly labelled assumption. Never type a number from memory into a deliverable. "Compute, don't type" also applies to weighted scoring matrices, totals and percentages. Calculate them with code, because hand-added totals are often wrong.
- **The examples in the references come from past competitions** (M3C, CALIBER, ASiQ). They show what good looks like. They are not answers to reuse. Diagnose each case from its own data, and verify any number before carrying it into new work.
- **Ask before deciding things that belong to the team**: case choice when there are several, the big idea, and any assumption that drives the answer. Present 2–3 options with a recommendation and don't pick silently. If the brief is missing (no casebook yet), ask for it before analysing.
- Read large PDFs/DOCX through the `markitdown` skill rather than raw, so they don't flood the context. If markitdown isn't installed, fall back to `py` with `pypdf` (for PDFs) or `python-docx`. Cite **the PDF page plus the printed page if they differ** (e.g. "guidebook PDF p.9 / printed p.7"), or cite the exhibit or table name.

## Workflow

Scale the depth to the stage and the time left. With 2 days left, compress steps 3–5. In the final round, skip to steps 7–9 but still check continuity with the earlier round.

### 0. Locate the stage
Find out which competition, which round, which deliverable, the deadline, and what already exists in the folder (read `docs/` and any `progress.md` first). Resume, don't restart.

### 1. Intake: brief map and rubric
The user only shares case material that they're allowed to process with AI, so don't screen documents for AI-use or confidentiality clauses. Read everything they give you.

Read the guidebook/booklet and the casebook end to end. Produce the **brief map** (template: `assets/brief-map.md`):
- The management question, written in one sentence, plus the explicit traps or prohibitions in the case (e.g. "don't reprice mechanically after one bad period", "choose ONE case, never combine").
- Every required deliverable, format rule (page/slide limits, font, file name, anonymity), deadline, and disqualification trigger.
- The rubric with weights, turned into an **effort and page budget**. A criterion worth 30% gets about 30% of the effort and pages.
- Mandatory questions the deck must answer explicitly (e.g. CALIBER's Key Questions, ASiQ's 9 workstreams). These become a checklist ticked item by item.
- The judges (academics, practitioners, client executives) and what each kind will probe.
- Round continuity: if later rounds must deepen the same idea, the first-round big idea has to be wide enough to carry them.

Details and examples: `references/intake-and-rubric.md`.

### 2. Classify the case
One case can be more than one type. Load the matching reference:

| Type | Signals | Read |
|---|---|---|
| Business / consulting | Strategy, operations, kaizen, growth, org, market entry; exec summary → proposal → pitch | `references/solution-design.md` |
| Technical-quantitative | A model or workbook is provided; pricing, actuarial, valuation, risk; paper with formulas | `references/quant-technical-case.md` |
| AI / tech solution | "AI-powered", dashboard, knowledge hub, prototype/demo video, hackathon | `references/ai-solution-design.md` |

Also read the industry vertical from `references/mbb/` (e.g. `industrial-manufacturing.md` for TMMIN/Chandra Asri, `financial-services.md` for insurance) to calibrate benchmarks and KPIs.

### 3. Diagnose: this is where the most points are
Rubrics weight diagnosis heavily (M3C prelim 30%, ASiQ 45%). Work hypothesis-driven:
1. Write a Day-1 answer straight away, then try to kill it with the data.
2. Build a MECE issue tree, then **analyse the actual case data** (compute it, don't skim it). Look for the hook: one surprising, quantified fact that reframes the problem. Examples: "5 failures worth $2.58M were visible 5–6 weeks before trip"; "Motor is structurally underpriced while Property's spike is a single event".
3. Separate symptoms from root causes (5 Whys, 4M+1E fishbone, causal loop / vicious cycle). Separate **structural problems from one-off events and from drifting assumptions**.
4. End every analytic block with a "so what".

Method: `references/diagnosis.md`. Deeper tools are in `references/mbb/issue-hypothesis-trees.md`, `hypothesis-invalidation-discipline.md` and `case-types.md`.

### 4. Generate and select the solution
Generate options, run a quick financial check on each one (one `fin_calc.py --sens` run per option is enough to catch an idea that only works under heroic assumptions), score them against criteria taken from the rubric and the case (impact on the root cause, feasibility, fit with the client's own philosophy, differentiation from what most teams will submit, and how well it can be demonstrated). Pick one big idea that breaks into 3–4 initiatives. Each initiative must point to a specific root cause. If an initiative can't be traced back to a finding, cut it. Record the decision in the decision log. Method: `references/solution-design.md` (plus `references/ai-solution-design.md` for AI cases).

### 5. Quantify impact
Build a value driver tree from the initiatives to KPIs to money: baseline → target → ramp-up, a cost and investment build-up, and then NPV, IRR, payback and ROI. Use `scripts/fin_calc.py` for the numbers and the sensitivity table, and don't hand-compute them. On this Windows machine, run it with `py`, because `python` is a Store alias that doesn't work. It has quick mode for net flows and JSON spec mode for benefit and cost lines with ramp-up, scenarios and a tornado chart. Every assumption goes into an assumption register (`assets/assumption-register.md`) with its source and a confidence tier. Show at least one sensitivity case and state whether the recommendation survives it. Read `references/financial-impact.md`.

### 6. Roadmap, feasibility and risk
Phase the plan (pilot → scale → sustain), with owners (real functions from the case), resources, milestones, quick wins and KPIs per phase. Run a pre-mortem and write a risk table with mitigations. For people-centred themes, include change management and capability building (`references/mbb/change-management.md`, `capability-assessment-talent.md`).

### 7. Storyline and deliverable
Write the ghost deck or outline first: one action title per slide or section, in the section order the guidebook requires. Use the Pyramid Principle (answer first) and an SCQA opening. Then write the content. Read `references/deliverables.md` for exec summary, proposal, paper and deck patterns, and `references/mbb/storylining.md` and `pyramid-principle-and-scqa.md` for depth. To build the actual file, use the `docx`, `pptx`, `pdf` or `academic-pptx` skill, and `dataviz` for charts.

### 8. QA before submission
Run `references/qa-and-pitch.md` part A:
- Score the draft against the rubric, line by line, as a harsh judge would.
- Check traceability: every recommendation links to a finding and to an impact (`assets/traceability-matrix.md`).
- Reconcile the numbers: text = model = charts.
- Tick off every mandatory question.
- Check format and anonymity, including PDF metadata and the file name.

Fix the gaps before you call it done. Report the remaining weak spots honestly.

### 9. Pitch and Q&A prep
Build the judge question bank by judge persona, with 30-second answers backed by evidence, and red-team the weakest assumption. See `references/qa-and-pitch.md` part B. For a 24-hour hackathon final, follow the hackathon playbook in `references/ai-solution-design.md`.

## Reference map

| Need | File |
|---|---|
| Brief map, rubric → effort budget, round continuity | `references/intake-and-rubric.md` |
| Root cause and diagnosis methods | `references/diagnosis.md` |
| Option generation, big idea, initiative design | `references/solution-design.md` |
| AI solution architecture, use cases, prototype, hackathon | `references/ai-solution-design.md` |
| Model-based/actuarial/finance cases | `references/quant-technical-case.md` |
| ROI/NPV/IRR/TCO, value tree, sensitivity | `references/financial-impact.md` + `scripts/fin_calc.py` |
| Exec summary / proposal / paper / deck structure | `references/deliverables.md` |
| Rubric self-scoring, QA checklists, Q&A prep | `references/qa-and-pitch.md` |
| Templates | `assets/brief-map.md`, `assets/traceability-matrix.md`, `assets/assumption-register.md`, `assets/initiative-card.md` |
| MBB library: frameworks, guesstimation, industry verticals, GenAI strategy, change management, etc. | `references/mbb/INDEX.md` |
