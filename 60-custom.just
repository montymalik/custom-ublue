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

# Setup everything
setup-all: install-dotfiles install-editors
    echo "All configurations installed!"
