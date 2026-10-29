# Technical-Quantitative Cases (actuarial, finance, pricing, risk)

For cases that ship a workbook or model and ask for a technical paper. ASiQ (PSAK 117 pricing for a general insurer) is the archetype. Judges are typically academics (technical correctness) plus practitioners (commercial and regulatory realism). Accuracy is table stakes. What wins is **judgement**: telling structural problems from noise, and turning the numbers into an executive decision.

## 1. Model discipline
- **One source of truth**: build a calculation engine (Python) and a mirrored workbook (Excel), and auto-diff them (tolerance 0.01). Every number in the paper is copied from model output, never retyped.
- **No hardcoded numbers** in calculation sheets. Everything links to an Inputs sheet. Record the random seed for simulations.
- **Reconciliations** (write them as explicit checks): totals of components = totals; quarterly sums = annual; closing balances = opening + flows; cash vs P&L differences explained; simulation mean ≈ deterministic value (<1%).
- Keep `output/*.json` with the key results and generate the charts from them, so the figures match the text.

## 2. Respect case conventions, then critique them
- The **base case** follows the casebook conventions exactly (weights, trends, no discounting, etc.).
- **Alternative views** (your extra assumptions) are labelled, justified with sources, sensitivity-tested and kept clearly separate. Present them as a range around the base case.
- Show that you understand the convention's limitation (e.g. trending from the weighted average creates a trend lag). Explaining a weakness is worth more than silently "fixing" it.

## 3. Structural vs random: the judgement core
Use quantitative tests to classify each unit (product, segment, plant):
- Actual vs expected (A/E) by period and by quarter. Is the deviation persistent or concentrated?
- Significance: z-score against expected volatility (CV), or a credibility factor Z (limited-fluctuation, e.g. full credibility standard) to decide how much to trust the experience.
- Trend tests: observed trend vs assumed trend; acceleration.
- Event decomposition: recompute the metric without the large event.
- Forward view: do the results deteriorate next year if nothing changes (onerous next year, probability of loss)?

Then use the diagnosis matrix from `diagnosis.md`, and always state the **risk of the wrong response** for each unit (over-reacting vs under-reacting), quantified.

## 4. Sensitivity and uncertainty
- **Tornado**: flex each key assumption ±X and rank the drivers by impact on the decision metric. Name the single most influential assumption.
- **Scenarios**: base / conservative / optimistic, with a story behind each.
- **Monte Carlo** (where the case has frequency/severity): give P10/P50/P90 and the probability of a bad outcome (e.g. P(loss component > 0)).
- Always answer: **does the recommendation change** under the sensitivity? If not, say so, because that is the robustness argument.

## 5. Recommendations that pass practitioner judges
- Quantify them: % rate change, Rp impact, timeline, and the KPI to monitor.
- Offer more than price: segmentation, underwriting, deductibles/co-pay, expense actions, claims management, growth restriction, reinsurance, and monitoring triggers.
- Check regulatory and commercial constraints: tariff bands (e.g. OJK SEOJK for general insurance), competitor pricing, demand elasticity, anti-selection when raising price.
- Phase large changes (e.g. +20% now, review in 6 months with trigger X), and show the impact path on profit, loss component and the result line.
- Separate the "technical" answer from the "commercial" one, and explain any gap between them.

## 6. Communicating technical content
- Executive summary first: a one-sentence answer per unit (e.g. "Motor is structurally underpriced; raise now. Property's spike is one event; don't reprice. Health looks fine but its assumptions lag medical inflation; act before 2028").
- Every technical term is italicised with an Indonesian equivalent on first use when the paper language is Indonesian.
- Each section closes with "so what". Put formulas in boxes or an appendix, and keep the main text readable for non-technical directors.
- Charts: label axes and units, and give each chart an action title.
- Cite the standard and the method (e.g. PSAK 117/IFRS 17 PAA, Werner & Modlin ratemaking), plus regulator documents.

## 7. Workstream checklist
If the casebook lists workstreams or bullet questions, mirror them in the paper's structure or in a cross-reference table ("WS3 is answered in §4.2, Table 5"). Tick every bullet. Missing one is a cheap point lost.
