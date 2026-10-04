# CLAUDE.md — repo-specific guidance

## Authority

**AGENTS.md is authoritative for this repository.** Read it first: status and
mode, working agreements, layout, commands, conventions, design constraints and
the load-bearing CI and publishing facts are all there. This file only adds
what is specific to working here.

## Working here

- **The user commits and pushes — never execute `git commit`, `git push`, or
  any other git write on your own.** Draft commits and messages freely, but do
  not stage, reset, amend or otherwise mutate git history without explicit,
  current authorization.
- This repo is in **planning mode**: scope, design decisions, roadmap and GitHub
  setup. Do not start implementing until the user says planning is done.
- **The package is public on npm.** Organization-internal details (hostnames,
  topic names, Vault paths, internal conventions) never go into the code, the
  docs or any GitHub artifact. They come from configuration.
- **Dual ESM and CJS build** (D17). Before writing anything that carries state,
  remember the same module can be loaded twice: brand errors with `Symbol.for`
  and keep shared state on `globalThis` under `Symbol.for` keys. Never trust
  `instanceof`.
- Run the four gates — `pnpm typecheck`, `pnpm test:ci`, `pnpm lint`,
  `pnpm format:check` — before calling a change green.
- There is no `actionlint` in CI. If you touch `.github/workflows/`, validate by
  hand with `actionlint .github/workflows/*.yml`.
- Repo language is English for anything committed; the conversation with the
  user is in Spanish.

## Agents and providers

`.agents/README.md` is the inventory: which agent reads which file, and where
CodeGraph is wired. Add a row there when you wire a new tool.
