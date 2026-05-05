# macOS and Linux Codex setup

This guide assumes:

- macOS or Linux
- Bash-compatible shell
- Codex Desktop, Codex CLI, or another Codex environment that can load MCP servers
- Node.js 20 or newer
- a Google account with Apps Script access

## 1. Clone the repo

```bash
git clone https://github.com/MSotoudeh/codex-google-apps-script-mcp.git
cd codex-google-apps-script-mcp
```

## 2. Check local tooling

```bash
node --version
npm --version
npx -y @google/clasp --version
```

If Node.js is missing or too old, install a current Node.js LTS release first. On macOS, `brew`, `nvm`, `asdf`, or the official Node installer all work. On Linux, use your distribution packages, `nvm`, `asdf`, or the official Node packages.

## 3. Enable Apps Script API

Open:

<https://script.google.com/home/usersettings>

Enable the Apps Script API for the Google account you plan to use with clasp.

## 4. Authenticate clasp

```bash
npx -y @google/clasp login
```

Complete the browser OAuth flow.

Then verify:

```bash
npx -y @google/clasp show-authorized-user --json
```

Expected shape:

```json
{
  "loggedIn": true,
  "email": "you@example.com"
}
```

## 5. Run the installer

From this repo:

```bash
chmod +x ./install.sh ./scripts/verify-clasp.sh
./install.sh
```

Install into a different workspace:

```bash
./install.sh --workspace "$HOME/projects/my-apps-script-project"
```

Skip login if clasp is already authenticated:

```bash
./install.sh --skip-login
```

Use `--no-browser` in headless or remote terminal sessions.

## 6. Add clasp to Codex MCP config manually

The installer writes `.mcp.json` in the target workspace. If your Codex environment uses another config location, manually add the same MCP server entry there:

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

Codex CLI users should put the same `clasp` MCP server in the MCP config file that their CLI installation reads, then restart or reload Codex CLI.

Do not commit your local `.mcp.json`.

## 7. Verify locally

```bash
./scripts/verify-clasp.sh
```

For automated checks, use JSON output:

```bash
./scripts/verify-clasp.sh --json
```

This checks Node.js, npm, npx, clasp, and clasp login state.

## 8. Verify from Codex

Restart Codex after changing MCP config.

Ask Codex:

```text
List the available MCP tools from the clasp server. Do not create, modify, or delete any Apps Script project.
```

If Codex can see the clasp MCP tools, the local MCP wiring works.

## 9. Create a smoke-test project

```bash
npx -y @google/clasp create-script --title codex-clasp-smoke --rootDir gas-smoke
```

Inspect local output:

```bash
ls -la ./gas-smoke
```

The `gas-smoke/` folder is ignored by git.

## Common macOS/Linux issues

### Permission denied

Make the scripts executable:

```bash
chmod +x ./install.sh ./scripts/verify-clasp.sh
```

### Codex cannot find `npx`

Use the full path to `npx` in your MCP config.

Find it:

```bash
command -v npx
```

Then configure Codex with the resolved path, for example:

```json
{
  "mcpServers": {
    "clasp": {
      "command": "/usr/local/bin/npx",
      "args": ["-y", "@google/clasp", "mcp"]
    }
  }
}
```

### Wrong Google account

Check the active account:

```bash
npx -y @google/clasp show-authorized-user --json
```

Then reset login if needed:

```bash
npx -y @google/clasp logout
npx -y @google/clasp login
```
