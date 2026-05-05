# Codex clasp MCP setup

Windows-first setup template for connecting Codex to Google Apps Script through the official `@google/clasp` MCP server.

This repository does **not** implement a custom MCP server. It provides a reusable MCP configuration, safety rules, setup guide, verification script, plug-and-play installer, and minimal Apps Script example for using Codex to manage Google Apps Script projects through clasp.

It is **not** a general Google Workspace MCP server. It does not give Codex direct Gmail, Drive, Calendar, Docs, Sheets, or Admin SDK tools. Codex gets project-management access to Apps Script through clasp. Any Google Workspace access happens only inside the Apps Script project at runtime and depends on that script's authorization scopes.

## Plug-and-play setup

For most Windows users:

```powershell
git clone https://github.com/MSotoudeh/codex-google-apps-script-mcp.git
cd codex-google-apps-script-mcp
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installer checks local tools, opens the Apps Script API settings page, handles clasp login unless skipped, and creates or updates `.mcp.json` with the `clasp` MCP server.

After installation, restart Codex and ask:

```text
List the available MCP tools from the clasp server. Do not modify any files or Google projects.
```

For options such as installing into a different workspace, skipping login, or running without browser launch, see [`QUICKSTART.md`](QUICKSTART.md).

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
Codex Desktop on Windows
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

- your automation is implemented in Google Apps Script
- you want Codex to edit Apps Script source files in a local folder
- you want version control around Apps Script changes
- you need repeatable pull, push, deploy, run, and log workflows
- you already use Codex and want Apps Script available as another MCP-backed tool
- a script started in the browser editor and is now important enough to maintain properly

Typical targets:

- Google Sheets automations
- Apps Script web apps
- Gmail, Drive, Calendar, Docs, or Sheets automations implemented as Apps Script code
- scheduled trigger jobs
- internal business utilities
- small integrations where Apps Script is simpler than a full backend

## When not to use this

This setup is not the right tool when:

- you need direct Gmail, Drive, Calendar, or Docs MCP tools in Codex
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
├── install.ps1
├── LICENSE
├── QUICKSTART.md
├── README.md
├── docs/
│   ├── security-model.md
│   └── windows-codex-setup.md
├── examples/
│   └── hello-apps-script/
│       ├── Code.js
│       ├── README.md
│       └── appsscript.json
└── scripts/
    └── verify-clasp.ps1
```

## Prerequisites

- Windows with PowerShell
- Codex Desktop or another MCP-capable Codex environment
- Node.js 20 or newer
- npm or npx
- a Google account
- Git and GitHub if you want version control

Check Node and npm:

```powershell
node --version
npm --version
npx -y @google/clasp --version
```

## 1. Enable the Apps Script API

Before clasp can create or manage projects, enable the Apps Script API for your Google account:

<https://script.google.com/home/usersettings>

If you just enabled it and still see an API-disabled error, wait a few minutes and retry. Google account settings can take time to propagate.

## 2. Authenticate clasp

Run:

```powershell
npx -y @google/clasp login
```

Complete the browser OAuth flow with the Google account that owns or can access your Apps Script projects.

Verify authentication:

```powershell
npx -y @google/clasp show-authorized-user --json
```

Expected shape:

```json
{
  "loggedIn": true,
  "email": "you@example.com"
}
```

Do not commit clasp credentials, token files, generated local secrets, or private script identifiers to a public repository.

## 3. Configure Codex MCP manually

The installer does this automatically. Manual config is useful if you do not want to run scripts.

Copy the example MCP config into your Codex workspace config or merge the `clasp` server into your existing `.mcp.json`:

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

If your `.mcp.json` already has other MCP servers, add only the `clasp` entry under the existing `mcpServers` object.

After editing `.mcp.json`, restart Codex so it loads the MCP server.

## 4. Verify from PowerShell

Run the included verification script:

```powershell
.\scripts\verify-clasp.ps1
```

For CI or other automation, emit a machine-readable result:

```powershell
.\scripts\verify-clasp.ps1 -Json
```

The script checks:

- Node.js availability
- npm availability
- npx availability
- `@google/clasp` availability
- clasp authentication status

## 5. Verify from Codex

After restarting Codex, ask Codex something like:

```text
List the available MCP tools from the clasp server. Do not modify any files or Google projects.
```

Expected result: Codex should expose clasp-related MCP tools for project creation, cloning, pulling, pushing, deploying, running functions, logs, or project inspection.

## 6. Smoke test

After enabling the Apps Script API and authenticating:

```powershell
npx -y @google/clasp create-script --title codex-clasp-smoke --rootDir gas-smoke
```

Inspect the generated local folder:

```powershell
Get-ChildItem -Force .\gas-smoke
```

List accessible scripts:

```powershell
npx -y @google/clasp list-scripts
```

The `gas-smoke/` folder is ignored by git.

## 7. Try the minimal example

This repo includes a tiny Apps Script example in:

```text
examples/hello-apps-script/
```

Use it as starter source content after you create or clone an Apps Script project with clasp. Do not treat the example folder as an already-bound live Apps Script project; it intentionally does not contain a real `.clasp.json` script binding.

## Typical clasp workflows

Create a new Apps Script project:

```powershell
npx -y @google/clasp create-script --title my-script --rootDir my-script
```

Clone an existing Apps Script project:

```powershell
npx -y @google/clasp clone-script <script-id-or-url> --rootDir my-script
```

Pull remote changes:

```powershell
npx -y @google/clasp pull
```

Push local changes:

```powershell
npx -y @google/clasp push
```

Create a version:

```powershell
npx -y @google/clasp create-version "Initial version"
```

Run a function:

```powershell
npx -y @google/clasp run-function helloCodex
```

Tail logs:

```powershell
npx -y @google/clasp tail-logs
```

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

## Troubleshooting

### `loggedIn: false`

Run:

```powershell
npx -y @google/clasp login
```

### `User has not enabled the Apps Script API`

Open:

<https://script.google.com/home/usersettings>

Enable the Apps Script API and retry after a few minutes.

### Codex does not show the clasp MCP tools

Restart Codex after editing `.mcp.json`. MCP servers are normally loaded at startup.

Also confirm your `.mcp.json` is in the workspace Codex is actually using.

### `npx` cannot find clasp

Check Node.js and npm:

```powershell
node --version
npm --version
npx -y @google/clasp --version
```

### The wrong Google account is used

Run:

```powershell
npx -y @google/clasp show-authorized-user --json
```

If needed, log out and log in with the intended account:

```powershell
npx -y @google/clasp logout
npx -y @google/clasp login
```

## Suggested GitHub description

```text
Connect Codex on Windows to Google Apps Script using the official @google/clasp MCP server.
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
automation
developer-tools
ai-coding
google-workspace
```

## References

- [Google clasp guide](https://developers.google.com/apps-script/guides/clasp)
- [google/clasp on GitHub](https://github.com/google/clasp)
- [Apps Script API: manage projects](https://developers.google.com/apps-script/api/how-tos/manage-projects)
- [Apps Script authorization scopes](https://developers.google.com/apps-script/concepts/scopes)
