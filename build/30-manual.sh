#!/bin/bash
set -ouex pipefail

echo "Installing Manual Binaries & Fonts..."

# --- NERD FONTS ---
# We download these manually because Fedora doesn't package patched fonts.

mkdir -p /usr/share/fonts/nerd-fonts

# 1. Map Bluefin names to Nerd Font Zip names
FONTS=(
  "CascadiaCode"    # Caskaydia Cove
  "ComicShannsMono" # Comic Shanns
  "DroidSansMono"   # Droid Sans
  "Go-Mono"         # Go Mono
  "IBMPlexMono"     # Blex Mono
  "SourceCodePro"   # Sauce Code Pro
  "Ubuntu"          # Ubuntu
  "FiraCode"        # FiraCode
  "0xProto"         # 0xProto
  "JetBrainsMono"   # JetBrains Mono
)

# 2. Download and Unzip
for font in "${FONTS[@]}"; do
  echo "Downloading $font..."
  curl -fLo "/tmp/${font}.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
  unzip -o "/tmp/${font}.zip" -d /usr/share/fonts/nerd-fonts
  rm "/tmp/${font}.zip"
done

# 3. Clean up Windows-compatible files
find /usr/share/fonts/nerd-fonts -name "*Windows Compatible*" -delete

# 4. Refresh Font Cache
fc-cache -fv
