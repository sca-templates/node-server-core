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

This repository is in **planning mode**: scope, design decisions, roadmap and
GitHub setup. Do not implement until the user says planning is done.

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
| D02 | Pino behind a minimal logger interface owned by the library                                             | Depend on the interface, never on Pino. Logs carry trace and span ids.                                                                                                                                                                        |
| D03 | `AsyncLocalStorage` for user/tenant; trace and span from the OTel span                                  | Propagate W3C `traceparent` in the HTTP client and event headers. `x-request-id` is a fallback.                                                                                                                                               |
| D04 | `AppError` base with a stable code; RFC 9457 problem details on the wire                                | Exactly one error-to-response translation point per adapter.                                                                                                                                                                                  |
| D05 | Env vars drive configuration, validated with Zod via `loadConfig(schema)`                               | Env var names are public API. Options override the environment. Nothing reads env at import time.                                                                                                                                             |
| D06 | Framework-agnostic core, thin adapters at `/express` and `/nest`                                        | Express and NestJS are optional peer dependencies.                                                                                                                                                                                            |
| D07 | Kafka is reached only through the events port; no client type crosses the public API                    | Consumers import `…/providers/kafka`; the client is an optional peer dependency (D16) and never appears in a core module. Which client it is gets decided in phase 3.                                                                         |
| D08 | Vitest for everything, Testcontainers for integration                                                   | Vitest/esbuild emits no decorator metadata, so NestJS adapter tests need an SWC plugin.                                                                                                                                                       |
| D09 | Public on npm; published versions are immutable                                                         | Nothing organization-internal may appear in the package or its docs.                                                                                                                                                                          |
| D11 | Kafka is self-hosted on Kubernetes                                                                      | TLS and SASL must be configurable; credentials may come from the secrets provider.                                                                                                                                                            |
| D12 | The library **verifies** JWTs (JWKS cache and rotation, issuer, audience, expiry, algorithm allow-list) | No token issuance, no login flows. The JWT library must work from CJS.                                                                                                                                                                        |
| D13 | OpenTelemetry through `@opentelemetry/api` only                                                         | The app picks the SDK and exporters. In ESM, instrumentation must load before app code.                                                                                                                                                       |
| D14 | Audit event schema plus an `AuditSink` interface                                                        | Logger sink is the default, events sink is built in. Whether a failed audit blocks is open.                                                                                                                                                   |
| D15 | Current majors of Express and NestJS, Node `>=22.12`                                                    | Verify the exact majors when designing the adapters.                                                                                                                                                                                          |
| D16 | One package, subpath exports, optional peer dependencies                                                | Factories over singletons. Explicit options first, env fallback. No work at import time.                                                                                                                                                      |
| D17 | Dual ESM and CJS build                                                                                  | **Dual package hazard**: brand errors with `Symbol.for`, keep shared state on `globalThis` under `Symbol.for` keys, never trust `instanceof`. No top-level `await`. Every runtime dep must load from CJS. Validate with `publint` and `attw`. |
| D18 | Ports and adapters for cache, events and secrets                                                        | Interfaces stay small enough for every provider; provider extensions live outside the contract.                                                                                                                                               |
| D19 | AWS, Azure and GCP support via each cloud's standard credential chain                                   | Application Default Credentials on GCP, and the equivalents elsewhere.                                                                                                                                                                        |

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
| Providers           | Redis, Kafka, BullMQ, HashiCorp Vault, and AWS, Azure and GCP support (D19)             |
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
3. **Providers:** cache, events and secrets (Redis, Vault, Kafka and BullMQ
   first, then the cloud providers) and the HTTP client.
4. **HTTP layer:** validators, Swagger, authentication, guards and middlewares
   logic, then the Express and NestJS adapters.
5. **Integration and hardening:** bootstrap helpers, an example app,
   documentation, public API review.

Across all phases: an example app as first consumer, unit tests everywhere,
integration tests with real services in containers, `publint` and `attw` checks
for the dual build, Conventional Commits from the first change.

**Next step:** detail the foundations in this order — errors, configuration,
request context.

### Still to plan

- Lifecycle helpers for consumers: ordered startup, graceful shutdown on SIGTERM
  (close Kafka, Redis and BullMQ without losing messages), liveness and readiness.
- Security: sensitive data redaction in logs, CORS, body size limits, rate
  limiting, security headers.
- API standards: response format, pagination, endpoint versioning, idempotency.
- Test utilities for consumers (a `/testing` entry with mocks and helpers).
- The Kafka/BullMQ boundary: when a service reaches for which of the two, and
  whether Kafka serves only the events port or also cache invalidation and
  request-response. Both land in phase 3, which is also where D07 defers the
  choice of Kafka client.
- Per-module design: Vault auth methods and renewal; Kafka serialization, retries
  and dead-letter handling; BullMQ connection sharing and context propagation;
  HTTP client retries, mesh-coherent timeouts and token propagation; cloud
  credential chains.
- Public entry-point map and a semver and deprecation policy.
- Example app and adoption plan: which existing API migrates first.
- Whether to split this file into `docs/` (`INDEX.md`, `planning.md`,
  `decisions.md`, `ci-release.md`) once the content outgrows one screen. Open
  decision, not scheduled.

### GitHub conventions

- Everything on GitHub is written in English (see working agreements).
- The GitHub Project is a **planning board** for decisions, design topics and
  phases. It is not a kanban: do not assume `Todo`, `In Progress` and `Done`
  columns or a delivery workflow.
- The label set lives in [`scripts/labels.sh`](scripts/labels.sh) and nowhere
  else — that script is the source of truth. Run it with `--dry-run` first. It
  creates or updates every label, then deletes any label outside the set except
  `autorelease:*`. Flags: `--dry-run`, `--yes`, and an optional `owner/repo`.
- Board short description: "Planning board for node-server-core, the shared
  Node.js library (logging, auditing, validation, cache, events, secrets,
  AWS/Azure/GCP support, Express/NestJS adapters) for the organization's APIs."

### Pending deliverables

- A Word document with the high-level plan (requested, not yet produced).
- Revise the GitHub Project README: it still describes a kanban workflow and
  must describe a planning board, including the cache, events, secrets and cloud
  scope and the ESM and CJS support.

<!-- CODEGRAPH_START -->

## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
