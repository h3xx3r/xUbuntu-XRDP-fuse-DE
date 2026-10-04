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

## Password behavior

Admin accounts (`admin=1`) always receive the configured `RDP_MASTER_PASSWORD`.

When:

```text
RDP_PASSWORDLESS_STANDARD_USERS=1
```

all standard accounts (`admin=0`) receive an empty password. In the XRDP login dialog, enter the guest username and leave the password field empty.

Example:

```text
admin -> use RDP_MASTER_PASSWORD
guest -> leave password empty
```

To require `RDP_MASTER_PASSWORD` for standard accounts as well, use:

```text
RDP_PASSWORDLESS_STANDARD_USERS=0
```

Passwordless standard accounts should only be used on a trusted LAN or VPN.

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
