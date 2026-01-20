FROM ghcr.io/ublue-os/bluefin-dx:latest

# ===== 1. ADD REPOSITORIES =====
RUN curl -L https://copr.fedorainfracloud.org/coprs/yalter/niri/repo/fedora-$(rpm -E %fedora)/yalter-niri-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yalter-niri.repo && \
    curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/danklinux/repo/fedora-$(rpm -E %fedora)/avengemedia-danklinux-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-danklinux.repo && \
    curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-dms.repo && \
    curl -L https://copr.fedorainfracloud.org/coprs/atim/lazygit/repo/fedora-$(rpm -E %fedora)/atim-lazygit-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/lazygit.repo && \
    curl -L https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
    -o /etc/yum.repos.d/tailscale.repo && \
    curl -L https://copr.fedorainfracloud.org/coprs/lihaohong/yazi/repo/fedora-$(rpm -E %fedora)/lihaohong-yazi-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yazi.repo

# ===== 2. REMOVE PACKAGES =====
RUN rpm-ostree override remove code || true && \
    rpm-ostree cleanup -m

# ===== 3. INSTALL PACKAGES =====
# Batch 1: Core GUI, Editors & CLI Tools
RUN rpm-ostree install \
    unzip \
    neovim \
    alacritty \
    kitty \
    emacs \
    freerdp \
    google-noto-emoji-fonts \
    tailscale \
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
    && rpm-ostree cleanup -m

# Batch 2: Remmina & Niri
RUN rpm-ostree install \
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-secret \
    niri \
    quickshell-git \
    dms \
    fuzzel \
    && rpm-ostree cleanup -m

# ===== 4. MANUAL INSTALLS =====
# Install DevContainers CLI
RUN npm install -g --prefix /usr --cache /tmp/.npm @devcontainers/cli && \
    rm -rf /tmp/.npm

# Install Matugen
RUN curl -Lo /tmp/matugen.tar.gz https://github.com/InioX/matugen/releases/download/v3.1.0/matugen-3.1.0-x86_64.tar.gz && \
    tar -xzf /tmp/matugen.tar.gz -C /tmp && \
    mv /tmp/matugen /usr/bin/matugen && \
    chmod +x /usr/bin/matugen && \
    rm -rf /tmp/matugen*

# Install ShellCheck
RUN curl -Lo /tmp/shellcheck.tar.xz https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz && \
    tar -xf /tmp/shellcheck.tar.xz -C /tmp && \
    mv /tmp/shellcheck-v0.10.0/shellcheck /usr/bin/ && \
    chmod +x /usr/bin/shellcheck && \
    rm -rf /tmp/shellcheck*

# Install Pandoc
RUN curl -Lo /tmp/pandoc.tar.gz https://github.com/jgm/pandoc/releases/download/3.1.11.1/pandoc-3.1.11.1-linux-amd64.tar.gz && \
    tar -xzf /tmp/pandoc.tar.gz -C /tmp --strip-components=1 && \
    mv /tmp/bin/pandoc /usr/bin/ && \
    mkdir -p /usr/share/man/man1 && \
    mv /tmp/share/man/man1/pandoc.1 /usr/share/man/man1/ && \
    rm -rf /tmp/pandoc*

# Install Nerd Fonts (pinned version)
RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip && \
    unzip -o /tmp/JetBrainsMono.zip -d /usr/share/fonts/nerd-fonts && \
    rm /tmp/JetBrainsMono.zip && \
    fc-cache -fv

# ===== 5. CONFIGURATION =====
COPY config /usr/share/custom-ublue
COPY scripts /usr/share/custom-ublue/scripts
RUN chmod +x /usr/share/custom-ublue/scripts/*.sh
COPY 60-custom.just /usr/share/ublue-os/just/60-custom.just

LABEL org.opencontainers.image.title="Custom Bluefin DX - Niri Edition"
