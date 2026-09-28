#!/bin/bash
# 将 TripStar 安装为 macOS LaunchAgent 常驻服务（开机/登录自动启动，崩溃自动拉起）
# 卸载：scripts/uninstall-service.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="ai.tripdesign.local"
TEMPLATE="$PROJECT_ROOT/scripts/$LABEL.plist"
TARGET_DIR="$HOME/Library/LaunchAgents"
TARGET="$TARGET_DIR/$LABEL.plist"
DOMAIN="gui/$(id -u)"
LOG_DIR="$HOME/Library/Logs/TripDesign"
LOG_PATH="$LOG_DIR/tripstar.log"

# 默认端口/地址，可被 .env 覆盖
HOST="0.0.0.0"
PORT="7860"
if [ -f "$PROJECT_ROOT/.env" ]; then
  ENV_HOST=$(grep -E '^HOST=' "$PROJECT_ROOT/.env" | tail -1 | cut -d= -f2- | tr -d '"' || true)
  ENV_PORT=$(grep -E '^PORT=' "$PROJECT_ROOT/.env" | tail -1 | cut -d= -f2- | tr -d '"' || true)
  [ -n "${ENV_HOST:-}" ] && HOST="$ENV_HOST"
  [ -n "${ENV_PORT:-}" ] && PORT="$ENV_PORT"
fi

# 服务运行需要 node（小红书签名引擎）与 uvx（高德 MCP），PATH 必须显式声明
SERVICE_PATH="$(dirname "$(command -v node)"):$(dirname "$(command -v uvx)"):/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

if [ ! -x "$PROJECT_ROOT/backend/.venv/bin/uvicorn" ]; then
  echo "❌ 缺少后端虚拟环境：backend/.venv"
  echo "   请先执行：uv venv backend/.venv --python 3.10 && uv pip install --python backend/.venv/bin/python -r backend/requirements.txt"
  exit 1
fi

if [ ! -f "$PROJECT_ROOT/frontend/dist/index.html" ]; then
  echo "⚠️  未找到 frontend/dist，前端页面将无法访问：cd frontend && npm install && npx vite build"
fi

echo "📦 生成 LaunchAgent 配置：$TARGET"
mkdir -p "$TARGET_DIR" "$LOG_DIR"
sed -e "s|__PROJECT_ROOT__|$PROJECT_ROOT|g" \
    -e "s|__HOST__|$HOST|g" \
    -e "s|__PORT__|$PORT|g" \
    -e "s|__PATH__|$SERVICE_PATH|g" \
    -e "s|__LOG_PATH__|$LOG_PATH|g" \
    "$TEMPLATE" > "$TARGET"

# 重新加载（已加载则先卸载）
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
launchctl bootstrap "$DOMAIN" "$TARGET"
launchctl enable "$DOMAIN/$LABEL" 2>/dev/null || true

echo "⏳ 等待服务就绪..."
for _ in $(seq 1 30); do
  if curl -sS -m 2 "http://127.0.0.1:${PORT}/health" > /dev/null 2>&1; then
    echo "✅ 部署完成：http://localhost:${PORT}"
    echo "   日志：$LOG_PATH"
    echo "   停止：scripts/local-stop.sh    启动：scripts/local-start.sh"
    exit 0
  fi
  sleep 1
done

echo "❌ 服务启动超时，最近日志："
tail -40 "$LOG_PATH" 2>/dev/null || true
launchctl print "$DOMAIN/$LABEL" 2>/dev/null | head -20 || true
exit 1
