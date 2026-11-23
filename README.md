[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/openchamber-1?utm_medium=integration&utm_source=button&utm_campaign=openchamber)

# OpenChamber on Railway

This repo packages [OpenChamber](https://github.com/openchamber/openchamber), a web workspace for the [OpenCode](https://opencode.ai) AI coding agent, for one-click deployment on [Railway](https://railway.com). You get chat sessions with the agent, diffs, a file browser and a terminal in your browser, behind a password.

## What it deploys

| Service | Builds from | Version |
|---|---|---|
| `OpenChamber` | this repo (`Dockerfile`) | OpenChamber `2.8.0` (npm `@openchamber/web@2.8.0`, the v2.8.0 release) and OpenCode `2.3.2` (npm `@opencode/cli@2.3.2`), locked with integrity hashes in `bun.lock`, on `oven/bun:1.4.4@sha256:1d22548f177f4ff38e0c15baa3c2c46c6c2060ba2d1bc573bb4720b407548f1d` |

Upstream publishes no Docker image, so the `Dockerfile` installs the official npm release on the same Bun base image upstream's own Dockerfile uses. It's one service with a Railway domain, a `/health` check and one volume at `/data`:

- `/data/workspaces` holds your projects. Clone repositories here; OpenCode starts in this folder.
- `/data/home` holds OpenChamber's settings, OpenCode's sessions database, provider credentials and the SSH key.

The wrapper (`start.sh`):

- refuses to start without `OPENCHAMBER_UI_PASSWORD` (at least 12 characters), so the agent is never on an open URL;
- generates an SSH key once and prints the public key in the deploy logs (add it to GitHub or GitLab for private repos);
- if `LLM_API_KEY` is set, adds an OpenAI-compatible provider called "Railway" with `LLM_BASE_URL` and `LLM_MODEL` and makes it the default model;
- runs OpenChamber in the foreground on `PORT` and exits non-zero on any stop, so Railway restarts it.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `OPENCHAMBER_UI_PASSWORD` | generated per deploy (`${{secret(32)}}`) | Password for the web UI. Copy it from the service's Variables tab |
| `PORT` | `3000` | Port OpenChamber listens on. The Railway domain points at it |
| `LLM_API_KEY` | empty (optional) | API key of any OpenAI-compatible provider (OpenAI, OpenRouter, Groq, DeepSeek...). Leave it empty to use OpenCode's free models or to connect providers in the UI |
| `LLM_BASE_URL` | `https://api.openai.com/v1` | Base URL of that provider, for example `https://openrouter.ai/api/v1` |
| `LLM_MODEL` | `gpt-5-mini` | Model ID at that provider |

Nothing has to be filled in on the deploy form. OpenCode ships a few free models that work with no key. For your own provider, either set the three `LLM_*` variables, or connect a provider in OpenChamber's settings (Anthropic, OpenAI, OpenRouter, GitHub Copilot and 300+ others); keys entered in the UI are stored on the volume.

## After deploying

1. Open the service's **Variables** tab and copy `OPENCHAMBER_UI_PASSWORD`.
2. Open the Railway domain and sign in.
3. Start a chat, or clone a repository from the built-in terminal into `/data/workspaces` and open it as a project.
4. For private repos over SSH, copy the public key from the deploy logs (or run `cat ~/.ssh/id_ed25519.pub` in the terminal) and add it to your git host.

Anyone with the password can run commands in the container through the agent and the terminal. Keep it secret. Docker-based sandboxes are not available on Railway (no Docker-in-Docker); the agent works directly in the container.

## Memory

OpenChamber and OpenCode use about 0.2 GB idle and about 0.4 GB while answering a prompt, so a chat works on Railway's Free plan (0.5 GB). OpenCode's live model-catalogue download is turned off (`OPENCODE_DISABLE_MODELS_FETCH=1`) because it alone pushes memory past 0.5 GB; the catalogue built into OpenCode is used instead. Real project work (installing dependencies, builds, language servers in the terminal) needs more: give the service 1–2 GB on a paid plan.

## Updates

Railway tells everyone who deployed this template when a new version is merged to `main`. Read [CHANGELOG.md](CHANGELOG.md), then apply the update from the Railway dashboard. Your data stays on the `/data` volume. OpenCode's self-update is turned off, and OpenChamber's in-app "Update" button doesn't change the deployed version: versions change only through this repo.

To pin other versions yourself, change the versions in `package.json`, run `bun install` to refresh `bun.lock`, and redeploy.

## Local run

```sh
docker build -t openchamber-railway .
docker run --rm -p 3000:3000 -e OPENCHAMBER_UI_PASSWORD=change-me-to-something-long -v openchamber-data:/data openchamber-railway
```

Then open http://localhost:3000.

## Licence

OpenChamber and OpenCode are MIT-licensed by their authors. This wrapper is MIT-licensed as well.
