FROM ubuntu:24.04

ARG XRDP_VERSION=0.10.6.1
ARG XORGXRDP_VERSION=0.10.5
ARG XOURNAL_VERSION=1.3.8
ARG XOURNAL_SHA256=77a4fb0728e9d2b1d2d743706482344054ae17014e17adbd777c32081a238dfb

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de \
    LC_MESSAGES=de_DE.UTF-8 \
    LC_ALL=de_DE.UTF-8 \
    TZ=Europe/Berlin

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Ubuntu's minimal container image excludes translation .mo files by default.
RUN if [ -f /etc/dpkg/dpkg.cfg.d/excludes ]; then \
      cp -a /etc/dpkg/dpkg.cfg.d/excludes /etc/dpkg/dpkg.cfg.d/excludes.original; \
      sed -i '\|^[[:space:]]*path-exclude=/usr/share/locale/\*/LC_MESSAGES/\*.mo[[:space:]]*$|s|^|# |' /etc/dpkg/dpkg.cfg.d/excludes; \
    fi \
 && for SRC in /etc/apt/sources.list.d/*.sources; do \
      [ -f "$SRC" ] || continue; sed -i 's/^Types: deb$/Types: deb deb-src/' "$SRC"; \
    done

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates software-properties-common \
 && add-apt-repository -y universe \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    curl wget gnupg git locales gettext tzdata sudo zenity dbus dbus-x11 dbus-user-session \
    policykit-1 policykit-1-gnome at-spi2-core xauth x11-xserver-utils xdg-user-dirs xdg-utils \
    desktop-file-utils gvfs gvfs-common gvfs-daemons gvfs-backends gvfs-fuse libglib2.0-bin \
    xfce4 xfce4-goodies xfce4-terminal xfdesktop4 xfdesktop4-data thunar thunar-data tumbler mousepad \
    libxfce4ui-common supervisor xserver-xorg-core xserver-xorg-dev keyboard-configuration \
    language-pack-de language-pack-de-base language-pack-gnome-de language-pack-gnome-de-base \
    libreoffice libreoffice-l10n-de libreoffice-help-de hunspell-de-de hyphen-de mythes-de \
    evince pdfarranger qpdf poppler-utils gimp gimp-help-de synaptic gdebi software-properties-gtk \
    elementary-xfce-icon-theme adwaita-icon-theme hicolor-icon-theme humanity-icon-theme \
    librsvg2-common libgdk-pixbuf2.0-bin mesa-utils mesa-va-drivers mesa-vulkan-drivers libva2 vainfo \
    intel-media-va-driver ffmpeg fuse3 libfuse3-dev pulseaudio pulseaudio-utils pavucontrol alsa-utils \
    libpulse-dev cups cups-client cups-bsd cups-filters cups-ipp-utils system-config-printer \
    printer-driver-hpcups hplip fonts-dejavu fonts-liberation fonts-noto-core fonts-noto-color-emoji \
    procps psmisc nano less unzip openssl build-essential autoconf automake autotools-dev libtool m4 \
    pkg-config nasm libssl-dev libpam0g-dev libx11-dev libxfixes-dev libxrandr-dev libxkbfile-dev \
    libjpeg-dev libpixman-1-dev libopus-dev libgbm-dev libepoxy-dev lsb-release dpkg-dev meson ninja-build doxygen \
 && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^# *\(de_DE.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
 && locale-gen de_DE.UTF-8 \
 && ln -snf /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
 && echo Europe/Berlin >/etc/timezone \
 && printf '%s\n' 'XKBMODEL="pc105"' 'XKBLAYOUT="de"' 'XKBVARIANT=""' 'XKBOPTIONS=""' >/etc/default/keyboard \
 && test -s /usr/share/locale/de/LC_MESSAGES/thunar.mo \
 && test -s /usr/share/locale/de/LC_MESSAGES/xfdesktop.mo \
 && test -s /usr/share/locale/de/LC_MESSAGES/libxfce4ui.mo \
 && (userdel -r ubuntu 2>/dev/null || true) \
 && (groupdel ubuntu 2>/dev/null || true)

# Mozilla Firefox + German language pack.
RUN install -d -m 0755 /etc/apt/keyrings \
 && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /etc/apt/keyrings/packages.mozilla.org.asc \
 && echo 'deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main' >/etc/apt/sources.list.d/mozilla.list \
 && printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' >/etc/apt/preferences.d/mozilla \
 && apt-get update \
 && apt-get install -y firefox firefox-l10n-de \
 && rm -rf /var/lib/apt/lists/*

# Google Chrome.
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb \
 && apt-get update \
 && apt-get install -y /tmp/chrome.deb \
 && rm -f /tmp/chrome.deb \
 && rm -rf /var/lib/apt/lists/*

# Xournal++ 1.3.8 and Jammy qpdf ABI dependency.
RUN curl -fL https://archive.ubuntu.com/ubuntu/pool/main/q/qpdf/libqpdf28_10.6.3-1ubuntu0.1_amd64.deb -o /tmp/libqpdf28.deb \
 && apt-get update \
 && apt-get install -y /tmp/libqpdf28.deb \
 && rm -f /tmp/libqpdf28.deb \
 && curl -fL "https://github.com/xournalpp/xournalpp/releases/download/v${XOURNAL_VERSION}/xournalpp-${XOURNAL_VERSION}-Ubuntu-jammy-x86_64.deb" -o /tmp/xournalpp.deb \
 && printf '%s  %s\n' "$XOURNAL_SHA256" /tmp/xournalpp.deb | sha256sum -c - \
 && apt-get install -y /tmp/xournalpp.deb \
 && rm -f /tmp/xournalpp.deb \
 && curl -fL "https://raw.githubusercontent.com/xournalpp/xournalpp/v${XOURNAL_VERSION}/po/de.po" -o /tmp/xournal-de.po \
 && mkdir -p /usr/share/locale/de/LC_MESSAGES /usr/share/locale/de_DE/LC_MESSAGES \
 && msgfmt /tmp/xournal-de.po -o /usr/share/locale/de/LC_MESSAGES/xournalpp.mo \
 && ln -sf ../../de/LC_MESSAGES/xournalpp.mo /usr/share/locale/de_DE/LC_MESSAGES/xournalpp.mo \
 && rm -f /tmp/xournal-de.po \
 && ldconfig \
 && rm -rf /var/lib/apt/lists/*

# XRDP.
RUN getent group xrdp >/dev/null || groupadd --system xrdp; \
    id xrdp >/dev/null 2>&1 || useradd --system --gid xrdp --home-dir /run/xrdp --shell /usr/sbin/nologin xrdp \
 && git clone --branch "v${XRDP_VERSION}" --depth 1 --recursive https://github.com/neutrinolabs/xrdp.git /tmp/xrdp \
 && cd /tmp/xrdp \
 && ./bootstrap \
 && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib/x86_64-linux-gnu \
      --with-socketdir=/run/xrdp/sockdir --enable-ipv6 --enable-jpeg --enable-fuse --enable-painter \
      --enable-rfxcodec --enable-pixman --enable-opus \
 && make -j"$(nproc)" \
 && make install \
 && ldconfig

# xorgxrdp.
RUN git clone --branch "v${XORGXRDP_VERSION}" --depth 1 https://github.com/neutrinolabs/xorgxrdp.git /tmp/xorgxrdp \
 && cd /tmp/xorgxrdp \
 && ./bootstrap \
 && PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu \
 && make -j"$(nproc)" \
 && make install \
 && mkdir -p /etc/X11/xrdp \
 && cp /tmp/xorgxrdp/xrdpdev/xorg.conf /etc/X11/xrdp/xorg.conf \
 && ldconfig

# Official XRDP PulseAudio sink/source modules.
RUN apt-get update \
 && apt-get build-dep -y pulseaudio \
 && git clone --depth 1 https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /tmp/pulseaudio-module-xrdp \
 && cd /tmp/pulseaudio-module-xrdp \
 && ./scripts/install_pulseaudio_sources_apt.sh -d /tmp/pulseaudio.src \
 && ./bootstrap \
 && ./configure PULSE_DIR=/tmp/pulseaudio.src \
 && make -j"$(nproc)" \
 && make install \
 && rm -f /etc/xdg/autostart/pulseaudio-xrdp.desktop \
 && test -x /usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh \
 && rm -rf /tmp/pulseaudio-module-xrdp /tmp/pulseaudio.src /var/lib/apt/lists/*

COPY rootfs/ /

RUN chmod 755 /entrypoint.sh /etc/xrdp/startwm.sh /usr/local/bin/* /usr/local/sbin/* \
 && mkdir -p /run/xrdp/sockdir /etc/supervisor/conf.d /usr/local/share/applications \
 && chmod 1777 /run/xrdp/sockdir \
 && if grep -q '^FuseMountName=' /etc/xrdp/sesman.ini; then \
      sed -i 's#^FuseMountName=.*#FuseMountName=thinclient_drives#' /etc/xrdp/sesman.ini; \
    else \
      sed -i '/^\[Chansrv\]/a FuseMountName=thinclient_drives' /etc/xrdp/sesman.ini; \
    fi \
 && openssl req -x509 -newkey rsa:2048 -nodes -keyout /etc/xrdp/key.pem -out /etc/xrdp/cert.pem -days 3650 -subj '/CN=Ubuntu-XRDP' \
 && chown root:xrdp /etc/xrdp/key.pem \
 && chmod 640 /etc/xrdp/key.pem \
 && update-desktop-database /usr/local/share/applications \
 && rm -rf /tmp/xrdp /tmp/xorgxrdp

EXPOSE 3389
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
