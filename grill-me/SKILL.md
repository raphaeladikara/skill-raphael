---
name: grill-me
description: Interview the user before implementation, design, planning, debugging, refactoring, or product work to resolve ambiguity and reach shared understanding. Use when the user asks to be grilled, stress-test a plan, validate an approach, clarify requirements, improve accuracy before work starts, or says phrases like "grill me", "ask me questions first", "nanya dulu", "interview me", "before you code", "make sure you understand", or "biar lebih akurat".
---

# Grill Me

## Overview

Use this skill to slow down before action and aggressively remove uncertainty. The goal is not endless questioning; it is to gather enough project, product, technical, and decision context that the next work step is accurate, scoped, and mutually understood.

## Core Rule

Ask only questions that materially change the work. If an answer can be discovered from the repository, files, logs, docs, tests, issue text, or available tools, inspect those sources first and do not ask the user to repeat it.

For every question you do ask, include your recommended answer or default choice so the user can approve, correct, or refine quickly.

## Workflow

1. Restate the user's apparent objective in one or two sentences.
2. Explore local context before asking:
   - Read relevant README, AGENTS, package/config files, tests, routes, components, schemas, docs, and recent diffs when present.
   - Search with `rg` for domain terms, feature names, TODOs, and existing patterns.
   - Inspect errors, logs, screenshots, or artifacts the user already provided.
3. Separate known facts from assumptions.
4. Build a decision tree of the work:
   - Goal and success criteria
   - Users or audience
   - Scope and non-goals
   - Existing constraints
   - Data, APIs, state, permissions, and integrations
   - UX, copy, visual, or workflow choices
   - Risks, edge cases, rollout, validation, and maintenance
5. Ask the next smallest useful batch of questions, usually 3 to 7 at a time.
6. For each question, give:
   - Why it matters
   - Recommended answer
   - Consequence if the user chooses differently
7. Continue down dependent branches only after upstream choices are answered or accepted.
8. Stop grilling when the remaining unknowns are low-risk or can be handled with stated defaults.
9. Summarize the agreed plan, open assumptions, and the first execution step.

## Question Style

Use direct, concrete questions. Avoid vague prompts like "Any preferences?" unless paired with specific defaults.

Prefer this shape:

```text
1. What should count as success for this change?
   Recommended: Treat success as <specific measurable outcome>.
   Why it matters: This controls scope and validation.
   If different: I will adjust the implementation and tests toward that target.
```

When the user is casual, mirror their tone while keeping the questions precise. Indonesian, English, or mixed-language phrasing is fine; use the user's language by default.

## What To Ask About

Choose relevant categories instead of asking every category mechanically:

- Objective: What problem are we solving, and what outcome matters most?
- Audience: Who uses or reviews this, and what do they already know?
- Scope: What is included, excluded, and acceptable to defer?
- Constraints: Deadline, tech stack, dependencies, compatibility, budget, policy, or deployment limits.
- Current state: What already exists, what is broken, and what must be preserved?
- Data and contracts: Inputs, outputs, schemas, API behavior, permissions, error states.
- UX and content: Primary flow, empty/loading/error states, labels, tone, accessibility, responsive behavior.
- Design: Existing visual system, density, hierarchy, imagery, colors, and interaction patterns.
- Implementation: Architecture, ownership boundaries, reuse, migrations, feature flags, test strategy.
- Validation: How to prove it works, what checks to run, and what manual review is required.
- Risk: Security, privacy, data loss, user disruption, performance, rollback, and observability.

## Decision Discipline

Do not ask the user to design from a blank page if you can propose a good default. Make a recommendation based on:

- Existing project patterns
- The user's stated goal
- Simplicity and reversibility
- Risk reduction
- User-facing quality

Treat silence or "up to you" as acceptance of the recommended default. State that default before acting.

## When To Proceed

Proceed to implementation, planning, review, or debugging only when one of these is true:

- The user answered the blocking questions.
- The user explicitly accepted the recommended defaults.
- The remaining ambiguity is low-risk and you have clearly named the assumption.

Before proceeding, produce a short "shared understanding" summary:

```text
Shared understanding:
- Goal: ...
- Scope: ...
- Defaults accepted: ...
- Open assumptions: ...
- First step: ...
```

## Anti-Patterns

- Do not ask questions already answered by local context.
- Do not ask more than 7 questions in one batch unless the user explicitly wants a deep interrogation.
- Do not keep questioning after the next action is clear.
- Do not hide your recommendation; every question should make forward motion easier.
- Do not turn this into a generic requirements checklist. Follow dependencies in the actual decision tree.
