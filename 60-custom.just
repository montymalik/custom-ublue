# Install all dotfiles
install-dotfiles:
    #!/usr/bin/bash
    echo "Installing dotfiles..."
    mkdir -p ~/.config/{niri,alacritty,kitty,starship,nvim}
    
    # Copy configs if they don't exist
    [ ! -f ~/.config/niri/config.kdl ] && cp /usr/share/custom-ublue/niri/config.kdl ~/.config/niri/
    [ ! -f ~/.config/alacritty/alacritty.toml ] && cp /usr/share/custom-ublue/alacritty/alacritty.toml ~/.config/alacritty/
    [ ! -f ~/.config/kitty/kitty.conf ] && cp /usr/share/custom-ublue/kitty/kitty.conf ~/.config/kitty/
    [ ! -f ~/.config/starship.toml ] && cp /usr/share/custom-ublue/starship/starship.toml ~/.config/starship.toml
    
    echo "Dotfiles installed! Edit them in ~/.config/"

# Install Doom Emacs
install-doom:
    /usr/share/custom-ublue/scripts/install-doom.sh

# Install LazyVim
install-lazyvim:
    /usr/share/custom-ublue/scripts/install-lazyvim.sh

# Install both Doom and LazyVim
install-editors: install-doom install-lazyvim
  
# Install Starship prompt
install-starship:
    #!/usr/bin/bash
    if ! command -v starship &> /dev/null; then
        echo "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        # Add to bash
        if ! grep -q "starship init bash" ~/.bashrc 2>/dev/null; then
            echo 'eval "$(starship init bash)"' >> ~/.bashrc
        fi
        # Add to zsh if exists
        if [ -f ~/.zshrc ]; then
            if ! grep -q "starship init zsh" ~/.zshrc; then
                echo 'eval "$(starship init zsh)"' >> ~/.zshrc
            fi
        fi
        echo "✓ Starship installed"
    else
        echo "Starship already installed"
        starship --version
    fi

# Update the setup-all recipe
setup-all: install-dotfiles install-editors install-starship
    echo ""
    echo "All configurations installed!"
    echo ""
    echo "Restart your terminal to see the new starship prompt!"
