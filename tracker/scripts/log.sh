#!/bin/bash
LOG_DIR=~/dev/tracker/logs
TODAY=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/$TODAY.md"
mkdir -p "$LOG_DIR"
[ ! -f "$LOG_FILE" ] && echo "# 📓 $TODAY" > "$LOG_FILE"
echo "- [$(date +%H:%M)] $1 ${2:-#general}" >> "$LOG_FILE"
echo "✅ 已记录: $1"
