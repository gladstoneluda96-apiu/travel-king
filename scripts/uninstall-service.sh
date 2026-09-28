#!/bin/bash
# 卸载 TripStar LaunchAgent 常驻服务（不会删除项目文件）

set -uo pipefail

LABEL="ai.tripdesign.local"
DOMAIN="gui/$(id -u)"
TARGET="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null && echo "🛑 服务已停止" || echo "ℹ️  服务未在运行"
launchctl disable "$DOMAIN/$LABEL" 2>/dev/null || true

if [ -f "$TARGET" ]; then
  rm -f "$TARGET"
  echo "🗑️  已移除 $TARGET"
fi
