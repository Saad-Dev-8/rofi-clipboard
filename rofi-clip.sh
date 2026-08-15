#!/usr/bin/env bash

BASE_DIR="$HOME/.local/share/rofi-clip-history"
CLIP_FILE="$BASE_DIR/clipboard_history"

[ ! -f "$CLIP_FILE" ] && touch "$CLIP_FILE"

# Display entries in Rofi with icon preview support
SELECTED=$(rofi -dmenu -i -show-icons -p "Clipboard:" < <(awk '
/^\[IMAGE\] / {
    img = substr($0, 9)
    printf "%s\0icon\x1f%s\n", $0, img
    next
}
{ print }
' "$CLIP_FILE"))

if [ -n "$SELECTED" ]; then
    if [[ "$SELECTED" == "[IMAGE]"* ]]; then
        IMG_PATH="${SELECTED#\[IMAGE\] }"

        if [ -f "$IMG_PATH" ]; then
            xclip -selection clipboard -t image/png -i "$IMG_PATH"
            xclip -selection primary -t image/png -i "$IMG_PATH" 2>/dev/null || true
        fi
    else
        DECODED=$(printf '%b' "$SELECTED")
        printf '%s' "$DECODED" | xclip -selection clipboard
        printf '%s' "$DECODED" | xclip -selection primary
    fi
    # clip-daemon.sh automatically detects the xclip change and reorders history
fi
