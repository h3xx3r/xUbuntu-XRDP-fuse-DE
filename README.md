# xUbuntu-XRDP-fuse-DE

## Deutsch

Ubuntu 24.04 XFCE Remote-Desktop-Container für Unraid mit deutscher Desktop-Voreinstellung, Multiuser-XRDP-Sitzungen, FUSE-Laufwerksumleitung, RDP-Audio/Mikrofon, CUPS-Netzwerkdruckerprofilen, GPU-Passthrough und automatisch zurücksetzbaren Gastkonten.

### Highlights

- Ubuntu 24.04 + XFCE
- XRDP 0.10.6.1 + xorgxrdp 0.10.5
- Deutsche Oberfläche, Tastatur und Locale
- Mehrere Benutzerkonten mit Admin- oder zurücksetzbarer Standardrolle
- Optional passwortlose Gast-/Standardkonten, während Admin-Konten passwortgeschützt bleiben
- Standardname für das erste Konto: `admin`
- RDP-Client-Laufwerksumleitung über FUSE
- RDP-Audio und Mikrofon über `pulseaudio-module-xrdp`
- Firefox, Google Chrome, LibreOffice, GIMP, Xournal++ und PDF Arranger
- Xournal++ als PDF-Standard und GIMP als Bild-Standard
- CUPS mit benutzerspezifischer Netzwerkdrucker-Zuweisung
- Persistente Drucker-Golden-Profile pro Benutzer
- Blauer XFCE-Hintergrund, eine untere Leiste und automatische Desktop-Symbolanordnung
- GPU-/VAAPI-Passthrough über `/dev/dri`
- Unraid-DockerMan-Template mit editierbaren Benutzern, Passwort, Druckern, Pfaden, Audio- und Sitzungseinstellungen
- GHCR-Images über GitHub Actions

### Docker-Image

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:latest
```

Später stehen zusätzlich `:stable` und versionierte Tags wie `:v1.0.0` zur Verfügung.

### Installation unter Unraid

Im Unraid-Terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

Das Installationsskript:

1. lädt das aktuelle Unraid-Template aus diesem Repository,
2. speichert es unter `/boot/config/plugins/dockerMan/templates-user/my-Ubuntu-XRDP.xml`,
3. setzt den gewünschten Image-Kanal,
4. lädt **noch kein Docker-Image**.

Das Image wird absichtlich erst von Unraid geladen, wenn du den Container aus dem Template erstellst. Dadurch entsteht nach der Template-Installation kein **verwaistes Image**.

Danach in Unraid:

1. **Docker -> Add Container** öffnen.
2. Das Template **Ubuntu-XRDP** auswählen.
3. `RDP_USERS`, `RDP_MASTER_PASSWORD`, Home-Pfad, Druckerzuordnungen und optionale GPU-Geräte konfigurieren.
4. Das Standardpasswort `changeme` unbedingt ersetzen.
5. Optional **Gast ohne Passwort** konfigurieren.
6. Auf **Apply** klicken. Unraid lädt jetzt automatisch das Image und erstellt den Container.
7. Container starten und per RDP verbinden.

Standardformat für Benutzer:

```text
admin:1000:1000:1;guest:1001:1001:0
```

Das letzte Feld ist `1` für einen Administrator und `0` für ein zurücksetzbares Standardkonto.

### Gast-RDP ohne Passwort

Die Unraid-Variable:

```text
RDP_PASSWORDLESS_STANDARD_USERS=1
```

bewirkt, dass **alle Konten mit `admin=0`** ein leeres Passwort erhalten. Admin-Konten mit `admin=1` verwenden weiterhin zwingend `RDP_MASTER_PASSWORD`.

Mit der Standardkonfiguration:

```text
admin:1000:1000:1;guest:1001:1001:0
```

meldest du dich daher so an:

```text
Admin:
Benutzer: admin
Passwort: Wert aus RDP_MASTER_PASSWORD

Gast:
Benutzer: guest
Passwort: leer lassen
```

Wenn Standard-/Gastkonten ebenfalls das Master-Passwort verwenden sollen:

```text
RDP_PASSWORDLESS_STANDARD_USERS=0
```

### Updates unter Unraid

Docker-Image-Updates werden über GHCR bereitgestellt. In Unraid unter **Docker -> Check for Updates** prüfen und ein verfügbares Update installieren.

Entwicklung:

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:latest
```

Stabil:

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:stable
```

Feste Version:

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:v1.0.0
```

Das Unraid-Template selbst kann ebenfalls erneut aus GitHub aktualisiert werden:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

oder später für Stable:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) stable
```

Persistente Daten unter `/mnt/user/appdata/ubuntu-xrdp/home` bleiben bei normalen Container-Updates erhalten. Dort liegen auch die persistenten Drucker-Golden-Profile.

### Druckerzuordnung

`RDP_PRINTERS` verwendet:

```text
user|queue|uri|model|options
```

Beispiel:

```text
guest|Guest_HP|ipp://192.168.1.50/ipp/print|everywhere|media=A4,sides=one-sided
```

Weitere Informationen: [docs/PRINTING.md](docs/PRINTING.md)

### Dokumentation

- [Installation](docs/INSTALL.md)
- [Benutzer und Gast-Reset](docs/USERS.md)
- [Audio](docs/AUDIO.md)
- [Drucker](docs/PRINTING.md)
- [Fehlerbehebung](docs/TROUBLESHOOTING.md)
- [Updates](docs/UPDATES.md)

### Sicherheitshinweis

Admin-Konten verwenden immer `RDP_MASTER_PASSWORD`. Wenn `RDP_PASSWORDLESS_STANDARD_USERS=1` gesetzt ist, können Konten mit `admin=0` ohne Passwort per RDP angemeldet werden. Diese Option sollte nur in einem vertrauenswürdigen LAN/VPN verwendet werden. XRDP nicht direkt aus dem öffentlichen Internet erreichbar machen.

### Lizenz

Die projektspezifischen Skripte und Konfigurationsdateien stehen unter der MIT-Lizenz. Drittanbieter-Software unterliegt ihren jeweiligen Upstream-Lizenzen.

---

## English

Ubuntu 24.04 XFCE Remote Desktop container for Unraid with German desktop defaults, multi-user XRDP sessions, FUSE client-drive redirection, RDP audio/microphone, CUPS network-printer profiles, GPU passthrough and resettable guest accounts.

### Highlights

- Ubuntu 24.04 + XFCE
- XRDP 0.10.6.1 + xorgxrdp 0.10.5
- German UI, keyboard and locale
- Multiple user accounts with admin or resettable standard role
- Optional passwordless guest/standard accounts while admin accounts remain password-protected
- Default first account: `admin`
- RDP client-drive redirection via FUSE
- RDP audio and microphone via `pulseaudio-module-xrdp`
- Firefox, Google Chrome, LibreOffice, GIMP, Xournal++ and PDF Arranger
- Xournal++ as PDF default and GIMP as image default
- CUPS with per-user network-printer assignment
- Persistent per-user printer golden profiles
- Blue XFCE background, one bottom panel and automatic desktop-icon arrangement
- GPU/VAAPI passthrough with `/dev/dri`
- Unraid DockerMan template with editable users, password, printers, paths, audio and session settings
- GHCR images built by GitHub Actions

### Docker image

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:latest
```

Later releases will also provide `:stable` and versioned tags such as `:v1.0.0`.

### Installation on Unraid

Run in the Unraid terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

The installer:

1. downloads the current Unraid template from this repository,
2. stores it at `/boot/config/plugins/dockerMan/templates-user/my-Ubuntu-XRDP.xml`,
3. selects the requested image channel,
4. deliberately **does not pull the Docker image yet**.

The image is downloaded by Unraid only when you create the container from the template. This avoids an **orphaned image** immediately after installing the template.

Then in Unraid:

1. Open **Docker -> Add Container**.
2. Select the **Ubuntu-XRDP** template.
3. Configure `RDP_USERS`, `RDP_MASTER_PASSWORD`, the home path, printer mappings and optional GPU devices.
4. Replace the default password `changeme`.
5. Optionally configure **passwordless guest login**.
6. Click **Apply**. Unraid now downloads the image and creates the container.
7. Start the container and connect through RDP.

Default user specification:

```text
admin:1000:1000:1;guest:1001:1001:0
```

The final field is `1` for an administrator and `0` for a resettable standard account.

### Passwordless guest RDP login

The Unraid variable:

```text
RDP_PASSWORDLESS_STANDARD_USERS=1
```

causes **all accounts with `admin=0`** to have an empty password. Admin accounts with `admin=1` still require `RDP_MASTER_PASSWORD`.

With the default configuration:

```text
admin:1000:1000:1;guest:1001:1001:0
```

login is therefore:

```text
Admin:
Username: admin
Password: value of RDP_MASTER_PASSWORD

Guest:
Username: guest
Password: leave empty
```

To require the master password for standard/guest accounts as well:

```text
RDP_PASSWORDLESS_STANDARD_USERS=0
```

### Updates on Unraid

Docker image updates are distributed through GHCR. Use **Docker -> Check for Updates** in Unraid and install the update when one is available.

Development:

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:latest
```

Stable:

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:stable
```

Pinned version:

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:v1.0.0
```

The Unraid template itself can be refreshed from GitHub at any time:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) latest
```

or later for stable:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh) stable
```

Persistent data under `/mnt/user/appdata/ubuntu-xrdp/home` is preserved during normal container updates. This also contains the persistent printer golden profiles.

### Printer mapping

`RDP_PRINTERS` uses:

```text
user|queue|uri|model|options
```

Example:

```text
guest|Guest_HP|ipp://192.168.1.50/ipp/print|everywhere|media=A4,sides=one-sided
```

See [docs/PRINTING.md](docs/PRINTING.md).

### Documentation

- [Installation](docs/INSTALL.md)
- [Users and guest reset](docs/USERS.md)
- [Audio](docs/AUDIO.md)
- [Printing](docs/PRINTING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Updates](docs/UPDATES.md)

### Security note

Admin accounts always use `RDP_MASTER_PASSWORD`. When `RDP_PASSWORDLESS_STANDARD_USERS=1`, accounts with `admin=0` can log in over RDP with an empty password. Use this option only on a trusted LAN/VPN and do not expose XRDP directly to the public Internet.

### License

Project scripts and configuration are MIT licensed. Third-party software remains under its respective upstream licenses.
