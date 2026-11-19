# Security policy

Report vulnerabilities privately through GitHub's "Report a vulnerability" (private security advisory) on this repository rather than in a public issue.

This repository stores no credentials. OAuth state (`.clasprc.json`), script bindings (`.clasp.json`), machine config (`.mcp.json`) and any `.env` files or `secrets/` folders are git-ignored and must stay local. If you find a committed secret, report it the same way. The least-access design is described in [docs/security-model.md](docs/security-model.md).
