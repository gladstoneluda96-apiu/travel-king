#!/bin/bash
# 旅游大王（旅游大王）一键停止
# 等价于：启动旅游大王.command stop

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$HERE/启动旅游大王.command" stop
