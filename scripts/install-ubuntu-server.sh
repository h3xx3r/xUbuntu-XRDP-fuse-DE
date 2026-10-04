#!/bin/bash
set -Eeuo pipefail

CHANNEL="${1:-latest}"
IMAGE="ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:${CHANNEL}"
CONTAINER_NAME="${CONTAINER_NAME:-ubuntu-xrdp}"
RDP_PORT="${RDP_PORT:-3389}"
HOME_DIR="${HOME_DIR:-/srv/ubuntu-xrdp/home}"
CONFIG_DIR="${CONFIG_DIR:-/etc/ubuntu-xrdp}"
ENV_FILE="${ENV_FILE:-${CONFIG_DIR}/ubuntu-xrdp.env}"

case "$CHANNEL" in
  latest|stable|v*) ;;
  *)
    echo "Ungültiger Kanal: $CHANNEL" >&2
    echo "Erlaubt: latest, stable oder ein Versions-Tag wie v1.0.0" >&2
    exit 1
    ;;
esac

if [ "$(id -u)" -ne 0 ]; then
  echo "Bitte als root oder mit sudo ausführen." >&2
  exit 1
fi

if [ ! -r /etc/os-release ]; then
  echo "Fehler: /etc/os-release fehlt." >&2
  exit 1
fi

. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
  echo "Dieses Script ist für Ubuntu Server vorgesehen." >&2
  exit 1
fi

install_docker() {
  apt-get update
  apt-get install -y ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  cat >/etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
}

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker ist noch nicht installiert - Installation wird durchgeführt."
  install_docker
fi

mkdir -p "$CONFIG_DIR" "$HOME_DIR"
chmod 700 "$CONFIG_DIR"

if [ ! -f "$ENV_FILE" ]; then
  cat >"$ENV_FILE" <<EOF
RDP_USERS=${RDP_USERS:-admin:1000:1000:1;guest:1001:1001:0}
RDP_MASTER_PASSWORD=${RDP_MASTER_PASSWORD:-changeme}
RDP_GUEST_PASSWORD=${RDP_GUEST_PASSWORD:-guest}
RDP_GUEST_PASSWORD_ENABLED=${RDP_GUEST_PASSWORD_ENABLED:-0}
RESET_STANDARD_USERS=${RESET_STANDARD_USERS:-1}
RDP_AUDIO_ENABLED=${RDP_AUDIO_ENABLED:-1}
RDP_PRINTERS=${RDP_PRINTERS:-}
PRINTER_PROFILE_REFRESH=${PRINTER_PROFILE_REFRESH:-0}
MAX_SESSIONS=${MAX_SESSIONS:-20}
KILL_DISCONNECTED=${KILL_DISCONNECTED:-true}
DISCONNECTED_TIME_LIMIT=${DISCONNECTED_TIME_LIMIT:-60}
IDLE_TIME_LIMIT=${IDLE_TIME_LIMIT:-0}
SESSION_POLICY=${SESSION_POLICY:-Default}
TZ=${TZ:-Europe/Berlin}
EOF
  chmod 600 "$ENV_FILE"
  echo
  echo "Konfiguration wurde angelegt: $ENV_FILE"
  echo "WICHTIG: RDP_MASTER_PASSWORD ändern, bevor der Server öffentlich erreichbar ist."
  echo
else
  chmod 600 "$ENV_FILE"
  echo "Vorhandene Konfiguration wird weiterverwendet: $ENV_FILE"
fi

modprobe fuse >/dev/null 2>&1 || true

DOCKER_ARGS=(
  run -d
  --name "$CONTAINER_NAME"
  --restart unless-stopped
  --shm-size=2g
  --cap-add=SYS_ADMIN
  -p "${RDP_PORT}:3389"
  -v "${HOME_DIR}:/home"
  --env-file "$ENV_FILE"
  --label net.unraid.docker.managed=dockerman
  --label net.unraid.docker.shell=bash
)

if [ -e /dev/fuse ]; then
  DOCKER_ARGS+=(--device /dev/fuse)
else
  echo "Warnung: /dev/fuse ist nicht vorhanden. RDP-Laufwerksumleitung wird nicht funktionieren." >&2
fi

for DEV in /dev/dri/card* /dev/dri/renderD*; do
  [ -e "$DEV" ] || continue
  DOCKER_ARGS+=(--device "$DEV")
done

echo "Lade Image: $IMAGE"
docker pull "$IMAGE"

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "Vorhandener Container wird ersetzt. Persistente Daten unter $HOME_DIR bleiben erhalten."
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

docker "${DOCKER_ARGS[@]}" "$IMAGE"

echo
echo "Ubuntu-XRDP läuft."
echo "RDP: <SERVER-IP>:${RDP_PORT}"
echo "Konfiguration: $ENV_FILE"
echo "Persistentes Home: $HOME_DIR"
echo
echo "Update: denselben Installationsbefehl später erneut mit latest/stable/vX.Y.Z ausführen."
