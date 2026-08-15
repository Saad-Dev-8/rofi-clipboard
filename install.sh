#!/usr/bin/env bash

set -e

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
BASE_DIR="$HOME/.local/share/rofi-clip-history"
IMG_DIR="$BASE_DIR/images"
SYSTEMD_DIR="$HOME/.config/systemd/user"

INSTALL_SYSTEMD=false

# Parse flags
for arg in "$@"; do
    case $arg in
        --systemd)
            INSTALL_SYSTEMD=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./install.sh [OPTION]"
            echo "Options:"
            echo "  --systemd    Install and enable systemd user service for background daemon"
            exit 0
            ;;
    esac
done

echo "Checking required dependencies..."
for cmd in xclip clipnotify rofi awk sed sha1sum; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: Required command '$cmd' is not installed." >&2
        exit 1
    fi
done

if [ "$INSTALL_SYSTEMD" = true ]; then
    if ! command -v systemctl &>/dev/null; then
        echo "Error: systemctl is required for systemd installation." >&2
        exit 1
    fi
fi

echo "Creating target directories..."
mkdir -p "$BIN_DIR" "$IMG_DIR"
[ ! -f "$BASE_DIR/clipboard_history" ] && touch "$BASE_DIR/clipboard_history"

echo "Copying scripts to $BIN_DIR..."
cp -f "$SRC_DIR/clip-daemon.sh" "$BIN_DIR/clip-daemon"
cp -f "$SRC_DIR/rofi-clip.sh" "$BIN_DIR/rofi-clip"
cp -f "$SRC_DIR/clip-clean.sh" "$BIN_DIR/clip-clean"

echo "Setting execution permissions..."
chmod +x "$BIN_DIR/clip-daemon" "$BIN_DIR/rofi-clip" "$BIN_DIR/clip-clean"

if [ "$INSTALL_SYSTEMD" = true ]; then
    echo "Creating systemd user service..."
    mkdir -p "$SYSTEMD_DIR"
    cat << EOF > "$SYSTEMD_DIR/clip-daemon.service"
[Unit]
Description=Custom Rofi Clipboard History Daemon
After=graphical-session.target

[Service]
ExecStart=$BIN_DIR/clip-daemon
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF

    echo "Enabling and starting systemd service..."
    systemctl --user daemon-reload
    systemctl --user enable --now clip-daemon.service
    echo "Systemd service installed and started."
else
    echo "Skipping systemd installation."
    echo "To run daemon manually: clip-daemon &"
fi

echo "Installation complete! Run 'rofi-clip' to open your clipboard manager."
