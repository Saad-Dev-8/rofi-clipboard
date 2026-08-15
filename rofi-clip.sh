#!/usr/bin/env bash

BASE_DIR="$HOME/.local/share/rofi-clip-history"
HIST_FILE="$BASE_DIR/clipboard_history"

if [ -n "$1" ]; then
    SELECTION="$1"

    # Match image entries: [IMAGE] /path/to/image.png
    if [[ "$SELECTION" =~ ^\[IMAGE\]\ (.+) ]]; then
        IMG_PATH="${BASH_REMATCH[1]}"
        if [ -f "$IMG_PATH" ]; then
            xclip -selection clipboard -target image/png -i "$IMG_PATH" >/dev/null 2>&1
        fi
    else
        printf '%b' "$SELECTION" | xclip -selection clipboard >/dev/null 2>&1
    fi
    exit 0
fi

if [ -f "$HIST_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue

        # Format image entries with Rofi icon metadata (\0icon\x1f<path>)
        if [[ "$line" =~ ^\[IMAGE\]\ (.+) ]]; then
            IMG_PATH="${BASH_REMATCH[1]}"
            if [ -f "$IMG_PATH" ]; then
                printf "%s\0icon\x1f%s\n" "$line" "$IMG_PATH"
                continue
            fi
        fi

        # Standard text entry
        printf "%s\n" "$line"
    done < "$HIST_FILE"
fi
