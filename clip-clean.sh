#!/usr/bin/env bash

BASE_DIR="$HOME/.local/share/rofi-clip-history"
IMG_DIR="$BASE_DIR/images"
CLIP_FILE="$BASE_DIR/clipboard_history"

[ -d "$IMG_DIR" ] || exit 0

# Loop through stored PNGs and delete any not listed in clipboard_history
for img in "$IMG_DIR"/*.png; do
    [ -f "$img" ] || continue
    if ! grep -qF "$img" "$CLIP_FILE"; then
        rm -f "$img"
    fi
done

MAX_KB=204800
CUR_KB=$(du -sk "$IMG_DIR" 2>/dev/null | awk '{print $1}')

if [ "${CUR_KB:-0}" -gt "$MAX_KB" ]; then
    # Delete the 10 oldest image files
    find "$IMG_DIR" -type f -name "*.png" -printf '%T@ %p\n' | sort -n | head -n 10 | cut -d' ' -f2- | xargs rm -f
fi
