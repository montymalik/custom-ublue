#!/bin/bash
set -ouex pipefail

echo "Installing Manual Binaries..."

# Matugen (Material You Generator)
curl -Lo /tmp/matugen.tar.gz https://github.com/InioX/matugen/releases/download/v3.1.0/matugen-3.1.0-x86_64.tar.gz
tar -xzf /tmp/matugen.tar.gz -C /tmp
find /tmp -name matugen -type f -exec mv {} /usr/bin/matugen \;
chmod +x /usr/bin/matugen
rm -rf /tmp/matugen*

# Nerd Fonts
mkdir -p /usr/share/fonts/nerd-fonts
curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d /usr/share/fonts/nerd-fonts
rm /tmp/JetBrainsMono.zip
fc-cache -fv
