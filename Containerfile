FROM ghcr.io/ublue-os/bluefin-dx:latest

# ===== 1. ADD REPOSITORIES =====

# --- Core Desktop Components ---
RUN curl -L https://copr.fedorainfracloud.org/coprs/yalter/niri/repo/fedora-$(rpm -E %fedora)/yalter-niri-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yalter-niri.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/danklinux/repo/fedora-$(rpm -E %fedora)/avengemedia-danklinux-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-danklinux.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-dms.repo

# --- CLI Tools ---
RUN curl -L https://copr.fedorainfracloud.org/coprs/atim/lazygit/repo/fedora-$(rpm -E %fedora)/atim-lazygit-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/lazygit.repo

# NEW: Yazi Repo (Unofficial COPR)
RUN curl -L https://copr.fedorainfracloud.org/coprs/lihaohong/yazi/repo/fedora-$(rpm -E %fedora)/lihaohong-yazi-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yazi.repo

RUN printf '[charm]\n\
name=Charm\n\
baseurl=https://repo.charm.sh/yum/\n\
enabled=1\n\
gpgcheck=1\n\
gpgkey=https://repo.charm.sh/yum/gpg.key\n' > /etc/yum.repos.d/charm.repo

RUN printf '[smallstep]\n\
name=Smallstep\n\
baseurl=https://packages.smallstep.com/stable/fedora/\n\
enabled=1\n\
repo_gpgcheck=0\n\
gpgcheck=1\n\
gpgkey=https://packages.smallstep.com/keys/smallstep-0x889B19391F774443.gpg\n' > /etc/yum.repos.d/smallstep.repo

# ===== 2. INSTALL PACKAGES =====

# Batch 1: Core GUI, Editors & CLI Bling
RUN rpm-ostree install \
    unzip \
    neovim \
    alacritty \
    kitty \
    emacs \
    freerdp \
    google-noto-emoji-fonts \
    # --- CLI BLING ---
    gum \
    glow \
    atuin \
    lazygit \
    bat \
    zoxide \
    tealdeer \
    trash-cli \
    btop \
    yazi \
    # REMOVED: eza (as requested)
    pandoc \
    ShellCheck \
    && rpm-ostree cleanup -m

# Batch 2: Remmina
RUN rpm-ostree install \
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-exec \
    remmina-plugins-secret \
    && rpm-ostree cleanup -m

# Batch 3: Smallstep CLI
RUN rpm-ostree install step-cli && rpm-ostree cleanup -m

# Batch 4: Niri & COPRs
RUN rpm-ostree install \
    niri \
    quickshell-git \
    dms \
    fuzzel \
    && rpm-ostree cleanup -m

# ===== 3. MANUAL INSTALLS =====

# Install Matugen (Manual Archive)
RUN curl -Lo /tmp/matugen.tar.gz https://github.com/InioX/matugen/releases/download/v3.1.0/matugen-3.1.0-x86_64.tar.gz && \
    tar -xzf /tmp/matugen.tar.gz -C /tmp && \
    find /tmp -name matugen -type f -exec mv {} /usr/bin/matugen \; && \
    chmod +x /usr/bin/matugen && \
    rm -rf /tmp/matugen*

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
