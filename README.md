# rofi-clipboard

A lightweight, minimal, and fast clipboard manager for Linux/X11 powered by `rofi` and `xclip`. It supports text and full image previews while storing your clipboard history locally as plain text.

## Features

- **Image Support:** Captures screenshots/images copied to the clipboard and renders them inside Rofi using standard icon metadata.
- **Deduplication:** Automatically bumps reused text and images to the top of your history instead of duplicating entries.
- **Auto-Cleanup:** Includes a background daemon function that safely purges orphaned or unused image caches in real time.
- **Service Management:** Native support for both `systemd` user services and `OpenRC` init scripts.
- **Zero Configuration:** Entirely portable shell scripts using base POSIX utilities.

## Requirements

Ensure the following dependencies are installed via your package manager:
- `rofi` (for the graphical menu)
- `xclip` (for clipboard operations)
- `clipnotify` (to monitor clipboard events asynchronously)
- `awk`, `sed`, `sha1sum` (standard POSIX tools)

*Arch Linux example:*
```bash
sudo pacman -S rofi xclip clipnotify
```

*Alpine / Gentoo / Artix (OpenRC) example:*
```bash
sudo apk add rofi xclip clipnotify
```

## Installation

Clone the repository and make the installation script executable:

```bash
git clone [https://github.com/yourusername/rofi-clipboard.git](https://github.com/yourusername/rofi-clipboard.git)
cd rofi-clipboard
chmod +x install.sh
```

### Option A: Standard Install (Manual Startup)
Copies executables into `~/.local/bin`.
```bash
./install.sh
```
*Note: Add `clip-daemon &` to your window manager's autostart file (e.g., `.xinitrc` or `autostart.sh`).*

### Option B: Systemd User Service
Copies executables and automatically enables/starts the background `systemd` user service.
```bash
./install.sh --systemd
```

### Option C: OpenRC Service
Generates an OpenRC init script with user privilege dropping and X11 display environment fixes.
```bash
./install.sh --openrc
```

To register and start the OpenRC service:
```bash
sudo cp ~/.local/share/rofi-clip-history/clip-daemon.openrc /etc/init.d/clip-daemon
sudo rc-update add clip-daemon default
sudo rc-service clip-daemon start
```

## Usage

Bind a key combination in your window manager (e.g., `Mod + Shift + V` in dwm or i3) to run:
```bash
rofi-clip
```

## File Structure

- **Binaries:** Installed to `~/.local/bin/` (`clip-daemon`, `rofi-clip`, `clip-clean`)
- **History File:** `~/.local/share/rofi-clip-history/clipboard_history`
- **Cached Images:** `~/.local/share/rofi-clip-history/images/`
- **Daemon Logs (OpenRC):** `~/.local/share/rofi-clip-history/daemon.log`

## Troubleshooting

- **No Images showing?** Make sure your Rofi theme supports icons (`-show-icons` is included by default).
- **OpenRC log permission errors?** Run `sudo chown -R $USER:$USER ~/.local/share/rofi-clip-history` to ensure log ownership belongs to your user.
- **History isn't updating?** Verify the daemon status:
  - Systemd: `systemctl --user status clip-daemon`
  - OpenRC: `sudo rc-service clip-daemon status`
  - Manual: `pgrep clip-daemon`
