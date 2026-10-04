#!/bin/bash
set -Eeuo pipefail

RDP_USERS="${RDP_USERS:-admin:1000:1000:1}"
RDP_MASTER_PASSWORD="${RDP_MASTER_PASSWORD:-changeme}"
RESET_STANDARD_USERS="${RESET_STANDARD_USERS:-1}"
RDP_AUDIO_ENABLED="${RDP_AUDIO_ENABLED:-1}"
RDP_PRINTERS="${RDP_PRINTERS:-}"
PRINTER_PROFILE_REFRESH="${PRINTER_PROFILE_REFRESH:-0}"
MAX_SESSIONS="${MAX_SESSIONS:-20}"
KILL_DISCONNECTED="${KILL_DISCONNECTED:-true}"
DISCONNECTED_TIME_LIMIT="${DISCONNECTED_TIME_LIMIT:-60}"
IDLE_TIME_LIMIT="${IDLE_TIME_LIMIT:-0}"
SESSION_POLICY="${SESSION_POLICY:-Default}"
TZ="${TZ:-Europe/Berlin}"

export RDP_USERS RDP_MASTER_PASSWORD RESET_STANDARD_USERS RDP_AUDIO_ENABLED RDP_PRINTERS PRINTER_PROFILE_REFRESH
export MAX_SESSIONS KILL_DISCONNECTED DISCONNECTED_TIME_LIMIT IDLE_TIME_LIMIT SESSION_POLICY TZ

if [ -e "/usr/share/zoneinfo/${TZ}" ]; then
  ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
  echo "$TZ" >/etc/timezone
fi

mkdir -p /etc/ubuntu-xrdp/user-roles /run/dbus /run/xrdp/sockdir /run/ubuntu-xrdp
chmod 1777 /run/xrdp/sockdir
printf '%s\n' "$RESET_STANDARD_USERS" >/etc/ubuntu-xrdp/reset-standard-users
printf '%s\n' "$RDP_AUDIO_ENABLED" >/etc/ubuntu-xrdp/rdp-audio-enabled

sed -i "s/^MaxSessions=.*/MaxSessions=${MAX_SESSIONS}/" /etc/xrdp/sesman.ini
sed -i "s/^KillDisconnected=.*/KillDisconnected=${KILL_DISCONNECTED}/" /etc/xrdp/sesman.ini
sed -i "s/^DisconnectedTimeLimit=.*/DisconnectedTimeLimit=${DISCONNECTED_TIME_LIMIT}/" /etc/xrdp/sesman.ini
sed -i "s/^IdleTimeLimit=.*/IdleTimeLimit=${IDLE_TIME_LIMIT}/" /etc/xrdp/sesman.ini
sed -i "s/^Policy=.*/Policy=${SESSION_POLICY}/" /etc/xrdp/sesman.ini

IFS=';' read -ra USERS <<<"$RDP_USERS"
for SPEC in "${USERS[@]}"; do
  [ -n "$SPEC" ] || continue
  IFS=':' read -r NAME UID_NUM GID_NUM ADMIN <<<"$SPEC"
  HOME_DIR="/home/${NAME}"

  if ! getent group "$GID_NUM" >/dev/null 2>&1; then groupadd -g "$GID_NUM" "$NAME"; fi
  GROUP_NAME="$(getent group "$GID_NUM" | cut -d: -f1)"

  if ! id "$NAME" >/dev/null 2>&1; then
    if [ -d "$HOME_DIR" ]; then
      useradd -u "$UID_NUM" -g "$GROUP_NAME" -M -d "$HOME_DIR" -s /bin/bash "$NAME"
    else
      useradd -u "$UID_NUM" -g "$GROUP_NAME" -m -d "$HOME_DIR" -s /bin/bash "$NAME"
    fi
  fi

  printf '%s:%s\n' "$NAME" "$RDP_MASTER_PASSWORD" | chpasswd

  if [ "$ADMIN" = "1" ]; then
    usermod -aG sudo,lpadmin "$NAME"
    echo admin >"/etc/ubuntu-xrdp/user-roles/${NAME}"
  else
    gpasswd -d "$NAME" sudo >/dev/null 2>&1 || true
    gpasswd -d "$NAME" lpadmin >/dev/null 2>&1 || true
    echo standard >"/etc/ubuntu-xrdp/user-roles/${NAME}"
  fi

  mkdir -p "$HOME_DIR" "/run/user/${UID_NUM}"
  chown -R "$UID_NUM:$GID_NUM" "$HOME_DIR"
  chown "$UID_NUM:$GID_NUM" "/run/user/${UID_NUM}"
  chmod 700 "/run/user/${UID_NUM}"

  runuser -u "$NAME" -- env HOME="$HOME_DIR" USER="$NAME" /usr/local/bin/ubuntu-xrdp-user-home-setup

  cat >"$HOME_DIR/.profile" <<'PROFILE'
export LANG=de_DE.UTF-8
export LANGUAGE=de_DE:de
export LC_MESSAGES=de_DE.UTF-8
export LC_ALL=de_DE.UTF-8
PROFILE
  cat >"$HOME_DIR/.pam_environment" <<'PAM'
LANG DEFAULT=de_DE.UTF-8
LANGUAGE DEFAULT=de_DE:de
LC_MESSAGES DEFAULT=de_DE.UTF-8
LC_ALL DEFAULT=de_DE.UTF-8
PAM
  cat >"$HOME_DIR/.xsession" <<'XSESSION'
#!/bin/bash
exec /etc/xrdp/startwm.sh
XSESSION
  chmod 755 "$HOME_DIR/.xsession"
  chown "$UID_NUM:$GID_NUM" "$HOME_DIR/.profile" "$HOME_DIR/.pam_environment" "$HOME_DIR/.xsession"
done

add_device_group() {
  local device="$1" gid group
  [ -e "$device" ] || return 0
  gid="$(stat -c '%g' "$device")"
  group="$(getent group "$gid" | cut -d: -f1 || true)"
  if [ -z "$group" ]; then group="device${gid}"; groupadd -g "$gid" "$group" 2>/dev/null || true; fi
  for SPEC in "${USERS[@]}"; do usermod -aG "$group" "${SPEC%%:*}" 2>/dev/null || true; done
}

for DEVICE in /dev/dri/card* /dev/dri/renderD* /dev/fuse; do [ -e "$DEVICE" ] && add_device_group "$DEVICE"; done
rm -f /run/dbus/pid /run/ubuntu-xrdp/printers.ready /tmp/.X*-lock 2>/dev/null || true
exec "$@"
