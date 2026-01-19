#!/bin/bash
# Install Doom Emacs
if [ ! -d "$HOME/.config/emacs" ]; then
  echo "Installing Doom Emacs..."
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install --no-env --no-fonts
else
  echo "Doom Emacs already installed"
fi
