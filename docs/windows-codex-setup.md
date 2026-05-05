# Windows Codex setup

This guide assumes:

- Windows
- PowerShell
- Codex Desktop or another Codex environment that can load MCP servers
- Node.js 20 or newer
- a Google account with Apps Script access

## 1. Clone the repo

```powershell
git clone https://github.com/MSotoudeh/codex-google-apps-script-mcp.git
cd codex-google-apps-script-mcp
```

## 2. Check local tooling

```powershell
node --version
npm --version
npx -y @google/clasp --version
```

If Node.js is missing or too old, install a current Node.js LTS release first.

## 3. Enable Apps Script API

Open:

<https://script.google.com/home/usersettings>

Enable the Apps Script API for the Google account you plan to use with clasp.

## 4. Authenticate clasp

```powershell
npx -y @google/clasp login
```

Complete the browser OAuth flow.

Then verify:

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

## 5. Add clasp to Codex MCP config

Use `.mcp.example.json` as the baseline:

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

If your workspace already has a `.mcp.json`, merge only the `clasp` server entry into the existing `mcpServers` object.

Do not commit your local `.mcp.json`.

## 6. Restart Codex

Restart Codex after changing `.mcp.json`. MCP servers are normally loaded at startup.

## 7. Verify from Codex

Ask Codex:

```text
List the available MCP tools from the clasp server. Do not create, modify, or delete any Apps Script project.
```

If Codex can see the clasp MCP tools, the local MCP wiring works.

## 8. Run local verification script

From this repo:

```powershell
.\scripts\verify-clasp.ps1
```

For automated checks, use JSON output:

```powershell
.\scripts\verify-clasp.ps1 -Json
```

This checks Node.js, npm, npx, clasp, and clasp login state.

## 9. Create a smoke-test project

```powershell
npx -y @google/clasp create-script --title codex-clasp-smoke --rootDir gas-smoke
```

Inspect local output:

```powershell
Get-ChildItem -Force .\gas-smoke
```

The `gas-smoke/` folder is ignored by git.

## 10. Clean up the smoke-test folder locally

```powershell
Remove-Item -Recurse -Force .\gas-smoke
```

This removes only the local folder. It does not necessarily delete the remote Apps Script project created in your Google account.

## Common Windows issues

### PowerShell script execution is blocked

Run the script with bypass for this session:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-clasp.ps1
```

### Codex cannot find `npx`

Use the full path to `npx.cmd` in `.mcp.json`.

Find it:

```powershell
where.exe npx
```

Then configure Codex with the resolved path, for example:

```json
{
  "mcpServers": {
    "clasp": {
      "command": "C:\\Program Files\\nodejs\\npx.cmd",
      "args": ["-y", "@google/clasp", "mcp"]
    }
  }
}
```

### Wrong Google account

Check the active account:

```powershell
npx -y @google/clasp show-authorized-user --json
```

Then reset login if needed:

```powershell
npx -y @google/clasp logout
npx -y @google/clasp login
```
