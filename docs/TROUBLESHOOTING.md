# Troubleshooting

## Guest login closes immediately

Check `/tmp/user-reset-USER.log`. The reset must preserve `.local/share/xrdp` and other active XRDP session files. The current reset script already does this.

## Desktop launchers are missing

The container uses real `.desktop` files and writes the XFCE trust checksum with GIO in the active session bus. Check `/tmp/session-init-USER.log` and verify that normal files/folders are visible on `~/Schreibtisch`.

## RDP client drives are missing

Confirm `/dev/fuse` is mapped into the container and the container has `SYS_ADMIN`. In the RDP client enable local drive redirection.

## No audio

Check:

```bash
pactl list short sinks
pactl list short sources
cat /tmp/xrdp-audio-*.log
```

## Wrong time

Set `TZ=Europe/Berlin` (or another valid zone). The entrypoint updates `/etc/localtime` and `/etc/timezone` on every container start.

## Printer missing

Check:

```bash
lpstat -r
lpstat -p -d
```

Verify the `RDP_PRINTERS` format and that the printer URI is reachable from the container.

## Unraid container cannot be edited

Use the provided Unraid template. It includes `net.unraid.docker.managed=dockerman` and stores all important runtime values as DockerMan variables.
