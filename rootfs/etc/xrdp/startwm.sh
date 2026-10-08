#!/bin/bash
set -Eeuo pipefail

unset DBUS_SESSION_BUS_ADDRESS SESSION_MANAGER
export USER="$(id -un)"
export HOME="$(getent passwd "$USER" | cut -d: -f6)"
export LANG=de_DE.UTF-8 LANGUAGE=de_DE:de LC_MESSAGES=de_DE.UTF-8 LC_ALL=de_DE.UTF-8
export XDG_CURRENT_DESKTOP=XFCE XDG_SESSION_DESKTOP=xfce DESKTOP_SESSION=xfce
export XDG_CONFIG_DIRS=/etc/xdg XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

ROLE=admin
[ -f "/etc/ubuntu-xrdp/user-roles/${USER}" ] && ROLE="$(cat "/etc/ubuntu-xrdp/user-roles/${USER}")"
RESET=0
[ -f /etc/ubuntu-xrdp/reset-standard-users ] && RESET="$(cat /etc/ubuntu-xrdp/reset-standard-users)"

if [ "$ROLE" = standard ] && [ "$RESET" = 1 ]; then
  /usr/local/bin/reset-standard-home >"/tmp/user-reset-${USER}.log" 2>&1
else
  /usr/local/bin/ubuntu-xrdp-user-home-setup >"/tmp/user-setup-${USER}.log" 2>&1
fi

exec dbus-run-session -- bash <<'SESSION'
export LANG=de_DE.UTF-8 LANGUAGE=de_DE:de LC_MESSAGES=de_DE.UTF-8 LC_ALL=de_DE.UTF-8
export XDG_CURRENT_DESKTOP=XFCE XDG_SESSION_DESKTOP=xfce DESKTOP_SESSION=xfce
export XDG_CONFIG_DIRS=/etc/xdg XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Start PulseAudio and the XRDP sink/source before XFCE loads its panel audio
# plugin. The session initializer calls this again later as a harmless retry.
/usr/local/bin/xrdp-audio-init >/dev/null 2>&1 || true

xfce4-session &
SESSION_PID=$!
sleep 4
pgrep -u "$(id -u)" -x xfsettingsd >/dev/null || xfsettingsd >/tmp/xfsettings-${USER}.log 2>&1 &
pgrep -u "$(id -u)" -x xfwm4 >/dev/null || xfwm4 --replace --compositor=off >/tmp/xfwm-${USER}.log 2>&1 &
sleep 1
pgrep -u "$(id -u)" -x xfdesktop >/dev/null || xfdesktop --disable-wm-check >/tmp/xfdesktop-${USER}.log 2>&1 &
pgrep -u "$(id -u)" -x xfce4-panel >/dev/null || xfce4-panel --disable-wm-check >/tmp/panel-${USER}.log 2>&1 &
/usr/local/bin/ubuntu-xrdp-session-init >"/tmp/session-init-${USER}.log" 2>&1
wait "$SESSION_PID"
SESSION
