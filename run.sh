#!/usr/bin/env bash

set -e

if [ ! -x "./node_modules/.bin/codex" ]; then
  echo "ERROR: ./node_modules/.bin/codex not found or not executable."
  echo "Run this script from the directory where you installed @openai/codex."
  exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  printf "OPENAI_API_KEY: "
  read -s OPENAI_API_KEY
  printf "\n"
  export OPENAI_API_KEY
fi

export CODEX_HOME="$PWD/.codex"

exec ./node_modules/.bin/codex "$@"
