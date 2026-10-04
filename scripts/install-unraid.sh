#!/bin/bash
set -Eeuo pipefail

CHANNEL="${1:-latest}"
REPO="h3xx3r/xUbuntu-XRDP-fuse-DE"
IMAGE="ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:${CHANNEL}"
TEMPLATE_URL="https://raw.githubusercontent.com/${REPO}/main/unraid/my-Ubuntu-XRDP.xml"
TEMPLATE_DIR="/boot/config/plugins/dockerMan/templates-user"
TEMPLATE_FILE="${TEMPLATE_DIR}/my-Ubuntu-XRDP.xml"
TMP="${TEMPLATE_FILE}.tmp"

case "$CHANNEL" in
  latest|stable|v*) ;;
  *)
    echo "Ungültiger Kanal: $CHANNEL"
    echo "Erlaubt: latest, stable oder ein Versions-Tag wie v1.0.0"
    exit 1
    ;;
esac

if [ ! -d /boot/config/plugins/dockerMan ]; then
  echo "Dieses Script ist für Unraid vorgesehen."
  exit 1
fi

mkdir -p "$TEMPLATE_DIR"

curl -fsSL "$TEMPLATE_URL" -o "$TMP"
sed -i "s#ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:[^<]*#${IMAGE}#" "$TMP"
mv "$TMP" "$TEMPLATE_FILE"

printf '\nTemplate installiert/aktualisiert:\n  %s\n\n' "$TEMPLATE_FILE"
printf 'Image-Kanal:\n  %s\n\n' "$IMAGE"

echo "Versuche Image zu laden ..."
if docker pull "$IMAGE"; then
  echo
  echo "Image erfolgreich geladen."
else
  echo
  echo "Hinweis: Das Image ist noch nicht verfügbar oder das GHCR-Paket ist noch nicht öffentlich."
  echo "Das Template wurde trotzdem installiert."
fi

echo
echo "Weiter in Unraid:"
echo "  Docker -> Add Container -> Template -> Ubuntu-XRDP"
echo
echo "Für spätere Template-Updates denselben Befehl erneut ausführen."
echo "Docker-Image-Updates erkennt Unraid über den Repository-Tag automatisch."
