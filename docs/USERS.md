# Users and guest reset

`RDP_USERS` uses this format:

```text
name:uid:gid:admin
```

Multiple users are separated with `;`.

Example:

```text
admin:1000:1000:1;guest:1001:1001:0
```

The final field is `1` for administrator and `0` for standard/resettable account.

## Reset behavior

When `RESET_STANDARD_USERS=1`, standard users are reset at the start of a new XRDP session. Personal files, browser profiles, LibreOffice/GIMP/Xournal++ settings, XFCE settings and `~/.cups/lpoptions` are removed and recreated.

The reset deliberately preserves XRDP session infrastructure such as:

- `.Xauthority`
- `.xsession`
- `.profile`
- `.pam_environment`
- `.local/share/xrdp`
- `.local/share/gvfs-metadata`
- `thinclient_drives`

This avoids terminating the XRDP session while it is being created.

Administrators are not reset.
