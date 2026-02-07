#!/usr/bin/env bash
# install.sh - Symlink claude-sandbox into place
# Run from the directory containing this script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/claude-sandbox"
CLAUDE_DIR="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing claude-sandbox...${NC}"

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$CLAUDE_DIR"

# Symlink the script
ln -sf "$SCRIPT_DIR/claude-sandbox" "$BIN_DIR/claude-sandbox"
echo -e "${GREEN}✓${NC} Linked claude-sandbox -> $BIN_DIR/claude-sandbox"

# Symlink the Dockerfile
ln -sf "$SCRIPT_DIR/Dockerfile" "$CONFIG_DIR/Dockerfile"
echo -e "${GREEN}✓${NC} Linked Dockerfile -> $CONFIG_DIR/Dockerfile"

# Symlink CLAUDE.md (user-level sandbox instructions)
ln -sf "$SCRIPT_DIR/CLAUDE.md" "$CONFIG_DIR/CLAUDE.md"
echo -e "${GREEN}✓${NC} Linked CLAUDE.md -> $CONFIG_DIR/CLAUDE.md"

# Install/update MCP config for AI tool integration (host usage, outside sandbox)
# This enables Claude on your Mac to use Codex, Gemini via MCP
# Merges into existing config, preserving user-added servers
MCP_FILE="$CLAUDE_DIR/mcp.json"
added=$(python3 - "$MCP_FILE" << 'PYTHON'
import json
import sys

mcp_file = sys.argv[1]

# Required MCP servers (host version - no sandbox flags needed)
required_servers = {
    'codex': {
        'command': 'codex-mcp-server',
        'args': [],
        'env': {}
    },
    'gemini': {
        'command': 'gemini-mcp',
        'args': [],
        'env': {}
    }
}

# Load existing config or create new
try:
    with open(mcp_file, 'r') as f:
        config = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    config = {}

if 'mcpServers' not in config:
    config['mcpServers'] = {}

# Add missing servers
added = []
for name, server in required_servers.items():
    if name not in config['mcpServers']:
        config['mcpServers'][name] = server
        added.append(name)

# Write back if changes were made
if added:
    with open(mcp_file, 'w') as f:
        json.dump(config, f, indent=2)
    print(', '.join(added))
PYTHON
)

if [[ -n "$added" ]]; then
    echo -e "${GREEN}✓${NC} Added MCP servers to $MCP_FILE: $added"
else
    echo -e "${GREEN}✓${NC} MCP config up to date: $MCP_FILE"
fi

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
echo -e "${GREEN}Done!${NC}"
echo ""
echo "Next steps:"
echo "  1. Build sandbox image: claude-sandbox --build"
echo "  2. For AI tool MCP (Codex/Gemini), authenticate on host:"
echo "     codex login && gemini auth login"
