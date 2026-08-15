# rofi-clipboard

A lightweight, minimal, and fast clipboard manager for Linux/X11 powered by `rofi` and `xclip`. It supports text and full image previews while storing your clipboard history locally as plain text.

## Features

- **Rofi Custom Mode (`modi`):** Native integration directly into Rofi menus alongside `drun` and `window`.
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

*Arch / Artix:*
```bash
sudo pacman -Syu rofi xclip clipnotify
```

*Gentoo:*
```bash
sudo emerge --ask x11-misc/rofi x11-misc/xclip x11-misc/clipnotify
```

## Installation

Clone the repository and make the installation script executable:

```bash
git clone https://github.com/Saad-Dev-8/rofi-clipboard.git
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

## Rofi Integration

Add `rofi-clip` as a custom script mode in `~/.config/rofi/config.rasi`:

```rasi
configuration {
    modi: "drun,run,window,clipboard:/home/yourusername/.local/bin/rofi-clip";
}
```

Now you can open the clipboard directly via command line:
```bash
rofi -show clipboard
```

## Window Manager Configuration (dwm)

To bind `Mod + Ctrl + W` to open the clipboard manager in dwm:

1. Update `config.h` in your dwm directory:

```c
static const char *clipcmd[] = { "rofi", "-show", "clipboard", NULL };

static const Key keys[] = {
    /* modifier                     key        function        argument */
    { MODKEY|ControlMask,           XK_w,      spawn,          {.v = clipcmd } },
};
```

2. Recompile and install dwm:

```bash
sudo make clean install
```

## File Structure

- **Binaries:** Installed to `~/.local/bin/` (`clip-daemon`, `rofi-clip`, `clip-clean`)
- **History File:** `~/.local/share/rofi-clip-history/clipboard_history`
- **Cached Images:** `~/.local/share/rofi-clip-history/images/`
- **Daemon Logs (OpenRC):** `~/.local/share/rofi-clip-history/daemon.log`

## Troubleshooting

- **No Images showing?** Make sure your Rofi theme supports icons (`-show-icons` is included by default).
- **OpenRC log permission errors?** Run `sudo chown -R $USER:$USER ~/.local/share/rofi-clip-history` to ensure log ownership belongs to your user.
- **Keybinding doesn't trigger?** Try to specify the full path (`/usr/bin/rofi`) in dwm's `config.h` or i3 if `~/.local/bin` is not in dwm's or i3's `$PATH`.

## Star History

<a href="https://www.star-history.com/?repos=Saad-Dev-8%2Frofi-clipboard&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=Saad-Dev-8/rofi-clipboard&type=date&theme=dark&legend=top-left&sealed_token=u-WQEueqDO02uOKAar7rcQZ1q64BFM43eE4GmLmpNBbF1g60IwgwXltVrtj9lgCSCjdnMSKDnA8DB5PbeQ-xu6XGVdee36DwpjPrhz_SdQbCHEFIvH7bAg" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=Saad-Dev-8/rofi-clipboard&type=date&legend=top-left&sealed_token=u-WQEueqDO02uOKAar7rcQZ1q64BFM43eE4GmLmpNBbF1g60IwgwXltVrtj9lgCSCjdnMSKDnA8DB5PbeQ-xu6XGVdee36DwpjPrhz_SdQbCHEFIvH7bAg" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=Saad-Dev-8/rofi-clipboard&type=date&legend=top-left&sealed_token=u-WQEueqDO02uOKAar7rcQZ1q64BFM43eE4GmLmpNBbF1g60IwgwXltVrtj9lgCSCjdnMSKDnA8DB5PbeQ-xu6XGVdee36DwpjPrhz_SdQbCHEFIvH7bAg" />
 </picture>
</a>
