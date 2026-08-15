# rofi-clipboard

A lightweight, minimal, and fast clipboard manager for Linux/X11 powered by `rofi` and `xclip`. It supports text and full image previews while storing your clipboard history locally as plain text.

## Features

- **Image Support:** Captures screenshots/images copied to the clipboard and renders them inside Rofi using standard icon metadata.
- **Deduplication:** Automatically bumps reused text and images to the top of your history instead of duplicating entries.
- **Auto-Cleanup:** Includes a background daemon function that safely purges orphaned or unused image caches in real time.
- **Crash Recovery:** Optional `systemd` service integration guarantees the monitoring daemon restarts instantly if it crashes.
- **Zero Configuration:** Entirely portable shell scripts using base utilities.

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

## Installation

Clone the repository and run the installation script:

```bash
git clone [https://github.com/yourusername/rofi-clipboard.git](https://github.com/yourusername/rofi-clipboard.git)
cd rofi-clipboard
chmod +x install.sh
```

**Standard Install (Manual Daemon):**
Copies the executables into `~/.local/bin`.
```bash
./install.sh
```
*Note: You will need to add `clip-daemon &` to your window manager's autostart file (e.g., `.xinitrc` or `autostart.sh`).*

**Systemd Install (Recommended):**
Copies the executables and automatically enables a background `systemd` user service to manage the daemon.
```bash
./install.sh --systemd
```

## Usage

Bind a hotkey in your window manager (e.g., `Mod + Shift + V` in dwm or i3) to execute:
```bash
rofi-clip
```

## File Structure

- **Binaries:** Installed to `~/.local/bin/`
- **History File:** `~/.local/share/rofi-clip-history/clipboard_history`
- **Cached Images:** `~/.local/share/rofi-clip-history/images/`

## Troubleshooting

- **No Images showing?** Make sure you are using a version of Rofi compiled with image support, and that your Rofi theme allows for icons (`-show-icons` is passed by default).
- **History isn't updating?** Ensure the `clip-daemon` is actually running by checking `systemctl --user status clip-daemon` or running `pgrep clip-daemon`.
