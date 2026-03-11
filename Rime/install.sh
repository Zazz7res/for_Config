#!/bin/bash
# =============================================================
# Rime + 雾凇拼音 一键安装 & 配置还原脚本
# 适用环境: Ubuntu 25.04 / Wayland / GNOME / Fcitx5
# 使用方式: 在 ~/for_Config/Rime/ 目录下执行 bash install.sh
#
# 依赖: 本脚本假设 Fcitx5 框架已安装
#       如未安装，请先运行 ../Fcitx5/install.sh
# =============================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RIME_DIR="$HOME/.local/share/fcitx5/rime"

echo "========================================"
echo " Rime + 雾凇拼音 安装 & 配置还原"
echo "========================================"

# -------------------------------------------------------
# 前置检查：Fcitx5 是否已安装
# -------------------------------------------------------
if ! command -v fcitx5 &>/dev/null; then
    echo ""
    echo "[错误] 未检测到 fcitx5，请先运行 ../Fcitx5/install.sh"
    exit 1
fi

# -------------------------------------------------------
# 第一步：安装 fcitx5-rime 及依赖
# -------------------------------------------------------
echo ""
echo "[1/5] 安装 fcitx5-rime 及依赖..."

sudo apt update -q
sudo apt install -y \
    fcitx5-rime \
    librime-bin \
    librime-plugin-lua \
    librime-plugin-charcode \
    librime-plugin-octagram

echo "    安装完成"

# -------------------------------------------------------
# 第二步：清除旧 Rime 配置（保留用户词库）
# -------------------------------------------------------
echo ""
echo "[2/5] 清除旧 Rime 配置..."

if [ -d "$RIME_DIR" ]; then
    # 备份用户词库（如果存在）
    if [ -d "$RIME_DIR/rime_ice.userdb" ]; then
        echo "    检测到用户词库，备份中..."
        cp -r "$RIME_DIR/rime_ice.userdb" /tmp/rime_ice.userdb.bak
        echo "    词库已备份到 /tmp/rime_ice.userdb.bak"
    fi
    rm -rf "$RIME_DIR"
fi

mkdir -p "$RIME_DIR"
echo "    旧配置清除完成"

# -------------------------------------------------------
# 第三步：克隆雾凇拼音（浅克隆节省空间）
# -------------------------------------------------------
echo ""
echo "[3/5] 克隆雾凇拼音配置..."

git clone --depth 1 https://github.com/iDvel/rime-ice.git "$RIME_DIR"

echo "    雾凇拼音克隆完成"

# -------------------------------------------------------
# 第四步：还原自定义文件
# -------------------------------------------------------
echo ""
echo "[4/5] 还原自定义配置..."

# 还原自定义短语
if [ -f "$SCRIPT_DIR/custom/custom_phrase.txt" ]; then
    cp "$SCRIPT_DIR/custom/custom_phrase.txt" "$RIME_DIR/custom_phrase.txt"
    echo "    自定义短语已还原"
fi

# 还原所有 .custom.yaml 补丁文件（如果有）
if ls "$SCRIPT_DIR/custom/"*.custom.yaml &>/dev/null 2>&1; then
    cp "$SCRIPT_DIR/custom/"*.custom.yaml "$RIME_DIR/"
    echo "    自定义补丁文件已还原"
fi

# 还原用户词库（如果有备份）
if [ -d /tmp/rime_ice.userdb.bak ]; then
    cp -r /tmp/rime_ice.userdb.bak "$RIME_DIR/rime_ice.userdb"
    rm -rf /tmp/rime_ice.userdb.bak
    echo "    用户词库已还原"
fi

echo "    自定义配置还原完成"

# -------------------------------------------------------
# 第五步：更新 Fcitx5 profile，确保 rime 为默认输入法
# -------------------------------------------------------
echo ""
echo "[5/5] 更新 Fcitx5 输入法配置..."

PROFILE="$HOME/.config/fcitx5/profile"

if [ -f "$PROFILE" ]; then
    # 备份原 profile
    cp "$PROFILE" "$PROFILE.bak"

    # 确保 rime 在 profile 中存在且为默认
    if ! grep -q "Name=rime" "$PROFILE"; then
        # rime 不在 profile 里，写入完整配置
        cat > "$PROFILE" << 'EOF'
[Groups/0]
# Group Name
Name=默认
# Layout
Default Layout=us
# Default Input Method
DefaultIM=rime

[Groups/0/Items/0]
# Name
Name=rime
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=keyboard-us
# Layout
Layout=

[GroupOrder]
0=默认
EOF
        echo "    已将 rime 写入 profile"
    else
        # rime 已在，确保 DefaultIM=rime
        sed -i 's/^DefaultIM=.*/DefaultIM=rime/' "$PROFILE"
        echo "    已将 DefaultIM 设为 rime"
    fi
else
    # profile 不存在，直接写入
    mkdir -p "$(dirname "$PROFILE")"
    cat > "$PROFILE" << 'EOF'
[Groups/0]
# Group Name
Name=默认
# Layout
Default Layout=us
# Default Input Method
DefaultIM=rime

[Groups/0/Items/0]
# Name
Name=rime
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=keyboard-us
# Layout
Layout=

[GroupOrder]
0=默认
EOF
    echo "    已创建 profile，rime 为默认输入法"
fi

# -------------------------------------------------------
# 触发 Rime 重新部署（编译词库）
# -------------------------------------------------------
echo ""
echo "    触发 Rime 部署（编译词库，需要约 30 秒）..."

# 停止 fcitx5
pkill fcitx5 2>/dev/null || true
sleep 2

# 启动 fcitx5（后台），触发 Rime 自动部署
fcitx5 &
FCITX_PID=$!

# 等待部署完成
echo -n "    等待部署"
for i in $(seq 1 30); do
    sleep 1
    echo -n "."
    if [ -f "$RIME_DIR/build/rime_ice.table.bin" ]; then
        echo ""
        echo "    词库编译完成！"
        break
    fi
done

# 如果超时仍未完成，给出提示
if [ ! -f "$RIME_DIR/build/rime_ice.table.bin" ]; then
    echo ""
    echo "    词库仍在编译中，首次使用时会继续编译（正常现象）"
fi

# -------------------------------------------------------
# 完成
# -------------------------------------------------------
echo ""
echo "========================================"
echo " 全部完成！"
echo ""
echo " 使用说明："
echo "   Ctrl+Space     切换中英文"
echo "   rq             输入当前日期"
echo "   nl             输入农历"
echo "   R100           大写数字：壹佰"
echo "   cC1+1          简易计算：2"
echo "   [ ]            以词定字（取首字/末字）"
echo ""
echo " 注意："
echo "   - 首次输入可能有短暂延迟（词库继续编译）"
echo "   - 浏览器中文输入依赖 Fcitx5 开机重连脚本"
echo "     确保已运行 ../Fcitx5/install.sh"
echo "========================================"
