FROM ghcr.io/ublue-os/bluefin-dx:latest

# ===== 1. ADD REPOSITORIES =====
RUN curl -L https://copr.fedorainfracloud.org/coprs/yalter/niri/repo/fedora-$(rpm -E %fedora)/yalter-niri-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yalter-niri.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/danklinux/repo/fedora-$(rpm -E %fedora)/avengemedia-danklinux-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-danklinux.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-dms.repo

RUN printf '[google-chrome]\n\
name=google-chrome\n\
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64\n\
enabled=1\n\
gpgcheck=1\n\
gpgkey=https://dl.google.com/linux/linux_signing_key.pub\n' > /etc/yum.repos.d/google-chrome.repo

RUN printf '[smallstep]\n\
name=Smallstep\n\
baseurl=https://packages.smallstep.com/stable/fedora/\n\
enabled=1\n\
repo_gpgcheck=0\n\
gpgcheck=1\n\
gpgkey=https://packages.smallstep.com/keys/smallstep-0x889B19391F774443.gpg\n' > /etc/yum.repos.d/smallstep.repo

# ===== 2. INSTALL PACKAGES (SPLIT FOR SAFETY) =====

# Batch 1: Core GUI & Tools (Standard Fedora/Chrome/Smallstep Repos)
# We install 'unzip' here so we can use it later
RUN rpm-ostree install \
    unzip \
    google-chrome-stable \
    alacritty \
    kitty \
    emacs \
    freerdp \
    step-cli \
    step-ca \
    google-noto-emoji-fonts \
    && rpm-ostree cleanup -m

# Batch 2: Remmina & Plugins
RUN rpm-ostree install \
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-exec \
    remmina-plugins-secret \
    && rpm-ostree cleanup -m

# Batch 3: Niri & COPR Packages
# (Removed 'matugen' from here as it likely caused the failure)
RUN rpm-ostree install \
    niri \
    quickshell-git \
    dms \
    fuzzel \
    && rpm-ostree cleanup -m

# ===== 3. MANUAL INSTALLS =====

# Install Matugen (Download Binary directly)
# Matugen is not in standard repos, so we fetch the latest release.
RUN curl -L https://github.com/InioX/matugen/releases/latest/download/matugen-linux-x86_64 -o /usr/bin/matugen && \
    chmod +x /usr/bin/matugen

# Install Nerd Fonts (Manual Download)
# This is the "System Image" way. Homebrew is for user-space only.
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
