# codex-google-apps-script-mcp

A setup template that connects Codex to Google Apps Script through the official `@google/clasp` MCP server, without granting Codex direct access to the rest of Google Workspace.

## Status

Maintenance. The template is complete and stable; it only needs changes when `@google/clasp` changes its CLI or MCP interface.

## What it does

Codex gets project-management access to Apps Script through clasp and nothing else. With this setup Codex can:

- create or clone Apps Script projects and pull them to a local folder
- edit the source files locally, with every change visible in git
- push edits back, create versions and deployments
- run script functions and tail logs

It does **not** give Codex Gmail, Drive, Calendar, Docs, Sheets or Admin tools. Any Workspace access happens inside the Apps Script project at runtime, limited by that script's own authorization scopes. The full rationale is in [docs/why-this-exists.md](docs/why-this-exists.md).

This repository implements no MCP server of its own. It ships configuration, installers, verification scripts, setup guides and a minimal example.

## How it works

```text
Codex Desktop or Codex CLI
   | MCP stdio
   v
npx -y @google/clasp mcp        (local OAuth session, clasp commands)
   |
   v
Google Apps Script API  ->  your Apps Script project
```

The installer checks Node.js/npm/npx, opens the Apps Script API settings page, runs `clasp login` (unless skipped) and writes a `clasp` entry into `.mcp.json`.

## Quick start

Requirements: Node.js 20+, npm/npx, a Google account, Codex Desktop or Codex CLI.

Windows:

```powershell
git clone https://github.com/MSotoudeh/codex-google-apps-script-mcp.git
cd codex-google-apps-script-mcp
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

macOS/Linux:

```bash
git clone https://github.com/MSotoudeh/codex-google-apps-script-mcp.git
cd codex-google-apps-script-mcp
chmod +x ./install.sh ./scripts/verify-clasp.sh
./install.sh
```

Restart Codex, then ask: "List the available MCP tools from the clasp server. Do not modify any files or Google projects."

Manual setup: enable the Apps Script API at <https://script.google.com/home/usersettings>, run `npx -y @google/clasp login`, and add this to your Codex MCP config:

```json
{ "mcpServers": { "clasp": { "command": "npx", "args": ["-y", "@google/clasp", "mcp"] } } }
```

More options (other workspace, skip login, no browser): [docs/quickstart.md](docs/quickstart.md), [docs/windows-codex-setup.md](docs/windows-codex-setup.md), [docs/macos-linux-codex-setup.md](docs/macos-linux-codex-setup.md).

### Verify the setup

Windows:

```powershell
.\scripts\verify-clasp.ps1
```

macOS/Linux, human-readable or machine-readable (JSON) output for Codex CLI or other automation:

```bash
./scripts/verify-clasp.sh
./scripts/verify-clasp.sh --json
```

The scripts check Node.js, npm, npx, clasp availability and clasp authentication (`clasp show-authorized-user --json`).

## Configuration

There are no environment variables. Local state is git-ignored: `.mcp.json` (your machine's MCP config; start from [`.mcp.example.json`](.mcp.example.json)), `.clasp.json`, `.clasprc.json`, `gas-smoke/`.

## Project layout

```text
install.ps1, install.sh      plug-and-play installers (Windows / macOS+Linux)
.mcp.example.json            example MCP configuration
scripts/                     verify-clasp.ps1 / verify-clasp.sh diagnostics
docs/                        quickstart, platform guides, security model, rationale, history
examples/hello-apps-script/  minimal Apps Script source (no real script binding)
tests/                       node:test checks for installers and docs
```

## Testing

```bash
node --test
```

On Node 25, `node --test tests/` is interpreted as a module path and fails; run `node --test` or `node --test tests/*.test.mjs`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security reports: [SECURITY.md](SECURITY.md). Project background: [docs/HISTORY.md](docs/HISTORY.md).

## License

MIT, see [LICENSE](LICENSE).
