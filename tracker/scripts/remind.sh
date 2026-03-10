#!/bin/bash
HOUR=$(date +%H)
if [ "$HOUR" -ge 9 ] && [ "$HOUR" -lt 22 ]; then
    notify-send "⏰ 整点复盘" "过去一小时做了什么？\n运行: et-log \"进展\" \"#标签\"" \
      -u normal -t 8000 -a "TimeTracker" 2>/dev/null || true
fi
