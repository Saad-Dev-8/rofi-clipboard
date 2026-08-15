#!/usr/bin/env bash

BASE_DIR="$HOME/.local/share/rofi-clip-history"
CLIP_FILE="$BASE_DIR/clipboard_history"
IMG_DIR="$BASE_DIR/images"
CLEAN_SCRIPT="$BASE_DIR/clip-clean.sh"
MAX_ENTRIES=100

mkdir -p "$IMG_DIR"
[ ! -f "$CLIP_FILE" ] && touch "$CLIP_FILE"

LAST_CLIP=""

while clipnotify 2>/dev/null || sleep 1; do
    TARGETS=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null)

    if echo "$TARGETS" | grep -q "image/png"; then
        CHECKSUM=$(xclip -selection clipboard -t image/png -o 2>/dev/null | sha1sum | awk '{print $1}')

        if [ -n "$CHECKSUM" ] && [ "$CHECKSUM" != "$LAST_CLIP" ]; then
            LAST_CLIP="$CHECKSUM"
            IMG_PATH="$IMG_DIR/$CHECKSUM.png"

            [ ! -f "$IMG_PATH" ] && xclip -selection clipboard -t image/png -o > "$IMG_PATH" 2>/dev/null

            ENTRY="[IMAGE] $IMG_PATH"

            TMP_FILE=$(mktemp)
            {
                printf '%s\n' "$ENTRY"
                TARGET_ENTRY="$ENTRY" awk 'BEGIN{target=ENVIRON["TARGET_ENTRY"]} $0 != target' "$CLIP_FILE" 2>/dev/null || true
            } | head -n "$MAX_ENTRIES" > "$TMP_FILE" && mv "$TMP_FILE" "$CLIP_FILE"

            # Trigger real-time orphaned image purge in background
            [ -x "$CLEAN_SCRIPT" ] && "$CLEAN_SCRIPT" &
        fi

    else
        RAW_CLIP=$(xclip -selection clipboard -o 2>/dev/null)

        if [ -n "$RAW_CLIP" ] && [ "$RAW_CLIP" != "$LAST_CLIP" ]; then
            LAST_CLIP="$RAW_CLIP"

            SINGLE_LINE=$(printf '%s' "$RAW_CLIP" | sed ':a;N;$!ba;s/\\/\\\\/g; s/\n/\\n/g')

            TMP_FILE=$(mktemp)
            {
                printf '%s\n' "$SINGLE_LINE"
                TARGET_ENTRY="$SINGLE_LINE" awk 'BEGIN{target=ENVIRON["TARGET_ENTRY"]} $0 != target' "$CLIP_FILE" 2>/dev/null || true
            } | head -n "$MAX_ENTRIES" > "$TMP_FILE" && mv "$TMP_FILE" "$CLIP_FILE"

            # Trigger real-time orphaned image purge in background
            [ -x "$CLEAN_SCRIPT" ] && "$CLEAN_SCRIPT" &
        fi
    fi
done
