#!/usr/bin/env bash
set -u

json=0

usage() {
  cat <<'EOF'
Usage: ./scripts/verify-clasp.sh [--json]

Options:
  --json     Emit machine-readable JSON.
  -h, --help Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      json=1
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

results=()
success=1

json_escape() {
  node -e 'process.stdout.write(JSON.stringify(process.argv[1] ?? ""))' "$1"
}

add_result() {
  local name="$1"
  local command_text="$2"
  local ok="$3"
  local exit_code="$4"
  local output="$5"
  local error="$6"
  local guidance="$7"

  if [[ "$ok" != "true" ]]; then
    success=0
  fi

  results+=("{\"name\":$(json_escape "$name"),\"command\":$(json_escape "$command_text"),\"success\":$ok,\"exitCode\":$exit_code,\"output\":$(json_escape "$output"),\"error\":$(json_escape "$error"),\"guidance\":$(json_escape "$guidance")}")
}

write_step() {
  if [[ "$json" -eq 0 ]]; then
    printf '\n==> %s\n' "$1"
  fi
}

write_result() {
  local ok="$1"
  local output="$2"
  local error="$3"
  local guidance="$4"

  if [[ "$json" -eq 1 ]]; then
    return
  fi

  if [[ "$ok" == "true" ]]; then
    if [[ -n "$output" ]]; then
      echo "OK: $output"
    else
      echo "OK"
    fi
    return
  fi

  echo "FAILED: $error"
  if [[ -n "$guidance" ]]; then
    echo "$guidance"
  fi
}

run_check() {
  local name="$1"
  local missing_guidance="$2"
  local failure_guidance="$3"
  shift 3

  local cmd="$1"
  local command_text="$*"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    local error="$cmd was not found on PATH."
    add_result "$name" "$command_text" "false" "null" "" "$error" "$missing_guidance"
    write_result "false" "" "$error" "$missing_guidance"
    return 1
  fi

  local output
  output="$("$@" 2>&1)"
  local exit_code=$?

  if [[ "$exit_code" -eq 0 ]]; then
    output="$(printf '%s' "$output" | sed -e 's/[[:space:]]*$//')"
    add_result "$name" "$command_text" "true" "$exit_code" "$output" "" ""
    write_result "true" "$output" "" ""
    return 0
  fi

  local error="Command exited with code $exit_code."
  add_result "$name" "$command_text" "false" "$exit_code" "$output" "$error" "$failure_guidance"
  write_result "false" "$output" "$error" "$failure_guidance"
  return 1
}

check_auth() {
  local name="clasp authentication"
  local command_text="npx -y @google/clasp show-authorized-user --json"
  local missing_guidance="Install Node.js/npm and make sure npx is available on PATH."
  local failure_guidance="Unable to check clasp authentication. This can be caused by network/DNS errors, npx package execution problems, or clasp authentication state. Retry the command manually: npx -y @google/clasp show-authorized-user --json"

  if ! command -v npx >/dev/null 2>&1; then
    local error="npx was not found on PATH."
    add_result "$name" "$command_text" "false" "null" "" "$error" "$missing_guidance"
    write_result "false" "" "$error" "$missing_guidance"
    return 1
  fi

  local output
  output="$(npx -y @google/clasp show-authorized-user --json 2>&1)"
  local exit_code=$?

  if [[ "$exit_code" -ne 0 ]]; then
    local error="Command exited with code $exit_code."
    add_result "$name" "$command_text" "false" "$exit_code" "$output" "$error" "$failure_guidance"
    write_result "false" "$output" "$error" "$failure_guidance"
    return 1
  fi

  local logged_in
  logged_in="$(node -e 'try { const v = JSON.parse(process.argv[1]); process.stdout.write(v.loggedIn === true ? "true" : "false"); } catch { process.exit(2); }' "$output")"
  local parse_code=$?

  if [[ "$parse_code" -ne 0 ]]; then
    local error="clasp returned output that was not valid JSON."
    local guidance="Retry manually with: npx -y @google/clasp show-authorized-user --json"
    add_result "$name" "$command_text" "false" "$exit_code" "$output" "$error" "$guidance"
    write_result "false" "$output" "$error" "$guidance"
    return 1
  fi

  if [[ "$logged_in" != "true" ]]; then
    local error="clasp is not authenticated."
    local guidance="Run: npx -y @google/clasp login"
    add_result "$name" "$command_text" "false" "$exit_code" "$output" "$error" "$guidance"
    write_result "false" "$output" "$error" "$guidance"
    return 1
  fi

  local email
  email="$(node -e 'const v = JSON.parse(process.argv[1]); process.stdout.write(v.email ? `logged in as ${v.email}` : "logged in");' "$output")"
  add_result "$name" "$command_text" "true" "$exit_code" "$email" "" ""
  write_result "true" "$email" "" ""
}

write_step "Checking Node.js"
run_check "Node.js" "Install Node.js 20 or newer, then reopen your shell so PATH is refreshed." "Node.js is installed but failed to run. Reinstall Node.js or check your PATH." node --version || true

write_step "Checking npm"
run_check "npm" "Install Node.js with npm included, then reopen your shell so PATH is refreshed." "npm is installed but failed to run. Reinstall Node.js/npm or check your PATH." npm --version || true

write_step "Checking npx"
run_check "npx" "Install Node.js with npm/npx included, then reopen your shell so PATH is refreshed." "npx is installed but failed to run. Reinstall Node.js/npm or check your PATH." npx --version || true

write_step "Checking @google/clasp availability"
run_check "@google/clasp" "Install Node.js/npm and make sure npx is available on PATH." "npx could not execute @google/clasp. Check your network connection, npm registry access, and Node.js installation." npx -y @google/clasp --version || true

write_step "Checking clasp authentication"
check_auth || true

if [[ "$json" -eq 1 ]]; then
  joined="$(IFS=,; echo "${results[*]}")"
  if [[ "$success" -eq 1 ]]; then
    printf '{"success":true,"checks":[%s]}\n' "$joined"
  else
    printf '{"success":false,"checks":[%s]}\n' "$joined"
  fi
elif [[ "$success" -eq 1 ]]; then
  printf '\nVerification completed.\n'
else
  printf '\nVerification failed. Fix the failed check above and rerun this script.\n'
fi

if [[ "$success" -ne 1 ]]; then
  exit 1
fi
