# Custom Universal Blue Image with GNOME and Niri
FROM ghcr.io/ublue-os/silverblue-main:latest

# ===== ADD COPR REPOSITORIES =====
RUN curl -L https://copr.fedorainfracloud.org/coprs/yalter/niri/repo/fedora-$(rpm -E %fedora)/yalter-niri-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/yalter-niri.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/danklinux/repo/fedora-$(rpm -E %fedora)/avengemedia-danklinux-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-danklinux.repo

RUN curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo \
    -o /etc/yum.repos.d/avengemedia-dms.repo

# ===== ADD SMALLSTEP REPOSITORY =====
RUN printf '[smallstep]\n\
name=Smallstep\n\
baseurl=https://packages.smallstep.com/stable/fedora/\n\
enabled=1\n\
repo_gpgcheck=0\n\
gpgcheck=1\n\
gpgkey=https://packages.smallstep.com/keys/smallstep-0x889B19391F774443.gpg\n' > /etc/yum.repos.d/smallstep.repo

# ===== INSTALL ALL PACKAGES =====
RUN rpm-ostree install \
    niri \
    quickshell-git \
    dms \
    alacritty \
    kitty \
    emacs \
    neovim \
    golang \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-devel \
    git \
    gcc \
    gcc-c++ \
    make \
    cmake \
    rust \
    cargo \
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-exec \
    remmina-plugins-secret \
    freerdp \
    matugen \
    step-cli \
    step-ca \
    jetbrains-mono-fonts-all \
    google-noto-emoji-fonts \
    && rpm-ostree cleanup -m

# ===== COPY CONFIGURATION FILES =====
COPY config /usr/share/custom-ublue
COPY scripts /usr/share/custom-ublue/scripts

RUN chmod +x /usr/share/custom-ublue/scripts/*.sh

# Copy configs to /etc/skel for new users
RUN mkdir -p /etc/skel/.config/{niri,alacritty,kitty,nvim}

COPY config/niri/config.kdl /etc/skel/.config/niri/
COPY config/alacritty/alacritty.toml /etc/skel/.config/alacritty/
COPY config/alacritty/dank-theme.toml /etc/skel/.config/alacritty/
COPY config/alacritty/catppuccin-macchiato.toml /etc/skel/.config/alacritty/
COPY config/kitty/kitty.conf /etc/skel/.config/kitty/
COPY config/kitty/dank-tabs.conf /etc/skel/.config/kitty/
COPY config/kitty/dank-theme.conf /etc/skel/.config/kitty/
COPY config/kitty/catppuccin-macchiato.conf /etc/skel/.config/kitty/
COPY config/starship/starship.toml /etc/skel/.config/starship.toml

COPY 60-custom.just /usr/share/ublue-os/just/60-custom.just

# ===== METADATA =====
LABEL org.opencontainers.image.title="Custom Universal Blue - GNOME/Niri Edition"
LABEL org.opencontainers.image.description="Universal Blue with GNOME, niri, DankMaterialShell, development tools, Smallstep CA, and pre-configured dotfiles"
LABEL org.opencontainers.image.version="1.0"
