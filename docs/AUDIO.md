# RDP audio

Audio redirection uses the official `pulseaudio-module-xrdp` sink/source modules.

Set:

```text
RDP_AUDIO_ENABLED=1
```

In the Windows Remote Desktop client enable:

- **Remote audio playback -> Play on this computer**
- **Remote audio recording -> Record from this computer**

Inside the session check:

```bash
pactl list short sinks
pactl list short sources
```

Expected devices include `xrdp-sink` and `xrdp-source`.

Session logs are written to `/tmp/xrdp-audio-USER.log` inside the container.
