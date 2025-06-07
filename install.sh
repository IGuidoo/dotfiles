#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo_info "Installing dotfiles from $DOTFILES_DIR"

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo_warn "Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi
    
    ln -sf "$source" "$target"
    echo_info "Created symlink: $target -> $source"
}

# Install package managers and dependencies
install_dependencies() {
    echo_info "Installing dependencies..."
    
    # Update package lists
    sudo apt update
    
    # Install essential packages
    sudo apt install -y curl git zsh tmux fzf bat exa ripgrep fd-find
    
    # Install oh-my-zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install powerlevel10k theme
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        echo_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
    fi
    
    # Install zsh plugins
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        echo_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        echo_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    fi
    
    # Install tmux plugin manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

# Create symlinks for dotfiles
create_symlinks() {
    echo_info "Creating symlinks..."
    
    # Zsh files
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    
    if [ -f "$DOTFILES_DIR/zsh/.p10k.zsh" ]; then
        create_symlink "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
    fi
    
    # Tmux files
    create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    
    # Git files
    if [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
        create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    fi
}

# Set zsh as default shell
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo_info "Setting zsh as default shell..."
        chsh -s $(which zsh)
        echo_warn "Please log out and log back in for the shell change to take effect"
    fi
}

# Main installation
main() {
    install_dependencies
    create_symlinks
    set_default_shell
    
    echo_info "Dotfiles installation complete!"
    echo_info "Please restart your terminal or run 'source ~/.zshrc'"
    echo_info "For tmux plugins, press prefix + I in tmux to install plugins"
}

# Run main function
main "$@"