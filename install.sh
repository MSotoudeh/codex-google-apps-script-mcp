#!/usr/bin/env bash
set -euo pipefail

workspace_path="$(pwd)"
skip_login=0
no_browser=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [--workspace PATH] [--skip-login] [--no-browser]

Options:
  --workspace PATH  Workspace directory where .mcp.json should be created or updated.
  --skip-login      Skip clasp authentication.
  --no-browser      Do not try to open the Apps Script API settings page.
  -h, --help        Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --workspace" >&2
        exit 1
      fi
      workspace_path="$2"
      shift 2
      ;;
    --skip-login)
      skip_login=1
      shift
      ;;
    --no-browser)
      no_browser=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

write_step() {
  printf '\n==> %s\n' "$1"
}

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "Required command not found: $name" >&2
    exit 1
  fi
  command -v "$name"
}

run_checked() {
  "$@"
}

open_url() {
  local url="$1"
  if [[ "$no_browser" -eq 1 ]]; then
    echo "Open this URL and enable the Apps Script API:"
    echo "$url"
    return
  fi

  if command -v open >/dev/null 2>&1; then
    open "$url" >/dev/null 2>&1 || true
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" >/dev/null 2>&1 || true
  else
    echo "Open this URL and enable the Apps Script API:"
    echo "$url"
    return
  fi

  echo "Opened Apps Script API settings page:"
  echo "$url"
}

set_clasp_mcp_config() {
  local target_path="$1"
  mkdir -p "$target_path"

  MCP_TARGET_PATH="$target_path/.mcp.json" node <<'NODE'
const fs = require("node:fs");
const path = process.env.MCP_TARGET_PATH;

let config = {};
if (fs.existsSync(path)) {
  const raw = fs.readFileSync(path, "utf8").trim();
  if (raw) {
    config = JSON.parse(raw);
  }
}

if (!config["mcpServers"] || typeof config["mcpServers"] !== "object" || Array.isArray(config["mcpServers"])) {
  config["mcpServers"] = {};
}

config["mcpServers"]["clasp"] = {
  command: "npx",
  args: ["-y", "@google/clasp", "mcp"],
};

fs.writeFileSync(path, `${JSON.stringify(config, null, 2)}\n`);
NODE

  echo "$target_path/.mcp.json"
}

echo "Codex + Google Apps Script clasp MCP installer"
echo "Target workspace: $workspace_path"

write_step "Checking required local tools"
node_path="$(require_command node)"
npm_path="$(require_command npm)"
npx_path="$(require_command npx)"

echo "node: $node_path"
echo "npm:  $npm_path"
echo "npx:  $npx_path"

write_step "Checking versions"
run_checked node --version
run_checked npm --version
run_checked npx --version

write_step "Checking @google/clasp"
run_checked npx -y @google/clasp --version

write_step "Apps Script API settings"
open_url "https://script.google.com/home/usersettings"

if [[ "$skip_login" -eq 0 ]]; then
  write_step "Checking clasp authentication"
  if ! npx -y @google/clasp show-authorized-user --json >/dev/null 2>&1; then
    echo "clasp is not authenticated. Starting login flow..."
    run_checked npx -y @google/clasp login
  fi

  write_step "Verifying clasp authentication"
  run_checked npx -y @google/clasp show-authorized-user --json
else
  write_step "Skipping clasp login because --skip-login was provided"
fi

write_step "Creating or updating Codex MCP config"
mcp_path="$(set_clasp_mcp_config "$workspace_path")"
echo "Updated: $mcp_path"

cat <<EOF

Install completed.

Next steps:
1. Restart Codex.
2. Open this workspace in Codex: $workspace_path
3. Ask Codex: List the available MCP tools from the clasp server. Do not modify any files or Google projects.
EOF
