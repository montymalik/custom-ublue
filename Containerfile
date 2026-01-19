FROM ghcr.io/ublue-os/bluefin-dx:latest

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

# ===== INSTALL PACKAGES =====
RUN rpm-ostree install \
    niri \
    quickshell-git \
    dms \
    fuzzel \
    alacritty \
    kitty \
    emacs \
    remmina \
    remmina-plugins-rdp \
    remmina-plugins-vnc \
    remmina-plugins-exec \
    remmina-plugins-secret \
    freerdp \
    matugen \
    step-cli \
    step-ca \
    google-noto-emoji-fonts \
    && rpm-ostree cleanup -m

# ===== COPY CONFIGURATION FILES =====
# This copies your entire local 'config/' folder to the image.
# Ensure your local folder structure matches:
# config/
#   ├── alacritty/
#   │   ├── alacritty.toml
#   │   ├── dank-theme.toml
#   │   └── catppuccin-macchiato.toml
#   ├── kitty/
#   │   ├── kitty.conf
#   │   ├── dank-tabs.conf
#   │   ├── dank-theme.conf
#   │   └── catppuccin-macchiato.conf
#   ├── fuzzel/
#   │   └── fuzzel.ini
#   └── niri/ ...
COPY config /usr/share/custom-ublue

COPY scripts /usr/share/custom-ublue/scripts
RUN chmod +x /usr/share/custom-ublue/scripts/*.sh

COPY 60-custom.just /usr/share/ublue-os/just/60-custom.just

# ===== METADATA =====
LABEL org.opencontainers.image.title="Custom Bluefin DX - Niri Edition"
LABEL org.opencontainers.image.description="Bluefin DX with Niri, DankMaterialShell, Fuzzel, and Custom Themes"
LABEL org.opencontainers.image.version="1.0"
