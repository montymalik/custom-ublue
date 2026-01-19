FROM ghcr.io/ublue-os/bluefin-dx:latest

# ===== 1. ADD REPOSITORIES =====
RUN curl -L https://copr.fedorainfracloud.org/coprs/yalter/niri/repo/fedora-$(rpm -E %fedora)/yalter-niri-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yalter-niri.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/danklinux/repo/fedora-$(rpm -E %fedora)/avengemedia-danklinux-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-danklinux.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-dms.repo

RUN printf '[smallstep]\n\
name=Smallstep\n\
baseurl=https://packages.smallstep.com/stable/fedora/\n\
enabled=1\n\
repo_gpgcheck=0\n\
gpgcheck=1\n\
gpgkey=https://packages.smallstep.com/keys/smallstep-0x889B19391F774443.gpg\n' > /etc/yum.repos.d/smallstep.repo

# ===== 2. INSTALL PACKAGES =====

# Batch 1: Core GUI & Fonts
RUN rpm-ostree install \
    unzip \
    alacritty \
    kitty \
    emacs \
    freerdp \
    google-noto-emoji-fonts \
    && rpm-ostree cleanup -m

# Batch 2: Remmina
RUN rpm-ostree install \
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-exec \
    remmina-plugins-secret \
    && rpm-ostree cleanup -m

# Batch 3: Smallstep CLI (Client only)
RUN rpm-ostree install step-cli && rpm-ostree cleanup -m

# Batch 4: Niri & COPRs
RUN rpm-ostree install \
    niri \
    quickshell-git \
    dms \
    fuzzel \
    && rpm-ostree cleanup -m

# ===== 3. MANUAL INSTALLS =====

# Install Matugen (Binary)
RUN curl -L https://github.com/InioX/matugen/releases/latest/download/matugen-linux-x86_64 -o /usr/bin/matugen && \
    chmod +x /usr/bin/matugen

# Install Nerd Fonts (Manual)
RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip && \
    unzip -o /tmp/JetBrainsMono.zip -d /usr/share/fonts/nerd-fonts && \
    rm /tmp/JetBrainsMono.zip && \
    fc-cache -fv

# ===== 4. CONFIGURATION =====
COPY config /usr/share/custom-ublue
COPY scripts /usr/share/custom-ublue/scripts
RUN chmod +x /usr/share/custom-ublue/scripts/*.sh
COPY 60-custom.just /usr/share/ublue-os/just/60-custom.just

# ===== METADATA =====
LABEL org.opencontainers.image.title="Custom Bluefin DX - Niri Edition"
LABEL org.opencontainers.image.version="1.0"
