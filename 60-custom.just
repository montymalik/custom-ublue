# Install all dotfiles (Safe Mode - skips if file exists)
install-dotfiles:
    #!/usr/bin/bash
    echo "Installing dotfiles..."
    # Create directories
    mkdir -p ~/.config/{niri,alacritty,kitty,starship,doom,fuzzel}

    # --- NIRI ---
    [ ! -f ~/.config/niri/config.kdl ] && cp /usr/share/custom-ublue/niri/config.kdl ~/.config/niri/

    # --- ALACRITTY ---
    # Main config
    [ ! -f ~/.config/alacritty/alacritty.toml ] && cp /usr/share/custom-ublue/alacritty/alacritty.toml ~/.config/alacritty/
    # Themes
    cp -n /usr/share/custom-ublue/alacritty/dank-theme.toml ~/.config/alacritty/
    cp -n /usr/share/custom-ublue/alacritty/catppuccin-macchiato.toml ~/.config/alacritty/

    # --- KITTY ---
    # Main config
    [ ! -f ~/.config/kitty/kitty.conf ] && cp /usr/share/custom-ublue/kitty/kitty.conf ~/.config/kitty/
    # Themes & Tabs
    cp -n /usr/share/custom-ublue/kitty/dank-tabs.conf ~/.config/kitty/
    cp -n /usr/share/custom-ublue/kitty/dank-theme.conf ~/.config/kitty/
    cp -n /usr/share/custom-ublue/kitty/catppuccin-macchiato.conf ~/.config/kitty/

    # --- FUZZEL ---
    [ ! -f ~/.config/fuzzel/fuzzel.ini ] && cp /usr/share/custom-ublue/fuzzel/fuzzel.ini ~/.config/fuzzel/

    # --- STARSHIP ---
    [ ! -f ~/.config/starship.toml ] && cp /usr/share/custom-ublue/starship/starship.toml ~/.config/starship.toml

    echo "Dotfiles installed! Edit them in ~/.config/"

# Force update Niri config from the image (Overwrites local changes!)
update-niri-config:
    cp -f /usr/share/custom-ublue/niri/config.kdl ~/.config/niri/config.kdl
    echo "Niri config updated from image."

# Force update ALL dotfiles (Overwrites local changes!)
force-update-dotfiles:
    cp -f /usr/share/custom-ublue/niri/config.kdl ~/.config/niri/
    cp -f /usr/share/custom-ublue/alacritty/*.toml ~/.config/alacritty/
    cp -f /usr/share/custom-ublue/kitty/*.conf ~/.config/kitty/
    cp -f /usr/share/custom-ublue/fuzzel/fuzzel.ini ~/.config/fuzzel/
    echo "All dotfiles reset to image defaults."

# Set Fish as the default shell
set-shell-fish:
    sudo usermod -s /usr/bin/fish $USER

# Install Dev Tools via Devbox
install-dev-tools:
    devbox global add go nodejs rustup
    echo "Dev tools installed. Run 'devbox global shell' to use them."

# Install Google Chrome (Flatpak - Recommended)
install-chrome:
    flatpak install flathub com.google.Chrome -y
    echo "Chrome installed!"

# Install Google Chrome (Layered RPM - Alternative)
install-chrome-rpm:
    sudo dnf config-manager --set-enabled google-chrome
    sudo rpm-ostree install google-chrome-stable
    echo "Chrome layered. Please reboot."

# Install Doom Emacs
install-doom:
    chmod +x /usr/share/custom-ublue/scripts/install-doom.sh
    /usr/share/custom-ublue/scripts/install-doom.sh

# Sync Doom Env (Run after updates)
doom-sync:
    ~/.config/emacs/bin/doom env
    ~/.config/emacs/bin/doom sync
    echo "Doom environment synced."

# Install LazyVim
install-lazyvim:
    chmod +x /usr/share/custom-ublue/scripts/install-lazyvim.sh
    /usr/share/custom-ublue/scripts/install-lazyvim.sh

# Install both editors
install-editors: install-doom install-lazyvim

# Setup everything
setup-all: install-dotfiles set-shell-fish install-editors install-chrome
    echo "All configurations installed! Please restart your session."
