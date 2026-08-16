#!/usr/bin/env bash

BASE_DIR="$HOME/.local/share/rofi-clip-history"
CLIP_FILE="$BASE_DIR/clipboard_history"
IMG_DIR="$BASE_DIR/images"
THUMB_DIR="$BASE_DIR/thumbs"

[ ! -f "$CLIP_FILE" ] && exit 0

# Clean full images
for img in "$IMG_DIR"/*.png; do
    [ -f "$img" ] || continue
    if ! grep -qF "$img" "$CLIP_FILE"; then
        rm -f "$img"
    fi
done

# Clean thumbnails
for thumb in "$THUMB_DIR"/*.png; do
    [ -f "$thumb" ] || continue
    filename=$(basename "$thumb")
    if ! grep -qF "$filename" "$CLIP_FILE"; then
        rm -f "$thumb"
    fi
done
