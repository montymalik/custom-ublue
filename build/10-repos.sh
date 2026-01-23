#!/bin/bash
set -ouex pipefail

echo "Adding Repositories..."

# Niri & Desktop Components
curl -L https://copr.fedorainfracloud.org/coprs/yalter/niri/repo/fedora-$(rpm -E %fedora)/yalter-niri-fedora-$(rpm -E %fedora).repo \
  -o /etc/yum.repos.d/yalter-niri.repo

curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/danklinux/repo/fedora-$(rpm -E %fedora)/avengemedia-danklinux-fedora-$(rpm -E %fedora).repo \
  -o /etc/yum.repos.d/avengemedia-danklinux.repo

curl -L https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo \
  -o /etc/yum.repos.d/avengemedia-dms.repo

# CLI Tools Repos
curl -L https://copr.fedorainfracloud.org/coprs/atim/lazygit/repo/fedora-$(rpm -E %fedora)/atim-lazygit-fedora-$(rpm -E %fedora).repo \
  -o /etc/yum.repos.d/lazygit.repo

# Tailscale (Stable)
curl -L https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
  -o /etc/yum.repos.d/tailscale.repo
