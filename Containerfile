# --- SYSTEM MAINTENANCE ---

# Overrides the default Bluefin update command
# Updates CLI tools, Apps, and the System Image in one go.
update:
    echo "=== 🍺 Updating Homebrew ==="
    brew upgrade
    
    echo "=== 📦 Updating Flatpaks ==="
    flatpak update -y
    
    echo "=== 💿 Updating System Image ==="
    # Checks for image updates (rpm-ostree) and firmware updates (fwupd)
    rpm-ostree upgrade

# Name: bluefin-dx-niri-custom
FROM ghcr.io/ublue-os/bluefin-dx:latest

# 1. COPY BUILD SCRIPTS
COPY build /tmp/build

# 2. RUN BUILD SCRIPTS
RUN chmod +x /tmp/build/*.sh && \
    /tmp/build/10-repos.sh && \
    /tmp/build/20-packages.sh && \
    /tmp/build/30-manual.sh && \
    rpm-ostree cleanup -m && \
    rm -rf /tmp/build

# 3. COPY CONFIG & JUSTFILES
COPY config /usr/share/custom-ublue
COPY scripts /usr/share/custom-ublue/scripts
RUN chmod +x /usr/share/custom-ublue/scripts/*.sh

# Copy your custom Just commands to the system location
COPY custom/ujust/setup.just /usr/share/ublue-os/just/60-custom.just

# 4. COPY BREW & FLATPAK LISTS
# Bluefin knows to look in /usr/share/ublue-os/ for these
COPY custom/brew/Brewfile /usr/share/ublue-os/brew/Brewfile
COPY custom/flatpaks/flatpaks /usr/share/ublue-os/flatpak/overrides/user-flatpaks.txt

LABEL org.opencontainers.image.title="Custom Bluefin DX - Niri Edition"
