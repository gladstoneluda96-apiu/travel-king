#!/bin/bash
#
# 旅游大王（Travel King）一键启动
#
# 双击本文件即可：检查依赖 → 启动后端服务（API 与前端界面同一端口）→ 自动打开浏览器
# 也可在终端里带参数使用：
#     ./启动旅游大王.command start    启动（默认）
#     ./启动旅游大王.command stop     停止
#     ./启动旅游大王.command restart  重启
#     ./启动旅游大王.command status   查看状态
#     ./启动旅游大王.command log      实时查看日志
#
# 关于「需要启动哪些服务」：
#   本项目只需要这一个常驻服务（FastAPI/uvicorn，同时提供接口与前端界面）。
#   行程生成时才用到的「高德 MCP 服务」和「小红书签名引擎（Node 脚本）」，
#   都由主服务在用到时自动拉起，不需要单独启动；数据缓存都是本地文件，
#   也没有数据库 / Redis 需要起。

set -uo pipefail

# 项目根目录：默认取脚本所在目录的上一级，可用 TRIPSTAR_HOME 覆盖
PROJECT_ROOT="${TRIPSTAR_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LABEL="ai.tripdesign.local"
DOMAIN="gui/$(id -u)"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/TripDesign/tripstar.log"
PORT="$(grep -E '^PORT=' "$PROJECT_ROOT/.env" 2>/dev/null | tail -1 | cut -d= -f2- | tr -d '"' || true)"
PORT="${PORT:-7870}"
URL="http://localhost:$PORT"

# 让脚本与 launchd 都能找到 node / uvx（小红书签名引擎与高德 MCP 依赖它们）
export PATH="$HOME/.hermes/node/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

say()  { printf "\033[1;36m%s\033[0m\n" "$1"; }
ok()   { printf "  ✅ %s\n" "$1"; }
warn() { printf "  ⚠️  %s\n" "$1"; }
bad()  { printf "  ❌ %s\n" "$1"; }

health() { curl -fsS -m 3 "$URL/health" >/dev/null 2>&1; }
service_pid() { launchctl print "$DOMAIN/$LABEL" 2>/dev/null | awk '/pid =/ {print $3; exit}'; }

print_summary() {
  echo
  say "服务地址：$URL"
  echo "     接口文档：$URL/docs"
  echo "     日志文件：$LOG"
  echo "     配置文件：$PROJECT_ROOT/.env（LLM / 高德 / 小红书凭据）"
  echo
}

ensure_requirements() {
  command -v node >/dev/null 2>&1 || warn "未找到 node：小红书景点搜索与配图会失败（可执行 brew install node）"
  command -v uvx  >/dev/null 2>&1 || warn "未找到 uvx：天气与酒店查询会失败（可执行 brew install uv）"
  [ -f "$PROJECT_ROOT/.env" ] || bad "缺少配置文件 $PROJECT_ROOT/.env，服务能启动但无法生成行程"

  if [ ! -x "$PROJECT_ROOT/backend/.venv/bin/uvicorn" ]; then
    say "首次运行：创建 Python 环境并安装后端依赖（约 1-2 分钟）"
    ( cd "$PROJECT_ROOT" && uv venv backend/.venv --python 3.10 && \
      uv pip install --python backend/.venv/bin/python -r backend/requirements.txt ) || {
      bad "后端依赖安装失败，请检查网络后重试"; return 1; }
  fi

  if [ ! -f "$PROJECT_ROOT/frontend/dist/index.html" ]; then
    say "首次运行：构建前端界面（约 30 秒）"
    ( cd "$PROJECT_ROOT/backend" && npm install --registry=https://registry.npmmirror.com >/dev/null 2>&1 )
    ( cd "$PROJECT_ROOT/frontend" && npm install --registry=https://registry.npmmirror.com && npx vite build ) || {
      bad "前端构建失败，请检查网络后重试"; return 1; }
  fi
  return 0
}

start_service() {
  ensure_requirements || return 1

  if health; then
    ok "服务已在运行"
    print_summary
    [ "${TRIPSTAR_NO_OPEN:-0}" = "1" ] || open "$URL"
    return 0
  fi

  # 端口被别的进程占着时给出明确提示，避免只看到“启动超时”
  if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    warn "端口 $PORT 已被占用，可能是上一次的进程还在退出中"
  fi

  if [ ! -f "$PLIST" ]; then
    say "首次运行：注册常驻服务（开机自启、异常自动重启）"
    bash "$PROJECT_ROOT/scripts/install-service.sh" || { bad "服务注册失败"; return 1; }
    print_summary
    [ "${TRIPSTAR_NO_OPEN:-0}" = "1" ] || open "$URL"
    return 0
  fi

  if launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
    launchctl kickstart -k "$DOMAIN/$LABEL" >/dev/null 2>&1
  else
    launchctl bootstrap "$DOMAIN" "$PLIST" >/dev/null 2>&1
  fi

  printf "  正在启动"
  for _ in $(seq 1 60); do
    if health; then
      echo
      ok "启动成功"
      print_summary
      [ "${TRIPSTAR_NO_OPEN:-0}" = "1" ] || open "$URL"
      return 0
    fi
    printf "."
    sleep 1
  done

  echo
  bad "启动超时，最近日志："
  tail -20 "$LOG" 2>/dev/null | sed 's/^/     /' || echo "     （暂无日志）"
  return 1
}

# 等待服务真正退出：uvicorn 收到信号后要等在处理的请求结束（可能数十秒）
wait_down() {
  local pid="$1" waited=0
  while [ "$waited" -lt 45 ]; do
    if ! health && { [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; }; then
      return 0
    fi
    printf "."
    sleep 1
    waited=$((waited + 1))
  done
  return 1
}

stop_service() {
  if ! health && ! launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
    ok "服务当前未运行"
    return 0
  fi

  local pid
  pid="$(service_pid)"
  printf "  正在停止"

  if launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
    launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1
  fi

  if wait_down "$pid"; then
    echo
    ok "已停止（再次双击启动脚本即可恢复运行）"
    return 0
  fi

  # 还有残留就强制结束
  if [ -n "$pid" ]; then
    kill -9 "$pid" 2>/dev/null
  fi
  if wait_down ""; then
    echo
    ok "已强制停止"
    return 0
  fi

  echo
  bad "停止失败，请手动执行：kill -9 ${pid:-<pid>}"
  return 1
}

show_status() {
  if health; then
    ok "运行中：$URL"
    launchctl print "$DOMAIN/$LABEL" 2>/dev/null | grep -E "^\s+(state|pid) =" | sed 's/^/     /'
  else
    warn "未运行（双击「启动旅游大王」即可启动）"
  fi
  echo
  echo "     最近日志："
  tail -5 "$LOG" 2>/dev/null | sed 's/^/     /' || echo "     （暂无日志）"
}

case "${1:-start}" in
  start)   start_service ;;
  stop)    stop_service ;;
  restart) stop_service && start_service ;;
  status)  show_status ;;
  log)     tail -f "$LOG" ;;
  *)       echo "用法：$0 [start|stop|restart|status|log]" ;;
esac

# 双击运行时保留窗口，方便查看结果与错误
if [ -t 0 ] && [ "$#" -eq 0 ]; then
  echo
  read -n 1 -s -r -p "按任意键关闭此窗口..."
  echo
fi
