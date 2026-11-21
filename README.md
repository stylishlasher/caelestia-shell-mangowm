# stylish-dots-nextgen

Next-generation fork of **stylish-dots** for MangoWC: Waybar/fuzzel/bar-menu shell replaced with a **Quickshell**-based shell.

## What changed

- **Panel**: Quickshell `Bar.qml` (tags via `mmsg`, layout, clock, tray, volume/network/battery, notifications, power).
- **Menus/Popups**: Quickshell drop panels — launcher, settings, network/bluetooth, volume, control center, music, wallpaper picker, time/weather, clipboard, power.
- **Desktop widgets**: Quickshell bottom-layer widgets — clock/date, weather, media player. Position and visibility configurable in Settings.
- **Matugen integration**: `stylish-set-wallpaper` updates `~/.config/stylish/settings.json` with Matugen colors and writes `~/.config/stylish/matugen-colors.json`; Quickshell `Theme.qml` watches it. Matugen template also installed at `~/.config/matugen/templates/quickshell-colors.json`.
- **MangoWC integration**: `mango/scripts/autostart.sh` starts `stylish-shell`; `mango/config.conf` routes keybinds to QS panels where appropriate, with fallbacks to legacy scripts.

## Requirements

- `mangowc` / `mmsg` (MangoWC IPC)
- `quickshell` (0.3+)
- `jq`, `curl`, `python3`, `bash`
- `matugen` (optional, for wallpaper palette generation)
- `grim`, `slurp`, `wl-copy` (screenshots/clipboard)
- `cliphist`, `wl-paste` (clipboard history)
- `nmcli` / NetworkManager, `bluez` (network/bluetooth panels)
- `pipewire`, `wpctl` / PipeWire services
- `brightnessctl` (optional)
- `playerctl` / MPRIS players (optional)

## Install

```bash
git clone git@github.com:stylishlasher/stylish-dots-nextgen.git
cd stylish-dots-nextgen
# copy quickshell config
mkdir -p ~/.config/quickshell
cp -a quickshell ~/.config/quickshell/stylish
# scripts
mkdir -p ~/.local/bin
cp -a scripts/stylish-shell scripts/stylish-set-wallpaper scripts/stylish-screenshot ~/.local/bin/
chmod +x ~/.local/bin/stylish-*
# mango integration (review before overwriting)
cp -a mango ~/.config/
cp -a matugen ~/.config/
```

Or symlink for development:

```bash
ln -sfn "$PWD/quickshell" ~/.config/quickshell/stylish
```

## Usage

```bash
stylish-shell start|stop|restart|reload|status
stylish-shell toggle launcher
stylish-shell toggle settings
stylish-shell toggle power
stylish-shell toggle wallpaper
stylish-shell volume up|down|mute
stylish-shell brightness up|down

# Обновление
stylish-shell update --check   # проверить, есть ли обновления
stylish-shell update           # обновить репозиторий и установить файлы
stylish-update --check         # то же самое напрямую
stylish-update                 # обновить, установить, перезагрузить shell
```

IPC target: `qs -c stylish ipc call shell toggle <panel>`.

Panels: `launcher`, `settings`, `network`, `clipboard`, `volume`, `control`, `music`, `wallpaper`, `time`, `power`.

## Desktop widgets

Configured in Settings -> Widgets:
- Desktop clock/date
- Desktop weather
- Desktop media widget
- Widget position: top-left/top-right/bottom-left/bottom-right

## Обновление

Скрипт `scripts/stylish-update` (устанавливается как `~/.local/bin/stylish-update`) делает:

1. `git fetch` и проверяет `origin/<current-branch>`.
2. Если есть обновления — выполняет `git pull --ff-only` (только при чистом рабочем дереве).
3. Копирует `quickshell/` в `~/.config/quickshell/stylish`.
4. Устанавливает скрипты в `~/.local/bin`.
5. Обновляет шаблоны Matugen и конфиг Mango (для Mango создаётся бэкап в `~/.config/mango/.backup-stylish-update-*`).
6. Перезагружает shell (`stylish-shell reload`/`restart`), если не передан `--no-reload`.

Команды:

```bash
stylish-shell update --check
stylish-shell update
stylish-update --check
stylish-update --no-reload
stylish-update --repo /path/to/stylish-dots-nextgen
```

## Notes

- `mango/scripts/launch settings` and `launcher` prefer Quickshell panels and fall back to legacy `mango-settings`/`fuzzel`.
- `mango/scripts/power-menu` and `wallpaper-pick` also prefer Quickshell panels.
- Legacy Waybar/dock scripts remain in `mango/scripts` for reference/fallback, but autostart now starts `stylish-shell`.
- Quickshell DesktopEntries singleton wraps `Quickshell.DesktopEntries`; if your Quickshell build exposes a different API, adjust `quickshell/singletons/DesktopEntries.qml`.
