# Codex + Google Apps Script MCP

Connect Codex to Google Apps Script by running the official `@google/clasp` MCP server. This lets Codex manage Apps Script projects from your local machine using the same workflow Google recommends for Apps Script command-line development.

## What this gives you

With this setup, Codex can use clasp-backed MCP tools to:

- create or clone Google Apps Script projects
- pull Apps Script files to a local folder
- push local edits back to Apps Script
- inspect file status before syncing
- create script versions and deployments
- run script functions
- tail Apps Script logs
- open related Apps Script project URLs

This repository is intentionally small. It does not contain a script project, OAuth token, or user-specific Google credentials. It is a reusable setup template and explanation for connecting Codex to Google Apps Script.

## Why you may need this

Google Apps Script is useful for automating Google Workspace tasks, but the browser editor is not ideal for larger changes, reviewable edits, or AI-assisted maintenance. Connecting Codex through clasp gives you a local development loop:

1. Codex edits files locally.
2. clasp syncs those files with Google Apps Script.
3. Apps Script runs inside Google's environment with access to services such as Sheets, Drive, Gmail, Calendar, Docs, and Workspace APIs.

You may need this when you want Codex to help maintain or build:

- Google Sheets automations
- Gmail or Drive workflow scripts
- Calendar or Docs automations
- Workspace admin utilities
- Apps Script web apps
- add-ons and internal business tools
- scheduled trigger jobs
- small integrations where Apps Script is simpler than a full backend

## When this is a good fit

Use this setup when:

- your automation lives in Google Workspace
- you want Codex to edit Apps Script source files safely in a local folder
- you want version control around Apps Script changes
- you need repeatable push, pull, deploy, and run commands
- you already use Codex and want Apps Script available as another MCP-backed tool

This is especially useful for scripts that started in the Apps Script editor and became important enough to maintain more carefully.

## When not to use this

This setup is not the best option when:

- the script is a one-line personal macro that will never be maintained
- you need a production backend with low latency, private networking, or heavy compute
- you need service-account/domain-wide Google Workspace delegation from day one
- you want Google Apps Script to call Codex directly

For durable background orchestration, retries, long-running workflows, or complex multi-step jobs, consider adding a workflow engine such as Temporal outside this basic setup. The clasp MCP connection is focused on managing Apps Script projects, not replacing a backend orchestration system.

## Prerequisites

- Codex desktop or another MCP-capable Codex environment
- Node.js 20 or newer
- npm or npx
- a Google account
- GitHub or another Git host if you want version control

Check Node:

```powershell
node --version
npx -y @google/clasp --version
```

## Enable the Apps Script API

Before clasp can create or manage projects, enable the Apps Script API for your Google account:

[https://script.google.com/home/usersettings](https://script.google.com/home/usersettings)

If you just enabled it and still see an API-disabled error, wait a few minutes and retry. Google account settings can take a short time to propagate.

## Authenticate clasp

Run:

```powershell
npx -y @google/clasp login
```

Complete the browser OAuth flow with the Google account that owns or can access your Apps Script projects.

Verify authentication:

```powershell
npx -y @google/clasp show-authorized-user --json
```

Expected result:

```json
{
  "loggedIn": true,
  "email": "you@example.com"
}
```

Do not commit clasp credentials, token files, or generated local secrets to a public repository.

## Configure Codex MCP

Add this server to your Codex MCP configuration, usually `.mcp.json` in your workspace:

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

After editing `.mcp.json`, restart Codex so it loads the new MCP server.

## Example full `.mcp.json`

```json
{
  "mcpServers": {
    "desktop-commander": {
      "command": "desktop-commander",
      "args": []
    },
    "clasp": {
      "command": "npx",
      "args": ["-y", "@google/clasp", "mcp"]
    }
  }
}
```

## Smoke test

After enabling the Apps Script API and authenticating:

```powershell
npx -y @google/clasp create-script --title codex-clasp-smoke --rootDir gas-smoke
```

Then inspect the generated local folder:

```powershell
Get-ChildItem -Force .\gas-smoke
```

You can also list scripts:

```powershell
npx -y @google/clasp list-scripts
```

## Typical workflows

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
npx -y @google/clasp run-function myFunction
```

Tail logs:

```powershell
npx -y @google/clasp tail-logs
```

## Recommended public-repo safety

For public repositories, commit setup files and source code, but do not commit:

- OAuth tokens
- `.clasprc.json`
- `.env` files
- credentials
- private script IDs if they should not be public
- local logs or generated artifacts

Use a `.gitignore` like the one in this repository as a baseline.

## Troubleshooting

### `loggedIn: false`

Run:

```powershell
npx -y @google/clasp login
```

### `User has not enabled the Apps Script API`

Open:

[https://script.google.com/home/usersettings](https://script.google.com/home/usersettings)

Enable the Apps Script API and retry after a few minutes.

### Codex does not show the clasp MCP tools

Restart Codex after editing `.mcp.json`. MCP servers are normally loaded at startup.

### `npx` cannot find clasp

Check Node.js and npm:

```powershell
node --version
npm --version
npx -y @google/clasp --version
```

## References

- [Google clasp guide](https://developers.google.com/apps-script/guides/clasp)
- [google/clasp on GitHub](https://github.com/google/clasp)
- [Apps Script API: manage projects](https://developers.google.com/apps-script/api/how-tos/manage-projects)
- [Apps Script authorization scopes](https://developers.google.com/apps-script/concepts/scopes)
