#!/usr/bin/env bash
# Copyright (c) 2026 Ryvione. All rights reserved.

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'

INSTALL_DIR="$HOME/.local/share/rpkg"
BIN_DIR="$HOME/.local/bin"
REPO="https://github.com/ryvione/Ryvione-s-Package-Manager"

echo -e "\n${BOLD}${CYAN}RPKG${RESET} — Ryvione's Package Manager\n"

if ! command -v node &>/dev/null; then
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

if command -v git &>/dev/null; then
  echo -e "  ${CYAN}→${RESET} Cloning RPKG from GitHub..."
  git clone --depth=1 "$REPO" "$INSTALL_DIR" 2>/dev/null || {
    echo -e "  ${CYAN}→${RESET} Directory exists, pulling latest..."
    git -C "$INSTALL_DIR" pull --ff-only
  }
elif command -v curl &>/dev/null; then
  echo -e "  ${CYAN}→${RESET} Downloading RPKG from GitHub..."
  curl -fsSL "$REPO/archive/refs/heads/master.tar.gz" | tar -xz -C "$INSTALL_DIR" --strip-components=1
elif command -v wget &>/dev/null; then
  echo -e "  ${CYAN}→${RESET} Downloading RPKG from GitHub..."
  wget -qO- "$REPO/archive/refs/heads/master.tar.gz" | tar -xz -C "$INSTALL_DIR" --strip-components=1
else
  echo -e "${RED}✖ Neither git, curl, nor wget found.${RESET}"
  exit 1
fi

echo -e "  ${CYAN}→${RESET} Linking ryv command..."
cat > "$BIN_DIR/ryv" << 'EOF'
#!/usr/bin/env bash
exec node "$HOME/.local/share/rpkg/bin/ryv.js" "$@"
EOF
chmod +x "$BIN_DIR/ryv"

CURRENT_SHELL="$(basename "$SHELL")"
case "$CURRENT_SHELL" in
  bash) SHELL_RC="$HOME/.bashrc" ;;
  zsh)  SHELL_RC="$HOME/.zshrc" ;;
  fish) SHELL_RC="$HOME/.config/fish/config.fish" ;;
  *)    SHELL_RC="$HOME/.profile" ;;
esac

if ! echo "$PATH" | grep -q "$BIN_DIR"; then
  echo "" >> "$SHELL_RC"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
fi

echo -e "\n  ${GREEN}${BOLD}✔ RPKG installed successfully!${RESET}"
echo -e "  Run ${CYAN}source $SHELL_RC${RESET} or open a new terminal, then:"
echo -e "  ${CYAN}ryv help${RESET}\n"