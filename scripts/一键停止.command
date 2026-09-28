#!/bin/bash
# 旅途星辰（TripDesign）一键停止
# 等价于：启动旅途星辰.command stop

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$HERE/启动旅途星辰.command" stop
