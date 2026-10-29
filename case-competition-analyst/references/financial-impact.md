# Financial Impact & Business Case

Impact is usually 20–35% of the score. Judges don't expect precision. They expect a **traceable logic chain** with explicit, sourced assumptions and an honest range.

## 1. Value driver tree first
Link each initiative to an operational KPI, then to money:
```
Initiative → operational KPI change → financial value
Early warning → unplanned downtime −30% (from 2,261 h/yr) → loss avoided = Δhours × loss/hour
Knowledge capture → engineer search/support time −40% → hours freed × loaded cost/hour (or redeployed to kaizen)
Price action → loss ratio from 105% to 92% → Δ underwriting result in Rp
```
Use the case's own baselines wherever they exist. Where they don't, use public benchmarks (cited) or labelled assumptions.

## 2. Cost build-up
| Category | One-time (capex / implementation) | Recurring (opex / yr) |
|---|---|---|
| Technology: licences, infrastructure, development | | |
| Integration with existing systems | | |
| Data engineering / data quality | | |
| People: new roles, FTE time, external partners | | |
| Change management & training | | |
| Contingency (10–20%) | | |

Hidden costs that judges like to see included: adoption productivity dip, maintenance and technical debt, vendor lock-in or switching cost, security and compliance, and the opportunity cost of internal staff.

## 3. Core metrics
- **ROI** = (total benefits − total costs) / total costs. Simple, but it ignores timing.
- **NPV** = Σ CF_t/(1+r)^t − I₀. The main decision metric; NPV > 0 means value is created.
- **IRR**: the rate at which NPV = 0; compare it with the hurdle rate.
- **Payback / discounted payback**: when the cumulative cash flow turns positive.
- **TCO** for build vs buy or vendor comparisons (3–5 years).

**Discount rate for Indonesian cases**: use the company's WACC if it is disclosed (annual report) or a reasoned proxy, roughly BI rate + risk premium for corporate projects; ~10–12% is a common defensible range for large IDR corporates, higher for risky ventures. State it and include it in the sensitivity.

**Horizon**: 3–5 years for digital/AI initiatives; longer only for physical assets.

Compute with the script, never by hand:
```bash
python scripts/fin_calc.py --investment 80000 --flows 15000 30000 45000 50000 50000 --rate 0.11 --sens rate=0.08,0.14 flows=0.7,1.2
```
Or pass a JSON spec (see the script docstring) for multi-line cost and benefit models with ramp-up.

## 4. Ramp-up and confidence
- Benefits ramp with adoption (e.g. 25% → 60% → 90%). Costs are front-loaded.
- Give each benefit line a confidence tier: **High** (contractual or directly from case data), **Medium** (benchmark-based), **Low** (strategic/derived). Show the NPV with High+Medium only as the conservative case.
- Separate **definite value** (counted in NPV) from **derived value** (safety, knowledge retention, morale; listed but not monetised, or monetised only in a sensitivity scenario).

## 5. Sensitivity
At minimum, run a 3-scenario table (conservative / base / optimistic) plus one tornado or a single-variable flex on the most uncertain driver (adoption rate, benefit size, discount rate, cost overrun +30%). Report the **break-even** value of the key assumption: "NPV stays positive as long as downtime reduction ≥ 12%". This is the strongest Q&A defence.

## 6. Sanity checks before you publish
- Is the investment plausible relative to the client's scale (revenue, capex, size of the loss pool)?
- Is the benefit ≤ the addressable loss pool? You can't save more downtime cost than exists.
- Is there no double counting (the same hours saved claimed by two initiatives)?
- Is the payback in a realistic range for the project type? (Digital/SaaS ~6–24 months; platforms ~1–3 years; infrastructure ~3+ years.)
- Do the units and currency stay consistent (Rp juta vs miliar, USD vs IDR, with the exchange rate stated)?
- Do the numbers match across text, tables, charts and appendix?

## 7. Presenting impact
- Headline slide: 3–4 big numbers (NPV, payback, KPI deltas), each with a one-line driver.
- Impact table: KPI | baseline | target Y1/Y2/Y3 | source of baseline | measurement method.
- Put the assumptions table in the appendix, with a reference in the main text.
- Write "illustrative" honestly when round 1 numbers aren't validated yet, and validate them in the next round.

## 8. Common pitfalls
| Pitfall | Fix |
|---|---|
| Over-optimistic benefits | Conservative case, ramp-up, confidence tiers |
| Ignoring soft costs | Include training, change, integration, productivity dip |
| Timeline optimism | Add a 30–50% buffer to implementation |
| Sunk cost reasoning | Count only future cash flows |
| One-point estimate | Always give a range plus a break-even |
