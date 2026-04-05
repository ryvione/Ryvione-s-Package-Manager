#!/usr/bin/env bash
set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'

echo -e "\n${BOLD}${CYAN}ryv-kernel${RESET} — ryvionOS terminal simulator\n"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
BIN_DIR="$HOME/.rpkg/bin"
mkdir -p "$BIN_DIR"

echo -e "  Downloading ryv-kernel for $OS..."
curl -fsSL "https://pkg.ryvione.dev/kits/ryv-kernel/bin/$OS" -o "$BIN_DIR/ryv-kernel"
chmod +x "$BIN_DIR/ryv-kernel"

echo -e "\n${GREEN}✓${RESET} ${BOLD}ryv-kernel${RESET} installed!\n"
echo -e "  Run: ${CYAN}ryv-kernel${RESET}"
echo -e "  Run: ${CYAN}ryv-kernel --no-boot${RESET}  — skip boot sequence\n"