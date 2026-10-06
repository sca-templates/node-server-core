# node-server-core — AI Agent Guide

`@sca-templates/node-server-core` is the shared core for the organization's
Node.js APIs. It holds the plumbing every Node service repeats — helpers, error
types, shared constants, configuration, validation, logging — so a fix lands here
once instead of in every repository.

It is a **library, not a service**: no server, no Dockerfile, no Kubernetes
manifests, and no business logic. A domain rule belongs in the microservice that
owns it.

## Status and mode

The public surface is intentionally empty: `src/index.ts` is a bare barrel with
no exports. The pipeline around it — build, types, tests, coverage, release and
publish — is complete, so the first real module is one file plus its `exports`
subpath plus its test. The manifest sits at `0.0.0` and **no version has been
published**.

This repository's initial planning is done: scope, roadmap and every design area
are on the board. Implementation follows the roadmap and starts with the
foundations in the order already listed — errors (#2), configuration (#3),
request context (#4).

Planning is not over; it is no longer the whole job. Every module is still designed
before it is written: its sub-issues reach `Decided`, their outcome lands in the
decision log, and only then does code follow. The `module-design` skill is that
process, and nothing is implemented until its design session says so.

## Authority

- **`AGENTS.md` is the single source of truth** for this repository. Do not
  restate its facts in another agent file; link instead.
- `README.md` is the public, consumer-facing document: install, scripts, CI
  gates, release and publishing notes. Read it instead of duplicating it here.
- `.claude/CLAUDE.md` holds repo-specific guidance for Claude Code and points
  back here.
- Per-agent and per-provider wiring is inventoried in
  [`.agents/README.md`](.agents/README.md).
- Organization-wide documentation is external: [sca-docs](https://github.com/sca-templates/sca-docs),
  fetched as raw URLs from
  `https://raw.githubusercontent.com/sca-templates/sca-docs/main/<path>` —
  `00-ecosystem/conventions.md`, `00-ecosystem/platform-overview.md`,
  `05-packages/INDEX.md`, `05-packages/sca-core.md`.

## Working agreements

### Language rules (strict)

1. **Everything written for GitHub must be in English**: README files, issue and
   pull request titles and bodies, commit messages, labels and their
   descriptions, project board text, release notes, ADRs, CONTRIBUTING and
   script output messages.
2. **All content inside code blocks must be in English**: comments, identifiers,
   strings and inline docs.
3. Library names, protocols and technical terms are kept as they are.

### Working style

- Lead with a **recommendation and its reasoning**. State trade-offs, and
  disagree openly when a choice looks wrong.
- Ask **one question at a time**, and never ask about something already decided
  in the decision table.
- Verify current facts (library maintenance status, versions, tool
  compatibility) with a search before recommending. Do not rely on memory for
  versions.
- Never invent API surface. If something is undecided, say so and list it as
  open.
- **The user commits and pushes.** Never run `git commit`, `git push`, or any
  other git write, and do not stage, reset or amend. Draft commits and messages
  instead, and ask.
- Never commit secrets, tokens or credentials.
- **The package is public on npm.** Never put organization-internal details
  (hostnames, topic names, Vault paths, internal conventions) into the library
  design or any GitHub artifact. Those must always come from configuration.

### Decision log format

Append an entry at the end of every planning session, in order, without
renumbering existing ones.

```text
### Dxx: <short title>
- Status: Accepted | Proposed | Superseded by Dyy
- Decision: <one or two sentences>
- Rationale: <why>
- Consequences: <what changes, trade-offs>
- Open points: <anything still undecided>
```

## Layout

```text
.
├── .agents/                # inventory of agents, providers and skills
│   └── skills/              # canonical skills, read natively by every provider
├── .claude/                # CLAUDE.md + settings.json; skills/ symlinks to ../.agents/skills
├── .codex/config.toml       # MCP servers (Codex CLI)
├── .cursor/mcp.json        # MCP servers
├── .gemini/settings.json   # MCP servers
├── .github/
│   ├── ISSUE_TEMPLATE/     # bug_report.yml, feature_request.yml, task.yml, config.yml
│   ├── workflows/
│   │   ├── ci.yml          # caller of the shared CI workflows
│   │   ├── publish.yml     # npm publish, on `release: published`
│   │   └── release.yml     # caller of shared-release-flow
│   ├── CODEOWNERS
│   ├── CONTRIBUTING.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── dependabot.yml      # npm + github-actions ecosystems
├── scripts/labels.sh       # label source of truth (gh CLI)
├── src/
│   └── index.ts            # public entry point; an empty barrel today
├── test/                   # vitest suites, one per src/ module; empty today
├── .editorconfig
├── .lintstagedrc.json      # pre-commit: eslint --fix + prettier
├── .mcp.json               # MCP servers (Claude Code)
├── .npmrc                  # git-checks=false
├── AGENTS.md               # this file — the source of truth
├── GEMINI.md               # CodeGraph block, read by Gemini CLI
├── commitlint.config.js    # Conventional Commits rules
├── eslint.config.js        # flat config; ignores root *.config.js / *.config.mjs
├── opencode.jsonc          # MCP servers (opencode)
├── package.json            # scripts, exports, publishConfig, pnpm overrides
├── pnpm-workspace.yaml     # ignoredBuiltDependencies only — single package
├── tsconfig.json           # type-check only; must list every linted *.config.ts
├── tsup.config.ts          # bundler: esm, dts, target node22, entry globs src/**
└── vitest.config.ts        # v8 coverage over src/; no thresholds until code exists
```

`.nvmrc` pins the Node version, `.husky/` holds the Git hooks. `0.Project_info/`
and `context/` are local-only material and are not committed. `test/` is absent
until the first module exists: Git does not track empty directories, and
`vitest.config.ts` sets `passWithNoTests` so `pnpm test:ci` still exits `0`.

## Commands

The four gates, all of which must pass before calling a change green:

| Command                             | What it does                                       |
| ----------------------------------- | -------------------------------------------------- |
| `pnpm typecheck`                    | `tsc`, no emit. Strict; the only type gate.        |
| `pnpm test:ci`                      | `vitest run --coverage`. **This is what CI runs**. |
| `pnpm lint` / `pnpm lint:fix`       | ESLint.                                            |
| `pnpm format` / `pnpm format:check` | Prettier.                                          |

`pnpm build` bundles with tsup into `dist/`; `pnpm dev` is `tsup --watch`. The
full script list and what each one does is in [README.md](README.md#scripts).

`pnpm test:ci` passes with **zero test files** until the first module exists.
That is `passWithNoTests` in `vitest.config.ts`, not a broken suite: read the
line count before concluding the tests pass. There are **no coverage
thresholds** for the same reason; add them with the first module, not before.

There is **no `actionlint` in CI** and no markdown linter wired locally. If you
touch `.github/workflows/`, validate by hand with
`actionlint .github/workflows/*.yml`.

## Conventions

- **English only**: content, commits, PR descriptions.
- **Conventional Commits**, enforced by commitlint via the `commit-msg` Husky
  hook: types `feat`, `fix`, `perf`, `build`, `ci`, `docs`, `refactor`, `style`,
  `test`, `chore`, `revert`; scopes are free-form (not an enum). Subject under
  72 chars, lowercase, no trailing period. Use `feat!:` and `fix!:` for
  breaking changes; Release Please reads the PR title, so use squash merge.
- **Release Please** manages versions and the changelog. Never delete or rename
  its `autorelease: pending` and `autorelease: tagged` labels.
- **Git writes are the user's** (see working agreements).
- **Never commit** secrets, tokens or credentials.
- **Pin actions by commit SHA** with the version in a trailing comment. Never
  `@main` or `@latest`.
- Prettier and ESLint disagree by design: `eslint-config-prettier` is loaded, so
  formatting is never an ESLint error.
- Root `*.config.js` and `*.config.mjs` are **excluded from ESLint** on purpose —
  they are build config, not source.

## Design constraints

These are decided. Implement against them; do not relitigate them.

| ID  | Decision                                                                                                | Consequence for the code                                                                                                                                                                                                                      |
| --- | ------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| D01 | Zod 4 is the only schema library                                                                        | No `class-validator`. One schema serves validation, DTOs and OpenAPI.                                                                                                                                                                         |
| D02 | Pino behind a minimal logger interface owned by the library                                             | Depend on the interface, never on Pino. Logs carry trace and span ids. Each factory takes the logger as an option (D21).                                                                                                                      |
| D03 | `AsyncLocalStorage` for user/tenant; trace and span from the OTel span                                  | Propagate W3C `traceparent` in the HTTP client and event headers. `x-request-id` is a fallback.                                                                                                                                               |
| D04 | `AppError` base with a stable code; RFC 9457 problem details on the wire                                | Exactly one error-to-response translation point per adapter.                                                                                                                                                                                  |
| D05 | Env vars drive configuration, validated with Zod via `loadConfig(schema)`                               | Env var names are public API. Options override the environment. Nothing reads env at import time.                                                                                                                                             |
| D06 | Framework-agnostic core, thin adapters at `/express` and `/nest`                                        | Express and NestJS are optional peer dependencies.                                                                                                                                                                                            |
| D07 | Kafka is reached only through the events port; no client type crosses the public API                    | Consumers import `…/providers/kafka`; the client is an optional peer dependency (D16) and never appears in a core module. Kafka carries facts and BullMQ carries work (D24); which Kafka client it is gets decided in phase 3.                |
| D08 | Vitest for everything, Testcontainers for integration                                                   | Vitest/esbuild emits no decorator metadata, so NestJS adapter tests need an SWC plugin.                                                                                                                                                       |
| D09 | Public on npm; published versions are immutable                                                         | Nothing organization-internal may appear in the package or its docs.                                                                                                                                                                          |
| D11 | Kafka is self-hosted on Kubernetes                                                                      | TLS and SASL must be configurable; credentials may come from the secrets provider.                                                                                                                                                            |
| D12 | The library **verifies** JWTs (JWKS cache and rotation, issuer, audience, expiry, algorithm allow-list) | No token issuance, no login flows. The JWT library must work from CJS.                                                                                                                                                                        |
| D13 | OpenTelemetry through `@opentelemetry/api` only                                                         | The app picks the SDK and exporters. In ESM, instrumentation must load before app code.                                                                                                                                                       |
| D14 | Audit event schema plus an `AuditSink` interface                                                        | Logger sink is the default, events sink is built in. A failed write is logged and counted, never blocking (D23).                                                                                                                              |
| D15 | Current majors of Express and NestJS, Node `>=22.12`                                                    | Verify the exact majors when designing the adapters.                                                                                                                                                                                          |
| D16 | One package, subpath exports, optional peer dependencies                                                | Factories over singletons. Explicit options first, env fallback. No work at import time.                                                                                                                                                      |
| D17 | Dual ESM and CJS build                                                                                  | **Dual package hazard**: brand errors with `Symbol.for`, keep shared state on `globalThis` under `Symbol.for` keys, never trust `instanceof`. No top-level `await`. Every runtime dep must load from CJS. Validate with `publint` and `attw`. |
| D18 | Ports and adapters for cache, events and secrets                                                        | Interfaces stay small enough for every provider; provider extensions live outside the contract.                                                                                                                                               |
| D19 | AWS, Azure and GCP support via each cloud's standard credential chain                                   | Application Default Credentials on GCP, and the equivalents elsewhere.                                                                                                                                                                        |
| D20 | The GitHub Project is a planning board with its own vocabulary                                          | Planning values, not delivery ones: `Status` is `Proposed`/`In design`/`Decided`/`Blocked`/`Superseded`/`Dropped` and `Domain` mirrors the plan layers. `Team`, `Effort`, `Iteration` and `Quarter` are gone. No code impact.                 |
| D21 | The logger is a factory option; no module-level or global registry                                      | Each factory takes the logger explicitly and defaults to a no-op or console sink. Two loggers in one process are allowed, so nothing is cached under `Symbol.for`. Refines D02 and D16.                                                       |
| D22 | The library redacts sensitive keys by default and the app extends the list                              | Defaults cannot be turned off, only widened. Keys come from the library plus an app-supplied list. Covers structured logging (D02) and the audit payload (D14).                                                                               |
| D23 | A failed audit write is logged and counted, and never blocks the operation                              | Closes the open point in D14. The sink is best effort by design; a strict mode is not provided.                                                                                                                                               |
| D24 | Kafka carries facts, BullMQ carries work; each has one adapter                                          | Closes the boundary half of D07. The Kafka client choice stays open. Events never run job logic and queues never broadcast facts.                                                                                                             |
| D25 | One independently decidable question per sub-issue                                                      | A parent issue is an area container, not a work item. It holds the constraints already decided and a list of sub-issues; it is `Decided` when all of them are. Twelve narrow areas stay whole. No code impact.                                |
| D26 | Cache invalidation happens at the write site; the cached representation is versioned separately         | No staleness probe on the read path and no push invalidation. A cached entry carries a version of the shape it was written under, so a schema change cannot be read as current. The key _layout_ stays in #62.                                |
| D27 | Managed cloud equivalents for every ported component                                                    | Each of D18's three ports has an AWS, Azure and GCP counterpart; where none exists the portability matrix says so instead of failing silently. Provider choice and failover belong to the consuming team. Built last, in phase 5.             |

### D17 in practice

The dual build is the constraint most likely to produce a silent bug: the same
module can be loaded twice, once per format. Shared state must not depend on
module identity.

- Detect `AppError` through a `Symbol.for` brand, not `instanceof` alone.
- Keep the `AsyncLocalStorage` instance and any registry on `globalThis` under
  `Symbol.for` keys.
- No top-level `await` anywhere.
- TypeScript consumers on `moduleResolution: node` ignore `exports`, so subpath
  entries need `typesVersions` or the docs must require `node16`, `nodenext` or
  `bundler`. Whether to support node10 through `typesVersions` is open.

### D20: The Project is a planning board, with its own vocabulary

- Status: Accepted
- Decision: Project 3 tracks decisions and design topics, so its `Status` and
  `Domain` fields were given planning values instead of the delivery values the
  organization template ships, and the delivery-only fields were removed.
- Rationale: the template's `New`/`In progress`/`Deployed` flow and its
  `Domain` options (business domains such as `Edge & Mesh`) do not describe this
  library, and all three items were sitting in a wrong `Domain`. A board whose
  field values argue against its own purpose invites the delivery reading.
- Consequences: `Status` is `Proposed`, `In design`, `Decided`, `Blocked`,
  `Superseded` or `Dropped`; `Domain` is the plan layers, same vocabulary as the
  `Area` dropdown in `task.yml`; `Milestone` carries the phase; `Team`, `Effort`,
  `Iteration` and `Quarter` are gone, and so is the stray `Triaged` option in
  `Priority`. The board no longer mirrors project 1 field for field, which is the
  trade-off accepted for a coherent board. Project 1 is untouched. The board
  README and its short description state the scope and point at `AGENTS.md`.
- Open points: the three default views (`Monthly roadmap`, `Quarterly
roadmap`, `Backlog`) still carry delivery names. The Projects v2 API does not
  allow renaming a view, so they have to be renamed by hand in the UI or left
  alone. Neither does it allow adding the `Parent issue` grouping D25 needs.

### D21: The logger is a factory option, not a registry

- Status: Accepted
- Decision: every factory that logs takes the logger as an explicit option and
  defaults to a no-op or console sink. There is no module-level logger and no
  global registry.
- Rationale: D16 already commits to factories over singletons, and two loggers in
  one process are legitimate — a request logger and a background worker logger, for
  instance. A registry would force one of them to win, and caching a logger under
  `Symbol.for` for D17's sake would reintroduce the singleton through the back
  door.
- Consequences: every factory signature grows a `logger` option; a module that
  needs a logger outside a factory call has to be handed one. Nothing is cached
  under `Symbol.for` for logging.
- Open points: none.

### D22: Redaction defaults belong to the library

- Status: Accepted
- Decision: the library redacts a built-in list of sensitive keys by default. The
  app passes extra keys to widen it. There is no switch to turn redaction off.
- Rationale: a public package cannot know a given deployment's secrets, but it can
  ship the obvious ones — `password`, `authorization`, `token`, cookie values and
  the like. Making the defaults optional would mean the first consumer that forgets
  the option ships credentials to its logs and audit trail.
- Consequences: keys are matched case-insensitively and also searched in nested
  objects; the same list governs log fields (D02) and audit payloads (D14). An app
  that wants a different policy is still covered, because it can add keys, not
  remove them.
- Open points: whether redaction replaces the value or drops the field is part of
  the logging module design.

### D23: A failed audit write never blocks the operation

- Status: Accepted
- Decision: an audit sink that throws is treated as a failure to record, not as a
  failure of the business operation. The error is logged and counted, and the
  operation continues.
- Rationale: this closes the open point in D14 in the direction that keeps the
  library's audit trail from becoming a availability dependency of every write
  path. An audit gap is an operational problem; blocking a customer operation on it
  turns a bookkeeping failure into an outage.
- Consequences: a `strict` mode is not provided, so an application that must block
  on audit has to wrap the sink itself. Silent loss is not acceptable, hence the
  log and the counter rather than a bare `catch`.
- Open points: the metric name and where it is exported.

### D24: Kafka carries facts, BullMQ carries work

- Status: Accepted
- Decision: Kafka is for facts other services may react to. BullMQ is for work this
  service performs. Each gets exactly one adapter.
- Rationale: this closes the boundary half of D07. The two have different delivery
  guarantees, different retry semantics and different operational owners; using
  either for the other's job loses whichever guarantee matters. It also keeps the
  events port (D18) free of job semantics.
- Consequences: an event never runs job logic and a job never broadcasts facts. A
  slow consumer is back-pressured by the queue, not by the event stream. The Kafka
  client choice stays open and is still phase 3 work.
- Open points: whether a job may publish an event as a side effect of completing.

### D25: One independently decidable question per sub-issue

- Status: Accepted
- Decision: a parent issue is an area container and a sub-issue is one decision. A
  sub-issue can be agreed or rejected on its own, and the parent is `Decided` only
  when every one of them is.
- Rationale: the parents mixed several decisions with the constraints already
  settled, so a reviewer could not tell which part was still open, and the board
  could not show that a question was resolved. Splitting where it helps and
  leaving a narrow area whole keeps the container useful in both cases.
- Consequences: twenty parents became sixty-three sub-issues, and the board holds
  ninety-five items instead of thirty-two. A sub-issue inherits the parent's
  `Domain`, milestone and labels, and starts as `Proposed`. Grouping by
  `Parent issue` is a board view someone adds by hand. The twelve narrow areas —
  the validator factory, OpenAPI, guards and middlewares, both adapters, the
  testing entry, the example app, `publint` and `attw`, adoption, the documentation
  split, the plan document and the `sca-docs` note — stay whole.
- Open points: none.

### D26: Cache invalidation happens at the write site, and the representation is versioned separately

- Status: Accepted
- Decision: writes go through code in production, so invalidation happens where the
  write happens. There is no staleness probe on the read path and no push
  invalidation. Separately, a cached entry carries a version of the shape it was
  written under.
- Rationale: these are three different questions that were being answered with one
  mechanism. A `TTL` bounds staleness in time, a version key bounds it in changes,
  and the representation is a third axis: when a column is added, the row in the
  database is current and the stored snapshot is simply missing the field, so
  nothing is stale by either of the two existing measures. A probe against the
  database would be a database round trip on every cache read to solve a problem
  that only exists where writes do not go through code, and the library cannot
  write it in any case — it does not know the tables, and must not.
- Consequences: invalidation is not a read-path concern, and the cache port needs no
  freshness argument. In development and QA, where the cache is written directly,
  the cache is reset out of band. Backfills, migrations and administrative tooling
  that write outside the application need a stated rule rather than an implicit one.
  The entry envelope and its version are the consumer's, since they describe the
  consumer's representation; the library supplies the mechanism.
- Open points: whether the version is a constant the consumer bumps, or derived from
  a schema describing the cached view, is open. A namespace-wide reset is a provider
  operation rather than a port one, because a keyspace scan is not portable (D18).
  Both questions, and the collection case below, are in #99 and its sub-issues.
- The consuming services cache **full rows, whole objects and whole arrays**, so the
  representation problem is real rather than hypothetical. It is also the reason D26
  does not settle collections: a cached array is one entry holding many rows, so its
  unit of invalidation is the query, not the entity. Cached collections may lag a
  write by seconds, which is a stated tolerance, and it is what makes separating
  collection identity from entity data affordable. Decided in #103.

### D27: Managed cloud equivalents for every ported component

- Status: Accepted
- Decision: every component behind one of D18's three ports supports its managed
  equivalent on AWS, Azure and GCP. Where an equivalent does not exist, a
  portability matrix names it as not portable instead of leaving the promise
  unspoken. Choosing a provider, and any failover between providers, belongs to the
  consuming team rather than to the library.
- Rationale: this package is public and the teams adopting it run on different
  clouds, so "you can choose" only means something if the components are equivalent
  or the difference was written down before someone found it in a migration.
  Failover is left to the application because it is a state machine — which
  provider is primary, what happens to in-flight messages, whether to dual-write
  and how to replay — and D16 already puts composition in factories rather than in
  a registry the library would own.
- Consequences: three portability matrices and a parity contract carry the detail
  (#104–#107). BullMQ is a library whose transport is Redis, so it inherits the
  Redis row instead of having one of its own; it needs a script-capable Redis and,
  on a cluster, hash tags, which are part of the key layout decided in #62. Azure
  Cache for Redis has been superseded by Azure Managed Redis, so the current name
  is used everywhere. D24 is unchanged and a queue port was considered and not
  opened: a port thin enough for SQS cannot express BullMQ's priorities, repeats
  and pausing, and one that can express them is too wide for SQS — so the queue
  story is BullMQ on Redis, and SQS, Service Bus and Cloud Tasks are not
  providers. The cloud area moved to phase 5 because a managed provider depends on
  the ports, the error model, the configuration loader and the logging interface
  existing first.
- Open points: whether any consuming service depends on Vault's short-lived
  database credentials, which no cloud secret manager offers; the dead-letter
  behaviour of Event Hubs; and the command surface each managed Redis exposes,
  which decides whether BullMQ can run on it. All three are in #104, #105 and #106.

## Load-bearing facts

Facts that are expensive to rediscover. Each one has already cost this
repository a debugging session.

## CI

- `ci.yml` and `release.yml` are thin callers over
  [`sca-templates/CI-CD-Templates`](https://github.com/sca-templates/CI-CD-Templates),
  pinned to a full commit SHA. `publish.yml` is local: the template has no npm
  path at all.
- **Caller permissions are a ceiling.** GitHub validates the declared permissions
  of every job in the called workflow against the caller's grants while building
  the run graph, including jobs gated behind `false`. A missing grant fails the
  whole run as `startup_failure` with **zero check runs**. That is why `ci.yml`
  grants `packages: write` and `release.yml` grants `pull-requests: write`; both
  look unnecessary and are not.
- **`uses: ./.github/actions/…` inside a reusable workflow resolves against the
  caller**, not against `CI-CD-Templates`, so a local composite action dies at
  the setup step. Fixed in v3.3.1.
- A required check that never reports blocks every PR forever. Conditional jobs
  (`release / Sign release tag`, `stack / Publish Docker image`) must never be
  made required in a branch ruleset.
- To bump the template pin: read the target tag, confirm the reusable workflows
  and composite actions exist **in that tree**, update all five references, then
  push and wait for a real run. A green PR on the template validates files, not
  external consumption.

## Release

- Nothing is published by hand and nobody edits the `version` field.
- **No release exists yet**: the manifest sits at `0.0.0` with no tag and no
  `CHANGELOG.md`, so release-please reports `No version for path .` while still
  exiting `0`. A green Release check does not prove a release happened.
- `shared-release-flow.yml` mints its own GitHub App token, so `APP_ID` and
  `APP_PRIVATE_KEY` must be **organization** secrets with `--visibility all`.
  `gh secret list -R` will not show them.

## Publishing

- `NPM_TOKEN` is an organization secret whose visibility must include public
  repositories. `gh secret set --org` defaults to `private`, so for a public repo
  it resolves to an empty string, not an error: the job installs, builds, and
  fails at publish with a bare `401`. `publish.yml` asserts it is non-empty.
- The token is a granular npm token limited to the `@sca-templates` scope with
  `bypass_2fa`, and it **expires in 90 days**. Rehearse a rotation with the
  `dry-run` input on `publish.yml`.
- The token is **bound to the npm account that created it**, not to the robot.
- **Provenance and npm trusted publishing are unavailable, not merely
  unconfigured**: both authenticate over OIDC and npm supports neither on
  self-hosted runners, which is what `vars.RUNS_ON` resolves to here.
- **Never trigger on `push: tags`.** `sign-tag` re-pushes the tag to sign it, so
  a tag trigger fires a second publish for a version npm already accepted.
- `publish.yml` does not reuse the template's `setup-node-project` composite: it
  has no `registry-url` input, so it never writes the `.npmrc` that reads
  `NODE_AUTH_TOKEN`. It calls `pnpm/action-setup` then `actions/setup-node`, in
  that order.

## Planning state

### Scope

| Area                | Contents                                                                                |
| ------------------- | --------------------------------------------------------------------------------------- |
| Foundations         | Shared types, errors, utils, helpers, configuration loading and validation              |
| Cross-cutting       | Request context, structured logging, auditing, telemetry                                |
| Provider interfaces | Cache, events and secrets abstractions (D18)                                            |
| Providers           | Redis, Kafka, BullMQ, HashiCorp Vault, and AWS, Azure and GCP support (D19, D27)        |
| HTTP client         | Axios, preconfigured                                                                    |
| HTTP layer          | Validator factory, Swagger/OpenAPI setup, authentication, global guards and middlewares |
| Adapters            | Express and NestJS                                                                      |
| Integration         | Bootstrap helpers that assemble everything for each framework                           |

Heavy integrations are separate **subpath exports** whose clients are **optional
peer dependencies**, so an API only loads what it uses. Entry point names are
indicative until the public API map is defined.

### Non-goals

The library will **not** provide: database access or ORM, token issuance or login
flows, business logic, dashboards, or a replacement for Express or NestJS.

### Roadmap

1. **Foundations:** types, errors, utils, configuration.
2. **Observability:** request context, logging, auditing, telemetry.
3. **Providers:** cache, events and secrets (Redis, Vault, Kafka and BullMQ)
   and the HTTP client.
4. **HTTP layer:** validators, Swagger, authentication, guards and middlewares
   logic, then the Express and NestJS adapters.
5. **Integration and hardening:** bootstrap helpers, an example app,
   documentation, public API review, and the managed cloud equivalents for
   every port (D27) last.

Across all phases: an example app as first consumer, unit tests everywhere,
integration tests with real services in containers, `publint` and `attw` checks
for the dual build, Conventional Commits from the first change.

**Next step:** detail the foundations in this order — errors (#2), configuration
(#3), request context (#4).

Every design topic below is tracked as an issue in
[Project 3](https://github.com/orgs/sca-templates/projects/3) with
`Status=Proposed`. An issue carries the design, not a delivery ticket, and nothing
is implemented until its session says so.

Twenty-one of them are **area containers**: they hold the constraints already
decided and a list of sub-issues, one decision each (D25). The remaining twelve are
narrow enough to stay whole. Both kinds sit on the board, so a decision can be
resolved without its parent moving.

### Still to plan

Each entry below is a parent issue. Where it has sub-issues, they are listed in its
body and carry the decisions; the parent moves to `Decided` when all of them do.

- Public entry-point map and semver and deprecation policy — #7.
- Structured logging, including whether redaction replaces a value or drops the
  field, the open point in D22 — #8.
- Audit event schema and sinks — #9.
- Telemetry and OpenTelemetry integration — #10.
- Cache port and Redis provider — #11.
- Cache invalidation and cached value versioning, the open points in D26 — #99.
- Events port and Kafka provider — #12.
- Secrets port and Vault provider, auth methods and renewal — #13.
- BullMQ: connection sharing, workers and context propagation — #14.
- Kafka and BullMQ boundary details plus the Kafka client choice, the open point
  in D07 — #15.
- Cloud provider support: credential chains, the cloud services in scope, and the
  portability matrices and parity contract for AWS, Azure and GCP, the open points
  in D27 — #16.
- HTTP client: retries, mesh-coherent timeouts and token propagation — #17.
- Validator factory — #18.
- Swagger and OpenAPI generation — #19.
- Authentication and JWT verification — #20.
- Global guards and middlewares — #21.
- Express adapter — #22.
- NestJS adapter — #23.
- Lifecycle: ordered startup, graceful shutdown and health — #24.
- Bootstrap helpers for Express and NestJS — #25.
- Security baseline: CORS, body size, rate limiting, headers — #26.
- API standards: response envelope, pagination, versioning, idempotency — #27.
- Test utilities for consumers, a `/testing` entry — #28.
- Example app as first consumer — #29.
- `publint` and `attw` in CI — #30.
- Adoption plan: which existing API migrates first — #31.
- Splitting this file into `docs/` — #32.
- Whether a job may publish an event when it completes, the open point in D24 —
  #15.

### GitHub conventions

- Everything on GitHub is written in English (see working agreements).
- The GitHub Project is a **planning board** for decisions, design topics and
  phases. It is not a kanban (D20). Its `Status` options are `Proposed`, `In
design`, `Decided`, `Blocked`, `Superseded` and `Dropped` — never `In
Progress` or `Deployed`.
- `Domain` groups an item by the part of the plan it belongs to, using the same
  vocabulary as the `Area` dropdown in `task.yml`. `Milestone` carries the
  phase. `Priority` stays empty unless the item blocks another decision.
- The label set lives in [`scripts/labels.sh`](scripts/labels.sh) and nowhere
  else — that script is the source of truth. Run it with `--dry-run` first. It
  creates or updates every label, then deletes any label outside the set except
  `autorelease:*`. Flags: `--dry-run`, `--yes`, and an optional `owner/repo`.
- A planning item carries the `design` label plus the label of the area it
  touches. `needs decision` means blocked on an open question, with the options
  in the thread.
- A sub-issue inherits its parent's `Domain`, milestone and labels, starts as
  `Proposed`, and is the unit that reaches `Decided` (D25). A parent is a
  container, never a work item.
- Board short description: "Planning board for node-server-core, the shared
  Node.js library behind the organization's APIs. Decisions and design topics,
  not a delivery queue. Scope and decisions live in AGENTS.md."

### Pending deliverables

- A Word document with the high-level plan (requested, not yet produced) — #33.
- The `sca-docs` package note for this library — #34.

<!-- CODEGRAPH_START -->

## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
