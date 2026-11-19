
#!/bin/bash
#
# OpenWrt DIY script part 2
#

set -e

cd /workdir/openwrt

PATCH_FILE="target/linux/rockchip/patches-6.12/100-rockchip-use-system-LED-for-OpenWrt.patch"

echo "========== Fix ROC-PC LED patch conflict =========="

python3 - "$PATCH_FILE" <<'PY'
import sys
from pathlib import Path

patch = Path(sys.argv[1])

start = "--- a/arch/arm64/boot/dts/rockchip/rk3568-roc-pc.dts"
end = "--- a/arch/arm64/boot/dts/rockchip/rk3568-rock-3a.dts"

content = patch.read_text()

if start not in content:
    raise SystemExit("ERROR: ROC-PC patch section not found")

if end not in content:
    raise SystemExit("ERROR: Next patch section not found")

before, remainder = content.split(start, 1)
_, after = remainder.split(end, 1)

patch.write_text(before + end + after)

print("Removed only rk3568-roc-pc patch section.")
print("Other Rockchip device patches are preserved.")
PY

echo "========== Apply Custom DTS =========="

DTS_SRC="$GITHUB_WORKSPACE/rk3568-roc-pc.dts"
DTS_DIR="target/linux/rockchip/files/arch/arm64/boot/dts/rockchip"
DTS_DST="$DTS_DIR/rk3568-roc-pc.dts"

test -f "$DTS_SRC"

mkdir -p "$DTS_DIR"

cp -f "$DTS_SRC" "$DTS_DST"

cmp -s "$DTS_SRC" "$DTS_DST"

echo "========== DTS Verification =========="

sha256sum "$DTS_SRC" "$DTS_DST"

grep -n 'model =' "$DTS_DST"
grep -n 'led-running' "$DTS_DST"

echo "Custom DTS applied successfully!"
