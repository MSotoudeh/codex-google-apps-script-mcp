# Security model

This repository is a setup template for connecting Codex to Google Apps Script through the official `@google/clasp` MCP server.

The design goal is **narrow access by default**.

It is for users who want Codex to help with Apps Script project development, but do not want to expose broad Google Workspace MCP tools such as Gmail, Drive, Calendar, Docs, Sheets, or Admin SDK.

## Core idea

Use this narrower path:

```text
Codex
  -> local MCP process
  -> @google/clasp
  -> Apps Script project management
```

Avoid this broader path when you do not need it:

```text
Codex
  -> broad Google Workspace MCP
  -> Gmail / Drive / Calendar / Docs / Sheets / Admin data
```

This does not make every Apps Script workflow risk-free. It does reduce the default tool surface exposed to Codex.

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

That distinction is the main reason this repo exists.

A user may want AI help editing Apps Script code without also giving the AI assistant direct tools for reading email, browsing Drive files, modifying Docs, inspecting Calendar events, or touching other unrelated Workspace data.

## Important limitation

Apps Script code may still use Google services at runtime if the script has the required scopes and the user authorizes them.

That runtime authorization belongs to the Apps Script project, not to this repository.

Users still need to review:

- `appsscript.json`
- requested OAuth scopes
- Apps Script source code
- trigger behavior
- clasp push operations
- versions and deployments

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

## Practical risk reduction

This setup helps reduce accidental blast radius because:

- Codex works against local files before syncing
- changes can be reviewed with git before push
- Workspace-wide tools are not exposed by this repo
- project management goes through clasp
- sensitive Gmail, Drive, Calendar, Docs, and Sheets data are not direct MCP tool targets here

This is not a replacement for OAuth review, code review, or least-privilege scopes. It is a narrower operating model.

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

```bash
git status
git diff --staged
```

Search for likely secrets:

```bash
git grep -n "token\|secret\|password\|client_secret\|private_key\|scriptId"
```

If a sensitive file was committed accidentally, removing it in a later commit is not enough. Treat the value as exposed and rotate or revoke it.
