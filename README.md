# xUbuntu-XRDP-fuse-DE

Ubuntu 24.04 XFCE Remote Desktop container for Unraid, with German desktop defaults, multi-user XRDP sessions, FUSE client-drive redirection, RDP audio/microphone, CUPS network-printer profiles, GPU passthrough and resettable guest accounts.

## Highlights

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

## Image

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:stable
```

Development builds use `:latest`; versioned releases use tags such as `:v1.0.0`.

## Unraid quick start

1. Copy `unraid/my-Ubuntu-XRDP.xml` to `/boot/config/plugins/dockerMan/templates-user/` or install it from the repository.
2. Open **Docker -> Add Container** and select the Ubuntu-XRDP template.
3. Configure `RDP_USERS`, `RDP_MASTER_PASSWORD`, home/CUPS paths, printer mappings and optional GPU devices.
4. Start the container and connect with any RDP client.

Default user specification format:

```text
admin:1000:1000:1;guest:1001:1001:0
```

The last field is `1` for an administrator and `0` for a resettable standard account.

## Printer mapping

`RDP_PRINTERS` uses:

```text
user|queue|uri|model|options
```

Example:

```text
guest|Guest_HP|ipp://192.168.1.50/ipp/print|everywhere|media=A4,sides=one-sided
```

See [docs/PRINTING.md](docs/PRINTING.md).

## Documentation

- [Installation](docs/INSTALL.md)
- [Users and guest reset](docs/USERS.md)
- [Audio](docs/AUDIO.md)
- [Printing](docs/PRINTING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Updates](docs/UPDATES.md)

## Security note

All users currently share the configured `RDP_MASTER_PASSWORD`. Do not expose XRDP directly to the public Internet. Prefer LAN/VPN access and change the password from its example/default value.

## License

Project scripts and configuration in this repository are MIT licensed. Bundled or installed third-party software remains under its respective upstream licenses.
