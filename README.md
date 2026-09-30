# node-server-core

Shared core for the organization's Node.js APIs.

[![CI](https://github.com/sca-templates/node-server-core/actions/workflows/ci.yml/badge.svg)](https://github.com/sca-templates/node-server-core/actions/workflows/ci.yml)
[![Release](https://github.com/sca-templates/node-server-core/actions/workflows/release.yml/badge.svg)](https://github.com/sca-templates/node-server-core/actions/workflows/release.yml)
[![Publish](https://github.com/sca-templates/node-server-core/actions/workflows/publish.yml/badge.svg)](https://github.com/sca-templates/node-server-core/actions/workflows/publish.yml)

> **Status: no public API yet, on purpose.** `src/index.ts` is an empty barrel.
> The pipeline around it — build, types, tests, coverage, release and publish —
> is complete, so the first real module is a single file plus its `exports`
> subpath and its test. The npm scope exists; **no version has been published
> yet**. See [AGENTS.md](AGENTS.md) for the agent-facing guide and
> [sca-docs](https://github.com/sca-templates/sca-docs) `05-packages/` for the
> intended package layout.

## Why

Every Node service in the org ends up repeating the same plumbing — helpers,
error types, shared constants. This package is where that lands, so a fix goes
in once instead of in every repository.

It is a **library**, not a service: no server, no Dockerfile, no Kubernetes
manifests. And it carries **no business logic** — a domain rule belongs in the
microservice that owns it.

## Requirements

| Tool | Version                            |
| ---- | ---------------------------------- |
| Node | `>=22.12` (pinned in `.nvmrc`)     |
| pnpm | `10.18.0` (`packageManager` field) |

## Install

The `@sca-templates` scope exists on npm, but this package has no published
version yet. Once the first release lands:

```bash
pnpm add @sca-templates/node-server-core
```

Until then, consume it from git:

```bash
pnpm add github:sca-templates/node-server-core
```

## Usage

There is nothing to import yet. When the first module lands it is documented
here and exported both from the package root and from its own subpath, so a
consumer pulls only what it needs:

```ts
import { something } from '@sca-templates/node-server-core';
import { something } from '@sca-templates/node-server-core/errors';
```

## Scripts

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
| `pnpm dev`                          | `tsup --watch`.                                                |

## Git hooks

`pnpm install` wires two Husky hooks:

- `pre-commit` — runs `lint-staged` (ESLint `--fix` + Prettier) on staged files.
- `commit-msg` — runs `commitlint`, enforcing [Conventional Commits](https://www.conventionalcommits.org/).

## CI

`ci.yml`, `release.yml` and `publish.yml` are thin callers over
[`sca-templates/CI-CD-Templates`](https://github.com/sca-templates/CI-CD-Templates),
pinned to a full commit SHA. A push to `main` gates on:

```text
codeql / Analyze (javascript-typescript)
security / Dependency Vulnerabilities (osv)
security / Secrets (gitleaks)
stack / Build
stack / Format
stack / Lint
stack / Test
```

## Release and publishing

Nothing is published by hand, and nobody edits the `version` field.

1. A `feat:` or `fix:` commit lands on `main`.
2. [release-please](https://github.com/googleapis/release-please) opens the release pull request and bumps `package.json`.
3. Merging it tags the version, creates the GitHub release and signs the tag.
4. `publish.yml` reacts to the release and publishes to npm.

**No release exists yet.** The manifest sits at `0.0.0` with no tag and no
`CHANGELOG.md`, so release-please has no baseline and reports `No version for
path .` while still exiting `0`. A green Release check does not prove a release
happened.

### Operational notes

- **The npm token expires.** `NPM_TOKEN` is an organization secret holding a
  granular npm token scoped to `@sca-templates`, and granular tokens are capped
  at 90 days. When it expires, publishing fails with a `401` until it is
  rotated. Rehearse or retry with `workflow_dispatch` on `publish.yml`, which
  takes a `tag` and a `dry-run` flag — the dry run builds the tarball and
  validates credentials without contacting npm's write API.
- **The token is bound to a person, not to the robot.** npm revokes a granular
  token's access when the owning account loses access to the scope. If that
  account leaves the npm organization, publishing breaks even though the secret
  is still in place.
- **Publishing uses a long-lived token, not OIDC.** npm provenance and npm
  trusted publishing both authenticate over OpenID Connect, and npm supports
  neither on self-hosted runners — which is what `vars.RUNS_ON` resolves to for
  this organization. Reconsider if the organization moves to GitHub-hosted
  runners; that is the only path to provenance and to tokenless publishing.

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md).

## License

[MIT](LICENSE)
