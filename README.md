# node-server-core

Shared core for the organization's Node.js APIs.

[![CI](https://github.com/sca-templates/node-server-core/actions/workflows/ci.yml/badge.svg)](https://github.com/sca-templates/node-server-core/actions/workflows/ci.yml)
[![Release](https://github.com/sca-templates/node-server-core/actions/workflows/release.yml/badge.svg)](https://github.com/sca-templates/node-server-core/actions/workflows/release.yml)

> **Status: scaffold.** `src/index.ts` exports a single `ping()` placeholder so
> the CI pipeline has something to build. The public surface is not decided yet,
> and the package is not published to npm. See [AGENTS.md](AGENTS.md) for the
> agent-facing guide and [sca-docs](https://github.com/sca-templates/sca-docs)
> `05-packages/` for the intended package layout.

## Why

Every Node service in the org ends up repeating the same plumbing — helpers,
error types, shared constants. This package is where that lands, so a fix goes
in once instead of in every repository.

It is a **library**, not a service: no server, no Dockerfile, no Kubernetes
manifests.

## Requirements

| Tool | Version                            |
| ---- | ---------------------------------- |
| Node | `>=22.12` (pinned in `.nvmrc`)     |
| pnpm | `10.18.0` (`packageManager` field) |

## Install

Not on npm yet. The `@sca-templates` scope does not exist on the registry, so
the package cannot be installed as a dependency today. Until then, consume it
from git:

```bash
pnpm add github:sca-templates/node-server-core
```

## Usage

```ts
import { ping } from '@sca-templates/node-server-core';

ping(); // 'pong'
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

## Git hooks

`pnpm install` wires two Husky hooks:

- `pre-commit` — runs `lint-staged` (ESLint `--fix` + Prettier) on staged files.
- `commit-msg` — runs `commitlint`, enforcing [Conventional Commits](https://www.conventionalcommits.org/).

## CI

`ci.yml` and `release.yml` are thin callers over
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

Release-please drives releases from Conventional Commits. The manifest is at
`0.0.0` and there is no baseline tag yet, so **no release has been produced** —
a green Release check does not imply a release happened.

## License

[MIT](LICENSE)
