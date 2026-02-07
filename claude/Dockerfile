# Dockerfile.claude-sandbox
FROM ubuntu:24.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    git-lfs \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    gnupg \
    ripgrep \
    fd-find \
    jq \
    unzip \
    vim \
    less \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN corepack enable && corepack prepare yarn@stable --activate

# Install Rust (system-wide, accessible to all users)
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --default-toolchain stable

# Install Python + pipenv
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && pip3 install --break-system-packages pipenv

# Install MCAP CLI (robotics recording format tools)
# Note: Only amd64 binary available; on ARM this step will fail and can be removed
RUN curl -fsSL "https://github.com/foxglove/mcap/releases/download/releases%2Fmcap-cli%2Fv0.0.59/mcap-linux-amd64" -o /usr/local/bin/mcap \
    && chmod +x /usr/local/bin/mcap

# Install Claude Code (installs to /root/.local/bin as root)
# Pass --build-arg CLAUDE_CACHEBUST=$(date +%s) to force reinstall
ARG CLAUDE_CACHEBUST=1
RUN curl -fsSL https://claude.ai/install.sh | bash

# AI tool CLIs for MCP integration (Codex, Gemini)
# Credentials are mounted read-only from host at runtime
RUN npm install -g @openai/codex @google/gemini-cli

# MCP servers that wrap the CLIs (uses CLI's existing auth)
RUN npm install -g codex-mcp-server gemini-mcp

# Playwright MCP for browser automation (allows Claude to control a browser)
# Let Playwright download its own Chromium binary with --with-deps to install system libs
# Note: Ubuntu 24.04's chromium-browser is just a Snap wrapper that doesn't work in Docker
RUN npm install -g @playwright/mcp@latest \
    && npx playwright install --with-deps chromium

# External service MCP servers (read-only access to dev tools & communication)
# Token-based: Slack, Notion, GitHub, Linear (credentials passed as env vars at runtime)
# OAuth-based: Google Calendar, Gmail, Drive (credentials mounted from host at runtime)
RUN npm install -g \
    slack-mcp-server \
    @notionhq/notion-mcp-server \
    @tacticlaunch/mcp-linear \
    @cocal/google-calendar-mcp \
    @shinzolabs/gmail-mcp \
    @modelcontextprotocol/server-gdrive

# GitHub MCP server (official Go binary from GitHub's Docker image)
COPY --from=ghcr.io/github/github-mcp-server:latest /github-mcp-server /usr/local/bin/github-mcp-server

# Google OAuth credentials directory (mounted at runtime if available)
RUN mkdir -p /home/sandbox/.google-mcp && chmod 777 /home/sandbox/.google-mcp

# Claude is installed at /root/.local/bin; also add $HOME/.local/bin to silence doctor warnings
ENV PATH="/home/sandbox/.local/bin:/root/.local/bin:$PATH"

# Create a home directory that will be used at runtime
# The actual UID will be set via --user at runtime, but we need the directory to exist
RUN mkdir -p /home/sandbox && chmod 777 /home/sandbox

# Bake in Claude Code settings with bypass permissions
# This ensures sandbox always has correct permissions regardless of project settings
# Note: The volume mount at runtime hides these, so claude-sandbox script also ensures
# settings.json exists in the mounted auth directory
RUN mkdir -p /home/sandbox/.claude && chmod 777 /home/sandbox/.claude
COPY <<'SETTINGS' /home/sandbox/.claude/settings.json
{
  "permissions": {
    "allow": [],
    "deny": [],
    "defaultMode": "bypassPermissions"
  }
}
SETTINGS
RUN chmod 666 /home/sandbox/.claude/settings.json

# Stable machine-id so Claude auth persists across container runs
RUN echo "claude-sandbox-stable-machine-id" > /etc/machine-id

ENV HOME=/home/sandbox

WORKDIR /workspace

# Git config (global config will be in /home/sandbox at runtime)
RUN git config --system init.defaultBranch main \
    && git config --system --add safe.directory /workspace

# Block dangerous git commands - user should review all changes on host
# Move original to /usr/libexec (never in PATH) to avoid git-* subcommand discovery
# SANDBOX_NO_COMMIT env var controls whether commits are blocked (set at runtime)
RUN mkdir -p /usr/libexec/sandbox \
    && mv /usr/bin/git /usr/libexec/sandbox/git \
    && cat > /usr/bin/git <<'GITSCRIPT'
#!/bin/bash
case "$1" in
  commit)
    if [[ -n "$SANDBOX_NO_COMMIT" ]]; then
      echo "git commit is disabled in sandbox - use: git-draft-commit \"your message\""
      exit 1
    fi
    exec /usr/libexec/sandbox/git "$@"
    ;;
  push|stash|reset|clean|rebase)
    echo "git $1 is disabled in sandbox - review and manage on host"
    exit 1
    ;;
  *)
    exec /usr/libexec/sandbox/git "$@"
    ;;
esac
GITSCRIPT
RUN chmod +x /usr/bin/git

# Draft commit helper - for use when commits are disabled
RUN printf '#!/bin/bash\necho "$*" > /workspace/.commit-msg\necho "Commit message saved to .commit-msg"\necho "On host run: git commit -F .commit-msg"\n' > /usr/local/bin/git-draft-commit \
    && chmod +x /usr/local/bin/git-draft-commit

CMD ["claude"]
