# Solution Design: from root causes to a winning big idea

## 1. Generate options wide, then cut
Generate 8–15 candidate ideas before converging. Sources:
- One or more ideas per root cause (RC1..RCn).
- The client's own playbook, digitised or extended. Example: Toyota's Jidoka → "Digital Jidoka"; Yokoten → "Digital Yokoten". Judges love seeing their own philosophy made modern.
- Cross-industry patterns (`mbb/case-pattern-library.md`, `mbb/problem-playbooks.md`).
- The theme of the competition (e.g. "Human Centered AI Kaizen"), which has to be clearly visible in the answer.
- Anything the case explicitly lists as expected components. Cover all of them, but don't stop there.

Record all ideas in `docs/daftar_ide.md` with a one-line rationale each.

## 2. Score and select
Use a weighted matrix whose criteria come from the rubric and the case:
| Criterion | Why |
|---|---|
| Addresses root cause (which RC IDs) | Rubric "solution answers root cause" |
| Quantifiable impact with available data | Impact is usually 20%+ of the score |
| Feasibility (cost, time, the client's capabilities, integration) | Feasibility is 15–25% |
| Differentiation vs the obvious team answer | Most teams submit the default idea (e.g. "RAG chatbot", "train employees", "dashboard") |
| Fit with client philosophy and theme | Strategic relevance |
| Demonstrability (prototype, data backtest, visual) | Pitch quality |
| Room to deepen in later rounds | Continuity rules |

Present the top 2–3 to the user with a recommendation. The team makes the final call, then log it.

## 3. Shape the big idea
- One name and one sentence. Example: "PlantPulse: Detect → Prioritize → Diagnose → Act → Track."
- 3–4 initiatives (pillars), each mapped to root causes. Use `assets/initiative-card.md`: what it is, which RC it solves, who uses it, how it works, KPI, cost, timeline, risk.
- Make it **human-centred** where the theme asks for it. Spell out the human role at each step (AI suggests, the human decides, the human updates the standard), plus capability building and incentives.
- Sequence the pillars: foundation first (data, standards, governance), then use cases, then scale and culture.

## 4. Avoid the classic losing patterns
- **Generic**: the solution would fit any company. Fix it by naming the client's systems, plants, products, data and people.
- **Disconnected**: an initiative that no root cause asks for. Cut it or move it to "future extension".
- **Tech-first**: "we'll deploy AI" with no process change or owner. Fix it with the human process, the RACI and the adoption plan.
- **Boiling the ocean**: 10 initiatives, all shallow. Three deep ones beat ten thin ones.
- **Unfundable**: no cost estimate, or a cost wildly out of scale with the client. Sanity-check against the client's revenue, capex or loss pool.
- **Ignoring constraints**: regulation (OJK tariff bands, safety standards), union and workforce realities, legacy systems, security.

## 5. Value proposition
For each stakeholder (management, operators/engineers, customers, regulator), state the pain removed and the gain created. Separate **definite value** (money: cost, revenue, loss avoided) from **derived value** (safety, knowledge retention, morale, speed). See `mbb/value-creation-measurement.md`.

## 6. Feasibility section checklist
- Resources: people (roles and FTE), budget (capex and opex), technology (build, buy or partner), and data readiness.
- Timeline: phases with milestones and gate criteria (pilot success metric before scale).
- Organisation: owner per initiative (use the real functions from the case), governance cadence, change management (ADKAR/Kotter; `mbb/change-management.md`).
- Risk: technical, adoption, data, financial, regulatory. Each risk gets a mitigation and an early-warning indicator.
- Proof: pilots, benchmarks from comparable companies (cite sources), and a prototype or backtest if you have one.
