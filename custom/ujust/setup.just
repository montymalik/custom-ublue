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

# 1. Homebrew Installer
install-brew-packages:
    echo "Installing Brew packages..."
    brew bundle --file /usr/share/ublue-os/homebrew/custom.Brewfile

# 2. Flatpak Installer
install-flatpaks:
    echo "Configuring Flathub..."
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Installing Flatpaks from list..."
    for pkg in $(cat /usr/share/ublue-os/flatpak/overrides/user-flatpaks.txt); do \
        flatpak install --user -y flathub $pkg; \
    done

# 3. Dotfiles Installer (Overwrite Mode)
# WARNING: This will reset your local configs to match the image every time.
install-dotfiles:
    echo "Installing dotfiles (Overwriting local changes)..."
    mkdir -p ~/.config/{niri/dms,alacritty,kitty,starship,doom,fuzzel,fastfetch,fish/conf.d}

    # Niri. The config includes the DMS-managed files under niri/dms/; make sure
    # they exist (empty is fine) so niri loads on a fresh install before DMS has
    # written them.
    cp -f /usr/share/custom-ublue/niri/config.kdl ~/.config/niri/
    for f in alttab binds colors cursor input layout outputs windowrules wpblur; do \
        touch ~/.config/niri/dms/$f.kdl; \
    done

    # Alacritty & Kitty
    cp -f /usr/share/custom-ublue/alacritty/*.toml ~/.config/alacritty/
    cp -f /usr/share/custom-ublue/kitty/*.conf ~/.config/kitty/

    # Starship, Fuzzel & Fastfetch
    cp -f /usr/share/custom-ublue/starship/starship.toml ~/.config/starship.toml
    cp -f /usr/share/custom-ublue/fuzzel/fuzzel.ini ~/.config/fuzzel/
    cp -f /usr/share/custom-ublue/fastfetch/* ~/.config/fastfetch/

    echo "Dotfiles installed."

# 4. Shell Setup (Fixed: Adds Homebrew to Path)
set-shell-fish:
    sudo usermod -s /usr/bin/fish $USER
    mkdir -p ~/.config/fish/conf.d

    # 1. Initialize Homebrew (Must run first!)
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' > ~/.config/fish/conf.d/00-brew.fish

    # 2. Enable Tools
    echo 'atuin init fish | source' > ~/.config/fish/conf.d/atuin.fish
    echo 'starship init fish | source' > ~/.config/fish/conf.d/starship.fish

    # Activate Mise
    echo 'mise activate fish | source' > ~/.config/fish/conf.d/mise.fish

# 5. Editors
install-editors:
    bash /usr/share/custom-ublue/scripts/install-doom.sh
    bash /usr/share/custom-ublue/scripts/install-lazyvim.sh
