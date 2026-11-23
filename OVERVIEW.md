# Deploy and Host OpenChamber on Railway

OpenChamber is an open-source web workspace for the OpenCode AI coding agent. In the browser you chat with the agent, review its diffs, browse files and use a terminal, on desktop or phone. It runs OpenCode on the server, so sessions keep going after you close the tab.

## About Hosting OpenChamber

This template deploys one service, `OpenChamber`, built from a public GitHub repo. It runs OpenChamber 2.8.0 with OpenCode 2.3.2 inside, on a Railway domain with a `/health` check. One volume at `/data` keeps your workspaces, settings, sessions, provider keys and an SSH key across redeploys.

The web UI is locked with a generated password (`OPENCHAMBER_UI_PASSWORD`). The service refuses to start without one. Nothing has to be filled in on the deploy form: OpenCode's free models work without a key. To use your own model, set `LLM_API_KEY` (any OpenAI-compatible API) or connect a provider in the settings.

## Common Use Cases

* An always-on AI coding agent you can reach from any browser or your phone
* Long-running agent sessions that keep going while your laptop sleeps
* Reviewing the agent's diffs and running commands away from your workstation

## Dependencies for OpenChamber Hosting

* An LLM provider for real work: OpenAI, Anthropic, OpenRouter, GitHub Copilot or any OpenAI-compatible API (free OpenCode models work with no key)
* A git host account if you want to clone private repositories

### Deployment Dependencies

* OpenChamber: https://github.com/openchamber/openchamber (MIT, release v2.8.0)
* OpenCode: https://opencode.ai/docs
* Template repo: https://github.com/aalfath/openchamber-railway-template

### Implementation Details

After deploy:

1. Copy `OPENCHAMBER_UI_PASSWORD` from the service's Variables tab, open the Railway domain and sign in.
2. Pick a model and start a chat, or clone a repository into `/data/workspaces` from the built-in terminal.
3. For private repos over SSH, add the public key printed in the deploy logs to your git host.

Optional variables: `LLM_API_KEY`, `LLM_BASE_URL` (default `https://api.openai.com/v1`) and `LLM_MODEL` (default `gpt-5-mini`) add an OpenAI-compatible provider and make it the default model. Keys entered in the UI are stored on the volume instead.

Memory: about 0.2 GB idle and 0.4 GB while answering, so chats fit Railway's 0.5 GB Free plan. Installing dependencies or building projects in the terminal needs 1–2 GB. Anyone with the password can run commands in the container; Docker-based sandboxes are not available on Railway.

Updates: version bumps are merged to the template repo, and Railway shows you an update notice. Read the CHANGELOG, then apply it from the dashboard. Your data stays on the volume.

## Why Deploy OpenChamber on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying OpenChamber on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
