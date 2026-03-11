# DevContainerLab

A dev container that clones a .NET repository, detects a failing unit test, and uses [OpenCode](https://opencode.ai) (an AI coding agent) to automatically fix the bug — all in one `postCreateCommand`.

## How it works

1. The dev container image is built with .NET SDK 10, Git, and OpenCode.
2. On container start, `run-fix.sh` clones the repo specified by `REPO_URL`.
3. `dotnet test` runs and confirms a test is failing.
4. OpenCode is invoked with a prompt describing the task. It reads the test, locates the bug, applies a fix, and re-runs `dotnet test`.
5. A final `dotnet test` verifies all tests pass.

## Prerequisites

- Docker (or a compatible container runtime)
- VS Code with the Dev Containers extension, **or** the [`devcontainer` CLI](https://github.com/devcontainers/cli)
- An SSH key added to your SSH agent (`ssh-add`) with access to the target repo — the dev container forwards the host SSH agent automatically
- An [OpenCode API key](https://opencode.ai)

## Setup

### Option A: Host environment variables (recommended for CI)

Set these on the host before building the container:

```bash
export REPO_URL="git@github.com:your-org/devcontainerlab.git"
export OPENCODE_API_KEY="your-opencode-api-key"
# Optional:
export OPENCODE_PROMPT="Fix the failing test."
```

### Option B: Local JSON config file

1. Copy the example config:
   ```bash
   cp .devcontainer/devcontainer.local.json.example .devcontainer/devcontainer.local.json
   ```
2. Edit `.devcontainer/devcontainer.local.json` with your values.

The file is gitignored, so your secrets stay local. The script reads it at runtime as a fallback when environment variables are not set.

## Running

### VS Code

Open the repo in VS Code, then **Reopen in Container** (Ctrl+Shift+P → "Dev Containers: Reopen in Container").

### CLI

```bash
devcontainer up --workspace-folder .
```

### Azure DevOps / CI

Set `REPO_URL` and `OPENCODE_API_KEY` as pipeline variables or secrets, then use the `devcontainer` CLI in your pipeline.

## Project structure

```
App/              .NET 10 console app with a Calculator class (contains the bug)
Tests/            Unit tests that expose the bug
.devcontainer/
  Dockerfile      Container image (SDK + Git + OpenCode + jq)
  devcontainer.json   Dev container config (env vars via localEnv)
  run-fix.sh      Entry-point script (clone → test → fix → verify)
  devcontainer.local.json.example   Template for local config
```

## Configuration reference

| Variable | Required | Description |
|---|---|---|
| `REPO_URL` | Yes | SSH clone URL of the target repository |
| `OPENCODE_API_KEY` | Yes | API key for OpenCode |
| `OPENCODE_PROMPT` | No | Custom prompt for OpenCode (default: fix the failing test) |
