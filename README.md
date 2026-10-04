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
- ChatGPT als Admin-only Desktop-/Menü-Launcher
- Synaptic-Paketverwaltung mit XRDP-tauglichem Admin-Passwortdialog
- CUPS mit benutzerspezifischer Netzwerkdrucker-Zuweisung
- Persistente Drucker-Golden-Profile pro Benutzer
- Blauer XFCE-Hintergrund, nur eine untere Leiste und automatische Desktop-Symbolanordnung
- GPU-/VAAPI-Unterstützung über `/dev/dri`
- GHCR-Images über GitHub Actions

### Standardmäßig im Image enthaltene Programme

| Programm / Komponente | Zweck | Verfügbarkeit |
| --- | --- | --- |
| **Firefox** + deutsche Sprachdateien | Webbrowser | Alle Benutzer |
| **Google Chrome** | Webbrowser | Alle Benutzer |
| **LibreOffice Writer** | Textverarbeitung | Alle Benutzer |
| **LibreOffice Calc** | Tabellenkalkulation | Alle Benutzer |
| **LibreOffice Impress** | Präsentationen | Alle Benutzer |
| **LibreOffice Draw** | Zeichnungen / PDF-Bearbeitung | Alle Benutzer |
| **GIMP** | Bildbearbeitung | Alle Benutzer |
| **Xournal++ 1.3.8** | PDF-Anmerkungen / handschriftliche Notizen | Alle Benutzer |
| **Evince / PDF-Betrachter** | PDF-Anzeige | Alle Benutzer |
| **PDF Arranger** | PDF-Seiten anordnen, drehen und zusammenfügen | Alle Benutzer |
| **Mousepad** | Einfacher Texteditor | Alle Benutzer |
| **XFCE Terminal** | Terminal | Installiert, aber kein Desktop-Symbol |
| **ChatGPT** | Admin-only Launcher zu `https://chatgpt.com` in Chrome-App-Modus | Nur Admin |
| **Synaptic-Paketverwaltung** | Grafische Paketverwaltung mit XRDP-tauglichem Passwortdialog | Nur Admin |
| **GDebi** | Installation lokaler `.deb`-Pakete | Admin-Werkzeug |
| **Software & Updates** (`software-properties-gtk`) | Paketquellen verwalten | Admin-Werkzeug |
| **system-config-printer** | Grafische Druckerverwaltung | Admin / Druckerverwaltung |
| **Pavucontrol** | PulseAudio-Lautstärke- und Audiogeräteverwaltung | Alle Benutzer |
| **CUPS** | Drucksystem / Netzwerkdrucker | Systemdienst |
| **qpdf + Poppler-Tools** | PDF-Werkzeuge im Hintergrund / Terminal | Systemwerkzeuge |
| **FFmpeg** | Audio-/Video-Werkzeuge | Systemwerkzeug |
| **Mesa / VAAPI / Vulkan-Werkzeuge** | GPU-/Video-Beschleunigung und Diagnose | Systemkomponenten |
| **FUSE3 / GVFS** | RDP-Laufwerksumleitung und virtuelle Dateisysteme | Systemkomponenten |
| **XRDP 0.10.6.1 + xorgxrdp 0.10.5** | RDP-Server und Xorg-Backend | Systemkomponenten |
| **XFCE 4** | Desktop-Umgebung | Alle Benutzer |

Die Desktop-Symbole werden bewusst auf die wichtigsten Anwendungen beschränkt. Einige installierte Admin- und Systemwerkzeuge sind nur über das XFCE-Menü oder das Terminal erreichbar.

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

### Admin-Anwendungen: ChatGPT und Synaptic

Admin-Konten erhalten zusätzlich **ChatGPT** als Desktop- und Menü-Launcher. Der Launcher öffnet `https://chatgpt.com` in Google Chrome im App-Modus. Zugangsdaten werden nicht im Image gespeichert; ein Browser-Login liegt im persistenten Admin-Home.

**Synaptic-Paketverwaltung** ist ebenfalls nur für Admin-Konten sichtbar. Unter XRDP wird Synaptic nicht über `pkexec`, sondern über einen eigenen `sudo -A`/Zenity-Askpass-Wrapper gestartet. Beim Start erscheint ein grafischer Passwortdialog für das Admin-Passwort.

### Persistenz von nachträglich installierten Programmen

Wichtig bei Docker:

- **Container Stop/Start:** nachträglich mit Synaptic oder `apt` installierte Programme bleiben erhalten.
- **Docker-/Host-Neustart:** sie bleiben erhalten, solange derselbe Container weiterverwendet wird.
- **Image-Update / Unraid-Update:** Unraid erstellt den Container aus dem neuen Image neu. Manuell im alten Container installierte Systempakete sind dann **nicht mehr vorhanden**.
- **Container löschen und neu erstellen:** manuell installierte Systempakete gehen ebenfalls verloren.
- Dateien, Browserprofile und Benutzereinstellungen unter dem persistent gemounteten `/home` bleiben erhalten.

Wenn Programme updatesicher benötigt werden, sollten sie in das Docker-Image aufgenommen oder über eine deklarierte Paketliste bei Containerstart installiert werden.

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
- Admin-only ChatGPT desktop/menu launcher
- XRDP-compatible Synaptic package manager with graphical admin password prompt
- CUPS per-user printer assignment
- Persistent per-user printer golden profiles
- Blue XFCE desktop, one bottom panel and automatic desktop icon arrangement
- GPU/VAAPI support through `/dev/dri`
- GHCR images built through GitHub Actions

### Applications included in the image by default

| Application / component | Purpose | Availability |
| --- | --- | --- |
| **Firefox** + German language pack | Web browser | All users |
| **Google Chrome** | Web browser | All users |
| **LibreOffice Writer** | Word processing | All users |
| **LibreOffice Calc** | Spreadsheets | All users |
| **LibreOffice Impress** | Presentations | All users |
| **LibreOffice Draw** | Drawing / PDF editing | All users |
| **GIMP** | Image editing | All users |
| **Xournal++ 1.3.8** | PDF annotation / handwritten notes | All users |
| **Evince / PDF Viewer** | PDF viewing | All users |
| **PDF Arranger** | Reorder, rotate and merge PDF pages | All users |
| **Mousepad** | Lightweight text editor | All users |
| **XFCE Terminal** | Terminal emulator | Installed, no desktop shortcut |
| **ChatGPT** | Admin-only launcher to `https://chatgpt.com` in Chrome app mode | Admin only |
| **Synaptic Package Manager** | Graphical package management with XRDP-compatible password dialog | Admin only |
| **GDebi** | Install local `.deb` packages | Admin tool |
| **Software & Updates** (`software-properties-gtk`) | Manage software sources | Admin tool |
| **system-config-printer** | Graphical printer management | Admin / printer management |
| **Pavucontrol** | PulseAudio volume and device control | All users |
| **CUPS** | Printing / network printers | System service |
| **qpdf + Poppler tools** | PDF command-line/background tools | System tools |
| **FFmpeg** | Audio/video tools | System tool |
| **Mesa / VAAPI / Vulkan tools** | GPU/video acceleration and diagnostics | System components |
| **FUSE3 / GVFS** | RDP drive redirection and virtual filesystems | System components |
| **XRDP 0.10.6.1 + xorgxrdp 0.10.5** | RDP server and Xorg backend | System components |
| **XFCE 4** | Desktop environment | All users |

Desktop shortcuts are intentionally limited to the most important applications. Some installed administration and system tools are available only through the XFCE menu or terminal.

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

### Admin applications: ChatGPT and Synaptic

Administrator accounts additionally receive a **ChatGPT** desktop and menu launcher. It opens `https://chatgpt.com` in Google Chrome app mode. No account credentials are baked into the image; browser login state is stored in the persistent administrator home directory.

**Synaptic Package Manager** is also exposed only to administrator accounts. Under XRDP it uses a dedicated `sudo -A` + Zenity askpass wrapper instead of `pkexec`, providing a graphical administrator password prompt.

### Persistence of manually installed applications

Important Docker behavior:

- **Container stop/start:** packages installed manually with Synaptic or `apt` remain present.
- **Docker/host restart:** they remain present as long as the same container is retained.
- **Image update / Unraid update:** the container is recreated from the new image, so manually installed system packages are **not preserved**.
- **Deleting/recreating the container:** manually installed system packages are lost as well.
- Files, browser profiles and user configuration stored below the persistent `/home` mount remain preserved.

Applications which must survive image updates should be added to the image itself or declared in a package list installed automatically when the container starts.

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

Project scripts and configuration are MIT licensed. Third-party software remains under their respective upstream licenses.
