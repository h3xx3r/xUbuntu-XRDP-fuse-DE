#!/bin/bash
set -Eeuo pipefail

CHANNEL="${1:-latest}"
VMID="${VMID:-$(pvesh get /cluster/nextid 2>/dev/null || echo 9000)}"
VM_NAME="${VM_NAME:-ubuntu-xrdp}"
STORAGE="${STORAGE:-local-lvm}"
SNIPPET_STORAGE="${SNIPPET_STORAGE:-local}"
BRIDGE="${BRIDGE:-vmbr0}"
CORES="${CORES:-4}"
MEMORY="${MEMORY:-4096}"
DISK_SIZE="${DISK_SIZE:-32G}"
RDP_PORT="${RDP_PORT:-3389}"
RDP_USERS="${RDP_USERS:-admin:1000:1000:1;guest:1001:1001:0}"
RDP_MASTER_PASSWORD="${RDP_MASTER_PASSWORD:-$(openssl rand -hex 16)}"
RDP_GUEST_PASSWORD="${RDP_GUEST_PASSWORD:-guest}"
RDP_GUEST_PASSWORD_ENABLED="${RDP_GUEST_PASSWORD_ENABLED:-0}"
RESET_STANDARD_USERS="${RESET_STANDARD_USERS:-1}"
RDP_AUDIO_ENABLED="${RDP_AUDIO_ENABLED:-1}"
TZ="${TZ:-Europe/Berlin}"
IMAGE_URL="https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
IMAGE_FILE="/var/lib/vz/template/iso/ubuntu-24.04-server-cloudimg-amd64.img"
SNIPPET_NAME="ubuntu-xrdp-${VMID}.yaml"
INSTALL_URL="https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh"

case "$CHANNEL" in
  latest|stable|v*) ;;
  *) echo "Ungültiger Kanal: $CHANNEL" >&2; exit 1 ;;
esac

if [ "$(id -u)" -ne 0 ]; then
  echo "Bitte auf dem Proxmox-Host als root ausführen." >&2
  exit 1
fi

if ! command -v qm >/dev/null 2>&1 || ! command -v pvesm >/dev/null 2>&1; then
  echo "Dieses Script muss auf einem Proxmox VE Host ausgeführt werden." >&2
  exit 1
fi

if qm status "$VMID" >/dev/null 2>&1; then
  echo "VMID $VMID existiert bereits. Bitte VMID anders wählen." >&2
  exit 1
fi

if ! pvesm status --storage "$STORAGE" >/dev/null 2>&1; then
  echo "Storage '$STORAGE' wurde nicht gefunden." >&2
  exit 1
fi

SNIPPET_PATH="$(pvesm path "${SNIPPET_STORAGE}:snippets/${SNIPPET_NAME}" 2>/dev/null || true)"
if [ -z "$SNIPPET_PATH" ]; then
  echo "Storage '$SNIPPET_STORAGE' unterstützt keine Snippets." >&2
  echo "Aktiviere für einen Directory-Storage den Inhaltstyp 'Snippets' und starte das Script erneut." >&2
  exit 1
fi

mkdir -p "$(dirname "$IMAGE_FILE")" "$(dirname "$SNIPPET_PATH")"

if [ ! -s "$IMAGE_FILE" ]; then
  echo "Lade offizielles Ubuntu 24.04 Cloud-Image ..."
  curl -fL "$IMAGE_URL" -o "$IMAGE_FILE"
else
  echo "Vorhandenes Ubuntu Cloud-Image wird verwendet: $IMAGE_FILE"
fi

ENV_CONTENT="$(cat <<EOF
RDP_USERS=${RDP_USERS}
RDP_MASTER_PASSWORD=${RDP_MASTER_PASSWORD}
RDP_GUEST_PASSWORD=${RDP_GUEST_PASSWORD}
RDP_GUEST_PASSWORD_ENABLED=${RDP_GUEST_PASSWORD_ENABLED}
RESET_STANDARD_USERS=${RESET_STANDARD_USERS}
RDP_AUDIO_ENABLED=${RDP_AUDIO_ENABLED}
RDP_PRINTERS=
PRINTER_PROFILE_REFRESH=0
MAX_SESSIONS=20
KILL_DISCONNECTED=true
DISCONNECTED_TIME_LIMIT=60
IDLE_TIME_LIMIT=0
SESSION_POLICY=Default
TZ=${TZ}
EOF
)"
ENV_B64="$(printf '%s\n' "$ENV_CONTENT" | base64 -w0)"

cat >"$SNIPPET_PATH" <<EOF
#cloud-config
package_update: true
packages:
  - qemu-guest-agent
  - curl
write_files:
  - path: /etc/ubuntu-xrdp/ubuntu-xrdp.env
    owner: root:root
    permissions: '0600'
    encoding: b64
    content: ${ENV_B64}
runcmd:
  - [ systemctl, enable, --now, qemu-guest-agent ]
  - [ mkdir, -p, /srv/ubuntu-xrdp/home ]
  - [ curl, -fsSL, ${INSTALL_URL}, -o, /root/install-ubuntu-xrdp.sh ]
  - [ chmod, '0755', /root/install-ubuntu-xrdp.sh ]
  - [ bash, -lc, 'RDP_PORT=${RDP_PORT} HOME_DIR=/srv/ubuntu-xrdp/home ENV_FILE=/etc/ubuntu-xrdp/ubuntu-xrdp.env /root/install-ubuntu-xrdp.sh ${CHANNEL}' ]
EOF
chmod 600 "$SNIPPET_PATH"

qm create "$VMID" \
  --name "$VM_NAME" \
  --memory "$MEMORY" \
  --cores "$CORES" \
  --cpu x86-64-v2-AES \
  --net0 "virtio,bridge=${BRIDGE}" \
  --agent enabled=1 \
  --onboot 1

qm disk import "$VMID" "$IMAGE_FILE" "$STORAGE"
IMPORTED_DISK="$(qm config "$VMID" | awk -F': ' '/^unused0:/ {print $2; exit}')"
if [ -z "$IMPORTED_DISK" ]; then
  echo "Importiertes Disk-Volume konnte nicht ermittelt werden." >&2
  exit 1
fi

qm set "$VMID" --scsihw virtio-scsi-pci --scsi0 "$IMPORTED_DISK"
qm set "$VMID" --ide2 "${STORAGE}:cloudinit"
qm set "$VMID" --boot order=scsi0
qm set "$VMID" --serial0 socket --vga serial0
qm set "$VMID" --ipconfig0 ip=dhcp
qm set "$VMID" --ciuser ubuntu
qm set "$VMID" --cicustom "user=${SNIPPET_STORAGE}:snippets/${SNIPPET_NAME}"
qm resize "$VMID" scsi0 "$DISK_SIZE"

if [ -s /root/.ssh/authorized_keys ]; then
  qm set "$VMID" --sshkeys /root/.ssh/authorized_keys
fi

qm start "$VMID"

echo
echo "Proxmox-VM wurde erstellt und gestartet."
echo "VMID: $VMID"
echo "Name: $VM_NAME"
echo "RDP-Port in der VM: $RDP_PORT"
echo "Admin-Benutzer laut RDP_USERS: ${RDP_USERS%%;*}"
echo "Admin Master-Passwort: $RDP_MASTER_PASSWORD"
if [ "$RDP_GUEST_PASSWORD_ENABLED" = "1" ]; then
  echo "Gast-Passwort: $RDP_GUEST_PASSWORD"
else
  echo "Gast-Passwort: deaktiviert (Gastkonten ohne Passwort)"
fi
echo
echo "Cloud-Init installiert Docker und Ubuntu-XRDP automatisch in der Ubuntu-24.04-VM."
echo "Die VM bezieht standardmäßig per DHCP eine Adresse."
echo "Bei aktivierter Proxmox-Firewall muss TCP/$RDP_PORT zur VM erlaubt werden."
echo "GPU-Beschleunigung erfordert zusätzlich ein GPU-/PCI-Passthrough-Gerät für diese VM."
