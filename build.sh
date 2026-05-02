#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZMK_DIR="${ZMK_DIR:-$HOME/workspace/keyboards/zmk}"
CONFIG_DIR="$SCRIPT_DIR"

mkdir -p "$CONFIG_DIR/zmk"

echo "Updating ZMK modules..."
docker run --rm -v "$ZMK_DIR:/workspaces/zmk" zmkfirmware/zmk-build-arm:4.1-branch bash -c "cd /workspaces/zmk && west update"

for side in left right; do
  docker run --rm \
    -v "$ZMK_DIR:/workspaces/zmk" \
    -v "$CONFIG_DIR:/workspaces/zmk-config-totem" \
    zmkfirmware/zmk-build-arm:stable \
    bash -c "cd /workspaces/zmk && west build -s app -b xiao_ble//zmk --pristine -p -- -DSHIELD='totem_$side' -DZMK_CONFIG='/workspaces/zmk-config-totem/config'"

  cp "$ZMK_DIR/build/zephyr/zmk.uf2" "$CONFIG_DIR/build/totem_${side}-xiao_ble.uf2"
done

ls "$CONFIG_DIR/zmk/"*.uf2

