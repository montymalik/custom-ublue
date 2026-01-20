FROM ghcr.io/ublue-os/bluefin-dx:latest

# ===== 1. COMPOSITION (The Modern Way) =====
# Instead of downloading tarballs, we "borrow" binaries from official images.
# This is faster, safer, and never has broken URLs.

# ShellCheck (Linting)
COPY --from=docker.io/koalaman/shellcheck-alpine:stable /bin/shellcheck /usr/bin/shellcheck

# Pandoc (Document Converter)
COPY --from=docker.io/pandoc/core:latest /usr/bin/pandoc /usr/bin/pandoc

# Matugen (Material You Generator)
# (Matugen doesn't have an official "bin" image yet, so we keep the curl method for now,
#  but we move it to a dedicated build stage to keep the final image clean).

# ===== 2. REPOSITORIES =====

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

# ===== 3. PACKAGES (rpm-ostree) =====

# Remove VSCode (Lean Build)
RUN rpm-ostree override remove code && \
    rpm-ostree cleanup -m

# Install Everything in one clean transaction
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
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-secret \
    niri \
    quickshell-git \
    dms \
    fuzzel \
    && rpm-ostree cleanup -m

# ===== 4. MANUAL INSTALLS (Legacy Scripts) =====

# Install Matugen
RUN curl -Lo /tmp/matugen.tar.gz https://github.com/InioX/matugen/releases/download/v3.1.0/matugen-3.1.0-x86_64.tar.gz && \
    tar -xzf /tmp/matugen.tar.gz -C /tmp && \
    find /tmp -name matugen -type f -exec mv {} /usr/bin/matugen \; && \
    chmod +x /usr/bin/matugen && \
    rm -rf /tmp/matugen*

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
