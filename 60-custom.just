# Install all dotfiles
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

# Set Fish as the default shell
set-shell-fish:
    sudo usermod -s /usr/bin/fish $USER

# Install Dev Tools via Devbox
install-dev-tools:
    devbox global add go nodejs rustup
    echo "Dev tools installed. Run 'devbox global shell' to use them."

# Install Doom Emacs
install-doom:
    /usr/share/custom-ublue/scripts/install-doom.sh

# Sync Doom Env (Run after updates)
doom-sync:
    ~/.config/emacs/bin/doom env
    ~/.config/emacs/bin/doom sync
    echo "Doom environment synced."

# Install LazyVim
install-lazyvim:
    /usr/share/custom-ublue/scripts/install-lazyvim.sh

# Install both editors
install-editors: install-doom install-lazyvim

# Setup everything
setup-all: install-dotfiles set-shell-fish install-editors
    echo "All configurations installed! Please restart your session."
