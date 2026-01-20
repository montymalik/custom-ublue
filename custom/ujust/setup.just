# --- SETUP ALL ---

# The Main Orchestrator
setup-all:
    echo "Starting Setup..."
    ujust install-brew-packages
    ujust install-flatpaks
    ujust install-dotfiles
    ujust set-shell-fish
    ujust install-editors
    echo "All done! Restart your session."

# --- WORKER COMMANDS ---

# 1. Homebrew Installer (FIXED: Removed invalid --no-lock flag)
install-brew-packages:
    echo "Installing Brew packages..."
    brew bundle --file /usr/share/ublue-os/brew/Brewfile

# 2. Flatpak Installer
install-flatpaks:
    echo "Configuring Flathub..."
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Installing Flatpaks from list..."
    for pkg in $(cat /usr/share/ublue-os/flatpak/overrides/user-flatpaks.txt); do \
        flatpak install --user -y flathub $pkg; \
    done

# 3. Dotfiles Installer

# 3. Dotfiles Installer (Overwrite Mode)
# WARNING: This will reset your local configs to match the image every time.
install-dotfiles:
    echo "Installing dotfiles (Overwriting local changes)..."
    mkdir -p ~/.config/{niri,alacritty,kitty,starship,doom,fuzzel,fish/conf.d}
    
    # Niri
    cp -f /usr/share/custom-ublue/niri/config.kdl ~/.config/niri/
    
    # Alacritty & Kitty
    cp -f /usr/share/custom-ublue/alacritty/*.toml ~/.config/alacritty/
    cp -f /usr/share/custom-ublue/kitty/*.conf ~/.config/kitty/
    
    # Starship & Fuzzel
    cp -f /usr/share/custom-ublue/starship/starship.toml ~/.config/starship.toml
    cp -f /usr/share/custom-ublue/fuzzel/fuzzel.ini ~/.config/fuzzel/
    
    echo "Dotfiles installed."

# 4. Shell Setup
set-shell-fish:
    sudo usermod -s /usr/bin/fish $USER
    mkdir -p ~/.config/fish/conf.d
    echo 'atuin init fish | source' > ~/.config/fish/conf.d/atuin.fish
    echo 'starship init fish | source' > ~/.config/fish/conf.d/starship.fish

# 5. Editors
install-editors:
    bash /usr/share/custom-ublue/scripts/install-doom.sh
    bash /usr/share/custom-ublue/scripts/install-lazyvim.sh
