---
name: sca-docs
description: Fetch organization-wide documentation from the sca-docs repository as raw URLs. Use when a question depends on ecosystem conventions, the platform overview, the package index or a shared package's contract, and the answer is not in this repository. Also use before recommending a library version or a tool convention.
---

# sca-docs

`AGENTS.md` links to [sca-docs](https://github.com/sca-templates/sca-docs) instead of
restating it, because that content changes without a release of this package. This skill
is the procedure for reading it.

## Fetch, do not guess

Read a document with a `webfetch` call against its raw URL:

```text
https://raw.githubusercontent.com/sca-templates/sca-docs/main/<path>
```

Append `.md` to documentation paths that the index writes without it. Never invent a path,
a filename or a directory: a wrong guess returns `404` and reads like a missing fact.

## Known paths

| Path                                | Answers                                             |
| ----------------------------------- | --------------------------------------------------- |
| `00-ecosystem/conventions.md`       | Naming, layout and repository conventions           |
| `00-ecosystem/platform-overview.md` | How the platform pieces together                    |
| `05-packages/INDEX.md`              | Which shared packages exist; start here when unsure |
| `05-packages/sca-core.md`           | The shared core's surface and boundaries            |

When a needed document is not in this table, fetch `05-packages/INDEX.md` and look for it
there before assuming it does not exist.

## Procedure

1. Decide whether the question is actually organization-wide. Repo mechanics belong to
   `AGENTS.md`; do not fetch external docs to answer them.
2. Fetch the narrowest document that covers the question.
3. Treat what you read as current external documentation, not as a fact about this
   repository. If it contradicts `AGENTS.md`, `AGENTS.md` wins for this repo and the
   contradiction is worth reporting.
4. Cite the path you used, so the next reader can fetch it again.

## Boundaries

- Do not copy these documents into this repository. Link them.
- Do not invent API surface for a shared package. If the docs do not cover what you need,
  say it is open and list it as an open point.
