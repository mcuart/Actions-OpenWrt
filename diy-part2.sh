
#!/bin/bash
set -e

cd /workdir/openwrt

PATCH="target/linux/rockchip/patches-6.12/100-rockchip-use-system-LED-for-OpenWrt.patch"

# 1. 删除官方补丁中 ROC-RK3568-PC 的修改
python3 - "$PATCH" <<'PY'
import sys
from pathlib import Path

p = Path(sys.argv[1])
text = p.read_text()
blocks = text.split("diff --git ")

target = "arch/arm64/boot/dts/rockchip/rk3568-roc-pc.dts"

header = blocks[0]
kept = [b for b in blocks[1:] if target not in b.splitlines()[0]]

if len(kept) == len(blocks[1:]):
    print("ROC-PC patch section already removed")
else:
    p.write_text(header + "".join("diff --git " + b for b in kept))
    print("ROC-PC patch section removed")

PY

# 2. 复制自定义 DTS
DTS_SRC="$GITHUB_WORKSPACE/rk3568-roc-pc.dts"
DTS_DST="target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3568-roc-pc.dts"

mkdir -p "$(dirname "$DTS_DST")"
cp -f "$DTS_SRC" "$DTS_DST"

# 3. 检查 DTS
cmp "$DTS_SRC" "$DTS_DST"

grep -q 'power_led: power' "$DTS_DST"
grep -q 'user_led: user' "$DTS_DST"

echo "========== DTS CHECK =========="
grep 'model =' "$DTS_DST"
grep -nE 'firefly:blue:power|firefly:yellow:user' "$DTS_DST"

echo "DTS applied successfully!"
