# Benutzer / Users

## Deutsch

`RDP_USERS` verwendet dieses Format:

```text
name:uid:gid:admin
```

Mehrere Benutzer werden mit `;` getrennt.

Beispiel:

```text
admin:1000:1000:1;guest:1001:1001:0
```

Das letzte Feld bedeutet:

- `1` = Administrator
- `0` = Gast-/Standardkonto

### Passwörter

Admin-Konten (`admin=1`) verwenden immer:

```text
RDP_MASTER_PASSWORD
```

Gast-/Standardkonten (`admin=0`) verwenden getrennt davon:

```text
RDP_GUEST_PASSWORD
```

ob dieses Gast-Passwort tatsächlich verlangt wird, steuert:

```text
RDP_GUEST_PASSWORD_ENABLED
```

Werte:

```text
1 = Gast-Passwort ist aktiv
0 = Gast-Passwort ist deaktiviert, Gast meldet sich ohne Passwort an
```

Beispiel mit getrennten Passwörtern:

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

Beispiel ohne Gast-Passwort:

```text
RDP_MASTER_PASSWORD=MeinAdminPasswort
RDP_GUEST_PASSWORD_ENABLED=0
```

Dann gilt:

```text
admin -> MeinAdminPasswort
guest -> Passwortfeld leer lassen
```

Das Admin-Masterpasswort darf niemals leer sein. Passwortlose Gastkonten sollten nur in einem vertrauenswürdigen LAN oder über VPN verwendet werden.

Die frühere Variable `RDP_PASSWORDLESS_STANDARD_USERS` bleibt aus Kompatibilitätsgründen erhalten. Neue Installationen sollten `RDP_GUEST_PASSWORD_ENABLED` verwenden.

### Gast-Reset

Wenn `RESET_STANDARD_USERS=1`, werden Standard-/Gastkonten beim Start einer neuen XRDP-Sitzung zurückgesetzt. Persönliche Dateien, Browserprofile, LibreOffice-/GIMP-/Xournal++-Einstellungen, XFCE-Einstellungen und `~/.cups/lpoptions` werden entfernt und neu aufgebaut.

Erhalten bleiben absichtlich XRDP-relevante Sitzungsdateien wie:

- `.Xauthority`
- `.xsession`
- `.profile`
- `.pam_environment`
- `.local/share/xrdp`
- `.local/share/gvfs-metadata`
- `thinclient_drives`

Admin-Konten werden nicht zurückgesetzt.

---

## English

`RDP_USERS` uses this format:

```text
name:uid:gid:admin
```

Multiple users are separated with `;`.

Example:

```text
admin:1000:1000:1;guest:1001:1001:0
```

The final field means:

- `1` = administrator
- `0` = guest/standard account

### Passwords

Administrator accounts (`admin=1`) always use:

```text
RDP_MASTER_PASSWORD
```

Guest/standard accounts (`admin=0`) use the separate:

```text
RDP_GUEST_PASSWORD
```

Whether that guest password is required is controlled by:

```text
RDP_GUEST_PASSWORD_ENABLED
```

Values:

```text
1 = require the guest password
0 = disable the guest password and allow an empty password
```

Example with separate passwords:

```text
RDP_MASTER_PASSWORD=MyAdminPassword
RDP_GUEST_PASSWORD=MyGuestPassword
RDP_GUEST_PASSWORD_ENABLED=1
```

Example with passwordless guests:

```text
RDP_MASTER_PASSWORD=MyAdminPassword
RDP_GUEST_PASSWORD_ENABLED=0
```

The administrator master password may never be empty. Passwordless guest accounts should only be used on a trusted LAN or over VPN.

The former `RDP_PASSWORDLESS_STANDARD_USERS` variable remains supported for backwards compatibility. New installations should use `RDP_GUEST_PASSWORD_ENABLED`.

### Guest reset

When `RESET_STANDARD_USERS=1`, guest/standard accounts are reset at the start of a new XRDP session. Personal files, browser profiles, LibreOffice/GIMP/Xournal++ settings, XFCE settings and `~/.cups/lpoptions` are removed and recreated.

XRDP session infrastructure is deliberately preserved, including `.Xauthority`, `.xsession`, `.profile`, `.pam_environment`, `.local/share/xrdp`, `.local/share/gvfs-metadata` and `thinclient_drives`.

Administrator accounts are not reset.
