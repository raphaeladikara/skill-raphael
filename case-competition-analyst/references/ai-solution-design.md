# AI / Tech Solution Cases

Use this for cases like "design an AI-powered knowledge hub / intelligent dashboard / predictive maintenance", plus any case that needs a prototype, a demo video or a hackathon final. Judges in these cases are usually engineers and managers from the client. They are excited by AI, but they are sceptical of hallucination, integration cost and safety.

## 1. Start from the decision, not the model
For each use case, define:
- **Decision or task supported**: who decides what, how often, and what it costs when they get it wrong or late.
- **Current way**: time taken, error rate, and where it breaks (use the case data).
- **Target way**: the new flow with AI, and the human step that remains.
- **Value**: hours saved × cost per hour, downtime avoided × loss per hour, incidents avoided × cost per incident.

## 2. Reference architecture (describe in layers)
1. **Data sources**: name the real systems from the case (e.g. DCS/PI historian, CMMS/SAP PM, EDMS, AIMS, LIMS, incident DB, SOP/P&ID repositories).
2. **Data foundation / Industrial DataOps**: ingestion, tag and asset mapping (a common asset ID across documents and sensors), a KPI dictionary with one definition per KPI, data quality checks, metadata, versioning.
3. **Intelligence layer**: pick the simplest method that works with the data available.
   - Few labelled failures (say, 5) → rule- or threshold-based plus trend detection, which is transparent. Put ML on the roadmap.
   - Many labelled events → ML classification or regression, validated by a backtest.
   - Documents → retrieval (RAG) with citations; an LLM for summarising and drafting (RCA reports, CAPA).
   - Similarity search over incidents or failure signatures.
4. **Application / UX**: dashboard, alert inbox, assistant, action tracker. Name the user role for each screen.
5. **Governance**: human-in-the-loop approval, audit trail, access control, data security (on-prem or VPC, no plant data sent to public models without controls), model monitoring, MOC integration.

## 3. Trust requirements (judges will test these)
- **Traceability**: every AI answer shows its sources (document, version, approval status) and a confidence level. Answers about safety-critical procedures are restricted to approved documents.
- **Human oversight**: AI recommends and the human approves. State explicitly what AI must never do on its own (change setpoints, bypass interlocks).
- **Evaluation**: report accuracy honestly. Run a backtest on historical cases ("5/5 failures flagged 35–42 days before trip") and blind-test the LLM against verified root causes, including the failures. Honest limits read as maturity.
- **Hallucination handling**: if the answer isn't in the sources, the system says "not found" and escalates to an SME.
- **Security & reliability**: deployment option, role-based access, offline fallback.

## 4. Use-case specs (lightweight, from use-case-writer)
When the proposal or appendix needs functional detail, write 3–6 system use cases, not 30:
- **Scope test**: each use case is at *user-goal level*: one primary actor, one goal, done in one session (the "coffee-break test": after finishing, the actor can take a break with the job done). "Verify OTP"-sized steps are sub-steps, not use cases.
- Fields: ID + verb-noun name · primary actor (a specific role such as "Reliability Engineer", never "User") · trigger · preconditions · normal flow (numbered actor ↔ system steps, no if/else) · alternative flows · exceptions (data missing, low confidence, source not approved) · postconditions · business rules · related KPI.
- Identify use cases goal-first (each actor's goals), then event-first (alarm fired, shift handover, monthly review), then CRUD-first (incident, action, document).

## 5. Prototype strategy
- Build only what proves the core claim. Features that make the "hook" visible beat a broad but shallow demo.
- Use the **real case data**, embedded. A replay of an actual historical failure (time-machine slider, alerts firing as weeks advance) is more convincing than any mock.
- Pre-generate the LLM outputs (stored as JSON) for a reliable demo. Live calls fail at the worst moment.
- Deploy as a link (Vercel/static hosting). Record a 2–3 minute demo video that walks one user story end to end.
- Keep a `docs/keputusan_build.md` covering: what was built, what was skipped, and why.

## 6. Business case for AI solutions
- Costs: platform and licences, cloud or on-prem infrastructure, integration (often the biggest item), data engineering, change management and training, and run costs (support, model monitoring, LLM tokens).
- Benefits: downtime avoided, quicker MTTR, fewer repeat failures, engineer hours freed, faster onboarding, avoided safety incidents (treat as derived value unless the case gives costs).
- Phase the benefits with adoption ramp-up (e.g. 25% / 60% / 90% over 3 years). Assuming 100% from day one is a red flag to judges.
- Use `scripts/fin_calc.py` and include a conservative scenario.

## 7. Hackathon finals (e.g. 24 hours on an unseen case)
| Time | Do |
|---|---|
| 0–1h | Read the case, write the brief map (question, rubric, deliverable, constraints); every member reads it all |
| 1–3h | Explore the data and find the hook; choose the idea with a fast scoring matrix; lock the storyline (ghost deck) |
| 3–14h | Build in parallel: analysis/impact numbers · prototype core flow · deck. Sync every 3h |
| 14–18h | Feature freeze; integrate; record a demo backup video |
| 18–21h | Deck polish; rehearse with a timer; red-team Q&A |
| 21–24h | Sleep or buffer; final export; check the submission format |

Reuse existing components (dashboard shell, RAG pipeline, chart templates) prepared before the event. Pitch in English if required, and rehearse the opening and closing word for word.
