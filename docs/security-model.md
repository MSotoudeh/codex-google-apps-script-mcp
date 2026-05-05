# Security model

This repository is a setup template for connecting Codex to Google Apps Script through the official `@google/clasp` MCP server.

It is important to keep the security boundary clear.

## What Codex gets

With the MCP configuration in this repo, Codex can talk to the local `@google/clasp mcp` server.

That means Codex may be able to ask clasp to:

- create Apps Script projects
- clone existing Apps Script projects
- pull project source files to the local machine
- push local files back to Apps Script
- create versions and deployments
- run functions
- inspect logs or project metadata exposed by clasp

The exact tool list depends on the installed `@google/clasp` version.

## What Codex does not get from this repo

This repo does not provide direct MCP tools for:

- Gmail
- Google Drive
- Google Calendar
- Google Docs
- Google Sheets
- Google Admin SDK
- all of Google Workspace

Apps Script code may use those services at runtime if the script has the required scopes and the user authorizes them. That runtime authorization belongs to the Apps Script project, not to this repository.

## Trust chain

```text
Codex
  -> local MCP process
  -> @google/clasp
  -> local Google OAuth session
  -> Apps Script API
  -> Apps Script project
  -> script runtime scopes
  -> Google services used by the script
```

## Sensitive files

Do not commit these files to a public repo:

```text
.clasprc.json
.clasp.json
.mcp.json
.env
.env.*
credentials.json
token.json
*.pem
*.key
```

Notes:

- `.clasprc.json` may contain OAuth-related local clasp state.
- `.clasp.json` can contain a script ID. In private project repos, teams may intentionally commit it. In a public template or public personal repo, avoid committing real script bindings.
- `.mcp.json` can contain machine-specific local MCP configuration. Commit `.mcp.example.json` instead.

## Public repository rule

For a public repository, commit only reusable configuration, examples, source code, and documentation.

Do not commit anything that proves ownership of a Google account, binds the repo to a private Apps Script project, or exposes a real user or organization credential.

## Operational safety checklist

Before pushing changes to GitHub, run:

```powershell
git status
```

Then inspect anything suspicious:

```powershell
git diff --staged
```

Search for likely secrets:

```powershell
git grep -n "token\|secret\|password\|client_secret\|private_key\|scriptId"
```

If a sensitive file was committed accidentally, removing it in a later commit is not enough. Treat the value as exposed and rotate or revoke it.
