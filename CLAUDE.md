# node-server-core — Service Guide

## What this repo is

`@sca-templates/node-server-core` is the shared core for the organization's
Node.js APIs. It is meant to hold plumbing that every Node service repeats —
helpers, error types, shared constants — so a fix lands here once instead of in
every repository.

It is **not** a deployable service. It ships no server, no Dockerfile and no
Kubernetes manifests. It is a library consumed by other repositories.

> **Status.** The public surface is intentionally empty: `src/index.ts` is a
> bare barrel with no exports. The pipeline around it — build, types, tests,
> coverage, release and publish — is complete, so the first real module is one
> file plus its `exports` subpath plus its test. No version has been published
> yet. See [sca-docs](https://github.com/sca-templates/sca-docs) `05-packages/`
> for the intended package layout.

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
│   ├── ISSUE_TEMPLATE/     # bug_report.yml, feature_request.yml, config.yml
│   ├── workflows/
│   │   ├── ci.yml          # caller of the shared CI workflows
│   │   ├── publish.yml     # npm publish, on `release: published`
│   │   └── release.yml     # caller of shared-release-flow
│   ├── CODEOWNERS
│   ├── CONTRIBUTING.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── dependabot.yml      # npm + github-actions ecosystems
├── src/
│   └── index.ts            # public entry point; an empty barrel today
├── test/                   # vitest suites, one per src/ module; empty today
├── .editorconfig
├── .npmrc                  # git-checks=false, see trap 3
├── commitlint.config.js    # Conventional Commits rules
├── eslint.config.js        # flat config; ignores root *.config.js / *.config.mjs
├── package.json            # scripts, exports, publishConfig, pnpm overrides
├── pnpm-workspace.yaml     # ignoredBuiltDependencies only — single package
├── tsconfig.json           # type-check only; must list every linted *.config.ts
├── tsup.config.ts          # bundler: esm, dts, target node22, entry globs src/**
└── vitest.config.ts        # v8 coverage over src/; no thresholds until code exists
```

`.nvmrc` pins the Node version. `.husky/` holds the Git hooks.
`test/` is absent from the working tree until the first module exists: Git does
not track empty directories, and `vitest.config.ts` sets `passWithNoTests` so
`pnpm test:ci` still exits `0`.

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

`pnpm test:ci` passes with **zero test files** until the first module exists.
That is `passWithNoTests` in `vitest.config.ts`, not a broken suite: read the
line count before concluding the tests pass.

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
pinned to a full commit SHA. `publish.yml` is **local**, not a caller: the
template has no npm path at all (its `publish` job builds a Docker image). The
checks that actually gate a push to `main`:

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

### Four traps this repo already paid for

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

**3. `pnpm publish` refuses a detached HEAD, even on a pristine tree.**
`actions/checkout` with `ref: <tag>` leaves the runner on a detached HEAD, and
pnpm's publish-branch check (`master|main`) rejects it with
`ERR_PNPM_GIT_UNKNOWN_BRANCH` — the checkout is clean, the ref is correct, and
the publish still dies. The equivalent CLI escape, `--no-git-checks`, is not
the fix: pnpm forwards it to npm, which does not know the flag and warns that it
will stop working. `.npmrc` sets `git-checks=false` instead, which applies to
every publish path including a local one. `git-checks: false` in
`pnpm-workspace.yaml` does **not** work — with no `packages:` key pnpm never
reads the settings from that file.

**4. An org secret whose visibility excludes this repository resolves to an
empty string — silently.**
`gh secret set --org` defaults to `private`, meaning private and internal
repositories only. This repository is public, so `${{ secrets.NPM_TOKEN }}` is
not an error, it is `''`: the job installs, builds, and fails at the publish
step with a bare `401` that points at npm instead of at the secret. `gh secret
list -R` cannot detect this, because it only lists repository-level secrets —
ask the API instead (`gh api orgs/sca-templates/actions/secrets/NPM_TOKEN
--jq .visibility`). `publish.yml` asserts the token is non-empty before
publishing, and the check belongs in code, not in the operator's memory.

## Bumping the CI-CD-Templates pin

`ci.yml` and `release.yml` pin the same SHA. To upgrade: read the target tag,
confirm the reusable workflows and any composite actions exist **in that tree**,
update all five references, then push and wait for a real run. Do not trust a
green PR on the template repo — its checks validate files, not external
consumption.

The third-party SHAs in `publish.yml` (`actions/checkout`, `pnpm/action-setup`,
`actions/setup-node`) were copied from the template's own composite action and
are **not** the template pin. They move only when Dependabot opens a PR for
them.

## Release

[release-please](https://github.com/googleapis/release-please) drives releases
from Conventional Commits, configured in `.release-please-config.json` and
`.release-please-manifest.json`. `shared-release-flow.yml` mints its own GitHub
App token, so `APP_ID` and `APP_PRIVATE_KEY` must exist — they are **organization**
secrets (`--visibility all`), not repository ones, which is why `gh secret list -R`
reports nothing and looks like a misconfiguration.

Releases are **not running yet**: the manifest sits at `0.0.0` with no tag and
no `CHANGELOG.md`, so release-please has no baseline and reports
`No version for path .` while still exiting `0`. A green Release check does not
prove a release happened.

## Publishing

`publish.yml` is local and fires on `release: published`, plus
`workflow_dispatch` with a `tag` and a `dry-run` input. Two design points that
are not obvious from the file:

- **Never trigger on `push: tags`.** `shared-release-flow.yml`'s `sign-tag` job
  re-pushes the tag (`git tag -f -s`) to sign it, so a tag trigger fires a
  second publish for a version npm already accepted. The `release` event is not
  re-emitted by that re-push.
- **It does not reuse the template's `setup-node-project` composite.** That
  action has no `registry-url` input, so it never writes the `.npmrc` that
  reads `NODE_AUTH_TOKEN`. `publish.yml` calls `pnpm/action-setup` then
  `actions/setup-node` directly, in that order: setup-node resolves the pnpm
  store path only once pnpm is on the `PATH`.

`NPM_TOKEN` is an organization secret holding a granular npm token limited to
the `@sca-templates` scope, with `bypass_2fa` enabled — without it, publishing
triggers an interactive OTP challenge that no CI job can answer.

Two things constrain the design and are worth remembering before anyone
"modernizes" it:

- **Provenance and npm trusted publishing are unavailable, not merely
  unconfigured.** Both authenticate over OIDC, and npm supports neither on
  self-hosted runners. `vars.RUNS_ON` is `self-hosted` for this organization, so
  a long-lived token is the only mechanism that works. Moving to GitHub-hosted
  runners is the prerequisite, not a preference.
- **The token expires in 90 days** (npm caps granular tokens there on a free
  plan) and is bound to the npm account that created it, not to the robot. When
  it lapses, the next publish fails with a `401`. The `dry-run` dispatch exists
  to rehearse a rotation before it is needed.

## CodeGraph

If a `.codegraph/` index exists at the repo root, reach for `codegraph explore`
(or the `codegraph_explore` MCP tool) before grepping or reading files when you
need to understand or locate code. It returns the verbatim source of the
relevant symbols plus the call paths between them, which is usually one call
instead of a search-and-read loop. Indexing is the user's decision, not yours.
