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

            export ENTRY MAX_ENTRIES CLIP_FILE
            perl -e '
                use strict;
                use warnings;

                my $entry = $ENV{"ENTRY"};
                my $file = $ENV{"CLIP_FILE"};
                my $max = $ENV{"MAX_ENTRIES"} || 100;

                my @lines = ();
                if (-f $file) {
                    open(my $fh, "<", $file);
                    while (<$fh>) {
                        chomp;
                        push @lines, $_ if $_ ne $entry && $_ ne "";
                    }
                    close($fh);
                }

                unshift @lines, $entry;
                splice @lines, $max if @lines > $max;

                open(my $out, ">", $file);
                print $out join("\n", @lines) . "\n";
                close($out);
            '

            # Trigger real-time orphaned image purge in background
            [ -x "$CLEAN_SCRIPT" ] && "$CLEAN_SCRIPT" &
        fi

    else
        RAW_CLIP=$(xclip -selection clipboard -o 2>/dev/null)

        if [ -n "$RAW_CLIP" ] && [ "$RAW_CLIP" != "$LAST_CLIP" ]; then
            LAST_CLIP="$RAW_CLIP"

            export RAW_CLIP MAX_ENTRIES CLIP_FILE
            perl -e '
                use strict;
                use warnings;

                my $raw = $ENV{"RAW_CLIP"};
                my $file = $ENV{"CLIP_FILE"};
                my $max = $ENV{"MAX_ENTRIES"} || 100;

                $raw =~ s/\\/\\\\/g;
                $raw =~ s/\r/\\r/g;
                $raw =~ s/\n/\\n/g;

                my @lines = ();
                if (-f $file) {
                    open(my $fh, "<", $file);
                    while (<$fh>) {
                        chomp;
                        push @lines, $_ if $_ ne $raw && $_ ne "";
                    }
                    close($fh);
                }

                unshift @lines, $raw;
                splice @lines, $max if @lines > $max;

                open(my $out, ">", $file);
                print $out join("\n", @lines) . "\n";
                close($out);
            '

            # Trigger real-time orphaned image purge in background
            [ -x "$CLEAN_SCRIPT" ] && "$CLEAN_SCRIPT" &
        fi
    fi
done
