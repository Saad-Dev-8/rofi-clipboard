#!/usr/bin/env bash

BASE_DIR="$HOME/.local/share/rofi-clip-history"
HIST_FILE="$BASE_DIR/clipboard_history"
IMG_DIR="$BASE_DIR/images"

if [ -n "$1" ]; then
    SELECTION="$1"

    # Check if selection is an image reference: [IMAGE: <hash>]
    if [[ "$SELECTION" =~ ^\[IMAGE:\ ([a-f0-9]+)\] ]]; then
        IMG_HASH="${BASH_REMATCH[1]}"
        IMG_PATH="$IMG_DIR/$IMG_HASH.png"

        if [ -f "$IMG_PATH" ]; then
            xclip -selection clipboard -target image/png -i "$IMG_PATH"
        fi
    else
        # Standard text entry - write back to clipboard and primary selection
        printf '%s' "$SELECTION" | xclip -selection clipboard
    fi
    exit 0
fi

if [ -f "$HIST_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue

        # Format image entries with Rofi icon metadata (\0icon\x1f<path>)
        if [[ "$line" =~ ^\[IMAGE:\ ([a-f0-9]+)\] ]]; then
            IMG_HASH="${BASH_REMATCH[1]}"
            IMG_PATH="$IMG_DIR/$IMG_HASH.png"
            if [ -f "$IMG_PATH" ]; then
                printf "%s\0icon\x1f%s\n" "$line" "$IMG_PATH"
                continue
            fi
        fi

        # Output standard text line
        printf "%s\n" "$line"
    done < "$HIST_FILE"
fi
