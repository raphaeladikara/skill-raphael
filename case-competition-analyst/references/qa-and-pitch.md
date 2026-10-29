# QA & Pitch Preparation

## Part A: QA before submission

### A1. Rubric self-score (be the harshest judge)
For each rubric criterion: score 1–5, cite the exact page or slide that earns it, and write the one change that would raise it by a point. Do the fixes for anything ≤3 on high-weight criteria first. Write the result to `docs/NN_QA_*.md`.

### A2. Traceability
Fill `assets/traceability-matrix.md`: Root cause → Recommendation → KPI → Financial impact → Roadmap phase → Risk. Check that:
- every recommendation maps to at least one root cause (otherwise cut it, or label it as an extension);
- every major root cause is addressed;
- every impact number traces to an assumption in the register.

### A3. Numbers
- Text = model = tables = charts = appendix, and the same number is rounded the same way everywhere.
- Totals add up; percentages are taken of the right base; units and currency are consistent.
- Re-run the calculation scripts from scratch and diff the outputs against the document.
- Each external number has a citation.

### A4. Must-answer checklist
Tick every mandatory question, workstream bullet and expected component from the casebook, with the location where it is answered.

### A5. Format & compliance
Run through the full list from the brief map: page or slide count (with exclusions), fonts, spacing, margins, cover elements, logos, file name, file size, anonymity (including PDF metadata), language rules (EYD V, italics for foreign terms), and references. Open the exported PDF and look at every page for cut tables, broken images and widow headings.

### A6. Read-through
- Read only the titles. Do they tell the story?
- Read as the client executive. Is anything generic, insulting or unrealistic for their plant or business?
- Read as an academic. Is any method unnamed, misapplied, or unsupported?

Report the remaining weak spots to the user honestly. Don't call it done while a high-weight gap remains.

## Part B: Pitch & Q&A

### B1. Delivery
- Know the time limit. Rehearse to 90% of it, because there will be an interruption buffer.
- Opening (≤30s): the hook number plus the one-sentence answer. Closing: the answer, the ask and the impact.
- Split the speaking by section and plan the handovers. Every member must be able to answer questions on any part.
- Rehearse with a timer at least 3 times. Record one run and review it.

### B2. Build the question bank
Generate 25–40 likely questions, grouped by judge persona and by the weakest points:
- **Methodology** (academic): why this method, this weight or this assumption? What if X changes? How did you validate it?
- **Data** (all): where does this number come from? What about the data gap in Y? Is the sample size sufficient?
- **Feasibility** (practitioner): who owns this? How does it integrate with SAP, the DCS or EDMS? What about the union or the operators? What does it cost, and how was the cost estimated?
- **Risk & safety** (practitioner): what if the AI is wrong? How do you prevent hallucination in a safety procedure? Cybersecurity?
- **Impact** (management): why this %? What's the payback in the worst case? Isn't this double-counted?
- **Strategic** (all): why not the obvious alternative? What's new compared with what we already do? How does it fit our philosophy (TPS, operational excellence)?
- **Continuity**: what changed since the last round, and why?

### B3. Answer format
For each question, prepare a 30-second answer: **direct answer → evidence (number or source) → link back to the recommendation**. Prepare a backup slide for the top 10. When you don't know, acknowledge it, give your best reasoned estimate, and say how you would validate it. Never bluff a number.

### B4. Red-team
Have one person or agent attack the single weakest assumption (usually the size of the impact or the adoption rate) and the biggest feasibility risk. Strengthen the answer or the deck accordingly. Use `mbb/communication-under-pressure.md` for hostile Q&A composure.
