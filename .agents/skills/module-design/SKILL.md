---
name: module-design
description: Design a module for this library before implementing it. Use when a session starts on a new foundation, provider, adapter or HTTP-layer module, or when a change would add a public entry point, a dependency or a runtime dependency. Produces a written design for the user to approve, not code.
---

# Module design

This repository is a shared library, so a module is a contract other services depend on.
Design it before writing it, and get the user to approve the contract before implementing.

## Read first

Read `AGENTS.md` and, from it:

- the **scope table** to know which area the module belongs to and what the non-goals are;
- the **decision table** for the constraints already decided, and the detailed entries
  that follow it — read the table itself rather than a remembered range;

Do not relitigate a decided item. If one looks wrong, say so and propose a new decision
entry instead of quietly ignoring it.

## Sequence

1. **Contract.** Name the public symbols and their signatures. Every entry point is part of
   the semver surface: factories over singletons, explicit options first, environment as
   fallback, and no work at import time.
2. **Placement.** Decide the file under `src/`, its `exports` subpath, and whether the
   dependency is a regular dependency or an optional peer. Heavy integrations must be
   separate subpaths so an API only loads what it uses.
3. **Boundaries.** For anything external, define the port as an interface small enough for
   every provider. Provider extensions belong outside the contract.
4. **Dual build.** Assume the module can be loaded twice, once per format: brand errors with
   `Symbol.for`, keep shared state on `globalThis` under `Symbol.for` keys, never trust
   `instanceof`, and add no top-level `await`. Every runtime dependency must load from CJS.
5. **Configuration.** Name the environment variables and validate them with Zod through
   `loadConfig(schema)`. Variable names are public API.
6. **Tests.** Plan unit tests per module and, when it talks to a service, an integration test
   with a real container.
7. **Open points.** List everything still undecided instead of guessing.

## Deliverable

A short written design: contract, placement, dependencies, boundaries, test plan, open
points. Then stop and ask. Only implement after the user approves, and run the four gates
before calling the result green.

## Out of scope

No database access or ORM, no token issuance or login flows, no business logic, no
dashboards, and no replacement for Express or NestJS. A domain rule belongs in the
microservice that owns it, not here.
