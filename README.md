# Codex clasp MCP setup

Cross-platform setup template for connecting Codex to Google Apps Script through the official `@google/clasp` MCP server.

This repository exists for people who want Codex to help with **Google Apps Script development** without giving Codex broad direct access to Gmail, Drive, Calendar, Docs, Sheets, or the rest of Google Workspace.

General Google Workspace MCP servers are powerful, but they can expose a large permission surface. That may be excessive if the real job is only: edit Apps Script files, push/pull with clasp, run functions, inspect logs, and manage Apps Script deployments.

This repo takes the narrower path:

```text
Codex
  -> @google/clasp MCP
  -> Apps Script project management
```

Not this broader path:

```text
Codex
  -> broad Google Workspace MCP
  -> Gmail / Drive / Calendar / Docs / Sheets / Admin data
```

The goal is a smaller blast radius: local files, explicit sync, visible code changes, and no direct Workspace-wide tool access by default.

Read the full rationale: [`docs/why-this-exists.md`](docs/why-this-exists.md).

## What this is

This repository does **not** implement a custom MCP server. It provides reusable MCP configuration, safety rules, setup guides, verification scripts, plug-and-play installers, and a minimal Apps Script example for using Codex to manage Google Apps Script projects through clasp.

It is **not** a general Google Workspace MCP server. It does not give Codex direct Gmail, Drive, Calendar, Docs, Sheets, or Admin SDK tools. Codex gets project-management access to Apps Script through clasp. Any Google Workspace access happens only inside the Apps Script project at runtime and depends on that script's authorization scopes.

## Plug-and-play setup

For most Windows users:

```powershell
git clone https://github.com/MSotoudeh/codex-google-apps-script-mcp.git
cd codex-google-apps-script-mcp
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

For most macOS/Linux users:

```bash
git clone https://github.com/MSotoudeh/codex-google-apps-script-mcp.git
cd codex-google-apps-script-mcp
chmod +x ./install.sh ./scripts/verify-clasp.sh
./install.sh
```

The installer checks local tools, opens the Apps Script API settings page when possible, handles clasp login unless skipped, and creates or updates `.mcp.json` with the `clasp` MCP server.

After installation, restart Codex and ask:

```text
List the available MCP tools from the clasp server. Do not modify any files or Google projects.
```

For options such as installing into a different workspace, skipping login, or running without browser launch, see [`QUICKSTART.md`](QUICKSTART.md). For platform-specific details, see [`docs/windows-codex-setup.md`](docs/windows-codex-setup.md) and [`docs/macos-linux-codex-setup.md`](docs/macos-linux-codex-setup.md).

## What this repo gives you

With this setup, Codex can use clasp-backed MCP tooling to:

- create or clone Google Apps Script projects
- pull Apps Script files to a local folder
- edit source files locally through Codex
- push local edits back to Apps Script
- inspect project status before syncing
- create script versions and deployments
- run script functions
- tail Apps Script logs
- open related Apps Script project URLs

This repo intentionally avoids storing any real Apps Script project, OAuth token, user-specific Google credential, or private script ID.

## Architecture

```text
Codex Desktop or Codex CLI
   |
   | MCP stdio
   v
@google/clasp mcp
   |
   | local OAuth session + clasp commands
   v
Google Apps Script API
   |
   v
Apps Script project
   |
   | runtime authorization scopes
   v
Google services used by that script
```

Boundary:

```text
This repo configures only the Codex -> clasp -> Apps Script project path.
It is not a general Google Workspace MCP server.
```

## When this is a good fit

Use this setup when:

- you want Codex to help develop Apps Script code
- you do not want Codex to have direct Gmail, Drive, Calendar, Docs, or Sheets MCP tools
- your automation is implemented in Google Apps Script
- you want Codex to edit Apps Script source files in a local folder
- you want version control around Apps Script changes
- you need repeatable pull, push, deploy, run, and log workflows
- a script started in the browser editor and is now important enough to maintain properly

Typical targets:

- Google Sheets automations implemented as Apps Script code
- Apps Script web apps
- Gmail, Drive, Calendar, Docs, or Sheets automations implemented inside Apps Script
- scheduled trigger jobs
- internal business utilities
- small integrations where Apps Script is simpler than a full backend

## When not to use this

This setup is not the right tool when:

- you intentionally want direct Gmail, Drive, Calendar, Docs, or Sheets MCP tools in Codex
- you need service-account or domain-wide delegation from day one
- you need a production backend with low latency, private networking, or heavy compute
- you need durable orchestration, retries, queues, or long-running workflows
- you want Apps Script to call Codex directly
- the script is a one-line personal macro that will never be maintained

For durable background orchestration, retries, long-running workflows, or complex multi-step jobs, use a real backend or workflow engine outside this basic clasp MCP setup.

## Repository contents

```text
.
├── .gitignore
├── .mcp.example.json
├── install.sh
├── install.ps1
├── LICENSE
├── QUICKSTART.md
├── README.md
├── docs/
│   ├── macos-linux-codex-setup.md
│   ├── security-model.md
│   ├── why-this-exists.md
│   └── windows-codex-setup.md
├── examples/
│   └── hello-apps-script/
│       ├── Code.js
│       ├── README.md
│       └── appsscript.json
└── scripts/
    ├── verify-clasp.ps1
    └── verify-clasp.sh
```

## Prerequisites

- Windows with PowerShell, or macOS/Linux with Bash
- Codex Desktop, Codex CLI, or another MCP-capable Codex environment
- Node.js 20 or newer
- npm or npx
- a Google account
- Git and GitHub if you want version control

Check Node and npm:

```bash
node --version
npm --version
npx -y @google/clasp --version
```

## Manual setup summary

The installer is recommended. Manual setup is still simple:

1. Enable the Apps Script API: <https://script.google.com/home/usersettings>
2. Authenticate clasp:

```bash
npx -y @google/clasp login
```

3. Add the MCP server to your Codex MCP config:

```json
{
  "mcpServers": {
    "clasp": {
      "command": "npx",
      "args": ["-y", "@google/clasp", "mcp"]
    }
  }
}
```

4. Restart Codex.
5. Ask Codex to list the clasp MCP tools without modifying anything.

For detailed setup, use [`QUICKSTART.md`](QUICKSTART.md).

## Verify locally

Windows:

```powershell
.\scripts\verify-clasp.ps1
```

macOS/Linux:

```bash
./scripts/verify-clasp.sh
```

The scripts check Node.js, npm, npx, clasp availability, and clasp authentication status.

## Smoke test

After enabling the Apps Script API and authenticating:

```bash
npx -y @google/clasp create-script --title codex-clasp-smoke --rootDir gas-smoke
```

List accessible scripts:

```bash
npx -y @google/clasp list-scripts
```

The `gas-smoke/` folder is ignored by git.

## Minimal example

This repo includes a tiny Apps Script example in:

```text
examples/hello-apps-script/
```

Use it as starter source content after you create or clone an Apps Script project with clasp. It intentionally does not contain a real `.clasp.json` script binding.

## Public-repo safety baseline

For public repositories, commit setup files and source code, but do not commit:

- OAuth tokens
- `.clasprc.json`
- `.clasp.json` with a private script ID
- `.mcp.json` with machine-specific local config
- `.env` files
- credentials
- private script IDs
- local logs or generated artifacts

See [`docs/security-model.md`](docs/security-model.md) for the security boundary.

## Suggested GitHub description

```text
Narrow Codex MCP setup for Google Apps Script via @google/clasp, without direct Workspace-wide MCP access.
```

## Suggested GitHub topics

```text
codex
mcp
model-context-protocol
google-apps-script
apps-script
clasp
google-clasp
windows
powershell
macos
linux
codex-cli
automation
developer-tools
ai-coding
google-workspace
privacy-conscious
least-privilege
```

## References

- [Google clasp guide](https://developers.google.com/apps-script/guides/clasp)
- [google/clasp on GitHub](https://github.com/google/clasp)
- [Apps Script API: manage projects](https://developers.google.com/apps-script/api/how-tos/manage-projects)
- [Apps Script authorization scopes](https://developers.google.com/apps-script/concepts/scopes)
