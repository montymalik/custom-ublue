# Install all dotfiles (Safe Mode - skips if file exists)
install-dotfiles:
    #!/usr/bin/bash
    echo "Installing dotfiles..."
    # Create directories
    mkdir -p ~/.config/{niri,alacritty,kitty,starship,doom,fuzzel,fish/conf.d}

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

# Set Fish as default shell & Configure CLI Tools (Atuin/Starship)
set-shell-fish:
    # 1. Set default shell
    sudo usermod -s /usr/bin/fish $USER

    # 2. Ensure config dir exists
    mkdir -p ~/.config/fish/conf.d

    # 3. Enable Atuin (Shell History)
    echo 'atuin init fish | source' > ~/.config/fish/conf.d/atuin.fish

    # 4. Enable Starship (Prompt)
    echo 'starship init fish | source' > ~/.config/fish/conf.d/starship.fish

    echo "Fish configured with Atuin and Starship."

# --- APPLICATIONS & TOOLS ---

# Install Google Chrome (Flatpak)
install-chrome:
    flatpak install flathub com.google.Chrome -y
    echo "Chrome installed!"

# Install Podman Desktop (Flatpak)
# The official GUI for managing containers on Bluefin
install-podman-desktop:
    flatpak install --user flathub io.podman_desktop.PodmanDesktop -y
    echo "Podman Desktop installed!"

# Install DevContainers CLI (Homebrew)
# Allows using devcontainers in Neovim/Terminal without VSCode
install-devcontainer-cli:
    brew install devcontainer
    echo "DevContainer CLI installed!"

# --- EDITORS ---

# Install Doom Emacs (Uses bash to avoid read-only errors)
install-doom:
    bash /usr/share/custom-ublue/scripts/install-doom.sh

# Sync Doom Env (Run after installing new system tools)
doom-sync:
    ~/.config/emacs/bin/doom env
    ~/.config/emacs/bin/doom sync
    echo "Doom environment synced."

# Install LazyVim (Uses bash to avoid read-only errors)
install-lazyvim:
    bash /usr/share/custom-ublue/scripts/install-lazyvim.sh

# Install both editors
install-editors: install-doom install-lazyvim

# --- SETUP ALL ---

# Setup everything (The "One Command" Setup)
setup-all: install-dotfiles set-shell-fish install-editors install-chrome install-podman-desktop install-devcontainer-cli
    echo "All configurations installed! Please restart your session."
