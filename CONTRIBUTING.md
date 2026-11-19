# Contributing

## Setup

Requirements: Node.js 20+ and npm. There are no dependencies to install.

## Tests

```bash
node --test
```

Run them before opening a pull request. If you change an installer or verification script, also run `scripts/verify-clasp.sh --json` (or the `.ps1` version) locally. Do not run anything that needs a live Google account in CI.

## Branches and commits

- Branch from `main`: `feat/<topic>`, `fix/<topic>`, `docs/<topic>`, `chore/<topic>`.
- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `test:`, `chore:`.
- Keep the README, the docs and `tests/cross-platform-docs.test.mjs` consistent with script behavior.
- Never commit `.mcp.json`, `.clasp.json`, `.clasprc.json`, tokens or `.env` files.
