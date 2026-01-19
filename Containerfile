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
RUN printf '[smallstep]\n\
name=Smallstep\n\
baseurl=https://packages.smallstep.com/stable/fedora/\n\
enabled=1\n\
repo_gpgcheck=0\n\
gpgcheck=1\n\
gpgkey=https://packages.smallstep.com/keys/smallstep-0x889B19391F774443.gpg\n' > /etc/yum.repos.d/smallstep.repo

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
    rust \
    cargo \
    # Remote desktop tools
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-exec \
    remmina-plugins-secret \
    freerdp \
    # Shell utilities
    matugen \
    # Certificate authority tools
    step-cli \
    step-ca \
    # Fonts (for terminals and editors)
    jetbrains-mono-fonts-all \
    google-noto-emoji-fonts \
    && rpm-ostree cleanup -m

# ===== INSTALL STARSHIP PROMPT =====
# Download and install starship binary from GitHub releases
RUN STARSHIP_VERSION="1.20.1" && \
    curl -sL "https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-x86_64-unknown-linux-musl.tar.gz" \
    -o /tmp/starship.tar.gz && \
    tar -xzf /tmp/starship.tar.gz -C /tmp && \
    install -m 755 /tmp/starship /usr/local/bin/starship && \
    rm -rf /tmp/starship*

# ===== COPY CONFIGURATION FILES =====
# Copy all config files to a system location
COPY config /usr/share/custom-ublue
COPY scripts /usr/share/custom-ublue/scripts

# Make scripts executable
RUN chmod +x /usr/share/custom-ublue/scripts/*.sh

# Copy configs to /etc/skel for new users
RUN mkdir -p /etc/skel/.config/{niri,alacritty,kitty,nvim}

# Niri configuration
COPY config/niri/config.kdl /etc/skel/.config/niri/

# Alacritty configurations (main + themes)
COPY config/alacritty/alacritty.toml /etc/skel/.config/alacritty/
COPY config/alacritty/dank-theme.toml /etc/skel/.config/alacritty/
COPY config/alacritty/catppuccin-macchiato.toml /etc/skel/.config/alacritty/

# Kitty configurations (main + themes + tabs)
COPY config/kitty/kitty.conf /etc/skel/.config/kitty/
COPY config/kitty/dank-tabs.conf /etc/skel/.config/kitty/
COPY config/kitty/dank-theme.conf /etc/skel/.config/kitty/
COPY config/kitty/catppuccin-macchiato.conf /etc/skel/.config/kitty/

# Starship configuration
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
