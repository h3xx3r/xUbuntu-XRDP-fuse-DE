# Installation

## Deutsch

### Unraid

Im Unraid-Terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

Danach:

1. **Docker -> Add Container** öffnen.
2. Template **Ubuntu-XRDP** auswählen.
3. Benutzer, Admin-Masterpasswort, optionales Gastpasswort, Home-Pfad und weitere Optionen konfigurieren.
4. **Apply** klicken. Unraid lädt das Image und erstellt den Container.

Wichtige Variablen:

```text
RDP_USERS=admin:1000:1000:1;guest:1001:1001:0
RDP_MASTER_PASSWORD=...
RDP_GUEST_PASSWORD=...
RDP_GUEST_PASSWORD_ENABLED=0|1
RESET_STANDARD_USERS=1
RDP_AUDIO_ENABLED=1
TZ=Europe/Berlin
```

`RDP_GUEST_PASSWORD_ENABLED=1` verlangt das separate `RDP_GUEST_PASSWORD` für alle Konten mit `admin=0`.

`RDP_GUEST_PASSWORD_ENABLED=0` deaktiviert das Gastpasswort; Gastkonten melden sich mit leerem Passwort an. Admin-Konten verwenden trotzdem weiterhin das `RDP_MASTER_PASSWORD`.

Das Template setzt `/dev/fuse`, `SYS_ADMIN` und 2 GiB Shared Memory. Für GPU-Beschleunigung können zusätzlich `/dev/dri/card*` und `/dev/dri/renderD*` als Devices eingetragen werden.

### Ubuntu Server 24.04

Der Ubuntu-Installer installiert bei Bedarf Docker aus dem offiziellen Docker-Repository, legt die persistente Konfiguration unter `/etc/ubuntu-xrdp` und die Benutzerprofile unter `/srv/ubuntu-xrdp/home` an und startet den Container.

Als root oder mit `sudo`:

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) latest'
```

Danach Konfiguration prüfen:

```bash
sudo nano /etc/ubuntu-xrdp/ubuntu-xrdp.env
```

Standardpfad für persistente Benutzerprofile:

```text
/srv/ubuntu-xrdp/home
```

Der Installer ist idempotent. Für ein späteres Update denselben Befehl erneut ausführen. Der Container wird ersetzt, `/srv/ubuntu-xrdp/home` und `/etc/ubuntu-xrdp/ubuntu-xrdp.env` bleiben erhalten.

Beispiele für andere Kanäle:

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) stable'
```

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) v1.0.0'
```

Host-Port ändern:

```bash
sudo RDP_PORT=3390 bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) latest'
```

### Proxmox VE

Docker wird bewusst **nicht direkt auf dem Proxmox-VE-Host** installiert. Das Proxmox-Script erstellt stattdessen eine Ubuntu-24.04-Cloud-Init-VM. In dieser VM wird automatisch der Ubuntu-Server-Installer ausgeführt.

Auf dem Proxmox-Host als root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-proxmox.sh) latest
```

Standardwerte:

```text
VMID: automatisch nächste freie ID
Name: ubuntu-xrdp
Storage: local-lvm
Cloud-Init Snippets: local
Bridge: vmbr0
CPU: 4 Cores
RAM: 4096 MB
Disk: 32 GB
Netzwerk: DHCP
RDP-Port: 3389
```

Das Script lädt das offizielle Ubuntu-24.04-Cloud-Image, erstellt die VM, richtet Cloud-Init ein und installiert Docker + Ubuntu-XRDP automatisch in der VM.

Parameter können über Umgebungsvariablen geändert werden. Beispiel:

```bash
VMID=250 \
VM_NAME=xrdp-server \
STORAGE=local-lvm \
BRIDGE=vmbr0 \
CORES=6 \
MEMORY=8192 \
DISK_SIZE=64G \
RDP_MASTER_PASSWORD='MeinAdminPasswort' \
RDP_GUEST_PASSWORD='MeinGastPasswort' \
RDP_GUEST_PASSWORD_ENABLED=1 \
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-proxmox.sh) latest
```

Wenn kein `RDP_MASTER_PASSWORD` übergeben wird, erzeugt der Proxmox-Installer automatisch ein zufälliges Admin-Masterpasswort und zeigt es nach der VM-Erstellung an.

Für `SNIPPET_STORAGE` muss auf dem gewählten Proxmox-Storage der Inhaltstyp **Snippets** aktiviert sein. Standardmäßig wird `local` verwendet.

Wenn die Proxmox-Firewall aktiv ist, muss TCP-Port `3389` beziehungsweise der gewählte `RDP_PORT` zur VM freigegeben werden.

GPU-Beschleunigung in der Proxmox-VM erfordert zusätzlich ein geeignetes GPU-/PCI-Passthrough-Gerät. Sobald `/dev/dri` in der Ubuntu-VM vorhanden ist, übernimmt der Ubuntu-Installer die Docker-Device-Zuordnung automatisch.

---

## English

### Unraid

Run in the Unraid terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

Then open **Docker -> Add Container**, select **Ubuntu-XRDP**, configure the users/passwords and click **Apply**.

Administrator accounts (`admin=1`) always use `RDP_MASTER_PASSWORD`. Guest/standard accounts (`admin=0`) use the separate `RDP_GUEST_PASSWORD` when `RDP_GUEST_PASSWORD_ENABLED=1`, or an empty password when it is `0`.

### Ubuntu Server 24.04

Run as root or through `sudo`:

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) latest'
```

The script installs Docker when necessary, stores configuration in:

```text
/etc/ubuntu-xrdp/ubuntu-xrdp.env
```

and persistent user data in:

```text
/srv/ubuntu-xrdp/home
```

Run the same installer again later to update/recreate the container while preserving configuration and persistent user data.

### Proxmox VE

Docker is deliberately not installed directly on the Proxmox VE host. The installer creates an Ubuntu 24.04 cloud-init VM and runs the Ubuntu Server installer inside that VM.

Run as root on the Proxmox host:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-proxmox.sh) latest
```

Defaults are 4 vCPUs, 4 GiB RAM, 32 GiB disk, DHCP networking through `vmbr0`, `local-lvm` for the VM disk and `local` for the cloud-init snippet.

Example with custom values:

```bash
VMID=250 \
VM_NAME=xrdp-server \
CORES=6 \
MEMORY=8192 \
DISK_SIZE=64G \
RDP_MASTER_PASSWORD='MyAdminPassword' \
RDP_GUEST_PASSWORD='MyGuestPassword' \
RDP_GUEST_PASSWORD_ENABLED=1 \
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-proxmox.sh) latest
```

The selected `SNIPPET_STORAGE` must support Proxmox **Snippets**. If no admin master password is supplied, the Proxmox installer generates one and prints it after creating the VM.
