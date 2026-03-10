#!/bin/bash
# =============================================================
# Fcitx5 一键安装 & 配置还原脚本
# 适用环境: Ubuntu 25.04 / Wayland / GNOME
# 使用方式: 在 ~/for_Config/Fcitx5/ 目录下执行 bash install.sh
# =============================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo " Fcitx5 安装 & 配置还原"
echo "========================================"

# -------------------------------------------------------
# 第一步：卸载清空旧的 fcitx5（全新安装时确保干净）
# -------------------------------------------------------
echo ""
echo "[1/6] 卸载并清除旧的 fcitx5..."

sudo apt remove --purge -y fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 fcitx5-frontend-qt5 fcitx5-config-qt 2>/dev/null || true

# 清除残留配置和数据
rm -rf ~/.config/fcitx5
rm -rf ~/.local/share/fcitx5
rm -f ~/.config/autostart/org.fcitx.Fcitx5.desktop

echo "    旧配置清除完成"

# -------------------------------------------------------
# 第二步：安装 fcitx5 及中文输入法组件
# -------------------------------------------------------
echo ""
echo "[2/6] 安装 fcitx5..."

sudo apt update -q
sudo apt install -y \
    fcitx5 \
    fcitx5-chinese-addons \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-frontend-qt5 \
    fcitx5-config-qt

echo "    安装完成"

# -------------------------------------------------------
# 第三步：还原配置文件
# -------------------------------------------------------
echo ""
echo "[3/6] 还原 fcitx5 配置..."

mkdir -p ~/.config/fcitx5/conf

cp "$SCRIPT_DIR/config"        ~/.config/fcitx5/config
cp "$SCRIPT_DIR/profile"       ~/.config/fcitx5/profile
cp "$SCRIPT_DIR/conf/"*.conf   ~/.config/fcitx5/conf/

echo "    配置文件还原完成"

# -------------------------------------------------------
# 第四步：还原开机自启脚本 & autostart 条目
# -------------------------------------------------------
echo ""
echo "[4/6] 配置开机自启（Wayland 浏览器中文输入修复）..."

mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/bin/fcitx5-restart-delay.sh" ~/.local/bin/fcitx5-restart-delay.sh
chmod +x ~/.local/bin/fcitx5-restart-delay.sh

mkdir -p ~/.config/autostart
cp "$SCRIPT_DIR/autostart/fcitx5-restart.desktop" ~/.config/autostart/fcitx5-restart.desktop

echo "    开机自启配置完成"

# -------------------------------------------------------
# 第五步：配置环境变量
# -------------------------------------------------------
echo ""
echo "[5/6] 配置环境变量..."

# 系统级：/etc/environment 只保留 XMODIFIERS
CURRENT_ENV=$(cat /etc/environment)
if echo "$CURRENT_ENV" | grep -q "GTK_IM_MODULE"; then
    echo "    检测到旧的 X11 输入法变量，正在清理 /etc/environment..."
    sudo cp /etc/environment /etc/environment.bak
    sudo tee /etc/environment > /dev/null << 'EOF'
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
XMODIFIERS=@im=fcitx
EOF
    echo "    /etc/environment 已清理（备份在 /etc/environment.bak）"
fi

# 用户级：~/.config/environment.d/fcitx5.conf
mkdir -p ~/.config/environment.d
cp "$SCRIPT_DIR/environment.d/fcitx5.conf" ~/.config/environment.d/fcitx5.conf

echo "    环境变量配置完成"

# -------------------------------------------------------
# 第六步：设置 fcitx5 为默认输入法框架
# -------------------------------------------------------
echo ""
echo "[6/6] 设置默认输入法框架..."

# im-config 方式（如果可用）
if command -v im-config &>/dev/null; then
    im-config -n fcitx5
    echo "    已通过 im-config 设置"
else
    echo "    im-config 不可用，跳过（environment.d 配置已足够）"
fi

# -------------------------------------------------------
# 完成
# -------------------------------------------------------
echo ""
echo "========================================"
echo " 全部完成！请重启系统生效。"
echo ""
echo " 重启后验证："
echo "   1. 打开浏览器，等待 5 秒"
echo "   2. 点击输入框，按 Ctrl+Space 切换中文"
echo "   3. 输入拼音测试"
echo "========================================"
