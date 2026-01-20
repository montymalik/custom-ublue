# Setup everything (The "One Command" Setup)
setup-all:
    echo "Starting Setup..."
    ujust install-brew-packages
    ujust install-flatpaks
    ujust install-dotfiles
    ujust set-shell-fish
    ujust install-editors
    echo "All done! Restart your session."

install-dotfiles:
    mkdir -p ~/.config/{niri,alacritty,kitty,starship,doom,fuzzel,fish/conf.d}
    # ... (Add your copy commands here) ...
    echo "Dotfiles installed."

set-shell-fish:
    sudo usermod -s /usr/bin/fish $USER
    mkdir -p ~/.config/fish/conf.d
    echo 'atuin init fish | source' > ~/.config/fish/conf.d/atuin.fish
    echo 'starship init fish | source' > ~/.config/fish/conf.d/starship.fish

install-editors:
    bash /usr/share/custom-ublue/scripts/install-doom.sh
    bash /usr/share/custom-ublue/scripts/install-lazyvim.sh
