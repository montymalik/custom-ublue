#!/bin/bash
set -ouex pipefail

echo "Installing System Packages..."

# Remove VSCode (We use Neovim/Emacs)
rpm-ostree override remove code

# Install Core System Components
rpm-ostree install \
  unzip \
  alacritty \
  kitty \
  freerdp \
  google-noto-emoji-fonts \
  tailscale \
  remmina \
  remmina-plugins-rdp \
  remmina-plugins-vnc \
  remmina-plugins-secret \
  niri \
  quickshell-git \
  dms \
  fuzzel
