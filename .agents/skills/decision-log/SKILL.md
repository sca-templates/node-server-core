---
name: decision-log
description: Append a decision entry to AGENTS.md and keep the decision table in sync. Use at the end of any planning session that settled, changed or reversed a design decision, and whenever a decision is superseded by a later one.
---

# Decision log

`AGENTS.md` holds the decision log, and it is the single source of truth for this
repository. Append entries in order; never renumber, reorder or rewrite a previous one.

## Where it goes

Two places must agree:

1. the **decision table** in _Design constraints_, one row per decision, with its
   consequence spelled out in a second column;
2. the **detailed entries** that follow, in numeric order.

A decision that only exists as a detailed entry is invisible to the reader who scans the
table first.

## Entry format

```text
### Dxx: <short title>
- Status: Accepted | Proposed | Superseded by Dyy
- Decision: <one or two sentences>
- Rationale: <why>
- Consequences: <what changes, trade-offs>
- Open points: <anything still undecided>
```

## Rules

- **Numbering.** The next free integer, always at the end. If the highest is `D19`, the new
  one is `D20`, even when it fills a gap that looks more logical. Gaps are normal: a removed
  or retired decision leaves its number unused.
- **Superseding.** Change the old entry's status to `Superseded by Dxx` and strike its row in
  the table. Write the replacement in full; do not edit the old decision's wording to
  pretend the new one was always the plan.
- **Retiring.** When a decision is dropped entirely and leaves nothing behind, delete its row
  and its section instead of leaving a dead pointer. Anything still true moves to
  `## Commands` or `## Conventions`, where it belongs as a fact instead of a decision.
- **Status.** `Proposed` while the user has not agreed. Use `Accepted` only on the user's
  word. Never mark a decision accepted because you implemented it.
- **Language.** English, like everything committed. Introduce and explain the entry to the
  user in Spanish.
- **No invented surface.** A decision about an API that does not exist yet is `Proposed` with
  the open points listed, not a fact.

## Close the session

At the end of a planning session, append the entry even when the outcome was a rejection:
recording what was rejected and why is what stops the same question returning next month.
