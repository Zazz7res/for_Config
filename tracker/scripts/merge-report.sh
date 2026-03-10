#!/bin/bash
TODAY=$(date +%Y-%m-%d)
REPORT=~/dev/tracker/reports/$TODAY.md
AW_BASE="http://localhost:5600/api/0"
TZ_OFFSET=$(date +%z | sed -E 's/^([+-])([0-9]{2})([0-9]{2})$/\1 \2 \3/' | awk '{sign=$1; h=$2; m=$3; print (sign=="+"?1:-1)*(h*3600+m*60)}')
NOISE='newtab|extensions|whats-new|127\.0\.0\.1|localhost'

echo "# 📊 个人时间追踪报告 - $TODAY（更新于 $(date +%H:%M)）" > "$REPORT"

# === 浏览器数据（分浏览器显示）===
echo "## Browser" >> "$REPORT"

process_bucket() {
    local BUCKET=$1
    local LABEL=$2
    echo -e "\n### $LABEL" >> "$REPORT"
    echo '```text' >> "$REPORT"
    curl -s "$AW_BASE/buckets/$BUCKET/events?limit=2000" | \
    jq -r --arg today "$TODAY" --argjson tz "$TZ_OFFSET" --arg noise "$NOISE" '
        .[]? |
        (((.timestamp[0:19] + "Z") | fromdateiso8601) + $tz | strftime("%Y-%m-%d")) as $local_date |
        select($local_date == $today) |
        (.data.url | split("/")[2] // "other") as $domain |
        select($domain | test($noise) | not) |
        {domain: $domain, duration: .duration}
    ' | jq -s -r '
        if length > 0 then
            group_by(.domain) | .[] |
            "- \(.[0].domain) : \((map(.duration) | add / 60 * 10 | round) / 10) 分钟"
        else
            "- 暂无记录"
        end
    ' | sort -t: -k2 -nr >> "$REPORT"
    echo '```' >> "$REPORT"
}

process_bucket "aw-watcher-web-chrome_hypower" "🟡 Chrome"
process_bucket "aw-watcher-web-edge_hypower"   "🔵 Edge"

echo "" >> "$REPORT"

# === 任务数据 ===
echo "## Tasks" >> "$REPORT"
echo '```text' >> "$REPORT"
timew summary :today >> "$REPORT" 2>/dev/null || echo "今日无任务记录" >> "$REPORT"
echo '```' >> "$REPORT"
echo "" >> "$REPORT"

# === 笔记 ===
echo "## Notes" >> "$REPORT"
LOG=~/dev/tracker/logs/$TODAY.md
[ -f "$LOG" ] && cat "$LOG" >> "$REPORT" || echo "今日无手动笔记" >> "$REPORT"

echo -e "\n✅ 报告生成成功: $REPORT"
