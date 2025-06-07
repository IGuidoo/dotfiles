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
    sudo apt install -y curl git zsh tmux fzf bat eza ripgrep fd-find zoxide
    
    # Install additional tools your config uses
    command -v nvim >/dev/null 2>&1 || {
        echo_info "Installing Neovim..."
        sudo apt install -y neovim
    }
    
    command -v lazygit >/dev/null 2>&1 || {
        echo_info "Installing Lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
    }
    
    # Install GitHub CLI if not present (for gh copilot)
    command -v gh >/dev/null 2>&1 || {
        echo_info "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh
    }
    
    # Zinit and all zsh plugins will be installed automatically when zsh starts
    echo_info "Zinit and zsh plugins will be installed automatically on first zsh startup"
    
    # Install tmux plugin manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

# Install GitHub CLI extensions
install_gh_extensions() {
    echo_info "Installing GitHub CLI extensions..."
    
    if command -v gh &> /dev/null; then
        echo_info "Attempting to install GitHub CLI copilot extension..."
        if gh extension install github/gh-copilot 2>/dev/null; then
            echo_info "GitHub CLI copilot extension installed successfully!"
        else
            echo_warn "Could not install gh copilot extension (this is optional)"
            echo_info "You may need to authenticate with 'gh auth login' first"
        fi
    else
        echo_warn "GitHub CLI not found, skipping copilot extension..."
    fi
}

# Apply configuration fixes
apply_config_fixes() {
    echo_info "Applying configuration fixes..."
    
    # Fix locale settings if not present
    if [ -f "$HOME/.zshrc" ] && ! grep -q "export LANG=en_US.UTF-8" "$HOME/.zshrc"; then
        echo_info "Adding locale settings to .zshrc..."
        echo -e "\n# Fix locale settings" >> "$HOME/.zshrc"
        echo "export LANG=en_US.UTF-8" >> "$HOME/.zshrc"
        echo "export LC_ALL=en_US.UTF-8" >> "$HOME/.zshrc"
    fi
    
    # Ensure Powerlevel10k instant prompt setting is present
    if [ -f "$HOME/.zshrc" ] && ! grep -q "POWERLEVEL9K_INSTANT_PROMPT" "$HOME/.zshrc"; then
        echo_info "Adding Powerlevel10k instant prompt setting..."
        # Create temp file with the setting at the top
        echo "# Suppress Powerlevel10k instant prompt warnings" > /tmp/.zshrc_temp
        echo "typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet" >> /tmp/.zshrc_temp
        echo "" >> /tmp/.zshrc_temp
        cat "$HOME/.zshrc" >> /tmp/.zshrc_temp
        mv /tmp/.zshrc_temp "$HOME/.zshrc"
    fi
    
    # Handle gh copilot alias - comment it out if extension is not available
    if [ -f "$HOME/.zshrc" ] && grep -q 'eval "$(gh copilot alias -- zsh)"' "$HOME/.zshrc"; then
        if ! gh extension list | grep -q "gh-copilot" 2>/dev/null; then
            echo_info "Commenting out gh copilot alias (extension not available)..."
            sed -i 's/^eval "$(gh copilot alias -- zsh)"/# eval "$(gh copilot alias -- zsh)"/' "$HOME/.zshrc"
        fi
    fi
    
    echo_info "Configuration fixes applied!"
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
    apply_config_fixes
    install_gh_extensions
    set_default_shell
    
    echo_info "Dotfiles installation complete!"
    echo_info "Please restart your terminal or run 'source ~/.zshrc'"
    echo_info "For tmux plugins, press prefix + I in tmux to install plugins"
    echo_info ""
    echo_info "Optional: Run 'gh auth login' to authenticate GitHub CLI for copilot extension"
}

# Run main function
main "$@"