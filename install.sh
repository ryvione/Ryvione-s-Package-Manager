#!/usr/bin/env bash
# Copyright (c) 2026 Ryvione. All rights reserved.
set -e
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'
INSTALL_DIR="$HOME/.local/share/rpkg"
BIN_DIR="$HOME/.rpkg/bin"
REPO="https://github.com/ryvione/Ryvione-s-Package-Manager"
echo -e "\n${BOLD}${CYAN}RPKG${RESET} — Ryvione's Package Manager\n"
check() {
  command -v "$1" &>/dev/null
}
skip() {
  echo -e "  ${YELLOW}↷${RESET} $1 already installed, skipping"
}
ok() {
  echo -e "  ${GREEN}✔${RESET} $1"
}
fail() {
  echo -e "  ${RED}✖${RESET} $1"
}
step() {
  echo -e "  ${CYAN}→${RESET} $1"
}
if ! check node; then
  fail "Node.js is required but not installed."
  echo -e "     Install it from https://nodejs.org (v18+) and re-run this script."
  exit 1
fi
NODE_MAJOR=$(node -e "process.stdout.write(process.versions.node.split('.')[0])")
if [ "$NODE_MAJOR" -lt 18 ]; then
  fail "Node.js v18+ is required. Found: $(node --version)"
  exit 1
fi
ok "Node.js $(node --version) detected"
mkdir -p "$BIN_DIR"
if [ -d "$INSTALL_DIR/.git" ]; then
  skip "RPKG source (pulling latest instead)"
  git -C "$INSTALL_DIR" pull --ff-only --quiet
elif [ -f "$INSTALL_DIR/package.json" ]; then
  skip "RPKG source (already present)"
else
  if check git; then
    step "Cloning RPKG from GitHub..."
    git clone --depth=1 "$REPO" "$INSTALL_DIR" --quiet
  elif check curl; then
    step "Downloading RPKG from GitHub..."
    curl -fsSL "$REPO/archive/refs/heads/master.tar.gz" | tar -xz -C "$INSTALL_DIR" --strip-components=1
  elif check wget; then
    step "Downloading RPKG from GitHub..."
    wget -qO- "$REPO/archive/refs/heads/master.tar.gz" | tar -xz -C "$INSTALL_DIR" --strip-components=1
  else
    fail "Neither git, curl, nor wget found."
    exit 1
  fi
fi
if [ -f "$BIN_DIR/ryv" ]; then
  skip "ryv binary"
else
  step "Linking ryv command..."
  cat > "$BIN_DIR/ryv" << 'EOF'
#!/usr/bin/env bash
exec node "$HOME/.local/share/rpkg/bin/ryv.js" "$@"
EOF
  chmod +x "$BIN_DIR/ryv"
  ok "ryv linked to $BIN_DIR/ryv"
fi
if [ -f "$BIN_DIR/rpkg" ]; then
  skip "rpkg binary"
else
  step "Linking rpkg command..."
  cat > "$BIN_DIR/rpkg" << 'EOF'
#!/usr/bin/env bash
exec node "$HOME/.local/share/rpkg/bin/ryv.js" "$@"
EOF
  chmod +x "$BIN_DIR/rpkg"
  ok "rpkg linked to $BIN_DIR/rpkg"
fi
CURRENT_SHELL="$(basename "$SHELL")"
case "$CURRENT_SHELL" in
  bash) SHELL_RC="$HOME/.bashrc" ;;
  zsh)  SHELL_RC="$HOME/.zshrc" ;;
  fish) SHELL_RC="$HOME/.config/fish/config.fish" ;;
  *)    SHELL_RC="$HOME/.profile" ;;
esac
if echo "$PATH" | grep -q "$BIN_DIR"; then
  skip "PATH entry"
else
  if [ "$CURRENT_SHELL" = "fish" ]; then
    mkdir -p "$(dirname "$SHELL_RC")"
    echo "" >> "$SHELL_RC"
    echo "fish_add_path ~/.rpkg/bin" >> "$SHELL_RC"
  else
    echo "" >> "$SHELL_RC"
    echo "export PATH=\"\$HOME/.rpkg/bin:\$PATH\"" >> "$SHELL_RC"
  fi
  ok "Added $BIN_DIR to PATH in $SHELL_RC"
fi
echo -e "\n  ${GREEN}${BOLD}✔ RPKG ready!${RESET}"
echo -e "  Run ${CYAN}source $SHELL_RC${RESET} or open a new terminal, then:"
echo -e "  ${CYAN}ryv help${RESET}  ${CYAN}rpkg help${RESET}\n"