#!/bin/bash
set -ouex pipefail

echo "Installing System Packages..."

# Remove VSCode
rpm-ostree override remove code

# Keep the Qt 6 stack in sync with Fedora updates.
# quickshell-git from the avengemedia COPR is built against the current
# qt6-qtbase in updates; the Bluefin base can lag behind by a patch release,
# and RPM deps do not catch that, so qs fails at runtime with a symbol lookup
# error (undefined symbol ... version Qt_6). Upgrading Qt first avoids it.
dnf5 -y upgrade 'qt6-qt*'

# Install Core System Components
rpm-ostree install \
  unzip \
  ncurses-term \
  kitty-terminfo \
  alacritty \
  kitty \
  freerdp \
  google-noto-emoji-fonts \
  jetbrains-mono-fonts \
  fira-code-fonts \
  adobe-source-code-pro-fonts \
  cascadia-code-fonts \
  google-noto-sans-mono-fonts \
  google-droid-sans-mono-fonts \
  tailscale \
  remmina \
  remmina-plugins-rdp \
  remmina-plugins-vnc \
  remmina-plugins-secret \
  niri \
  quickshell-git \
  dms \
  nfs-utils \
  autofs \
  fuzzel
