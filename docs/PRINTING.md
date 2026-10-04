# Printing

The container runs CUPS and rebuilds managed printer queues from the `RDP_PRINTERS` variable at startup.

## Mapping format

```text
user|queue|uri|model|options
```

Multiple printers are separated with `;`.

Example:

```text
guest|Guest_HP|ipp://192.168.1.50/ipp/print|everywhere|media=A4,sides=one-sided
```

For modern IPP printers, `everywhere` is recommended.

## Per-user access

Each managed queue is restricted to the assigned user plus administrator accounts. Managed queues are recreated on container start, so `/etc/cups` does not need to be persistent.

## Golden printer profiles

User defaults are stored in:

```text
~/.cups/lpoptions
```

For resettable users this file is restored from:

```text
/home/.ubuntu-xrdp-printer-profiles/USER/lpoptions.bak
```

That backup lives on the persistent `/home` volume.

To promote a user's current printer settings to the new default, run inside the container as root:

```bash
save-printer-profile guest
```

To regenerate profiles from `RDP_PRINTERS`, temporarily set:

```text
PRINTER_PROFILE_REFRESH=1
```

restart the container, then set it back to `0`.
