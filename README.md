# DevContainerLab

A dev container that detects a failing unit test in a .NET project and uses [OpenCode](https://opencode.ai) (an AI coding agent) to automatically fix the bug — all in one `postCreateCommand`.

## How it works

1. The dev container image is built with .NET SDK 10, Git, and OpenCode.
2. On container start, the repo is bind-mounted into the container at `/workspaces/devcontainerlab`.
3. `dotnet test` runs and confirms a test is failing.
4. OpenCode is invoked with a prompt describing the task. It reads the test, locates the bug, applies a fix, and re-runs `dotnet test`.
5. A final `dotnet test` verifies all tests pass.

## Prerequisites

- Docker (or a compatible container runtime)
- VS Code with the Dev Containers extension, **or** the [`devcontainer` CLI](https://github.com/devcontainers/cli)
- (Optional) An API key for your chosen provider if not using free OpenCode models

## Setup

### Option A: Zero config (free OpenCode models)

The default model (`opencode/big-pickle`) works without any API key. Just run it.

### Option B: Host environment variables (recommended for CI)

```bash
# Optional: override model (default: opencode/big-pickle)
export OPENCODE_MODEL="anthropic/claude-sonnet-4-6"
export ANTHROPIC_API_KEY="sk-ant-..."
# Optional: custom prompt
export OPENCODE_PROMPT="Fix the failing test."
```

### Option C: Local JSON config file

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

Set env vars as pipeline secrets, then use the `devcontainer` CLI in your pipeline.

## Project structure

```
App/              .NET 10 console app with a Calculator class (contains the bug)
Tests/            Unit tests that expose the bug
.devcontainer/
  Dockerfile      Container image (SDK + Git + OpenCode + jq)
  devcontainer.json   Dev container config (env vars via localEnv)
  run-fix.sh      Entry-point script (test → fix → verify)
  devcontainer.local.json.example   Template for local config
```

## Configuration reference

| Variable | Required | Default | Description |
|---|---|---|---|
| `OPENCODE_MODEL` | No | `opencode/big-pickle` | Model in `provider/model` format (e.g. `anthropic/claude-sonnet-4-6`) |
| `OPENCODE_PROMPT` | No | *(fix the failing test)* | Custom prompt for OpenCode |
| `OPENCODE_TIMEOUT` | No | `300` | Max seconds for OpenCode to run |
| `ANTHROPIC_API_KEY` | No | | Only needed for `anthropic/*` models |
