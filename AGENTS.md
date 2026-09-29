# node-server-core — Service Guide

## What this repo is

`@sca-templates/node-server-core` is the shared core for the organization's
Node.js APIs. It is meant to hold plumbing that every Node service repeats —
helpers, error types, shared constants — so a fix lands here once instead of in
every repository.

It is **not** a deployable service. It ships no server, no Dockerfile and no
Kubernetes manifests. It is a library consumed by other repositories.

> **Status.** The package is a scaffold. `src/index.ts` currently exports a
> single `ping()` placeholder so the pipeline has something to build. The real
> surface is not decided yet — see [sca-docs](https://github.com/sca-templates/sca-docs)
> `05-packages/` for the intended package layout.

## Ecosystem documentation (sca-docs)

Organization-wide documentation lives in [sca-docs](https://github.com/sca-templates/sca-docs),
not here. Fetch it as raw URLs:

```text
https://raw.githubusercontent.com/sca-templates/sca-docs/main/<path>
```

| Path                                | What it covers                                      |
| ----------------------------------- | --------------------------------------------------- |
| `00-ecosystem/conventions.md`       | Naming, tagging and catalog rules for the whole org |
| `00-ecosystem/platform-overview.md` | Ecosystem vision, delivery flow, repository model   |
| `05-packages/INDEX.md`              | The `@sca/*` shared packages and their status       |
| `05-packages/sca-core.md`           | The intended shape of the shared core package       |
| `99-glossary/INDEX.md`              | Ubiquitous language                                 |

## Layout

```text
.
├── .github/
│   └── workflows/
│       ├── ci.yml        # caller of the shared CI workflows
│       └── release.yml   # caller of shared-release-flow
├── src/
│   └── index.ts          # public entry point
├── test/
│   └── index.test.ts     # vitest suites, mirrors src/
├── commitlint.config.js  # Conventional Commits rules
├── eslint.config.js      # flat config; ignores root *.config.js / *.config.mjs
├── package.json          # scripts, pnpm overrides, exports
├── pnpm-workspace.yaml   # ignoredBuiltDependencies only — single package
├── tsconfig.json
└── tsup.config.ts        # bundler: esm, dts, target node22
```

`.nvmrc` pins the Node version. `.husky/` holds the Git hooks.

## Commands

| Command                             | What it does                                                   |
| ----------------------------------- | -------------------------------------------------------------- |
| `pnpm install`                      | Install. Runs `prepare`, which installs Husky.                 |
| `pnpm build`                        | Bundle with tsup into `dist/`.                                 |
| `pnpm test`                         | Run the vitest suites once.                                    |
| `pnpm test:ci`                      | `vitest run --coverage`. **This is what CI runs**, not `test`. |
| `pnpm test:watch`                   | Vitest in watch mode.                                          |
| `pnpm typecheck`                    | `tsc`, no emit.                                                |
| `pnpm lint` / `pnpm lint:fix`       | ESLint.                                                        |
| `pnpm format` / `pnpm format:check` | Prettier.                                                      |

`pnpm-workspace.yaml` deliberately has no `packages:` key — this is a single
package, not a monorepo.

There is **no `actionlint` in CI** and no markdown linter wired locally. If you
touch `.github/workflows/`, validate by hand with
`actionlint .github/workflows/*.yml`.

## Conventions

- **English only**: content, commits, PR descriptions.
- **Conventional Commits**: `feat`, `fix`, `build`, `ci`, `docs`, `chore`, with
  scopes `api`, `auth`, `config`, `deps`, `security`, `utils`. Enforced by
  commitlint via the `commit-msg` Husky hook. Keep the subject under 72 chars,
  lowercase, no trailing period.
- **Git writes are the user's**: do not `git commit` or `git push` on your own.
- **Never commit** secrets, tokens or credentials.
- **Pin actions by commit SHA** with the version in a trailing comment, matching
  what `CI-CD-Templates` does. Never `@main` or `@latest`.
- Prettier and ESLint disagree by design: `eslint-config-prettier` is loaded, so
  formatting is never an ESLint error.
- Root `*.config.js` and `*.config.mjs` are **excluded from ESLint** on purpose —
  they are build config, not source.

## CI

`ci.yml` and `release.yml` are thin callers. Both delegate to
[`sca-templates/CI-CD-Templates`](https://github.com/sca-templates/CI-CD-Templates),
pinned to a full commit SHA. The checks that actually gate a push to `main`:

| Check                                         | Comes from                                         |
| --------------------------------------------- | -------------------------------------------------- |
| `codeql / Analyze (javascript-typescript)`    | `shared-codeql.yml`                                |
| `security / Dependency Vulnerabilities (osv)` | `shared-security-scan.yml`                         |
| `security / Secrets (gitleaks)`               | `shared-security-scan.yml`                         |
| `stack / Build` · `Format` · `Lint` · `Test`  | `stack-node-ts.yml`                                |
| `release / Release please`                    | `shared-release-flow.yml`, **push to `main` only** |

`release-gate` (the qa-lock check) only runs on `pull_request`. Jobs marked
`skipped` above — `release / Sign release tag`, `release / Enable release PR
auto-merge`, `stack / Publish Docker image` — are conditional and **must never
be made required in a branch ruleset**: a required check that never reports
blocks every PR forever.

### Two traps this repo already paid for

**1. Caller permissions are a ceiling, and validation is static.**
A reusable workflow can never exceed the permissions its caller grants. GitHub
validates the declared permissions of **every** job in the called workflow
against the caller's grants while it builds the run graph — including jobs that
are gated behind `false`. A missing grant does not fail that one job; it kills
the whole run before any job is created, as `conclusion: startup_failure` with
**zero check runs**. This is why `ci.yml` grants `packages: write` (for
`stack-node-ts.yml`'s `publish` job, which this repo never runs) and why
`release.yml` grants `pull-requests: write` (for `shared-release-flow.yml`'s
`auto-merge` job). Both grants look unnecessary and are not.

**2. `uses: ./.github/actions/…` inside a reusable workflow resolves against the
_caller_, not against `CI-CD-Templates`.**
Such a reference only works for callers inside the template itself. Consumed
from here, every job using a composite action dies at the setup step with:

```text
Can't find 'action.yml', 'action.yaml' or 'Dockerfile' under
<checkout>/.github/actions/setup-node-project
```

Fixed in CI-CD-Templates v3.3.1. If you ever add a local composite action to
the template, reference it as
`sca-templates/CI-CD-Templates/.github/actions/<name>@<sha>`.

## Bumping the CI-CD-Templates pin

Both workflow files pin the same SHA. To upgrade: read the target tag, confirm
the reusable workflows and any composite actions exist **in that tree**, update
all five references, then push and wait for a real run. Do not trust a green
PR on the template repo — its checks validate files, not external consumption.

## Release

[release-please](https://github.com/googleapis/release-please) drives releases
from Conventional Commits, configured in `.release-please-config.json` and
`.release-please-manifest.json`. `shared-release-flow.yml` mints its own GitHub
App token, so `APP_ID` and `APP_PRIVATE_KEY` must exist as repository secrets.

Releases are **not running yet**: the manifest sits at `0.0.0` with no tag and
no `CHANGELOG.md`, so release-please has no baseline and reports
`No version for path .` while still exiting `0`. A green Release check does not
prove a release happened.

The package is also **not on npm yet** — the `@sca-templates` scope does not
exist on the registry.

## CodeGraph

If a `.codegraph/` index exists at the repo root, reach for `codegraph explore`
(or the `codegraph_explore` MCP tool) before grepping or reading files when you
need to understand or locate code. It returns the verbatim source of the
relevant symbols plus the call paths between them, which is usually one call
instead of a search-and-read loop. Indexing is the user's decision, not yours.
