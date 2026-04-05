#!/usr/bin/env bash
# Copyright (c) 2026 Ryvione. All rights reserved.

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'
BOLD='\033[1m'

INSTALL_DIR="$HOME/.local/share/rpkg"
BIN_DIR="$HOME/.local/bin"
REPO_URL="https://pkg.ryvione.dev/releases/rpkg-latest.tar.gz"

echo -e "\n${BOLD}${CYAN}RPKG${RESET} — Ryvione's Package Manager\n"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists node; then
  echo -e "${RED}✖ Node.js is required but not installed.${RESET}"
  echo -e "  Install it from https://nodejs.org (v18+) and re-run this script."
  exit 1
fi

NODE_MAJOR=$(node -e "process.stdout.write(process.versions.node.split('.')[0])")
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo -e "${RED}✖ Node.js v18+ is required. Found: v$(node --version)${RESET}"
  exit 1
fi

echo -e "  ${GREEN}✔${RESET} Node.js $(node --version) detected"

mkdir -p "$INSTALL_DIR" "$BIN_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/package.json" ]; then
  echo -e "  ${CYAN}→${RESET} Installing from local source..."
  cp -r "$SCRIPT_DIR/." "$INSTALL_DIR/"
else
  echo -e "  ${CYAN}→${RESET} Downloading RPKG..."
  if command_exists curl; then
    curl -fsSL "$REPO_URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1
  elif command_exists wget; then
    wget -qO- "$REPO_URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1
  else
    echo -e "${RED}✖ Neither curl nor wget found. Please install one and retry.${RESET}"
    exit 1
  fi
fi

echo -e "  ${CYAN}→${RESET} Linking ryv command..."
cat > "$BIN_DIR/ryv" << 'EOF'
#!/usr/bin/env bash
exec node "$HOME/.local/share/rpkg/bin/ryv.js" "$@"
EOF
chmod +x "$BIN_DIR/ryv"

SHELL_RC=""
CURRENT_SHELL="$(basename "$SHELL")"
case "$CURRENT_SHELL" in
  bash) SHELL_RC="$HOME/.bashrc" ;;
  zsh)  SHELL_RC="$HOME/.zshrc" ;;
  fish) SHELL_RC="$HOME/.config/fish/config.fish" ;;
  *)    SHELL_RC="$HOME/.profile" ;;
esac

if ! echo "$PATH" | grep -q "$BIN_DIR"; then
  echo -e "  ${CYAN}→${RESET} Adding $BIN_DIR to PATH in $SHELL_RC..."
  echo "" >> "$SHELL_RC"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
fi

echo -e "\n  ${GREEN}${BOLD}✔ RPKG installed successfully!${RESET}"
echo -e "  Run ${CYAN}source $SHELL_RC${RESET} or open a new terminal, then:"
echo -e "  ${CYAN}ryv help${RESET}\n"
