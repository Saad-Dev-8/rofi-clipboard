#!/usr/bin/env bash

BASE_DIR="$HOME/.local/share/rofi-clip-history"
CLIP_FILE="$BASE_DIR/clipboard_history.tsv"
IMG_DIR="$BASE_DIR/images"
CLEAN_SCRIPT="$BASE_DIR/clip-clean.sh"
MAX_ENTRIES=100

mkdir -p "$IMG_DIR"
[ ! -f "$CLIP_FILE" ] && touch "$CLIP_FILE"

LAST_CLIP=""

while clipnotify 2>/dev/null || sleep 1; do
    TARGETS=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null)
    TS=$(date +"%Y-%m-%d %H:%M:%S")

    if echo "$TARGETS" | grep -q "image/png"; then
        CHECKSUM=$(xclip -selection clipboard -t image/png -o 2>/dev/null | sha1sum | awk '{print $1}')

        if [ -n "$CHECKSUM" ] && [ "$CHECKSUM" != "$LAST_CLIP" ]; then
            LAST_CLIP="$CHECKSUM"
            IMG_PATH="$IMG_DIR/$CHECKSUM.png"

            if [ ! -f "$IMG_PATH" ]; then
                xclip -selection clipboard -t image/png -o > "$IMG_PATH" 2>/dev/null
            fi

            ENTRY="IMAGE	$TS	$IMG_PATH"

            export ENTRY MAX_ENTRIES CLIP_FILE IMG_PATH
            perl -e '
                use strict;
                use warnings;

                my $entry = $ENV{"ENTRY"};
                my $file = $ENV{"CLIP_FILE"};
                my $img = $ENV{"IMG_PATH"};
                my $max = $ENV{"MAX_ENTRIES"} || 100;

                my @lines = ();
                if (-f $file) {
                    open(my $fh, "<", $file);
                    while (<$fh>) {
                        chomp;
                        my @cols = split(/\t/, $_);
                        push @lines, $_ if ($cols[2] // "") ne $img && $_ ne "";
                    }
                    close($fh);
                }

                unshift @lines, $entry;
                splice @lines, $max if @lines > $max;

                open(my $out, ">", $file);
                print $out join("\n", @lines) . "\n";
                close($out);
            '

            [ -x "$CLEAN_SCRIPT" ] && "$CLEAN_SCRIPT" &
        fi

    else
        RAW_CLIP=$(xclip -selection clipboard -o 2>/dev/null)

        if [ -n "$RAW_CLIP" ] && [ "$RAW_CLIP" != "$LAST_CLIP" ]; then
            LAST_CLIP="$RAW_CLIP"

            CLEAN_STR=$(echo "$RAW_CLIP" | tr -d '\r')
            # Strip single trailing newline to prevent false multi-line code flags on terminal copies
            STRIPPED_STR="${CLEAN_STR%$'\n'}"

            TYPE="TEXT"
            if [[ "$STRIPPED_STR" =~ $'\n' ]]; then
                TYPE="CODE"
            elif [[ "$CLEAN_STR" =~ ^(https?|ftp|file):// ]]; then
                TYPE="URL"
            else
                # Expand ~ to $HOME for local filesystem checks
                EXP_PATH="${CLEAN_STR/#\~/$HOME}"

                if [ -d "$EXP_PATH" ]; then
                    TYPE="FOLDER"
                elif [ -f "$EXP_PATH" ]; then
                    TYPE="FILE"
                elif [[ "$CLEAN_STR" =~ ^(\$|#|\>|git|cd|ls|sudo|systemctl|chmod|mkdir|curl|wget|npm|cargo|docker|cat|grep|find|sed|awk)[[:space:]] ]]; then
                    TYPE="TERM"
                elif [[ "$CLEAN_STR" =~ ^(/|~/|\./) ]]; then
                    if [[ "$CLEAN_STR" =~ /$ ]]; then
                        TYPE="FOLDER"
                    else
                        TYPE="FILE"
                    fi
                else
                    TYPE="TEXT"
                fi
            fi

            export RAW_CLIP MAX_ENTRIES CLIP_FILE TYPE TS
            perl -e '
                use strict;
                use warnings;

                my $raw = $ENV{"RAW_CLIP"};
                my $file = $ENV{"CLIP_FILE"};
                my $type = $ENV{"TYPE"};
                my $ts = $ENV{"TS"};
                my $max = $ENV{"MAX_ENTRIES"} || 100;

                my $escaped_raw = $raw;
                $escaped_raw =~ s/\\/\\\\/g;
                $escaped_raw =~ s/\r/\\r/g;
                $escaped_raw =~ s/\n/\\n/g;

                my $entry = "$type\t$ts\t$escaped_raw";

                my @lines = ();
                if (-f $file) {
                    open(my $fh, "<", $file);
                    while (<$fh>) {
                        chomp;
                        my @cols = split(/\t/, $_);
                        push @lines, $_ if ($cols[2] // "") ne $escaped_raw && $_ ne "";
                    }
                    close($fh);
                }

                unshift @lines, $entry;
                splice @lines, $max if @lines > $max;

                open(my $out, ">", $file);
                print $out join("\n", @lines) . "\n";
                close($out);
            '

            [ -x "$CLEAN_SCRIPT" ] && "$CLEAN_SCRIPT" &
        fi
    fi
done
