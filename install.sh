#!/usr/bin/env bash

set -e

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
BASE_DIR="$HOME/.local/share/rofi-clip-history"
IMG_DIR="$BASE_DIR/images"
SYSTEMD_DIR="$HOME/.config/systemd/user"

INSTALL_SYSTEMD=false
INSTALL_OPENRC=false

# Parse flags
for arg in "$@"; do
    case $arg in
        --systemd)
            INSTALL_SYSTEMD=true
            shift
            ;;
        --openrc)
            INSTALL_OPENRC=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./install.sh [OPTION]"
            echo "Options:"
            echo "  --systemd    Install and enable systemd user service for background daemon"
            echo "  --openrc     Generate OpenRC init script with user permission fixes"
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
    if ! command -v systemctl &>/dev/null; then
        echo "Error: systemctl is required for systemd installation." >&2
        exit 1
    fi

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

elif [ "$INSTALL_OPENRC" = true ]; then
    CURRENT_USER=$(whoami)
    CURRENT_HOME="$HOME"

    echo "Generating OpenRC service script at $BASE_DIR/clip-daemon.openrc..."
    
    cat << EOF > "$BASE_DIR/clip-daemon.openrc"
#!/sbin/openrc-run

name="clip-daemon"
description="Custom Rofi Clipboard History Daemon"

command_user="$CURRENT_USER"
command="$BIN_DIR/clip-daemon"
command_background=true
pidfile="/run/clip-daemon-$CURRENT_USER.pid"
output_log="$BASE_DIR/daemon.log"
error_log="$BASE_DIR/daemon.err"

export DISPLAY="\${DISPLAY:-:0}"
export XAUTHORITY="\${XAUTHORITY:-$CURRENT_HOME/.Xauthority}"

start_pre() {
    checkpath -d -m 0755 -o $CURRENT_USER:$CURRENT_USER "$BASE_DIR"
    checkpath -f -m 0644 -o $CURRENT_USER:$CURRENT_USER "$BASE_DIR/daemon.log" "$BASE_DIR/daemon.err"
}

depend() {
    after display-manager
}
EOF

    chmod +x "$BASE_DIR/clip-daemon.openrc"
    
    touch "$BASE_DIR/daemon.log" "$BASE_DIR/daemon.err" 2>/dev/null || true
    chmod 0644 "$BASE_DIR/daemon.log" "$BASE_DIR/daemon.err" 2>/dev/null || true
    
    echo "OpenRC init script created successfully."
    echo ""
    echo "To activate the OpenRC service:"
    echo "  sudo cp $BASE_DIR/clip-daemon.openrc /etc/init.d/clip-daemon"
    echo "  sudo rc-update add clip-daemon default"
    echo "  sudo rc-service clip-daemon start"
else
    echo "Skipping service manager installation."
    echo "To run daemon manually: clip-daemon &"
fi

echo "Installation complete! Run 'rofi-clip' to open your clipboard manager."
