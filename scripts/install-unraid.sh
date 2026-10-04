#!/bin/bash
set -Eeuo pipefail

TEMPLATE_URL="https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/unraid/my-Ubuntu-XRDP.xml"
TEMPLATE_DIR="/boot/config/plugins/dockerMan/templates-user"
IMAGE="ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:stable"

[ -d /boot/config/plugins/dockerMan ] || { echo "This installer is intended for Unraid."; exit 1; }
mkdir -p "$TEMPLATE_DIR"
curl -fL "$TEMPLATE_URL" -o "$TEMPLATE_DIR/my-Ubuntu-XRDP.xml"
docker pull "$IMAGE"
echo
echo "Installed Unraid template and pulled $IMAGE"
echo "Open Unraid -> Docker -> Add Container and select Ubuntu-XRDP."
