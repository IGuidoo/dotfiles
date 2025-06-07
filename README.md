# My Dotfiles

Personal dotfiles for zsh, tmux, and other productivity tools.

## Features

- **Zsh** with Zinit plugin manager and Powerlevel10k theme
- **Tmux** with Catppuccin theme and custom configuration
- **FZF** for fuzzy finding with custom keybindings
- **Lazygit** integration with tmux popup
- **Neovim** as default editor
- **Zoxide** for smart directory jumping
- Various productivity tools and aliases

## Quick Install

```bash
git clone https://github.com/IGuidoo/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

**That's it!** The install script handles everything automatically.

## What the Install Script Does

1. **Installs system packages**: git, zsh, tmux, fzf, bat, eza, ripgrep, fd-find, zoxide
2. **Installs additional tools**: neovim, lazygit, github-cli
3. **Creates symlinks** for all config files
4. **Sets zsh as default shell**
5. **Installs Tmux Plugin Manager**

## Post-Installation (Automatic)

After running the install script:

1. **Restart your terminal** - Zinit will automatically install all zsh plugins
2. **Open tmux** and press `Prefix + I` to install tmux plugins
3. **Optional**: Run `p10k configure` to customize your prompt

## Included Configurations

### Zsh (with Zinit)
- Powerlevel10k theme
- Syntax highlighting
- Auto-suggestions
- Smart completions
- FZF integration
- Zoxide integration
- Custom keybindings and aliases

### Tmux
- Catppuccin theme (mocha flavor)
- Mouse support
- Custom status bar with system info
- Plugin manager (TPM)
- Custom key bindings

### Tools & Aliases
- `lazygit` - Opens in tmux popup
- `vim` → `nvim`
- `ls` → `ls --color`
- `c` → `clear`
- Enhanced fzf with bat preview

## Manual Setup (if needed)

### Prerequisites
- Ubuntu/Debian-based system
- Git
- Curl
- Sudo access

### Installation Steps
1. Clone this repository: `git clone git@github.com:IGuidoo/dotfiles.git ~/dotfiles`
2. Run the install script: `cd ~/dotfiles && ./install.sh`
3. Restart your terminal
4. Enjoy your new setup!

## Troubleshooting

### If plugins don't load
```bash
# Reload zsh config
source ~/.zshrc

# Or restart your terminal
```

### If tmux plugins don't work
```bash
# In tmux, press: Prefix + I
# Or manually install:
~/.tmux/plugins/tpm/scripts/install_plugins.sh
```

### If Powerlevel10k doesn't show correctly
```bash
# Reconfigure the theme
p10k configure
```

## Customization

All configurations are in their respective directories:
- `zsh/` - Zsh configuration
- `tmux/` - Tmux configuration  
- `git/` - Git configuration (if present)

Feel free to modify any configurations to suit your preferences.

## Updating

```bash
cd ~/dotfiles
git pull origin main
# Restart terminal to reload configurations
```

## What's Included

- **Zsh config** with modern plugin management
- **Tmux config** with beautiful theme and plugins
- **Powerlevel10k theme** configuration
- **Install script** for easy setup on new systems
- **All necessary tools** for development workflow