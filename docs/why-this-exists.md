# Why this repo exists

Powerful Google Workspace MCP servers are useful when you intentionally want an AI tool to work across Gmail, Drive, Calendar, Docs, Sheets, and other Workspace apps.

That is not always what you want.

Sometimes the goal is much narrower:

> I want Codex to help me develop Google Apps Script code, but I do not want to give it broad access to my Gmail, Drive files, Calendar events, Docs, Sheets, or other sensitive Workspace data.

This repository exists for that middle ground.

It gives Codex a practical way to manage Apps Script projects through the official `@google/clasp` MCP server, without wiring Codex directly into the rest of Google Workspace.

## The problem

A general Google Workspace MCP server can be powerful, but it can also create a large permission surface.

For many users, that feels uncomfortable:

- inbox data is private
- Drive files may contain personal, legal, financial, or business data
- Calendar events can reveal sensitive schedules and relationships
- Docs and Sheets may contain client data or internal company information
- accidental tool calls can be scary when the AI has broad write access

Even if the tool is trustworthy, the user may not want that much blast radius for a simple Apps Script development task.

## The narrower approach

This repo takes a more conservative path:

```text
Codex
  -> clasp MCP
  -> Apps Script project management
```

Instead of:

```text
Codex
  -> broad Google Workspace MCP
  -> Gmail / Drive / Calendar / Docs / Sheets / Admin data
```

The intent is simple:

- let Codex help with Apps Script source code
- keep development local and reviewable
- sync through clasp when the user chooses
- avoid giving Codex direct Workspace-wide tools
- reduce accidental access to sensitive personal or business data

## What this protects against

This setup is not a security product and it cannot make unsafe code safe by itself.

But it does reduce the default access surface. It helps avoid situations where a user only wanted Apps Script development help but ended up giving an AI assistant direct access to unrelated Workspace data.

It is useful when the user wants:

- less access by default
- clearer boundaries
- fewer sensitive tools exposed to Codex
- local files that can be reviewed before push
- a setup that feels safer for personal and small-business automation

## What still matters

Apps Script itself can still use Google services if the script requests and receives the required scopes.

That means users still need to review:

- `appsscript.json`
- OAuth scopes
- Apps Script code
- clasp push operations
- deployments
- trigger behavior

This repo does not remove the need for judgment. It gives users a narrower and more inspectable workflow.

## Human version

This project exists because not every automation task needs full access to your digital life.

If all you want is help writing and maintaining Apps Script code, giving an AI tool access to your whole Workspace can feel excessive. This repo keeps the workflow closer to normal software development: local files, explicit sync, visible code, and a smaller permission surface.

That is the value.
