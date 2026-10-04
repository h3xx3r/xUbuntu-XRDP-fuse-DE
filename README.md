# xUbuntu-XRDP-fuse-DE

## Deutsch

Ubuntu 24.04 XFCE Remote-Desktop-Container mit Multiuser-XRDP, FUSE-Laufwerksumleitung, RDP-Audio/Mikrofon, CUPS-Netzwerkdruckerprofilen, GPU-Unterstützung und automatisch zurücksetzbaren Gastkonten. Unterstützte Installationswege: **Unraid**, **Ubuntu Server 24.04** und **Proxmox VE über eine automatisch erzeugte Ubuntu-24.04-VM**.

### Highlights

- Ubuntu 24.04 + XFCE
- XRDP 0.10.6.1 + xorgxrdp 0.10.5
- Deutsche Oberfläche, Tastatur und Locale
- Mehrere Benutzerkonten mit Admin- oder zurücksetzbarer Gast-/Standardrolle
- Getrenntes Admin-Masterpasswort und Gastpasswort
- Gastpasswort optional deaktivierbar, ohne den Admin-Zugang zu schwächen
- RDP-Client-Laufwerksumleitung über FUSE
- RDP-Audio und Mikrofon über `pulseaudio-module-xrdp`
- Firefox, Google Chrome, LibreOffice, GIMP, Xournal++ und PDF Arranger
- CUPS mit benutzerspezifischer Netzwerkdrucker-Zuweisung
- Persistente Drucker-Golden-Profile pro Benutzer
- Blauer XFCE-Hintergrund, nur eine untere Leiste und automatische Desktop-Symbolanordnung
- GPU-/VAAPI-Unterstützung über `/dev/dri`
- GHCR-Images über GitHub Actions

### Docker-Image

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:latest
```

Später stehen zusätzlich `:stable` und versionierte Tags wie `:v1.0.0` zur Verfügung.

### Benutzer und Passwörter

Standardformat:

```text
admin:1000:1000:1;guest:1001:1001:0
```

Das letzte Feld bedeutet:

```text
1 = Administrator
0 = Gast-/Standardkonto
```

Admin-Konten verwenden immer:

```text
RDP_MASTER_PASSWORD
```

Gast-/Standardkonten verwenden getrennt davon:

```text
RDP_GUEST_PASSWORD
```

Ob das Gastpasswort aktiv ist, steuert:

```text
RDP_GUEST_PASSWORD_ENABLED
```

Mit Gastpasswort:

```text
RDP_MASTER_PASSWORD=MeinAdminPasswort
RDP_GUEST_PASSWORD=MeinGastPasswort
RDP_GUEST_PASSWORD_ENABLED=1
```

Dann gilt:

```text
admin -> MeinAdminPasswort
guest -> MeinGastPasswort
```

Ohne Gastpasswort:

```text
RDP_MASTER_PASSWORD=MeinAdminPasswort
RDP_GUEST_PASSWORD_ENABLED=0
```

Dann gilt:

```text
admin -> MeinAdminPasswort
guest -> Passwortfeld leer lassen
```

Das Admin-Masterpasswort darf nicht leer sein. Passwortlose Gastkonten nur in einem vertrauenswürdigen LAN oder über VPN verwenden.

### Installation unter Unraid

Im Unraid-Terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

Das Script installiert nur das Template und lädt noch kein Docker-Image. Dadurch entsteht nach der Template-Installation kein verwaistes Image.

Danach:

1. **Docker -> Add Container** öffnen.
2. Template **Ubuntu-XRDP** auswählen.
3. `RDP_USERS`, **Admin Master-Passwort**, **Gast-Passwort verwenden**, **Gast-Passwort**, Home-Pfad, Drucker und optionale GPU-Devices konfigurieren.
4. **Apply** klicken.
5. Unraid lädt das Image und erstellt den Container.

Updates:

```text
Docker -> Check for Updates
```

Template erneut aktualisieren:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

Persistente Daten bleiben unter:

```text
/mnt/user/appdata/ubuntu-xrdp/home
```

### Installation auf Ubuntu Server 24.04

Als root oder mit `sudo`:

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) latest'
```

Der Installer:

- installiert Docker bei Bedarf,
- verwendet das offizielle Docker-Repository,
- erstellt `/etc/ubuntu-xrdp/ubuntu-xrdp.env`,
- speichert Benutzerprofile persistent unter `/srv/ubuntu-xrdp/home`,
- bindet `/dev/fuse` ein,
- bindet vorhandene `/dev/dri`-Geräte automatisch ein,
- startet den Container mit `--restart unless-stopped`.

Konfiguration bearbeiten:

```bash
sudo nano /etc/ubuntu-xrdp/ubuntu-xrdp.env
```

Für ein späteres Update denselben Installationsbefehl erneut ausführen. Der Container wird ersetzt, Konfiguration und persistente Home-Daten bleiben erhalten.

Stable:

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) stable'
```

Feste Version:

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) v1.0.0'
```

### Installation auf Proxmox VE

Docker wird bewusst **nicht direkt auf dem Proxmox-Host** installiert. Das Script erstellt stattdessen eine Ubuntu-24.04-Cloud-Init-VM und installiert Ubuntu-XRDP automatisch innerhalb dieser VM.

Auf dem Proxmox-Host als root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-proxmox.sh) latest
```

Standardwerte:

```text
VMID: nächste freie ID
Name: ubuntu-xrdp
Storage: local-lvm
Snippet-Storage: local
Bridge: vmbr0
CPU: 4 Cores
RAM: 4096 MB
Disk: 32 GB
Netzwerk: DHCP
RDP-Port: 3389
```

Beispiel mit eigenen Werten:

```bash
VMID=250 \
VM_NAME=xrdp-server \
CORES=6 \
MEMORY=8192 \
DISK_SIZE=64G \
RDP_MASTER_PASSWORD='MeinAdminPasswort' \
RDP_GUEST_PASSWORD='MeinGastPasswort' \
RDP_GUEST_PASSWORD_ENABLED=1 \
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-proxmox.sh) latest
```

Wenn kein `RDP_MASTER_PASSWORD` angegeben wird, erzeugt das Proxmox-Script automatisch ein zufälliges Admin-Masterpasswort und zeigt es nach der VM-Erstellung an.

Für `SNIPPET_STORAGE` muss in Proxmox der Inhaltstyp **Snippets** aktiviert sein. Standard ist `local`.

Bei aktivierter Proxmox-Firewall muss TCP `3389` beziehungsweise der gewählte `RDP_PORT` zur VM freigegeben werden.

GPU-Beschleunigung benötigt in Proxmox zusätzlich GPU-/PCI-Passthrough zur Ubuntu-VM. Sobald `/dev/dri` in der VM existiert, wird es vom Ubuntu-Installer automatisch an den Container weitergereicht.

### Druckerzuordnung

`RDP_PRINTERS` verwendet:

```text
user|queue|uri|model|options
```

Beispiel:

```text
guest|Guest_HP|ipp://192.168.1.50/ipp/print|everywhere|media=A4,sides=one-sided
```

### Dokumentation

- [Installation](docs/INSTALL.md)
- [Benutzer, Passwörter und Gast-Reset](docs/USERS.md)
- [Audio](docs/AUDIO.md)
- [Drucker](docs/PRINTING.md)
- [Fehlerbehebung](docs/TROUBLESHOOTING.md)
- [Updates](docs/UPDATES.md)

### Sicherheitshinweis

XRDP nicht direkt aus dem öffentlichen Internet erreichbar machen. Für externen Zugriff LAN/VPN bevorzugen. `RDP_MASTER_PASSWORD` immer ändern. Passwortlose Gastkonten nur verwenden, wenn das Netz vertrauenswürdig ist.

### Lizenz

Die projektspezifischen Skripte und Konfigurationsdateien stehen unter der MIT-Lizenz. Drittanbieter-Software unterliegt ihren jeweiligen Upstream-Lizenzen.

---

## English

Ubuntu 24.04 XFCE Remote Desktop container with multi-user XRDP, FUSE client-drive redirection, RDP audio/microphone, CUPS network-printer profiles, GPU support and resettable guest accounts. Supported installation targets: **Unraid**, **Ubuntu Server 24.04**, and **Proxmox VE through an automatically created Ubuntu 24.04 VM**.

### Highlights

- Ubuntu 24.04 + XFCE
- XRDP 0.10.6.1 + xorgxrdp 0.10.5
- German UI, keyboard and locale
- Admin and resettable guest/standard accounts
- Separate administrator master password and guest password
- Optional passwordless guest login while administrator accounts remain protected
- FUSE RDP client-drive redirection
- RDP audio and microphone
- Firefox, Google Chrome, LibreOffice, GIMP, Xournal++ and PDF Arranger
- CUPS per-user printer assignment
- Persistent per-user printer golden profiles
- Blue XFCE desktop, one bottom panel and automatic desktop icon arrangement
- GPU/VAAPI support through `/dev/dri`
- GHCR images built through GitHub Actions

### Docker image

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:latest
```

### Users and passwords

Example:

```text
admin:1000:1000:1;guest:1001:1001:0
```

Administrator accounts (`admin=1`) always use:

```text
RDP_MASTER_PASSWORD
```

Guest/standard accounts (`admin=0`) use:

```text
RDP_GUEST_PASSWORD
```

when:

```text
RDP_GUEST_PASSWORD_ENABLED=1
```

Set:

```text
RDP_GUEST_PASSWORD_ENABLED=0
```

to allow guest accounts to log in with an empty password while administrators still require the master password.

### Unraid installation

Run in the Unraid terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

Then open **Docker -> Add Container**, select **Ubuntu-XRDP**, configure users/passwords and click **Apply**.

### Ubuntu Server 24.04 installation

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-ubuntu-server.sh) latest'
```

Configuration is stored in:

```text
/etc/ubuntu-xrdp/ubuntu-xrdp.env
```

Persistent user data is stored in:

```text
/srv/ubuntu-xrdp/home
```

Run the same installer again later to update/recreate the container while preserving configuration and persistent user data.

### Proxmox VE installation

Docker is deliberately not installed directly on the Proxmox VE host. The installer creates an Ubuntu 24.04 cloud-init VM and automatically runs the Ubuntu Server installer inside it.

Run as root on the Proxmox host:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-proxmox.sh) latest
```

Example:

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

The selected `SNIPPET_STORAGE` must support Proxmox **Snippets**. If no administrator master password is supplied, the installer generates one and prints it after creating the VM.

### Documentation

- [Installation](docs/INSTALL.md)
- [Users, passwords and guest reset](docs/USERS.md)
- [Audio](docs/AUDIO.md)
- [Printing](docs/PRINTING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Updates](docs/UPDATES.md)

### Security note

Do not expose XRDP directly to the public Internet. Prefer LAN/VPN access. Always change `RDP_MASTER_PASSWORD`. Use passwordless guest accounts only on a trusted network.

### License

Project scripts and configuration are MIT licensed. Third-party software remains under its respective upstream licenses.
