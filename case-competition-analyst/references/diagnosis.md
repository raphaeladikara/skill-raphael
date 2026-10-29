# Diagnosis: from case data to root cause

Diagnosis is usually the single heaviest rubric item. Judges reward depth (root cause, not symptom), evidence (quantified from the case's own data) and structure (a recognisable framework, applied properly).

## 1. Frame the question
Write the problem statement in SCQ form:
- **Situation**: who the client is and what they do (at most 2 sentences in the deliverable).
- **Complication**: what changed or what hurts, quantified.
- **Question**: the management question, restated precisely.

Add the **Day-1 answer**: what you would recommend right now if forced to. It focuses the analysis and should be revised freely.

## 2. Build the issue tree (MECE)
Decompose the question:
- **Value-driver trees** for financial questions: Profit = Revenue − Cost, where Revenue = Price × Volume, and so on. OEE = Availability × Performance × Quality. Loss = frequency × severity.
- **Process trees** for operational questions: follow the value chain or the problem's lifecycle (detect → prioritise → diagnose → act → verify).
- **Stakeholder/capability trees** for people questions: people / process / technology / data / governance.

Prioritise branches with 80/20: where is the money, the downtime, the risk? Deeper method: `mbb/issue-hypothesis-trees.md`, `mbb/case-types.md`.

## 3. Analyse the data for real
- Load every dataset and compute. Typical first cuts: totals and trends over time; Pareto by category (failure mode, component, plant, product); distributions and outliers; status/ageing (open vs closed, overdue); and before/after comparisons.
- Reconcile with numbers the casebook itself quotes. A mismatch is either your bug or an insight.
- Look for **the hook**: one surprising, quantified fact that reframes the problem. Strong hooks share a pattern: *"X was already visible / already known / already paid for, but the system failed at Y."* Examples:
  - "All 5 major failures were flagged by condition monitoring 6–15 weeks earlier. Detection worked; the path from alarm to action didn't." (CALIBER)
  - "Engineers spend 65% of their time firefighting, which leaves 25% for improvement, and kaizen ideas fell from 3.1 to 2.4 per person." That is a vicious cycle. (M3C)
  - "The pricing method has a built-in trend lag of about 0.7 years." A structural cause hiding behind 'one bad year'. (ASiQ)
- Save the computations as scripts or notebooks in the competition folder so the numbers can be regenerated and defended.

## 4. Get from symptom to root cause
Use at least one named method and show it in the deliverable, because judges look for it:
- **5 Whys**: keep asking why until you reach something controllable (a process, an incentive, a missing standard), not "human error".
- **Fishbone, 4M+1E** (Man, Machine, Method, Material, Environment) or 6M. Manufacturing judges know it well.
- **Causal loop / vicious cycle**: shows why the problem persists and gets worse. This is powerful in a narrative.
- **Pareto**: shows which few causes drive most of the loss.
- **Gap analysis**: current vs target or benchmark, decomposed into components.
- **Maturity model**: a level 1–5 assessment (data, digital, AI readiness) to show where the client stands.

## 5. Classify the cause
Before recommending, classify each problem:
| Type | Test | Right response |
|---|---|---|
| **Structural** | Persists across periods; systematic deviation (e.g. A/E consistently >100%, z-score high, trend not mean-reverting) | Change the system (price, process, design) |
| **Event / random** | Concentrated in one period or quarter; low credibility; explained by a single shock | Don't over-react: monitor, use reinsurance or contingency, set a trigger |
| **Assumption drift** | Looks fine today but the forward assumptions are stale (inflation, trend, demand) | Update assumptions and pre-empt |
| **Capability / people** | Knowledge is concentrated in few people; skills gap; incentives | Training, knowledge capture, role redesign |
| **Data / integration** | Fragmented systems, inconsistent KPI definitions, no single source of truth | Data foundation before AI |

Show the **"wrong response" risk**: what happens if management reacts to the symptom instead. Judges in ASiQ-style cases explicitly reward this.

## 6. Try to kill your hypothesis
For the main diagnosis, write the strongest alternative explanation and the evidence that rules it out (`mbb/hypothesis-invalidation-discipline.md`). Note what data would change the conclusion. This turns into Q&A ammunition.

## 7. Output of the diagnosis step
- A diagnosis matrix: rows = evidence, columns = units (products, plants, cases), with a final row "Diagnosis".
- A root-cause statement in 1–2 sentences, together with the hook.
- A list of root causes (RC1..RCn) with IDs. The solution design and the traceability matrix reference these IDs.
- A "so what" line under each analysis block.
