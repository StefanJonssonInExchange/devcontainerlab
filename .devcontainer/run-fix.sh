#!/bin/bash
set -e

# Source local overrides if present (devcontainer.local.json is gitignored)
LOCAL_CONFIG="/workspace/devcontainerlab/.devcontainer/devcontainer.local.json"
if [ -f "$LOCAL_CONFIG" ]; then
  echo "=== Loading config from devcontainer.local.json ==="
  export REPO_URL="${REPO_URL:-$(jq -r '.REPO_URL // empty' "$LOCAL_CONFIG")}"
  export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-$(jq -r '.ANTHROPIC_API_KEY // empty' "$LOCAL_CONFIG")}"
  export OPENCODE_PROMPT="${OPENCODE_PROMPT:-$(jq -r '.OPENCODE_PROMPT // empty' "$LOCAL_CONFIG")}"
fi

REPO_URL="${REPO_URL:?Set REPO_URL to the git clone URL}"
WORKDIR="/workspace/devcontainerlab"

# Clone the repo via SSH
git clone "$REPO_URL" "$WORKDIR"
cd "$WORKDIR"

# Verify the test fails first
echo "=== Verifying test fails ==="
dotnet test || true

# Run OpenCode in non-interactive mode with --yolo to fix the bug
DEFAULT_PROMPT="The dotnet test command shows a failing unit test. Read the test, find the bug in the source code, fix it, and run dotnet test again to confirm all tests pass. Keep iterating until all tests pass."
OPENCODE_PROMPT="${OPENCODE_PROMPT:-$DEFAULT_PROMPT}"

opencode run --yolo "$OPENCODE_PROMPT"

# Verify fix
echo "=== Final verification ==="
dotnet test
echo "=== Done! ==="
