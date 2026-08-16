#!/usr/bin/env bash

BASE_DIR="$HOME/.local/share/rofi-clip-history"
HIST_FILE="$BASE_DIR/clipboard_history.tsv"

# Pango Styled Icons
ICON_IMG='<span foreground="#88c0d0">󰋩</span>'
ICON_URL='<span foreground="#ebcb8b">󰌷</span>'
ICON_TERM='<span foreground="#b48ead">󰞷</span>'
ICON_FOLDER='<span foreground="#81a1c1">󰉋</span>'
ICON_FILE='<span foreground="#a3be8c">󰈔</span>'
ICON_CODE='<span foreground="#e5c07b">󰅨</span>'
ICON_TEXT='<span foreground="#d8dee9">󰈙</span>'

if [ -n "$1" ]; then
    SELECTION="$1"

    CLEAN_VAL=$(printf '%s' "$SELECTION" | sed -E 's/^<span[^>]*>([^<]*)<\/span>[[:space:]]*//')

    if [[ "$CLEAN_VAL" =~ ^(.+\.png)$ ]]; then
        IMG_PATH="${BASH_REMATCH[1]}"
        if [ -f "$IMG_PATH" ]; then
            xclip -selection clipboard -target image/png -i "$IMG_PATH" >/dev/null 2>&1
            exit 0
        fi
    fi

    RAW_TEXT=$(printf '%s' "$CLEAN_VAL" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g')
    printf '%b' "$RAW_TEXT" | xclip -selection clipboard >/dev/null 2>&1
    exit 0
fi

if [ -f "$HIST_FILE" ]; then
    awk -F'\t' \
        -v icon_img="$ICON_IMG" \
        -v icon_url="$ICON_URL" \
        -v icon_term="$ICON_TERM" \
        -v icon_folder="$ICON_FOLDER" \
        -v icon_file="$ICON_FILE" \
        -v icon_code="$ICON_CODE" \
        -v icon_text="$ICON_TEXT" '
        function pango_escape(str,   s) {
            s = str
            gsub(/&/, "\\&amp;", s)
            gsub(/</, "\\&lt;", s)
            gsub(/>/, "\\&gt;", s)
            return s
        }

        NF >= 3 {
            type = $1
            timestamp = $2
            content = $3

            if (seen[content]++) next

            esc_content = pango_escape(content)

            if (type == "IMAGE") {
                if (system("[ -f \"" content "\" ]") == 0) {
                    print icon_img "  " esc_content "\0icon\x1f" content
                } else {
                    print icon_img "  " esc_content
                }
            } else if (type == "URL") {
                print icon_url "  " esc_content
            } else if (type == "TERM") {
                print icon_term "  " esc_content
            } else if (type == "FOLDER") {
                print icon_folder "  " esc_content
            } else if (type == "FILE") {
                print icon_file "  " esc_content
            } else if (type == "CODE") {
                print icon_code "  " esc_content
            } else {
                print icon_text "  " esc_content
            }
        }
    ' "$HIST_FILE"
fi
