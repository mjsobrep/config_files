#!/usr/bin/env bash
# install.sh - Symlink claude-sandbox into place
# Run from the directory containing this script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/claude-sandbox"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing claude-sandbox...${NC}"

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"

# Symlink the script
ln -sf "$SCRIPT_DIR/claude-sandbox" "$BIN_DIR/claude-sandbox"
echo -e "${GREEN}✓${NC} Linked claude-sandbox -> $BIN_DIR/claude-sandbox"

# Symlink the Dockerfile
ln -sf "$SCRIPT_DIR/Dockerfile" "$CONFIG_DIR/Dockerfile"
echo -e "${GREEN}✓${NC} Linked Dockerfile -> $CONFIG_DIR/Dockerfile"

# Auth directory is created and populated by claude-sandbox script at runtime
# This ensures settings.json is always correct even if Claude Code modifies it

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo -e "${YELLOW}Note:${NC} $BIN_DIR is not in your PATH"
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

echo ""
echo -e "${GREEN}Done!${NC} Run 'claude-sandbox --build' to build the Docker image."
