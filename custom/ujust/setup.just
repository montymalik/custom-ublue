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
install-dotfiles:
    echo "Installing dotfiles..."
    mkdir -p ~/.config/{niri,alacritty,kitty,starship,doom,fuzzel,fish/conf.d}
    
    # Niri
    [ ! -f ~/.config/niri/config.kdl ] && cp /usr/share/custom-ublue/niri/config.kdl ~/.config/niri/
    
    # Alacritty & Kitty (Themes)
    cp -n /usr/share/custom-ublue/alacritty/*.toml ~/.config/alacritty/
    cp -n /usr/share/custom-ublue/kitty/*.conf ~/.config/kitty/
    
    # Starship & Fuzzel
    cp -n /usr/share/custom-ublue/starship/starship.toml ~/.config/starship.toml
    cp -n /usr/share/custom-ublue/fuzzel/fuzzel.ini ~/.config/fuzzel/

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
