# === Time Tracker ===
export PATH="$HOME/opt/activitywatch/activitywatch/aw-server:$PATH"
alias aw-start="~/opt/activitywatch/activitywatch/aw-server/aw-server --host localhost --port 5600 > ~/aw-server.log 2>&1 &"
alias aw-status="curl -s http://localhost:5600/api/0/info 2>/dev/null | jq -r .version 2>/dev/null || echo 未运行"
alias et-log="~/dev/tracker/scripts/log.sh"
alias et-report="~/dev/tracker/scripts/merge-report.sh"
alias et-remind="~/dev/tracker/scripts/remind-me.sh"
alias tt-check="aw-status && timew && echo 笔记: && ls ~/dev/tracker/logs/ | tail -3"
