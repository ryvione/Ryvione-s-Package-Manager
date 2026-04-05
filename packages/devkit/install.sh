#!/usr/bin/env bash
# Copyright (c) 2026 Ryvione. All rights reserved.

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'

echo -e "\n${BOLD}${CYAN}devkit${RESET} — Installing developer tools...\n"

detect_pkg_manager() {
  if command -v apt-get &>/dev/null; then echo "apt"
  elif command -v dnf &>/dev/null; then echo "dnf"
  elif command -v pacman &>/dev/null; then echo "pacman"
  elif command -v zypper &>/dev/null; then echo "zypper"
  elif command -v brew &>/dev/null; then echo "brew"
  else echo "unknown"; fi
}

install_pkg() {
  local mgr="$1"
  shift
  case "$mgr" in
    apt)    sudo apt-get install -y "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    pacman) sudo pacman -S --noconfirm "$@" ;;
    zypper) sudo zypper install -y "$@" ;;
    brew)   brew install "$@" ;;
  esac
}

PKG=$(detect_pkg_manager)

if [ "$PKG" = "unknown" ]; then
  echo -e "${RED}✖ Could not detect a supported package manager.${RESET}"
  exit 1
fi

echo -e "  ${CYAN}→${RESET} Detected package manager: ${BOLD}$PKG${RESET}"

PACKAGES=(git curl wget vim nano build-essential htop unzip)

if [ "$PKG" = "apt" ]; then
  sudo apt-get update -qq
fi

echo -e "  ${CYAN}→${RESET} Installing packages: ${PACKAGES[*]}"
install_pkg "$PKG" "${PACKAGES[@]}"

if ! command -v node &>/dev/null; then
  echo -e "  ${CYAN}→${RESET} Installing Node.js via nvm..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
fi

echo -e "\n  ${GREEN}${BOLD}✔ devkit installed successfully!${RESET}\n"
