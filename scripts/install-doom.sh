#!/bin/bash
set -e

echo "=== Installing Doom Emacs for Bluefin DX ==="

# 1. Dependency Check
REQUIRED_CMDS=("git" "emacs" "rg" "fd")
MISSING_CMDS=()

for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    MISSING_CMDS+=("$cmd")
  fi
done

if [ ${#MISSING_CMDS[@]} -ne 0 ]; then
  echo "Error: Missing dependencies: ${MISSING_CMDS[*]}"
  exit 1
fi

# 2. Back up existing Emacs config
if [ -d "$HOME/.config/emacs" ]; then
  echo "Backing up existing Emacs config..."
  mv "$HOME/.config/emacs" "$HOME/.config/emacs.bak.$(date +%s)"
fi

if [ -d "$HOME/.emacs.d" ]; then
  echo "Backing up existing .emacs.d..."
  mv "$HOME/.emacs.d" "$HOME/.emacs.d.bak.$(date +%s)"
fi

# 3. Clone Doom Emacs
echo "Cloning Doom Emacs..."
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# 4. Install Doom
echo "Running Doom install..."
# FIX: Removed --no-fonts. Added --force to auto-accept prompts.
~/.config/emacs/bin/doom install --env --force

# 5. Configure Path for Fish Shell
if command -v fish &>/dev/null; then
  echo "Configuring Fish shell path..."
  # We use -U (universal) so it persists instantly across all shells
  fish -c "fish_add_path $HOME/.config/emacs/bin" || true
  echo "✓ Added ~/.config/emacs/bin to Fish path."
fi

# 6. Configure Path for Bash (Fallback)
if ! grep -q ".config/emacs/bin" ~/.bashrc; then
  echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >>~/.bashrc
fi

echo ""
echo "=== Doom Emacs Installed Successfully! ==="
