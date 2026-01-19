# Custom Universal Blue Image with GNOME and Niri
FROM ghcr.io/ublue-os/silverblue-main:latest

# ===== ADD COPR REPOSITORIES =====
# These provide packages not in the default Fedora repos

# Niri compositor repository
RUN curl -L https://copr.fedorainfracloud.org/coprs/yalter/niri/repo/fedora-$(rpm -E %fedora)/yalter-niri-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yalter-niri.repo

# DankLinux repository (for DankMaterialShell dependencies)
RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/danklinux/repo/fedora-$(rpm -E %fedora)/avengemedia-danklinux-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-danklinux.repo

# DankMaterialShell repository
RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-dms.repo

# ===== ADD SMALLSTEP REPOSITORY =====
# For step-ca and step-cli (certificate authority tools)
RUN cat > /etc/yum.repos.d/smallstep.repo << 'REPO_EOF'
[smallstep]
name=Smallstep
baseurl=https://packages.smallstep.com/stable/fedora/
enabled=1
repo_gpgcheck=0
gpgcheck=1
gpgkey=https://packages.smallstep.com/keys/smallstep-0x889B19391F774443.gpg
REPO_EOF

# ===== INSTALL ALL PACKAGES =====
RUN rpm-ostree install \
    # Wayland compositor
    niri \
    # Desktop shell components
    quickshell-git \
    dms \
    # Terminal emulators
    alacritty \
    kitty \
    # Text editors
    emacs \
    neovim \
    # Development tools
    golang \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-devel \
    # Build tools
    git \
    gcc \
    gcc-c++ \
    make \
    cmake \
    # Remote desktop tools
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-exec \
    remmina-plugins-secret \
    freerdp \
    # System utilities
    systemd-homed \
    # Shell utilities
    starship \
    matugen \
    # Certificate authority tools
    step-cli \
    step-ca \
    # Fonts (for terminals and editors)
    jetbrains-mono-fonts-all \
    google-noto-emoji-fonts \
    && rpm-ostree cleanup -m

# ===== COPY CONFIGURATION FILES =====
# Copy all config files to a system location
COPY config /usr/share/custom-ublue
COPY scripts /usr/share/custom-ublue/scripts

# Make scripts executable
RUN chmod +x /usr/share/custom-ublue/scripts/*.sh

# Copy configs to /etc/skel for new users
RUN mkdir -p /etc/skel/.config/{niri,alacritty,kitty,nvim}
COPY config/niri/config.kdl /etc/skel/.config/niri/
COPY config/alacritty/alacritty.toml /etc/skel/.config/alacritty/
COPY config/kitty/kitty.conf /etc/skel/.config/kitty/
COPY config/starship/starship.toml /etc/skel/.config/starship.toml

# Install custom just recipes
COPY 60-custom.just /usr/share/ublue-os/just/60-custom.just

# ===== SETUP STARSHIP PROMPT =====
# Add starship initialization to bash and zsh
RUN echo 'eval "$(starship init bash)"' >> /etc/bashrc && \
    echo 'eval "$(starship init zsh)"' >> /etc/zshrc || true

# ===== METADATA =====
LABEL org.opencontainers.image.title="Custom Universal Blue - GNOME/Niri Edition"
LABEL org.opencontainers.image.description="Universal Blue with GNOME, niri, DankMaterialShell, development tools, Smallstep CA, and pre-configured dotfiles"
LABEL org.opencontainers.image.version="1.0"
