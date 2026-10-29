# Rewrite playbook

How to turn each tell into prose a human would write. Every example is a real transformation, not a word swap.

## The governing move

Most tells are symptoms of one disease: **the sentence asserts importance instead of carrying information.** The reliable fix is to replace the claim with the fact that would have justified it.

> `The library serves as a powerful and flexible foundation for modern data pipelines, ensuring seamless integration across diverse environments.`

Ask: what does it actually *do*? Then write only that.

> `The library moves rows between Postgres, S3, and Kafka. It handles backpressure, so a slow sink won't drop records.`

Shorter, more specific, and every tell vanished as a side effect — no word-level substitution required.

---

## 1. Significance and legacy claims

| Before | After |
|---|---|
| `stands as a testament to the team's commitment to quality` | *(delete)* — or: `has shipped without a P0 outage since 2023` |
| `plays a pivotal role in the authentication flow` | `issues the session token` |
| `marks a significant shift in how we handle state` | `replaces Redux with a single reducer` |
| `reflects a broader movement toward serverless architecture` | *(delete — it's about someone else's trend, not this project)* |
| `has left an indelible mark on the ecosystem` | *(delete)* |

**Rule:** if you can't replace it with a verifiable fact, cut the sentence. It was never carrying weight.

---

## 2. Participial tails

Delete the clause first, then check what was lost.

| Before | After |
|---|---|
| `Requests are batched, improving overall throughput.` | `Batching requests roughly triples throughput.` |
| `The config is validated at boot, ensuring reliability.` | `The config is validated at boot; a bad value fails fast instead of at 3am.` |
| `We cache the result, enhancing performance and reducing load.` | `We cache the result for 60s.` |
| `…, showcasing the framework's flexibility.` | *(delete)* |
| `…, thereby enabling seamless collaboration.` | *(delete, or name the actual capability)* |

Roughly two-thirds of these clauses should simply be deleted. The rest become their own short sentence.

---

## 3. Restoring the copula

| Before | After |
|---|---|
| `serves as the primary entry point` | `is the primary entry point` |
| `boasts over 40 integrations` | `has 40+ integrations` |
| `features a built-in retry mechanism` | `retries failed requests` |
| `offers support for TypeScript` | `supports TypeScript` |
| `maintains a comprehensive test suite` | `has 1,200 tests` |
| `Redis functions as the session store` | `Redis stores sessions` |
| `holds the distinction of being the first` | `was the first` |
| `Rate limiting refers to the practice of capping…` | `Rate limiting caps…` |

**Don't overcorrect:** `features` is right when something is genuinely on display (`the demo features a live editor`), and `provides` is standard in API reference prose (`the callback provides an AbortSignal`).

---

## 4. Puffery in technical docs

Every one of these is a claim the reader cannot check. Replace with a number, a behavior, or nothing.

| Before | After |
|---|---|
| `a robust, production-ready solution` | `runs in production at 3k req/s` |
| `blazing fast` | `parses 40 MB/s on an M2` |
| `seamless integration` | `one config block; no code changes` |
| `intuitive API` | *(delete — let the code sample argue it)* |
| `powerful and flexible` | *(delete — name the two things it does)* |
| `cutting-edge architecture` | `event-sourced, with a Postgres write-ahead log` |
| `comprehensive documentation` | `every public function has an example` |
| `empowers developers to unlock new workflows` | `lets you script the build` |

If no fact is available to replace the adjective, the honest edit is deletion.

---

## 5. Vague attribution

| Before | After |
|---|---|
| `Experts recommend caching at the edge.` | `The Fastly docs recommend caching at the edge.` |
| `It is widely considered the standard approach.` | `It's the approach used by Next.js, Remix, and SvelteKit.` |
| `Some critics argue the API is too verbose.` | `Issue #204 argues the API is too verbose.` |
| `Industry reports suggest adoption is growing.` | *(delete unless you can cite the report)* |

Name it or cut it. There is no third option that is honest.

---

## 6. Challenges / conclusion sections

Delete the section wholesale, then decide whether any real content deserves rescuing.

> `## Challenges and Future Outlook`
> `Despite its many strengths, the library faces several challenges. Performance at scale remains an area for improvement, and documentation could be more comprehensive. Looking ahead, continued community involvement will be crucial to its ongoing success.`

Becomes either nothing, or the honest version:

> `## Known limitations`
> `Queries over ~50k rows fall back to a table scan (#87). The streaming API has no docs yet.`

Real limitations are specific and have issue numbers. Generic ones are filler.

---

## 7. Negative parallelism

| Before | After |
|---|---|
| `It's not just a linter — it's a complete toolchain.` | `It lints, formats, and type-checks.` |
| `This isn't merely a refactor, it's a rethinking of the data layer.` | `This replaces the ORM with hand-written SQL.` |
| `No config, no boilerplate, just results.` | `Runs with zero config.` |
| `The goal was consolidation rather than ideological purity.` | `The goal was consolidation.` |

The construction always argues against a position nobody held. State the positive claim directly.

---

## 8. Rule of three

> `The API is fast, flexible, and easy to use.`

Ask which of the three you can defend. Usually one:

> `The API has four methods.`

When the three items are all real, keep them — but check that the third isn't invented to complete the rhythm. Inventing the third item is how paraphrasing introduces false facts.

---

## 9. Elegant variation

> `The **parser** handles the input. This **module** validates each token, and the **component** then emits an AST. The **utility** is fully typed.`

Four names, one thing. Pick one:

> `The **parser** handles the input. It validates each token and emits an AST. It's fully typed.`

Repetition is not a flaw in technical prose — it's how the reader tracks the referent.

---

## 10. Sentence rhythm

LLM paragraphs cluster tightly around 15–25 words per sentence. Human paragraphs vary hard.

**Before** (every sentence 18–22 words):
> `The authentication system uses JSON Web Tokens to maintain session state across requests. Each token is signed with a rotating secret that is refreshed every twenty-four hours automatically. This approach ensures that compromised tokens have a limited window of exploitability for potential attackers.`

**After** (4, 31, 9 words):
> `Auth uses JWTs. Each token is signed with a secret that rotates daily, so a leaked token is useless within 24 hours — which matters because we can't revoke individual tokens without a session table. We decided that trade was worth it.`

Techniques: open with a short declarative; let one sentence run long with a real subordinate clause; end short. Add the *reason* for a decision — LLMs describe what, humans explain why.

---

## 11. What NOT to do

These are common overcorrections that make text worse:

- **Don't inject casualness.** Adding "honestly," "basically," or "let's dive in" to sound human just swaps one formula for another. `let's dive in` is itself an AI tell.
- **Don't add errors.** Typos and grammar mistakes are not humanity.
- **Don't purge all em dashes and curly quotes.** See `ai-tells.md` §13 — the evidence is weak and Word/macOS insert curly quotes automatically.
- **Don't shorten everything.** Terseness is its own tell. Vary.
- **Don't remove real hedging.** `tends to`, `usually`, `in most cases` are signs of human writing and often more accurate than the absolute claim.
- **Don't change technical meaning to improve flow.** If the rewrite is smoother but the claim shifted, the rewrite is wrong. Revert.
- **Don't rewrite pre-2022 text.** Check `git log` first.

---

## Self-check before finishing

For each rewritten passage:

1. Does it state a fact the original didn't, that you can't verify? → You hallucinated. Revert.
2. Did any number, flag, symbol, version, or API name change? → Revert those.
3. Read it aloud. Does it sound like a person explaining something to a colleague?
4. Is it shorter? Good de-slopping almost always cuts 20–40% of the word count.
5. Did you preserve the author's register, or impose your own?
