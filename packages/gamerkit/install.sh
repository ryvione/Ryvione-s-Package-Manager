#!/usr/bin/env bash
# Copyright (c) 2026 Ryvione. All rights reserved.

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'
BOLD='\033[1m'

echo -e "\n${BOLD}${CYAN}gamerkit${RESET} — Installing gaming tools...\n"

detect_pkg_manager() {
  if command -v apt-get &>/dev/null; then echo "apt"
  elif command -v dnf &>/dev/null; then echo "dnf"
  elif command -v pacman &>/dev/null; then echo "pacman"
  else echo "unknown"; fi
}

PKG=$(detect_pkg_manager)

if [ "$PKG" = "unknown" ]; then
  echo -e "${RED}✖ Could not detect a supported package manager.${RESET}"
  exit 1
fi

echo -e "  ${CYAN}→${RESET} Detected package manager: ${BOLD}$PKG${RESET}"

if [ "$PKG" = "apt" ]; then
  sudo apt-get update -qq
  sudo apt-get install -y software-properties-common

  if ! command -v steam &>/dev/null; then
    echo -e "  ${CYAN}→${RESET} Installing Steam..."
    sudo add-apt-repository -y multiverse
    sudo apt-get update -qq
    sudo apt-get install -y steam
  fi

  echo -e "  ${CYAN}→${RESET} Installing Lutris..."
  sudo add-apt-repository -y ppa:lutris-team/lutris
  sudo apt-get update -qq
  sudo apt-get install -y lutris

  echo -e "  ${CYAN}→${RESET} Installing MangoHud..."
  sudo apt-get install -y mangohud

  echo -e "  ${CYAN}→${RESET} Installing gamemode..."
  sudo apt-get install -y gamemode

elif [ "$PKG" = "pacman" ]; then
  sudo pacman -S --noconfirm steam lutris mangohud gamemode discord

elif [ "$PKG" = "dnf" ]; then
  sudo dnf install -y steam lutris mangohud gamemode
fi

if ! command -v discord &>/dev/null; then
  echo -e "  ${CYAN}→${RESET} Installing Discord..."
  if [ "$PKG" = "apt" ]; then
    curl -fsSL "https://discord.com/api/download?platform=linux&format=deb" -o /tmp/discord.deb
    sudo apt-get install -y /tmp/discord.deb
    rm /tmp/discord.deb
  fi
fi

echo -e "\n  ${GREEN}${BOLD}✔ gamerkit installed successfully!${RESET}\n"
echo -e "  ${YELLOW}Tip:${RESET} Enable Steam Play (Proton) in Steam settings for Windows games.\n"
