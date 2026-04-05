#!/usr/bin/env bash
# Copyright (c) 2026 Ryvione. All rights reserved.

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'

DOTDIR="$HOME/.dotkit"

echo -e "\n${BOLD}${CYAN}dotkit${RESET} — Setting up dotfiles and shell config...\n"

detect_pkg_manager() {
  if command -v apt-get &>/dev/null; then echo "apt"
  elif command -v dnf &>/dev/null; then echo "dnf"
  elif command -v pacman &>/dev/null; then echo "pacman"
  else echo "unknown"; fi
}

PKG=$(detect_pkg_manager)

if [ "$PKG" = "apt" ]; then
  sudo apt-get update -qq
  sudo apt-get install -y zsh curl git fontconfig
elif [ "$PKG" = "pacman" ]; then
  sudo pacman -S --noconfirm zsh curl git
elif [ "$PKG" = "dnf" ]; then
  sudo dnf install -y zsh curl git
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "  ${CYAN}→${RESET} Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  echo -e "  ${CYAN}→${RESET} Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  echo -e "  ${CYAN}→${RESET} Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
  echo -e "  ${CYAN}→${RESET} Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

echo -e "  ${CYAN}→${RESET} Writing .zshrc..."
cat > "$HOME/.zshrc" << 'ZSHRC'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z colored-man-pages)
source $ZSH/oh-my-zsh.sh
alias ll='ls -lah'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias ..='cd ..'
alias ...='cd ../..'
export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
ZSHRC

echo -e "  ${CYAN}→${RESET} Writing .vimrc..."
cat > "$HOME/.vimrc" << 'VIMRC'
syntax on
set number
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set hlsearch
set incsearch
set ruler
set showcmd
set wildmenu
colorscheme desert
VIMRC

echo -e "\n  ${GREEN}${BOLD}✔ dotkit installed successfully!${RESET}\n"
echo -e "  ${YELLOW}Tip:${RESET} Run ${CYAN}chsh -s \$(which zsh)${RESET} to set zsh as your default shell.\n"
