#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -w /etc/apt/sources.list.d ]; then
    APT_TARGET=/etc/apt/sources.list.d/ubuntu.sources
    if [ -f "$APT_TARGET" ]; then
        cp "$APT_TARGET" "$APT_TARGET.bak.$(date +%Y%m%d-%H%M%S)"
    fi
    cp "$ROOT_DIR/config/apt/ubuntu.sources.aliyun" "$APT_TARGET"
    apt-get update
else
    echo "WARN: cannot write apt sources; run as root to install config/apt/ubuntu.sources.aliyun"
fi

git config --global url.https://github.insteadOf git://github
git config --global url.https://gitee.com/xmake-mirror/.insteadOf https://github.com/xmake-mirror/
git config --global url.https://gitee.com/tboox/xmake-repo.git.insteadOf https://github.com/xmake-io/xmake-repo.git

mkdir -p "$HOME/.config/pip"
cp "$ROOT_DIR/config/pip/pip.conf.china-example" "$HOME/.config/pip/pip.conf"

echo "OK: configured Aliyun apt, xmake Git mirrors, and Tsinghua pip mirror."
