#!/bin/bash
set -e

cd /workdir/openwrt

# 1. 替换 Rockchip 系统 LED 补丁
PATCH_SRC="$GITHUB_WORKSPACE/100-rockchip-use-system-LED-for-OpenWrt.patch"
PATCH_DST="target/linux/rockchip/patches-6.12/100-rockchip-use-system-LED-for-OpenWrt.patch"

if [ ! -f "$PATCH_SRC" ]; then
    echo "ERROR: Custom PATCH not found: $PATCH_SRC"
    exit 1
fi

mkdir -p "$(dirname "$PATCH_DST")"

cp -f "$PATCH_SRC" "$PATCH_DST"

# PATCH 文件校验
cmp "$PATCH_SRC" "$PATCH_DST"
echo "========== CHECK PATCH =========="

# 2. 复制自定义 DTS
DTS_SRC="$GITHUB_WORKSPACE/rk3568-roc-pc.dts"
DTS_DST="target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3568-roc-pc.dts"

if [ ! -f "$DTS_SRC" ]; then
    echo "ERROR: Custom DTS not found: $DTS_SRC"
    exit 1
fi

mkdir -p "$(dirname "$DTS_DST")"

cp -f "$DTS_SRC" "$DTS_DST"

# 3. DTS 文件校验
cmp "$DTS_SRC" "$DTS_DST"

echo "========== DTS CHECK =========="

grep 'model =' "$DTS_DST"

echo "DTS applied successfully!"
