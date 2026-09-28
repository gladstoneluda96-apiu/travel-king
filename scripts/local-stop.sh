#!/bin/bash
# 停止 TripStar 常驻服务（保留 LaunchAgent 配置，下次开机仍会自动启动）
# 如需彻底移除，请执行 scripts/uninstall-service.sh

set -uo pipefail

LABEL="ai.tripdesign.local"
DOMAIN="gui/$(id -u)"

if launchctl print "$DOMAIN/$LABEL" > /dev/null 2>&1; then
  launchctl kill SIGTERM "$DOMAIN/$LABEL" 2>/dev/null || true
  echo "🛑 已发送停止信号（KeepAlive 会将其拉起；如需长时间停止请用 scripts/uninstall-service.sh，或 launchctl bootout $DOMAIN/$LABEL）"
else
  echo "ℹ️  服务未在运行"
fi
