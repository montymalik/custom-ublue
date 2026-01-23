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

# NEW: Links Homebrew fonts so Linux can see them
link-brew-fonts:
    echo "Linking Homebrew fonts to system..."
    mkdir -p ~/.local/share/fonts
    # Find all fonts in Homebrew Caskroom and link them to user fonts
    find /home/linuxbrew/.linuxbrew/Caskroom -name "*.ttf" -o -name "*.otf" | xargs -I{} ln -sf {} ~/.local/share/fonts/
    # Refresh font cache
    fc-cache -fv
    echo "Fonts linked successfully!"

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

# 4. Shell Setup (Fixed: Adds Homebrew to Path)
set-shell-fish:
    sudo usermod -s /usr/bin/fish $USER
    mkdir -p ~/.config/fish/conf.d
    
    # 1. Initialize Homebrew (Must run first!)
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' > ~/.config/fish/conf.d/00-brew.fish
    
    # 2. Enable Tools
    echo 'atuin init fish | source' > ~/.config/fish/conf.d/atuin.fish
    echo 'starship init fish | source' > ~/.config/fish/conf.d/starship.fish

# 5. Editors
install-editors:
    bash /usr/share/custom-ublue/scripts/install-doom.sh
    bash /usr/share/custom-ublue/scripts/install-lazyvim.sh
