#!/bin/bash
set -ouex pipefail

echo "Installing System Packages..."

# Remove VSCode
rpm-ostree override remove code

# Install Core System Components
rpm-ostree install \
  unzip \
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
  fuzzel
