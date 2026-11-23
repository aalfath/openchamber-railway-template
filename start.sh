#!/bin/sh
# Start OpenChamber in the foreground on $PORT with password protection.
# Exits non-zero on any unrequested stop, so Railway's ON_FAILURE restart policy restarts it.
set -eu

: "${PORT:=3000}"
export HOME="${HOME:-/data/home}"
export OPENCHAMBER_OPENCODE_CWD="${OPENCHAMBER_OPENCODE_CWD:-/data/workspaces}"

pw="${OPENCHAMBER_UI_PASSWORD:-}"
if [ "${#pw}" -lt 12 ]; then
  echo "[railway] OPENCHAMBER_UI_PASSWORD must be set (at least 12 characters). Refusing to start an open agent." >&2
  exit 1
fi

mkdir -p "$HOME/.config/opencode" "$HOME/.local/share" "$HOME/.ssh" "$OPENCHAMBER_OPENCODE_CWD"
chmod 700 "$HOME/.ssh"

# One SSH key per deploy, kept on the volume. Add the public key to your git host for private repos.
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  ssh-keygen -q -t ed25519 -N "" -C "openchamber-railway" -f "$HOME/.ssh/id_ed25519"
fi
echo "[railway] SSH public key: $(cat "$HOME/.ssh/id_ed25519.pub")"

# Optional: an OpenAI-compatible provider from variables (any OpenAI-compatible API:
# OpenAI, OpenRouter, Groq, DeepSeek, a local gateway...). Written on every start so a
# changed variable takes effect after a redeploy. Providers added in the UI are kept separately.
PROVIDER_FILE="$HOME/.config/opencode/railway-provider.json"
if [ -n "${LLM_API_KEY:-}" ]; then
  : "${LLM_BASE_URL:=https://api.openai.com/v1}"
  : "${LLM_MODEL:=gpt-5-mini}"
  jq -n --arg url "$LLM_BASE_URL" --arg model "$LLM_MODEL" '{
    "$schema": "https://opencode.ai/config.json",
    provider: { railway: {
      npm: "@ai-sdk/openai-compatible",
      name: "Railway (LLM_* variables)",
      options: { baseURL: $url, apiKey: "{env:LLM_API_KEY}" },
      models: { ($model): { name: $model } }
    } },
    model: ("railway/" + $model)
  }' > "$PROVIDER_FILE"
  export OPENCODE_CONFIG="$PROVIDER_FILE"
  echo "[railway] LLM provider from variables: $LLM_BASE_URL, model $LLM_MODEL"
else
  rm -f "$PROVIDER_FILE"
fi

cd "$OPENCHAMBER_OPENCODE_CWD"
echo "[railway] starting OpenChamber $(jq -r .version /app/node_modules/@openchamber/web/package.json) on port $PORT"
set +e
bun /app/node_modules/@openchamber/web/bin/cli.js serve --foreground --port "$PORT" --host 0.0.0.0
code=$?
echo "[railway] OpenChamber exited with code $code" >&2
[ "$code" -eq 0 ] && code=1
exit "$code"
