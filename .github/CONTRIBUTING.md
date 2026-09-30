# Contributing to node-server-core

> Shared plumbing for the organization's Node.js APIs: helpers, error types, shared constants. It is a **library** — no server, no Dockerfile, no Kubernetes manifests. Docs-as-code: all changes land through a PR with review.

## Ground rules

- **English only** — notes, commits, and PR descriptions are written in English.
- **Conventional Commits** — enforced by the `commit-msg` Husky hook. Types `feat`, `fix`, `build`, `ci`, `docs`, `chore`; scopes `api`, `auth`, `config`, `deps`, `security`, `utils`. Subject under 72 characters, lowercase, no trailing period.
- **No business logic** — this package carries plumbing and pure code. A domain rule belongs in the microservice that owns it, so a fix lands once here instead of in every repository.
- **No secrets in the repo** — never commit tokens or credentials. Publishing credentials live as GitHub secrets, not files.
- **Git writes are yours** — agents and tooling prepare changes; the maintainer runs `git commit` and `git push`.
- **Docs-as-code** — every change goes through a pull request and is reviewed.

## Repository layout

```text
src/                     One file per module; each is a tsup entry and needs an `exports` subpath
test/                    Vitest suites, mirroring src/
.github/workflows/       ci.yml | release.yml | publish.yml — thin callers over CI-CD-Templates
.github/                 Dependabot, CODEOWNERS, PR and issue templates
.npmrc                   git-checks=false, so a detached-HEAD CI build can publish
package.json             Scripts, exports map, publishConfig, pnpm overrides
tsconfig.json            Type-check only (noEmit); tsup emits into dist/
tsup.config.ts           esm + dts, target node22
vitest.config.ts         v8 coverage over src/; no thresholds until the first module
```

## Adding a module

1. Create `src/<name>.ts`. `tsup.config.ts` globs `src/**/*.ts`, so no bundler change is needed.
2. Add the matching subpath to the `exports` map in `package.json`, plus a named re-export from `src/index.ts` if it is part of the top-level surface.
3. Add `test/<name>.test.ts`. Keep the suite next to the module, named after it.
4. Once real code exists, set `coverage.thresholds` in `vitest.config.ts` — they are deliberately absent today because an empty barrel cannot meet any threshold above zero.
5. Document the export in the README, in English.

## Contribution flow

1. Branch off `main`: `git checkout -b feat/<topic>`.
2. Make the change following the conventions above.
3. Run the checks (see Tooling).
4. Open a PR and fill the checklist from the template.

## Definition of done

- [ ] Content is in English.
- [ ] No secrets or tokens are committed.
- [ ] `pnpm typecheck` passes.
- [ ] `pnpm lint` passes.
- [ ] `pnpm format:check` passes.
- [ ] `pnpm test:ci` passes.
- [ ] `pnpm build` passes.
- [ ] New behaviour is covered by a test in `test/`.
- [ ] `README.md` is updated when the public surface, commands or release process change.

## Tooling

```sh
pnpm install         # also wires the Husky hooks
pnpm typecheck       # tsc, no emit
pnpm lint            # ESLint (typescript-eslint strictTypeChecked + sonarjs + security)
pnpm lint:fix
pnpm format          # Prettier write
pnpm format:check    # what CI runs
pnpm test            # vitest, single pass
pnpm test:ci         # vitest run --coverage — what CI runs, not `test`
pnpm test:watch
pnpm build           # tsup into dist/
```

The `pre-commit` hook runs `lint-staged` (ESLint `--fix` + Prettier) on staged files; `commit-msg` runs `commitlint`. Both are installed by `pnpm install`.

There is no `actionlint` in CI and no markdown linter wired locally. If you touch `.github/workflows/`, validate with `actionlint .github/workflows/*.yml`.

## Releases

Releases are driven by [release-please](https://github.com/googleapis/release-please) from Conventional Commits: merge a `feat:`/`fix:` commit, release-please opens the release pull request, and merging it tags the version and publishes the package to npm via `publish.yml`. Nothing is published by hand, and the maintainer never edits `package.json`'s version.

## License

This repository is licensed under the MIT License (see [LICENSE](../LICENSE)).
