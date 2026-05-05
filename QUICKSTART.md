# Plug-and-play quickstart

This is the shortest path for a Windows user who wants Codex to use Google Apps Script through the official `@google/clasp` MCP server.

## What this installs

It does not install a custom MCP server.

It configures Codex to run:

```json
{
  "command": "npx",
  "args": ["-y", "@google/clasp", "mcp"]
}
```

## One-command setup

Clone the repo:

```powershell
git clone https://github.com/MSotoudeh/codex-google-apps-script-mcp.git
cd codex-google-apps-script-mcp
```

Run the installer from the workspace you want Codex to use:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installer will:

- check `node`, `npm`, and `npx`
- check `@google/clasp`
- open the Apps Script API settings page
- start clasp login if needed
- create or update `.mcp.json`
- add the `clasp` MCP server entry
- print the next Codex test prompt

## Install into a different workspace

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -WorkspacePath "C:\GitHub\my-apps-script-project"
```

## Skip login

Use this if clasp is already authenticated or if you only want to generate `.mcp.json`:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -SkipLogin
```

## No browser launch

Use this if you are in a restricted terminal session:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -NoBrowser
```

## After installation

Restart Codex.

Then ask Codex:

```text
List the available MCP tools from the clasp server. Do not modify any files or Google projects.
```

If Codex lists clasp MCP tools, the setup works.

## What users still need to do manually

The installer cannot safely do these for every user:

- install Node.js if it is missing
- choose the correct Google account for the user
- guarantee the Apps Script API is enabled before Google finishes propagation
- restart Codex automatically
- verify Codex-specific UI state

## Security boundary

This setup does not give Codex direct access to Gmail, Drive, Calendar, Docs, or all of Google Workspace.

It gives Codex access to clasp-backed Apps Script project management through the user's local Google OAuth session.

Read: [`docs/security-model.md`](docs/security-model.md)
