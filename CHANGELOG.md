# Changelog

## 2.8.0 (2026-11-23)

First release of the Railway template (published as `openchamber-1`). The README has the Deploy on Railway button.

- OpenChamber 2.8.0 (`@openchamber/web@2.8.0`) and OpenCode 2.3.2 (`@opencode/cli@2.3.2`), locked in `bun.lock`, on `oven/bun:1.4.4` pinned by digest.
- One volume at `/data` for workspaces, settings, sessions, credentials and the SSH key.
- Generated UI password; the service refuses to start without one.
- Optional OpenAI-compatible provider from `LLM_API_KEY`, `LLM_BASE_URL` and `LLM_MODEL`.
- `OPENCODE_DISABLE_MODELS_FETCH=1` so the first prompt fits in 0.5 GB RAM.
