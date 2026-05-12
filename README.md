<div align="center">

<h1>🥭 My MangoWM Configs</h1>

# Video Demonstration
<video src="mangoWM.mp4" width="100%" controls autoplay muted loop>
  Your browser does not support the video tag.
</video>
</div>

---
<p>Personal dotfiles for MangoWM on Void Linux</p>

![MangoWM](https://img.shields.io/badge/WM-MangoWM-orange?style=for-the-badge&logo=wayland&logoColor=white)
![Void Linux](https://img.shields.io/badge/OS-Void_Linux-478061?style=for-the-badge&logo=linux&logoColor=white)
![Wayland](https://img.shields.io/badge/Display-Wayland-2196F3?style=for-the-badge&logo=wayland&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

</div>

---

## 📦 Contents

| Folder | Description |
|--------|-------------|
| `mango/` | MangoWM main config (animations, borders, keybinds, rules) |
| `waybar/` | Status bar (config + CSS) |
| `rofi/` | App launcher and wallpaper picker |
| `mako/` | Notifications |
| `foot/` | Terminal |
| `scripts/` | Helper scripts (screenshot, etc.) |

---

## 🖥️ Setup

| Component | Program |
|-----------|---------|
| **Compositor** | [MangoWM](https://github.com/dqrk0jeste/mango) |
| **OS** | [Void Linux](https://voidlinux.org) |
| **Display Server** | Wayland |
| **Bar** | Waybar |
| **Terminal** | Foot |
| **Launcher** | Rofi |
| **Notifications** | Mako |
| **Editor** | Micro |
| **Privilege escalation** | doas |

---

## ⚙️ Layout

MangoWM is configured with the **Scroller** layout on all tags, with a default proportion of `0.8` and support for multiple proportion presets (`0.5`, `0.8`, `1.0`).

Animations use **cubic-bezier** curves with an overshoot style (`0.22, 1.3, 0.36, 1`) for window opening and movement.

---

## ⌨️ Key Bindings

> `SUPER` = Windows key

| Keybind | Action |
|---------|--------|
| `SUPER + Return` | Open terminal (foot) |
| `SUPER + D` | Rofi launcher |
| `SUPER + Q` | Kill focused window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + \` | Toggle floating |
| `SUPER + W` | Wallpaper picker |
| `SUPER + Z` | Toggle scratchpad |
| `SUPER + 1..9` | Switch to tag |
| `SUPER + SHIFT + 1..9` | Move window to tag |
| `Print` | Screenshot (full screen) |
| `SHIFT + Print` | Screenshot (selection) |

---

## 🚀 Installation

```sh
git clone https://github.com/Knuc1klesxz/My-mangoWM-configs ~/dotfiles
cd ~/dotfiles

# Copy configs to their locations
cp mango/config.conf ~/.config/mango/
cp waybar/config.jsonc waybar/style.css ~/.config/waybar/
cp rofi/config.rasi ~/.config/rofi/
cp rofi/wallpaper-picker.sh ~/.config/rofi/
cp mako/config ~/.config/mako/
cp foot/foot.ini ~/.config/foot/
cp scripts/screenshot.sh ~/.local/bin/
chmod +x ~/.local/bin/screenshot.sh
chmod +x ~/.config/rofi/wallpaper-picker.sh
```

---

## 📝 Notes

- All paths use `$HOME` — no hardcoded usernames.
- The default wallpaper must be set manually in the `exec=swaybg` line inside `mango/config.conf`.
- Tested on Void Linux with the latest kernel.

---

<div align="center">
<sub>Built with 🥭 on Void Linux</sub>
</div>
