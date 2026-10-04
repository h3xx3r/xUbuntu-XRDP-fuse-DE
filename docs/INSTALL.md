# Installation

## Unraid

Use the provided template `unraid/my-Ubuntu-XRDP.xml` or run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/h3xx3r/xUbuntu-XRDP-fuse-DE/main/scripts/install-unraid.sh)
```

Then open **Docker -> Add Container** and select **Ubuntu-XRDP**.

Important settings:

- `RDP_USERS`: `name:uid:gid:admin`, entries separated by `;`
- `RDP_MASTER_PASSWORD`: shared RDP password
- `RESET_STANDARD_USERS`: `1` resets standard users on a new session
- `RDP_AUDIO_ENABLED`: `1` enables RDP speaker/microphone redirection
- `RDP_PRINTERS`: per-user printer mappings
- `/home`: persistent user profiles and printer golden profiles
- `TZ`: defaults to `Europe/Berlin`

The template adds `/dev/fuse`, `SYS_ADMIN`, DockerMan labels and 2 GiB shared memory. Add `/dev/dri/card*` and `/dev/dri/renderD*` as device mappings when GPU acceleration is wanted.

## First login

Default example users in the template are:

```text
admin:1000:1000:1;guest:1001:1001:0
```

Change the password before use. The first account name is intentionally `admin`, not a personal name.
