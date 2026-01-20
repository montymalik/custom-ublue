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

# --- Tailscale & Yazi ---
RUN curl -L https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
    -o /etc/yum.repos.d/tailscale.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/lihaohong/yazi/repo/fedora-$(rpm -E %fedora)/lihaohong-yazi-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yazi.repo

# ===== 2. REMOVE PACKAGES =====

# Remove VSCode (code) because you use Neovim/Emacs
# This saves space and removes the "bluefin-dx" default IDE
RUN rpm-ostree override remove code && \
    rpm-ostree cleanup -m

# ===== 3. INSTALL PACKAGES =====

# Batch 1: Core GUI, Editors & CLI Bling
RUN rpm-ostree install \
    unzip \
    neovim \
    alacritty \
    kitty \
    emacs \
    freerdp \
    google-noto-emoji-fonts \
    # --- NETWORKING ---
    tailscale \
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

# Install DevContainers CLI (Standalone)
# Allows using devcontainers with Neovim/Terminal without VSCode
RUN npm install -g @devcontainers/cli

# Install Matugen
RUN curl -Lo /tmp/matugen.tar.gz https://github.com/InioX/matugen/releases/download/v3.1.0/matugen-3.1.0-x86_64.tar.gz && \
    tar -xzf /tmp/matugen.tar.gz -C /tmp && \
    find /tmp -name matugen -type f -exec mv {} /usr/bin/matugen \; && \
    chmod +x /usr/bin/matugen && \
    rm -rf /tmp/matugen*

# Install ShellCheck (Static)
RUN curl -Lo /tmp/shellcheck.tar.xz https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz && \
    tar -xf /tmp/shellcheck.tar.xz -C /tmp && \
    mv /tmp/shellcheck-v0.10.0/shellcheck /usr/bin/shellcheck && \
    chmod +x /usr/bin/shellcheck && \
    rm -rf /tmp/shellcheck*

# Install Pandoc (Static)
RUN curl -Lo /tmp/pandoc.tar.gz https://github.com/jgm/pandoc/releases/download/3.1.11.1/pandoc-3.1.11.1-linux-amd64.tar.gz && \
    tar -xzf /tmp/pandoc.tar.gz -C /tmp && \
    find /tmp -name pandoc -type f -exec mv {} /usr/bin/pandoc \; && \
    chmod +x /usr/bin/pandoc && \
    mkdir -p /usr/share/man/man1 && \
    find /tmp -name pandoc.1 -type f -exec mv {} /usr/share/man/man1/ \; && \
    rm -rf /tmp/pandoc*

# Install Nerd Fonts
RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip && \
    unzip -o /tmp/JetBrainsMono.zip -d /usr/share/fonts/nerd-fonts && \
    rm /tmp/JetBrainsMono.zip && \
    fc-cache -fv

# ===== 5. CONFIGURATION =====
COPY config /usr/share/custom-ublue
COPY scripts /usr/share/custom-ublue/scripts
RUN chmod +x /usr/share/custom-ublue/scripts/*.sh
COPY 60-custom.just /usr/share/ublue-os/just/60-custom.just

LABEL org.opencontainers.image.title="Custom Bluefin DX - Niri Edition"
