#!/bin/bash
# 启动 / 重启 TripStar 常驻服务（LaunchAgent）
# 若尚未安装，先执行 scripts/install-service.sh

set -euo pipefail

LABEL="ai.tripdesign.local"
DOMAIN="gui/$(id -u)"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="$(grep -E '^PORT=' "$PROJECT_ROOT/.env" 2>/dev/null | tail -1 | cut -d= -f2- | tr -d '"' || true)"
PORT="${PORT:-7860}"
LOG_PATH="$HOME/Library/Logs/TripDesign/tripstar.log"

if ! launchctl print "$DOMAIN/$LABEL" > /dev/null 2>&1; then
  echo "ℹ️  服务未安装，正在执行 scripts/install-service.sh ..."
  exec bash "$PROJECT_ROOT/scripts/install-service.sh"
fi

launchctl kickstart -k "$DOMAIN/$LABEL"

for _ in $(seq 1 30); do
  if curl -sS -m 2 "http://127.0.0.1:${PORT}/health" > /dev/null 2>&1; then
    echo "✅ 已启动：http://localhost:${PORT}"
    exit 0
  fi
  sleep 1
done

echo "❌ 启动超时，日志：$LOG_PATH"
exit 1
