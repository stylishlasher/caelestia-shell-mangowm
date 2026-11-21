#!/bin/sh
# MangoWC session autostart

# Обновить окружение для user-сервисов (не критично, если dbus/systemd недоступны)
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots DISPLAY XDG_SESSION_TYPE 2>/dev/null || true

# Настройки пользователя
[ -f "$HOME/.config/mango/settings.env" ] && . "$HOME/.config/mango/settings.env"

# Polkit agent (нужен для GUI-запросов прав, напр. pavucontrol/nm в некоторых сценариях)
if ! pgrep -f "polkit.*agent|polkit-kde|polkit-gnome|lxqt-policykit|xfce-polkit|mate-polkit" >/dev/null 2>&1; then
  for agent in \
    /usr/lib/polkit-kde-authentication-agent-1 \
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
    /usr/libexec/polkit-gnome-authentication-agent-1 \
    /usr/lib/xfce-polkit/xfce-polkit \
    /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 \
    /usr/lib/lxqt-policykit-agent/lxqt-policykit-agent
  do
    if [ -x "$agent" ]; then
      "$agent" >/dev/null 2>&1 &
      break
    fi
  done
  # fallback: попробуем известные имена из PATH
  if ! pgrep -f "polkit.*agent|polkit-kde|polkit-gnome|lxqt-policykit|xfce-polkit|mate-polkit" >/dev/null 2>&1; then
    for name in polkit-kde-authentication-agent-1 lxqt-policykit-agent xfce-polkit polkit-mate-authentication-agent-1; do
      if command -v "$name" >/dev/null 2>&1; then
        "$name" >/dev/null 2>&1 &
        break
      fi
    done
  fi
fi

# Обои (и Matugen, если включён)
if [ -x "$HOME/.config/mango/scripts/wallpaper" ]; then
  "$HOME/.config/mango/scripts/wallpaper" >/dev/null 2>&1 &
fi

# Уведомления (mako) — Quickshell тоже умеет уведомления, но mako оставлен как fallback
# при желании можно отключить, если используются QS notification popups.
if command -v mako >/dev/null 2>&1 && ! pgrep -x mako >/dev/null 2>&1; then
  mako >/dev/null 2>&1 &
fi

# Quickshell shell (панель, док, меню, виджеты)
if command -v stylish-shell >/dev/null 2>&1; then
  stylish-shell start >/dev/null 2>&1 &
elif [ -x "$HOME/.config/mango/scripts/../scripts/stylish-shell" ]; then
  "$HOME/.config/mango/scripts/../scripts/stylish-shell" start >/dev/null 2>&1 &
elif [ -x "$HOME/.local/bin/stylish-shell" ]; then
  "$HOME/.local/bin/stylish-shell" start >/dev/null 2>&1 &
fi

# История буфера обмена (Super+C)
if command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
  pgrep -f 'wl-paste --type text --watch cliphist store' >/dev/null 2>&1 || wl-paste --type text  --watch cliphist store >/dev/null 2>&1 &
  pgrep -f 'wl-paste --type image --watch cliphist store' >/dev/null 2>&1 || wl-paste --type image --watch cliphist store >/dev/null 2>&1 &
fi

# Ночной свет (wlsunset или gammastep)
if [ "${NIGHT_LIGHT:-0}" = "1" ]; then
  temp="${NIGHT_TEMP:-4500}"
  case "$temp" in ''|*[!0-9]*) temp=4500 ;; esac
  if command -v wlsunset >/dev/null 2>&1; then
    pkill -x wlsunset >/dev/null 2>&1 || true
    wlsunset -T 6500 -t "$temp" >/dev/null 2>&1 &
  elif command -v gammastep >/dev/null 2>&1; then
    pkill -x gammastep >/dev/null 2>&1 || true
    gammastep -O "$temp" >/dev/null 2>&1 &
  elif command -v gammastep-indicator >/dev/null 2>&1; then
    pkill -x gammastep-indicator >/dev/null 2>&1 || true
    gammastep-indicator >/dev/null 2>&1 &
  fi
fi

# Автоблокировка/сон (swayidle)
if command -v swayidle >/dev/null 2>&1; then
  lock_s="${IDLE_LOCK:-0}"
  susp_s="${IDLE_SUSPEND:-0}"
  case "$lock_s" in ''|*[!0-9]*) lock_s=0 ;; esac
  case "$susp_s" in ''|*[!0-9]*) susp_s=0 ;; esac
  if [ "$lock_s" -gt 0 ] || [ "$susp_s" -gt 0 ]; then
    pkill -x swayidle >/dev/null 2>&1 || true
    # Сбрасываем предыдущие аргументы и собираем нужные
    set -- -w
    if [ -x "$HOME/.config/mango/scripts/lock" ]; then
      set -- "$@" before-sleep "$HOME/.config/mango/scripts/lock"
    fi
    if [ "$lock_s" -gt 0 ] && [ -x "$HOME/.config/mango/scripts/lock" ]; then
      set -- "$@" timeout "$lock_s" "$HOME/.config/mango/scripts/lock"
    fi
    if [ "$susp_s" -gt 0 ]; then
      set -- "$@" timeout "$susp_s" "systemctl suspend"
    fi
    # Если остался только -w, не запускаем пустой swayidle
    if [ "$#" -gt 1 ]; then
      swayidle "$@" >/dev/null 2>&1 &
    fi
  fi
fi
