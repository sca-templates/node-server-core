# Agents and providers

Inventory of the AI agents and providers this repository is wired for. The
instruction text lives in exactly one place, [`AGENTS.md`](../AGENTS.md); every
file listed here either reads it, points at it, or carries the CodeGraph block.

Nothing in this folder is published to npm: `package.json` ships `dist` only.

## Inventory

| Agent / provider | Reads in this repo                | File it needs                                | MCP config              |
| ---------------- | --------------------------------- | -------------------------------------------- | ----------------------- |
| Claude Code      | `.claude/CLAUDE.md` → `AGENTS.md` | `.claude/CLAUDE.md`, `.claude/settings.json` | `.mcp.json`             |
| Codex CLI        | `AGENTS.md` (native)              | —                                            | `.codex/config.toml`    |
| Gemini CLI       | `GEMINI.md` → `AGENTS.md`         | `GEMINI.md`, `.gemini/settings.json`         | `.gemini/settings.json` |
| Cursor           | `AGENTS.md` (native)              | —                                            | `.cursor/mcp.json`      |
| opencode         | `AGENTS.md` (native)              | —                                            | `opencode.jsonc`        |
| GitHub Copilot   | `AGENTS.md` (native)              | —                                            | not applicable          |

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

## Skills

Skills are procedural: they describe **how to do a task** and link to `AGENTS.md`
for the facts. A skill that restates the repo's mechanics belongs in `AGENTS.md`
instead, and one that contradicts it is a bug.

The canonical location is `.agents/skills/<name>/SKILL.md`, which every provider
reads natively except Claude Code:

| Agent / provider | Project skills directory | Needs a bridge |
| ---------------- | ------------------------ | -------------- |
| Codex CLI        | `.agents/skills/`        | no             |
| Gemini CLI       | `.agents/skills/`        | no             |
| Cursor           | `.agents/skills/`        | no             |
| opencode         | `.agents/skills/`        | no             |
| Claude Code      | `.claude/skills/`        | yes, symlinked |

`.claude/skills` is a committed symlink to `../.agents/skills`, because Claude
Code reads no other project directory. Edit the canonical copy; never write
through the symlink as if it were a separate directory. `.prettierignore` skips
it so the same `SKILL.md` is not formatted twice.

## MCP servers

Two servers are versioned, and both are the whole shared set:

| Server      | Endpoint                             | Auth                |
| ----------- | ------------------------------------ | ------------------- |
| `codegraph` | `codegraph serve --mcp`              | none, local process |
| `github`    | `https://api.githubcopilot.com/mcp/` | `GITHUB_TOKEN`      |

**No credential is ever committed.** Every tracked file declares only where a
secret comes from, never its value:

| Provider    | Project file            | Reference syntax                 | User-level file                    |
| ----------- | ----------------------- | -------------------------------- | ---------------------------------- |
| Claude Code | `.mcp.json`             | `${VAR}` in `url`, `headers`     | `~/.claude.json`                   |
| Codex CLI   | `.codex/config.toml`    | `bearer_token_env_var = "<VAR>"` | `~/.codex/config.toml`             |
| Gemini CLI  | `.gemini/settings.json` | `${VAR}`, whole file expanded    | `~/.gemini/settings.json`          |
| Cursor      | `.cursor/mcp.json`      | `${env:VAR}` in `url`, `headers` | `~/.cursor/mcp.json`               |
| opencode    | `opencode.jsonc`        | `{env:VAR}` in `headers`         | `~/.config/opencode/opencode.json` |

Export `GITHUB_TOKEN` in your shell profile (`gh auth token` prints one).
Without it the `github` server fails to authenticate in every provider, which is
the intended trade: a tracked config can never leak a token. Anything personal,
and any server needing credentials you do not want shared, belongs in the
user-level file for its provider, not here.

Codex loads `.codex/config.toml` only for trusted projects, so approve the
workspace once. Two more constraints: a server defined at both user and project
scope resolves to the project one, and Claude Code warns about the duplicate
name, so expect that warning if a `github` server already exists in your user
config.

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

For a new server: verify the endpoint and the reference syntax against that
provider's own documentation, add it to the tracked files above, and extend both
tables. Do not guess a field name.
