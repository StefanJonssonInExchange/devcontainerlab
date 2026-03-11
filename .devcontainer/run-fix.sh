#!/bin/bash
set -e

# Maximum time (in seconds) for the OpenCode run before we abort
OPENCODE_TIMEOUT="${OPENCODE_TIMEOUT:-300}"

# Default model (opencode provider models work without an API key)
OPENCODE_MODEL="${OPENCODE_MODEL:-opencode/big-pickle}"

# The workspace is bind-mounted by the devcontainer at /workspaces/devcontainerlab
WORKDIR="/workspaces/devcontainerlab"

# Source local overrides if present (devcontainer.local.json is gitignored)
LOCAL_CONFIG="$WORKDIR/.devcontainer/devcontainer.local.json"
if [ -f "$LOCAL_CONFIG" ]; then
  echo "=== Loading config from devcontainer.local.json ==="
  export OPENCODE_MODEL="${OPENCODE_MODEL:-$(jq -r '.OPENCODE_MODEL // empty' "$LOCAL_CONFIG")}"
  export OPENCODE_PROMPT="${OPENCODE_PROMPT:-$(jq -r '.OPENCODE_PROMPT // empty' "$LOCAL_CONFIG")}"
  # Load provider API keys if present (e.g. ANTHROPIC_API_KEY for anthropic/* models)
  for key in $(jq -r 'keys[] | select(endswith("_API_KEY"))' "$LOCAL_CONFIG" 2>/dev/null); do
    val=$(jq -r --arg k "$key" '.[$k] // empty' "$LOCAL_CONFIG")
    if [ -n "$val" ] && [ -z "${!key}" ]; then
      export "$key=$val"
    fi
  done
fi

cd "$WORKDIR"

# Verify the test fails first
echo "=== Verifying test fails ==="
dotnet test || true

# Run OpenCode in non-interactive mode to fix the bug
DEFAULT_PROMPT="The dotnet test command shows a failing unit test. Read the test, find the bug in the source code, fix it, and run dotnet test again to confirm all tests pass. Keep iterating until all tests pass."
OPENCODE_PROMPT="${OPENCODE_PROMPT:-$DEFAULT_PROMPT}"

echo "=== Running OpenCode (model: $OPENCODE_MODEL, timeout: ${OPENCODE_TIMEOUT}s) ==="
timeout "$OPENCODE_TIMEOUT" opencode run -m "$OPENCODE_MODEL" --print-logs "$OPENCODE_PROMPT" < /dev/null 2>&1
OPENCODE_EXIT=$?

if [ $OPENCODE_EXIT -eq 124 ]; then
  echo "ERROR: OpenCode timed out after ${OPENCODE_TIMEOUT}s"
  exit 1
elif [ $OPENCODE_EXIT -ne 0 ]; then
  echo "ERROR: OpenCode exited with code $OPENCODE_EXIT"
  exit $OPENCODE_EXIT
fi

# Verify fix
echo "=== Final verification ==="
dotnet test
echo "=== Done! ==="
