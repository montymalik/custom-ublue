#!/bin/bash
set -ouex pipefail

echo "Adding Repositories..."

FEDORA_VERSION="$(rpm -E %fedora)"
COPR_URL="https://copr.fedorainfracloud.org/coprs"

# Tailscale is already shipped (repo + package) by the Bluefin base image.

# Niri & Desktop Components
curl -fL "${COPR_URL}/yalter/niri/repo/fedora-${FEDORA_VERSION}/yalter-niri-fedora-${FEDORA_VERSION}.repo" \
  -o /etc/yum.repos.d/yalter-niri.repo

curl -fL "${COPR_URL}/avengemedia/danklinux/repo/fedora-${FEDORA_VERSION}/avengemedia-danklinux-fedora-${FEDORA_VERSION}.repo" \
  -o /etc/yum.repos.d/avengemedia-danklinux.repo

curl -fL "${COPR_URL}/avengemedia/dms/repo/fedora-${FEDORA_VERSION}/avengemedia-dms-fedora-${FEDORA_VERSION}.repo" \
  -o /etc/yum.repos.d/avengemedia-dms.repo
