#!/usr/bin/env bash
# Copyright (c) 2026 Ryvione. All rights reserved.

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RESET='\033[0m'
BOLD='\033[1m'

echo -e "\n${BOLD}${CYAN}syskit${RESET} — Installing system utilities...\n"

detect_pkg_manager() {
  if command -v apt-get &>/dev/null; then echo "apt"
  elif command -v dnf &>/dev/null; then echo "dnf"
  elif command -v pacman &>/dev/null; then echo "pacman"
  elif command -v zypper &>/dev/null; then echo "zypper"
  else echo "unknown"; fi
}

install_pkg() {
  local mgr="$1"; shift
  case "$mgr" in
    apt)    sudo apt-get install -y "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    pacman) sudo pacman -S --noconfirm "$@" ;;
    zypper) sudo zypper install -y "$@" ;;
  esac
}

PKG=$(detect_pkg_manager)

if [ "$PKG" = "unknown" ]; then
  echo -e "${RED}✖ Could not detect a supported package manager.${RESET}"
  exit 1
fi

echo -e "  ${CYAN}→${RESET} Detected package manager: ${BOLD}$PKG${RESET}"

if [ "$PKG" = "apt" ]; then
  sudo apt-get update -qq
fi

PACKAGES=(htop neofetch rsync tmux tree ncdu duf bat fd-find ripgrep lsof)

echo -e "  ${CYAN}→${RESET} Installing packages..."
install_pkg "$PKG" "${PACKAGES[@]}" 2>/dev/null || true

if ! command -v exa &>/dev/null; then
  echo -e "  ${CYAN}→${RESET} Installing exa (modern ls)..."
  if [ "$PKG" = "apt" ] || [ "$PKG" = "dnf" ]; then
    cargo install exa 2>/dev/null || true
  elif [ "$PKG" = "pacman" ]; then
    sudo pacman -S --noconfirm exa 2>/dev/null || true
  fi
fi

echo -e "  ${CYAN}→${RESET} Writing tmux config..."
cat > "$HOME/.tmux.conf" << 'TMUXCONF'
set -g prefix C-a
unbind C-b
bind C-a send-prefix
set -g mouse on
set -g history-limit 50000
set -g base-index 1
setw -g pane-base-index 1
set -g status-style bg=colour235,fg=colour136
set -g window-status-current-style fg=colour166,bold
TMUXCONF

echo -e "\n  ${GREEN}${BOLD}✔ syskit installed successfully!${RESET}\n"
