# Catalog of AI-writing tells

Every pattern below carries a severity and a regex you can feed straight to the Grep tool if the scanner script is unavailable. All regexes are case-insensitive unless noted.

**Severity meaning:**

| Level | Meaning | Action |
|---|---|---|
| `definitive` | Can only come from a chatbot. Not a style judgment. | Fix unconditionally |
| `high` | Strong tell. Rarely appears in careful human prose. | Rewrite unless clearly deliberate |
| `medium` | Real tell, but has honest uses. Judge in context. | Rewrite if clustered |
| `low` | Weak signal. Meaningful only in density. | Ignore in isolation |

---

## 1. Machine artifacts — `definitive`

Leaked internal markup from a chatbot's citation or rendering layer. These are unambiguous.

| Source | Pattern | Regex |
|---|---|---|
| ChatGPT | citation refs | `contentReference\|oaicite\|oai_citation\|attributableIndex` |
| ChatGPT | search/image turns | `turn\d+(search\|image\|news\|file)\d+` |
| ChatGPT/Copilot | UTM tags on links | `utm_source=(chatgpt\.com\|openai\|copilot\.com)` |
| Grok | citation cards | `grok_card\|grok_render_citation_card_json\|referrer=grok\.com` |
| Gemini | citation markers | `\[cite:\s*\d+\|\[span_\d+\]\((start\|end)_span\)` |
| DeepSeek | lenticular refs | `【\d+†` |
| Perplexity | file refs | `\[attached_file:\d+\]\|\[web:\d+\]\|ppl-ai-file-upload` |
| Unclassified | document markup | `:::writing\{` |

**Placeholders left unfilled** — also definitive:

```
\[(Your|Insert|Add|Company|Product|Entertainer's)\s+\w+\]
20\d\d-XX-XX
\(Add your .{0,30} here\)
\[TODO: (fill|insert|add)
```

**Chat-to-user leakage** — text meant as conversation, pasted as content:

```
\b(Certainly|Of course|Great question|I hope this helps|You're absolutely right)\b
\bWould you like me to\b|\bLet me know if you\b|\bIs there anything else\b
\bHere('s| is) (a|the) (detailed |comprehensive |brief )?(breakdown|overview|summary)\b
\bAs an AI (language )?model\b
```

**Knowledge-cutoff disclaimers:**

```
\b(as of|up to) my (last )?(knowledge|training)( (update|cutoff))?\b
\bbased on (the )?available (information|sources|search results)\b
\b(not|isn't) (widely |publicly )?(available|documented|disclosed) in (the )?(provided|available) sources\b
\bmaintains a low profile\b|\bkeeps personal details private\b
```

---

## 2. Undue significance, legacy, and broader trends — `high`

The single most reliable prose tell. LLMs inflate the importance of whatever they describe and connect it to a larger narrative.

```
\b(stands|serves) as (a|an|the)\b
\bis a testament to\b|\ba testament to\b|\bis a reminder (of|that)\b
\bplay(s|ed|ing)? (a|an) (crucial|pivotal|vital|significant|key|central|important) role\b
\bunderscor(es|ing|ed) (the|its) (importance|significance|need|role)\b
\bhighlight(s|ing) (the|its) (importance|significance)\b
\breflect(s|ing) (a )?broader\b|\bpart of a broader (movement|trend|shift)\b
\bsymboliz(es|ing) (its )?(ongoing|enduring|lasting|continued)\b
\bcontribut(es|ing) to (the|its) (rich|broader|growing|overall)\b
\bset(s|ting) the stage for\b
\bmark(s|ing|ed) (a|the) (pivotal|significant|key|turning) (moment|point|shift)\b
\brepresent(s|ed|ing) (a|the) (significant |major |fundamental )?shift\b
\bevolving landscape\b|\bindelible mark\b|\bdeeply rooted in\b|\bfocal point\b
\bcement(s|ing|ed) (its|his|her|their) (place|status|legacy)\b
\bleav(es|ing) (a|an) lasting (impact|impression|legacy)\b
```

**Why it's bad:** these sentences carry no information. They assert importance instead of demonstrating it. Delete them or replace with the concrete fact that would justify the claim.

---

## 3. Superficial participial analysis — `high`

A present participle clause bolted onto the end of a sentence to simulate insight. Usually the strongest structural tell after §2.

```
,\s*(highlighting|underscoring|emphasizing|showcasing|reflecting|symbolizing|ensuring|fostering|cultivating|enhancing|contributing to|solidifying|cementing|allowing for|making it|further)\b
\bthereby (ensuring|enabling|allowing|creating|providing)\b
\bwhile (also )?(ensuring|maintaining|providing|offering|preserving)\b
```

**Test:** delete the clause. If the sentence loses nothing, it was decoration. If it loses something, state that thing plainly as its own sentence.

---

## 4. Copula avoidance — `high`

LLMs systematically dodge `is`/`are`/`has` in favor of marketing verbs. Measured as a >10% drop in `is`/`are` frequency in post-2023 academic writing.

```
\b(serves|stands|functions|operates|acts) as (a|an|the)\b
\bboasts (a|an|\d|over|more)\b
\b(features|offers|provides|maintains|houses|delivers) (a|an|several|multiple|numerous)\b
\brefers to (a|an|the)\b          # in a defining first sentence
\bhold(s) the distinction of\b
\bventured into\b|\bembarked on\b|\bbegan (his|her|their|its) (career|journey) as\b
\bis home to\b
```

**Fix:** `serves as the primary interface` → `is the primary interface`. `boasts 12 endpoints` → `has 12 endpoints`. Be careful: `features` is correct when it means "puts on display," and `provides` is correct in API docs.

---

## 5. Promotional / puffery register — `medium`

LLMs drift toward brochure prose even when told to be neutral.

```
\b(vibrant|bustling|thriving|renowned|prestigious|esteemed|iconic|breathtaking|stunning|captivating|compelling)\b
\bnestled (in|within|among|between)\b|\bin the heart of\b
\b(rich|diverse) (tapestry|array|range|heritage|history|ecosystem)\b
\b(groundbreaking|revolutionary|transformative|game[- ]?chang(er|ing)|cutting[- ]edge|state[- ]of[- ]the[- ]art|next[- ]generation|world[- ]class|best[- ]in[- ]class)\b
\bcommitment to (excellence|quality|innovation|sustainability)\b
\bseamless(ly)?\b|\beffortless(ly)?\b|\bunparalleled\b|\bunwavering\b
\b(unlock|unleash|harness|empower|elevate|supercharge|revolutionize) (the|your|its|new)\b
\b(natural|stunning) beauty\b|\bmust[- ]visit\b|\bhidden gem\b
```

In software docs, `seamless`, `robust`, `powerful`, `flexible`, and `intuitive` are the worst offenders — they're claims the reader can't verify. Replace each with the measurement or behavior that would justify it.

---

## 6. Vague attribution — `high`

Opinions credited to an unnamed authority, or one source inflated into many.

```
\b(experts|analysts|observers|critics|scholars|researchers|commentators) (argue|note|say|believe|have (noted|cited|observed|suggested))\b
\bsome (critics|observers|analysts|experts)\b
\b(industry|market) reports (suggest|indicate|show)\b
\bis (widely|generally|often|commonly) (regarded|considered|seen|viewed|interpreted|believed) (as|to)\b
\bit is (widely|generally) (believed|accepted|understood|acknowledged)\b
\bhas been (praised|lauded|criticized|noted) for\b
\bseveral (sources|publications|outlets|studies)\b
```

**Fix:** name the source, or delete the claim. If you can't name it, it isn't a fact you can assert.

---

## 7. Canned emphasis on coverage and notability — `medium`

Common in 2025+ models. Asserts credibility by listing the *kinds* of sources rather than what they said.

```
\bindependent coverage\b|\bindependent(ly)? (verified|sourced)\b
\b(local|regional|national|international) (media )?outlets\b
\btrade publications\b|\b(tech|business|music|industry) outlets\b
\b(has been |was )?(profiled|featured) in\b
\bmaintains (an|a) (active|strong|significant) (social media |digital |online )?presence\b
\bwritten by a leading expert\b
```

---

## 8. Challenges / future-outlook formula — `high`

A rigid closing section. The formula is the tell, not the topic.

```
\bDespite (its|these|the) [\w\s]{0,40}(challenges|limitations|criticisms|setbacks)\b
\bfaces (several|numerous|various|a number of|ongoing) challenges\b
^#{1,6}\s*(Challenges( and (Legacy|Opportunities|Limitations))?|Future (Outlook|Prospects|Directions)|Conclusion|Final Thoughts|Key Takeaways)\s*$
\b(Looking|Moving) (ahead|forward)\b|\bAs (the|this) [\w\s]{0,30} (continues to )?(evolve|grow|expand)\b
\bOnly time will tell\b
```

---

## 9. Negative parallelism — `high`

Framing a fact as a correction to a misconception the reader never held.

```
\bnot (just|only|merely|simply) (a|an|about)?[^.]{0,60}\bbut (also )?\b
\bit'?s not (just )?[^.,]{1,40}, it'?s\b
\bisn'?t (just )?(about )?[^.,]{1,40}[—,-]\s*it'?s\b
\bno [\w]+, no [\w]+, just\b
\brather than (a|an|mere|simply|ideological|purely)\b
\bmore than (just )?(a|an)\b
```

---

## 10. Rule of three — `medium`

Three-item lists as a default rhythm. Detect by density, not by any single instance.

```
\b\w+, \w+,? and \w+\b                          # noisy — count occurrences per 100 lines
\b(fast|simple|powerful|clean|modern|flexible|scalable|secure|reliable|intuitive), \w+,? and \w+\b
```

**Heuristic:** more than ~4 three-item lists per 500 words is a rhythm tell. Check whether the third item is real or invented to complete the cadence.

---

## 11. AI vocabulary — `low` individually, `high` in density

Words empirically overused post-2022. **A word being on this list does not make it wrong.** Weight by cluster: 5+ distinct hits in a paragraph is a strong signal; one is nothing.

**2023 – mid-2024 (GPT-4 era):**
`delve` `tapestry` `testament` `intricate` `intricacies` `meticulous(ly)` `pivotal` `bolstered` `garner` `interplay` `enduring` `boasts` `vibrant` `crucial` `Additionally` `landscape` (abstract) `realm` `myriad` `plethora` `navigate the complexities`

**Mid-2024 – mid-2025 (GPT-4o era):**
`align with` `resonate with` `foster(ing)` `enhance` `showcase` `underscore` `emphasize` `highlight` (verb) `leverage` `robust` `holistic` `nuanced` `multifaceted` `comprehensive`

**Mid-2025+ (GPT-5 era):**
`emphasizing` `enhance` `highlighting` `showcasing` — plus everything in §7.

**Grok-specific:** `empirical` `causal` `correlate` `underscore` (still heavy in 2026).

Combined regex:
```
\b(delve|delving|tapestry|testament|intricate|intricacies|meticulous|meticulously|pivotal|bolster(ed|ing)?|garner(ed|ing)?|interplay|enduring|myriad|plethora|realm|holistic|multifaceted|nuanced|underscore(s|d)?|foster(s|ed|ing)?|showcase(s|d)?|leverage(s|d)?|align(s|ed)? with|resonate(s|d)? with|crucial|robust|comprehensive|seamless|vital|profound|paramount)\b
```

---

## 12. Formatting tells — `medium`

| Tell | Regex / check |
|---|---|
| Bold-header vertical lists | `^\s*[-*•]\s*\*\*[^*]+\*\*\s*[:—-]` |
| Emoji decorating headings/bullets | `^#{1,6}\s*[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]` |
| Title Case headings | `^#{1,6}\s+([A-Z][a-z]+\s+){2,}[A-Z][a-z]+\s*$` |
| Over-bolding | count `\*\*[^*]+\*\*` — more than ~6 per 300 words |
| Thematic break between every section | `^(---\|___\|\*\*\*)$` repeated before each `^#` |
| Skipped heading levels | `###` appearing before any `##` |
| Title heading duplicating the doc title | first `# X` where `X` == filename/frontmatter title |
| Headings containing only headings | `^##` immediately followed by `^###` with no prose between |

## 13. Punctuation tells — `low`

```
\s—\s                 # spaced em dash — LLMs space them; most style guides don't
[‘’“”]   # curly quotes / apostrophes
```

**Heavy false-positive risk.** macOS, iOS, and Microsoft Word insert curly quotes automatically. Chicago style mandates them. A July 2026 study found only Claude uses em dashes more than professional writers — ChatGPT now uses *fewer*. Treat both as corroborating evidence at most, never as a basis for editing on their own.

## 14. Didactic disclaimers & summaries — `medium` (mostly pre-2025)

```
\bit'?s (important|crucial|essential|worth) (to note|noting|to remember|to consider)\b
\bit should be noted that\b|\bkeep in mind that\b
\b(In (summary|conclusion)|To summarize|Overall|In essence|Ultimately),\b
```

## 15. Elegant variation — `medium`

LLMs carry a repetition penalty, so they rotate synonyms for the same referent within a paragraph: *the library → the package → the tool → the framework → the solution*. Humans repeat the noun.

**No regex.** Detect by reading: pick the paragraph's subject and count how many different nouns refer to it. More than two is a tell. Fix by choosing one name and using it every time.

---

## Ineffective indicators — do NOT treat these as evidence

Acting on these produces false accusations and worse writing.

- **Perfect grammar.** Many people write well.
- **Formal, academic, or "fancy" prose.** Only *specific* overused words correlate with AI, not formality in general.
- **"Bland" or "robotic" tone.** LLM output actually skews positive and verbose, not flat.
- **Mixed casual and formal register.** Normal for technical writers, non-native speakers, and playful authors.
- **Transition words alone.** `Additionally`, `Moreover`, `Furthermore` are standard in essay writing and endorsed by style guides.
- **Unsourced claims.** Predates LLMs by decades; modern LLMs actually add citations.
- **Correct or broken markup on its own.** Broken HTML/wikitext usually means a bad editor tool, not AI.
- **AI-detector scores.** GPTZero, Pangram, and similar have non-trivial error rates and are defeated by light paraphrasing. Never edit on a detector score alone.
- **Your own gut.** A 2025 study found humans distinguish LLM text at roughly chance level. Heavy LLM users reach ~90%, which still means one false positive in ten.

## Signs of *human* writing

Presence of these argues against AI authorship:

- Simple `is`/`has` constructions: *there is a*, *it has a*.
- Plain verbs where a stiff synonym exists: *wrote* not *authored*, *used* not *utilized*, *moved* not *relocated*, *died* not *passed away*.
- Superlatives and definite claims: *the only*, *the first*, *the best*.
- Hedges and intensifiers: *very*, *perhaps*, *tends to*, *pretty much*.
- Wordy-but-natural constructions: *as a result of*, *in order to*, *the fact that*.
- Repeating the same noun instead of rotating synonyms.
- High sentence-length variance.
- **Text committed before 30 November 2022.** ChatGPT's public launch. Check `git log --diff-filter=A -- <file>`. Older text cannot be AI-generated no matter how formulaic it looks.
