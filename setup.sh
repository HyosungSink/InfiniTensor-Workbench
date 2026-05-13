#!/bin/bash

set -e

CODEX_DIR="$PWD/.codex"
mkdir -p "$CODEX_DIR"
chmod 700 "$CODEX_DIR" || true

cat > "$CODEX_DIR/config.toml" << 'EOF'
model_provider = "codexzh"
model = "gpt-5.2"
model_reasoning_effort = "high"
disable_response_storage = false
web_search = "live"

# 缓存优化配置
cache_size_mb = 512
cache_ttl = "30m"
smart_cache = true
cache_compression = true

[model_providers.codexzh]
name = "codexzh"
base_url = "https://api.codexzh.com/v1"
wire_api = "responses"
env_key = "OPENAI_API_KEY"

EOF

chmod 600 "$CODEX_DIR/config.toml" || true

echo "OK: Config written to $CODEX_DIR/config.toml"
echo "API Key was not written by this script."
echo "Set OPENAI_API_KEY securely in your own shell/session or secret manager before use."
