#!/bin/bash
MIN=${1:-30}
sleep $(( MIN * 60 )) && \
    paplay /usr/share/sounds/freedesktop/stereo/bell.oga && \
    notify-send "⏰ 提醒" "该记录进展了" &
echo "已设置 ${MIN} 分钟后提醒"
