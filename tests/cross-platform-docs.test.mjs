import { readFileSync, existsSync } from "node:fs";
import { test } from "node:test";
import assert from "node:assert/strict";

const root = new URL("../", import.meta.url);

function read(path) {
  return readFileSync(new URL(path, root), "utf8");
}

test("macOS and Linux installer exists and configures clasp MCP", () => {
  assert.equal(existsSync(new URL("install.sh", root)), true);

  const install = read("install.sh");
  assert.match(install, /^#!\/usr\/bin\/env bash/);
  assert.match(install, /set -euo pipefail/);
  assert.match(install, /@google\/clasp/);
  assert.match(install, /"mcpServers"/);
  assert.match(install, /"clasp"/);
  assert.match(install, /script\.google\.com\/home\/usersettings/);
});

test("macOS and Linux verification script supports JSON output", () => {
  assert.equal(existsSync(new URL("scripts/verify-clasp.sh", root)), true);

  const verify = read("scripts/verify-clasp.sh");
  assert.match(verify, /^#!\/usr\/bin\/env bash/);
  assert.match(verify, /--json/);
  assert.match(verify, /show-authorized-user --json/);
  assert.match(verify, /"success"/);
  assert.match(verify, /npx -y @google\/clasp --version/);
});

test("README documents Windows, macOS/Linux, and Codex CLI paths", () => {
  const readme = read("README.md");
  assert.match(readme, /Windows/);
  assert.match(readme, /macOS\/Linux/);
  assert.match(readme, /install\.sh/);
  assert.match(readme, /verify-clasp\.sh --json/);
  assert.match(readme, /Codex CLI/);
});

