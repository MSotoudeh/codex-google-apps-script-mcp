# History

## Why it started

Broad Google Workspace MCP servers expose Gmail, Drive, Calendar and more to an AI agent. The author only wanted Codex to develop Apps Script code, so the project packages the narrow path: Codex -> `@google/clasp mcp` -> Apps Script project.

## Phases (2026-05-05 to 2026-05-06)

1. **Initial template (05-05).** `.mcp.example.json`, a clarified purpose, a hardened `.gitignore` for clasp local state, a security-model document.
2. **Tooling (05-05).** Windows setup guide, `verify-clasp` script, a minimal Apps Script example with manifest, then the plug-and-play installers and quickstart.
3. **Cross-platform (05-05).** The clasp template was improved, verification diagnostics added, and macOS/Linux/Codex CLI support (`install.sh`, `verify-clasp.sh --json`, node tests) arrived. This work lived on the `improve-clasp-mcp-template` branch and was merged into `main`.
4. **Rationale (05-06).** README and docs were extended to explain why a narrow setup is preferable and to state the least-access model.
5. **Public-ready cleanup (2026-11-19).** README restructured, quickstart moved to `docs/`, docs index and contributor/security files added, and the README regression fixed (`verify-clasp.sh --json` had been dropped from the README while a test required it).

## Previous state versus current state

Previously the README mixed rationale, a suggested GitHub description and topics list, and setup, and `QUICKSTART.md` sat in the root. Now the README follows a fixed structure and details live in `docs/`.

## Unmerged lines of work

None. The archive tag `archive/improve-clasp-mcp-template` (2026-05-05) marks the tip of the already-merged branch of that name; `main` contains it.

## Known unfinished

- No CI workflow runs the tests.
- The installers have no automated end-to-end tests (they need a Google account).
