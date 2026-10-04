# xUbuntu-XRDP-fuse-DE

## Deutsch

Ubuntu 24.04 XFCE Remote-Desktop-Container für Unraid mit deutscher Desktop-Voreinstellung, Multiuser-XRDP-Sitzungen, FUSE-Laufwerksumleitung, RDP-Audio/Mikrofon, CUPS-Netzwerkdruckerprofilen, GPU-Passthrough und automatisch zurücksetzbaren Gastkonten.

### Highlights

- Ubuntu 24.04 + XFCE
- XRDP 0.10.6.1 + xorgxrdp 0.10.5
- Deutsche Oberfläche, Tastatur und Locale
- Mehrere Benutzerkonten mit Admin- oder zurücksetzbarer Standardrolle
- Standardname für das erste Konto: `admin`
- RDP-Client-Laufwerksumleitung über FUSE
- RDP-Audiowiedergabe und Mikrofon über `pulseaudio-module-xrdp`
- Firefox, Google Chrome, LibreOffice, GIMP, Xournal++ und PDF Arranger
- Xournal++ als Standard für PDF-Dateien und GIMP als Standard für Bilder
- CUPS mit benutzerspezifischer Netzwerkdrucker-Zuweisung
- Persistente benutzerspezifische Drucker-Golden-Profile (`~/.cups/lpoptions` wird aus einem Backup wiederhergestellt)
- Blauer XFCE-Hintergrund, nur eine untere Leiste und automatische Desktop-Symbolanordnung
- GPU-/VAAPI-Passthrough über `/dev/dri`
- Unraid-DockerMan-Template mit editierbaren Benutzern, Passwort, Druckern, Pfaden, Audio- und Sitzungseinstellungen
- GHCR-Images werden automatisch über GitHub Actions gebaut

### Docker-Image

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:stable
```

Entwicklungs-Builds verwenden `:latest`; versionierte Releases verwenden Tags wie `:v1.0.0`.

### Schnellstart unter Unraid

1. `unraid/my-Ubuntu-XRDP.xml` nach `/boot/config/plugins/dockerMan/templates-user/` kopieren oder das Template direkt aus dem Repository installieren.
2. In Unraid **Docker -> Add Container** öffnen und das Ubuntu-XRDP-Template auswählen.
3. `RDP_USERS`, `RDP_MASTER_PASSWORD`, Home-/CUPS-Pfade, Druckerzuordnungen und optional GPU-Geräte konfigurieren.
4. Container starten und mit einem beliebigen RDP-Client verbinden.

Standardformat für Benutzer:

```text
admin:1000:1000:1;guest:1001:1001:0
```

Das letzte Feld ist `1` für einen Administrator und `0` für ein zurücksetzbares Standardkonto.

### Druckerzuordnung

`RDP_PRINTERS` verwendet folgendes Format:

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

Alle Benutzer verwenden derzeit das konfigurierte `RDP_MASTER_PASSWORD`. XRDP sollte nicht direkt aus dem öffentlichen Internet erreichbar sein. Bevorzugt LAN/VPN verwenden und das Beispiel-/Standardpasswort unbedingt ändern.

### Lizenz

Die projektspezifischen Skripte und Konfigurationsdateien in diesem Repository stehen unter der MIT-Lizenz. Installierte oder eingebundene Drittanbieter-Software unterliegt weiterhin den jeweiligen Upstream-Lizenzen.

---

## English

Ubuntu 24.04 XFCE Remote Desktop container for Unraid, with German desktop defaults, multi-user XRDP sessions, FUSE client-drive redirection, RDP audio/microphone, CUPS network-printer profiles, GPU passthrough and resettable guest accounts.

### Highlights

- Ubuntu 24.04 + XFCE
- XRDP 0.10.6.1 + xorgxrdp 0.10.5
- German UI / keyboard / locale
- Multi-user accounts with admin or resettable standard role
- Default first account: `admin`
- RDP client-drive redirection via FUSE
- RDP audio playback and microphone via `pulseaudio-module-xrdp`
- Firefox, Google Chrome, LibreOffice, GIMP, Xournal++ and PDF Arranger
- Xournal++ as PDF default and GIMP as image default
- CUPS with per-user network-printer assignment
- Persistent per-user printer golden profiles (`~/.cups/lpoptions` reset from backup)
- Blue XFCE background, one bottom panel and automatic desktop-icon arrangement
- GPU/VAAPI passthrough with `/dev/dri`
- Unraid DockerMan template with editable users, password, printers, paths, audio and session settings
- GHCR images built by GitHub Actions

### Docker image

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:stable
```

Development builds use `:latest`; versioned releases use tags such as `:v1.0.0`.

### Unraid quick start

1. Copy `unraid/my-Ubuntu-XRDP.xml` to `/boot/config/plugins/dockerMan/templates-user/` or install it from the repository.
2. Open **Docker -> Add Container** and select the Ubuntu-XRDP template.
3. Configure `RDP_USERS`, `RDP_MASTER_PASSWORD`, home/CUPS paths, printer mappings and optional GPU devices.
4. Start the container and connect with any RDP client.

Default user specification format:

```text
admin:1000:1000:1;guest:1001:1001:0
```

The last field is `1` for an administrator and `0` for a resettable standard account.

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

All users currently share the configured `RDP_MASTER_PASSWORD`. Do not expose XRDP directly to the public Internet. Prefer LAN/VPN access and change the password from its example/default value.

### License

Project scripts and configuration in this repository are MIT licensed. Bundled or installed third-party software remains under its respective upstream licenses.
