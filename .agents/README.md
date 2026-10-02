# Agents and providers

Inventory of the AI agents and providers this repository is wired for. The
instruction text lives in exactly one place, [`AGENTS.md`](../AGENTS.md); every
file listed here either reads it, points at it, or carries the CodeGraph block.

Nothing in this folder is published to npm: `package.json` ships `dist` only.

## Inventory

| Agent / provider | Reads in this repo                | File it needs                                | CodeGraph MCP wiring                 |
| ---------------- | --------------------------------- | -------------------------------------------- | ------------------------------------ |
| Claude Code      | `.claude/CLAUDE.md` → `AGENTS.md` | `.claude/CLAUDE.md`, `.claude/settings.json` | `.mcp.json`                          |
| Codex CLI        | `AGENTS.md` (native)              | —                                            | `~/.codex/config.toml` (global only) |
| Gemini CLI       | `GEMINI.md` → `AGENTS.md`         | `GEMINI.md`, `.gemini/settings.json`         | `.gemini/settings.json`              |
| Cursor           | `AGENTS.md` (native)              | `.cursor/mcp.json`                           | `.cursor/mcp.json`                   |
| opencode         | `AGENTS.md` (native)              | `opencode.jsonc`                             | `opencode.jsonc`                     |
| GitHub Copilot   | `AGENTS.md` (native)              | —                                            | not applicable                       |

## Rules

- **One source of truth.** If an instruction is not about the repo's mechanics —
  language rules, conventions, design constraints — it belongs in `AGENTS.md`.
  Agent files link to it; they never restate it.
- **The CodeGraph block is bounded and intentional.** The same instructions are
  repeated between the `<!-- CODEGRAPH_START -->` and `<!-- CODEGRAPH_END -->`
  markers in `AGENTS.md` and `GEMINI.md`, because each tool reads only its own
  file. The heading level differs (`##` vs `#`) and Prettier may reflow the
  blank line; the wording must not. If you edit the block, edit both, markers
  included.
- **Indexing is the user's decision.** `codegraph init` creates `.codegraph/`,
  which is gitignored here. Without that directory every agent skips CodeGraph.

## Adding a provider

CodeGraph knows how to wire its own MCP server:

```bash
codegraph install --location local --target <id>
```

Targets: `claude`, `cursor`, `codex`, `opencode`, `hermes`, `gemini`,
`antigravity`, `kiro`, `copilot-vscode`, `copilot-cli`, `copilot-jetbrains`.
Print the snippet for one without writing anything with
`codegraph install --print-config <id>`, then add the row above and, if the
provider reads a file other than `AGENTS.md`, a pointer file that leads back
here.

Shared skills, when this repo needs them, go in `.claude/skills/<name>/SKILL.md`;
opencode picks that directory up through `skills.paths` in `opencode.jsonc`.
