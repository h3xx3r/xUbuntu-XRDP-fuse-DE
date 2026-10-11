#!/bin/bash
set -Eeuo pipefail

log() {
  printf '[entrypoint] %s\n' "$*"
}

trap 'rc=$?; printf "[entrypoint] FEHLER in Zeile %s: %s (Exit %s)\n" "$LINENO" "$BASH_COMMAND" "$rc" >&2' ERR

RDP_USERS="${RDP_USERS:-admin:1000:1000:1}"
RDP_MASTER_PASSWORD="${RDP_MASTER_PASSWORD:-changeme}"
RDP_GUEST_PASSWORD="${RDP_GUEST_PASSWORD:-guest}"
RDP_GUEST_PASSWORD_ENABLED="${RDP_GUEST_PASSWORD_ENABLED:-}"
RDP_PASSWORDLESS_STANDARD_USERS="${RDP_PASSWORDLESS_STANDARD_USERS:-}"
RESET_STANDARD_USERS="${RESET_STANDARD_USERS:-1}"
RDP_AUDIO_ENABLED="${RDP_AUDIO_ENABLED:-1}"
RDP_PRINTERS="${RDP_PRINTERS:-}"
PRINTER_PROFILE_REFRESH="${PRINTER_PROFILE_REFRESH:-0}"
MAX_SESSIONS="${MAX_SESSIONS:-20}"
KILL_DISCONNECTED="${KILL_DISCONNECTED:-true}"
DISCONNECTED_TIME_LIMIT="${DISCONNECTED_TIME_LIMIT:-60}"
KEEP_ADMIN_SESSIONS="${KEEP_ADMIN_SESSIONS:-1}"
IDLE_TIME_LIMIT="${IDLE_TIME_LIMIT:-0}"
SESSION_POLICY="${SESSION_POLICY:-Default}"
TZ="${TZ:-Europe/Berlin}"

log "Initialisierung startet"

# Backwards compatibility with the former RDP_PASSWORDLESS_STANDARD_USERS option.
# New option wins when explicitly set.
if [ -z "$RDP_GUEST_PASSWORD_ENABLED" ]; then
  case "$RDP_PASSWORDLESS_STANDARD_USERS" in
    0|false|FALSE|no|NO) RDP_GUEST_PASSWORD_ENABLED=1 ;;
    *) RDP_GUEST_PASSWORD_ENABLED=0 ;;
  esac
fi

case "$RDP_GUEST_PASSWORD_ENABLED" in
  0|1) ;;
  *)
    echo "Fehler: RDP_GUEST_PASSWORD_ENABLED muss 0 oder 1 sein." >&2
    exit 1
    ;;
esac

case "$KEEP_ADMIN_SESSIONS" in
  0|1) ;;
  *)
    echo "Fehler: KEEP_ADMIN_SESSIONS muss 0 oder 1 sein." >&2
    exit 1
    ;;
esac

export RDP_USERS RDP_MASTER_PASSWORD RDP_GUEST_PASSWORD RDP_GUEST_PASSWORD_ENABLED
export RESET_STANDARD_USERS RDP_AUDIO_ENABLED RDP_PRINTERS PRINTER_PROFILE_REFRESH
export MAX_SESSIONS KILL_DISCONNECTED DISCONNECTED_TIME_LIMIT KEEP_ADMIN_SESSIONS IDLE_TIME_LIMIT SESSION_POLICY TZ

if [ -e "/usr/share/zoneinfo/${TZ}" ]; then
  ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
  echo "$TZ" >/etc/timezone
fi

log "Desktop-Anwendungen werden vorbereitet"
/usr/local/sbin/install-desktop-apps
log "Desktop-Anwendungen bereit"

mkdir -p /etc/ubuntu-xrdp/user-roles /run/dbus /run/xrdp/sockdir /run/ubuntu-xrdp
chmod 1777 /run/xrdp/sockdir
printf '%s\n' "$RESET_STANDARD_USERS" >/etc/ubuntu-xrdp/reset-standard-users
printf '%s\n' "$RDP_AUDIO_ENABLED" >/etc/ubuntu-xrdp/rdp-audio-enabled
printf '%s\n' "$RDP_GUEST_PASSWORD_ENABLED" >/etc/ubuntu-xrdp/guest-password-enabled
printf '%s\n' "$KEEP_ADMIN_SESSIONS" >/etc/ubuntu-xrdp/keep-admin-sessions

# Keep the configured disconnect policy active globally for guest/standard
# sessions. The patched XRDP build overrides these values only for users whose
# role file contains "admin" and only when KEEP_ADMIN_SESSIONS=1.
log "XRDP-Konfiguration wird gesetzt"
sed -i "s/^MaxSessions=.*/MaxSessions=${MAX_SESSIONS}/" /etc/xrdp/sesman.ini
sed -i "s/^KillDisconnected=.*/KillDisconnected=${KILL_DISCONNECTED}/" /etc/xrdp/sesman.ini
sed -i "s/^DisconnectedTimeLimit=.*/DisconnectedTimeLimit=${DISCONNECTED_TIME_LIMIT}/" /etc/xrdp/sesman.ini
sed -i "s/^IdleTimeLimit=.*/IdleTimeLimit=${IDLE_TIME_LIMIT}/" /etc/xrdp/sesman.ini
sed -i "s/^Policy=.*/Policy=${SESSION_POLICY}/" /etc/xrdp/sesman.ini

IFS=';' read -ra USERS <<<"$RDP_USERS"
for SPEC in "${USERS[@]}"; do
  [ -n "$SPEC" ] || continue
  IFS=':' read -r NAME UID_NUM GID_NUM ADMIN <<<"$SPEC"

  if [ -z "$NAME" ] || ! [[ "$UID_NUM" =~ ^[0-9]+$ ]] || ! [[ "$GID_NUM" =~ ^[0-9]+$ ]] || ! [[ "$ADMIN" =~ ^[01]$ ]]; then
    echo "Fehler: Ungültiger RDP_USERS-Eintrag: ${SPEC}. Erwartet: name:uid:gid:admin" >&2
    exit 1
  fi

  HOME_DIR="/home/${NAME}"
  log "Benutzer ${NAME} (UID ${UID_NUM}, GID ${GID_NUM}) wird vorbereitet"

  # Ensure the requested primary group exists. Reuse an existing group with
  # the requested GID if present; otherwise create one named like the user.
  if getent group "$GID_NUM" >/dev/null 2>&1; then
    GROUP_NAME="$(getent group "$GID_NUM" | cut -d: -f1)"
  elif getent group "$NAME" >/dev/null 2>&1; then
    EXISTING_GROUP_GID="$(getent group "$NAME" | cut -d: -f3)"
    if [ "$EXISTING_GROUP_GID" != "$GID_NUM" ]; then
      echo "Fehler: Gruppe ${NAME} existiert bereits mit GID ${EXISTING_GROUP_GID}, erwartet wird ${GID_NUM}." >&2
      exit 1
    fi
    GROUP_NAME="$NAME"
  else
    groupadd -g "$GID_NUM" "$NAME"
    GROUP_NAME="$NAME"
  fi

  if getent passwd "$NAME" >/dev/null 2>&1; then
    CURRENT_UID="$(id -u "$NAME")"
    if [ "$CURRENT_UID" != "$UID_NUM" ]; then
      UID_OWNER="$(getent passwd "$UID_NUM" | cut -d: -f1 || true)"
      if [ -n "$UID_OWNER" ] && [ "$UID_OWNER" != "$NAME" ]; then
        echo "Fehler: UID ${UID_NUM} ist bereits durch Benutzer ${UID_OWNER} belegt; ${NAME} kann nicht angelegt werden." >&2
        exit 1
      fi
      log "UID von ${NAME} wird von ${CURRENT_UID} auf ${UID_NUM} korrigiert"
      usermod -u "$UID_NUM" "$NAME"
    fi
    usermod -g "$GROUP_NAME" -d "$HOME_DIR" -s /bin/bash "$NAME"
  else
    UID_OWNER="$(getent passwd "$UID_NUM" | cut -d: -f1 || true)"
    if [ -n "$UID_OWNER" ]; then
      echo "Fehler: Benutzer ${NAME} existiert nicht, aber UID ${UID_NUM} gehört bereits ${UID_OWNER}. Bitte RDP_USERS prüfen." >&2
      exit 1
    fi

    if [ -d "$HOME_DIR" ]; then
      useradd -u "$UID_NUM" -g "$GROUP_NAME" -M -d "$HOME_DIR" -s /bin/bash "$NAME"
    else
      useradd -u "$UID_NUM" -g "$GROUP_NAME" -m -d "$HOME_DIR" -s /bin/bash "$NAME"
    fi
  fi

  if ! getent passwd "$NAME" >/dev/null 2>&1; then
    echo "Fehler: Benutzer ${NAME} konnte nicht angelegt werden." >&2
    exit 1
  fi
  log "Systemkonto ${NAME} ist vorhanden: $(getent passwd "$NAME" | cut -d: -f1,3,4,6,7)"

  if [ "$ADMIN" = "1" ]; then
    if [ -z "$RDP_MASTER_PASSWORD" ]; then
      echo "Fehler: RDP_MASTER_PASSWORD darf für Admin-Konten nicht leer sein." >&2
      exit 1
    fi
    printf '%s:%s\n' "$NAME" "$RDP_MASTER_PASSWORD" | chpasswd
    usermod -aG sudo,lpadmin "$NAME"
    echo admin >"/etc/ubuntu-xrdp/user-roles/${NAME}"
  else
    if [ "$RDP_GUEST_PASSWORD_ENABLED" = "1" ]; then
      if [ -z "$RDP_GUEST_PASSWORD" ]; then
        echo "Fehler: RDP_GUEST_PASSWORD darf nicht leer sein, wenn das Gast-Passwort aktiviert ist." >&2
        exit 1
      fi
      printf '%s:%s\n' "$NAME" "$RDP_GUEST_PASSWORD" | chpasswd
    else
      passwd -d "$NAME" >/dev/null
    fi
    gpasswd -d "$NAME" sudo >/dev/null 2>&1 || true
    gpasswd -d "$NAME" lpadmin >/dev/null 2>&1 || true
    echo standard >"/etc/ubuntu-xrdp/user-roles/${NAME}"
  fi

  mkdir -p "$HOME_DIR" "/run/user/${UID_NUM}"

  # A recursive chown on every startup can take a very long time once Chrome,
  # ChatGPT and LibreOffice profiles contain many files. Only repair ownership
  # recursively when the mounted home itself has the wrong uid/gid.
  HOME_UID="$(stat -c '%u' "$HOME_DIR")"
  HOME_GID="$(stat -c '%g' "$HOME_DIR")"
  if [ "$HOME_UID" != "$UID_NUM" ] || [ "$HOME_GID" != "$GID_NUM" ]; then
    log "Besitz von ${HOME_DIR} wird einmalig rekursiv auf ${UID_NUM}:${GID_NUM} korrigiert"
    chown -R "$UID_NUM:$GID_NUM" "$HOME_DIR"
  else
    log "Besitz von ${HOME_DIR} stimmt; rekursives chown wird übersprungen"
  fi

  chown "$UID_NUM:$GID_NUM" "/run/user/${UID_NUM}"
  chmod 700 "/run/user/${UID_NUM}"

  log "Desktop-Profil für ${NAME} wird eingerichtet"
  if ! timeout 60s runuser -u "$NAME" -- env HOME="$HOME_DIR" USER="$NAME" /usr/local/bin/ubuntu-xrdp-user-home-setup; then
    echo "Fehler: Home-Setup für ${NAME} ist fehlgeschlagen oder hat länger als 60 Sekunden gedauert." >&2
    exit 1
  fi

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
  log "Benutzer ${NAME} bereit"
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

log "Initialisierung abgeschlossen; starte: $*"
exec "$@"
