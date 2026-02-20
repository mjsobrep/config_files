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

# Install Node.js 20.x (system Node for global packages and MCP servers).
# Additional versions (20, 22, 24) are available via nvm — see below.
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN corepack enable && corepack prepare yarn@stable --activate

# Install GitHub CLI (for reading PR comments, issues, etc.)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

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

# AI tool CLIs for MCP integration (Codex, Gemini)
# Credentials are mounted read-only from host at runtime
RUN npm install -g @openai/codex @google/gemini-cli

# MCP servers that wrap the CLIs (uses CLI's existing auth)
RUN npm install -g codex-mcp-server gemini-mcp

# Pylon MCP server for customer support platform (read-only via deny list)
# Note: Package specifies engines >=24 but compiled JS runs fine on Node 20.
# We use --ignore-engines to bypass the check since we only run dist/*.js.
RUN npm install -g pylon-mcp@1.1.1 --ignore-engines

# Playwright MCP for browser automation (allows Claude to control a browser)
# Let Playwright download its own Chromium binary with --with-deps to install system libs
# Note: Ubuntu 24.04's chromium-browser is just a Snap wrapper that doesn't work in Docker
RUN npm install -g @playwright/mcp@latest \
    && npx playwright install --with-deps chromium

# Google Workspace MCP server (read-only mode, community maintained)
# Uses --read-only flag to request only *.readonly OAuth scopes
RUN pip3 install --break-system-packages workspace-mcp==1.11.1

# Proxy support for egress filtering (global-agent patches Node.js http/https).
# This is a USABILITY feature, not the security boundary. The Docker --internal
# network is the real enforcement -- even without global-agent, the sandbox cannot
# reach the internet. global-agent just makes Node.js tools work through the proxy.
# When GLOBAL_AGENT_HTTP_PROXY / GLOBAL_AGENT_HTTPS_PROXY env vars are set,
# all Node.js HTTP/HTTPS traffic is routed through the proxy.
# When no proxy env vars are set (--no-egress-filter), global-agent is a no-op.
# IMPORTANT: v4.x ships TypeScript source without compiled dist/ — DO NOT UPGRADE
# past 3.0.0 unless you verify the package includes dist/*.js files.
# Pinned version for supply chain safety. Audit before upgrading.
RUN npm install -g global-agent@3.0.0

# Language server binaries for LSP plugins (real-time type checking on every edit)
RUN npm install -g typescript-language-server typescript pyright
RUN rustup component add rust-analyzer

# Install nvm and multiple Node.js LTS versions for project-level use.
# System Node 20 (NodeSource, /usr/bin/node) remains for MCP servers and global packages.
# Claude can switch versions with: nvm use 20 | nvm use 22 | nvm use 24
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p "$NVM_DIR" \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install 20 \
    && nvm install 22 \
    && nvm install 24 \
    && nvm alias default 24 \
    && chmod -R 755 "$NVM_DIR"

# Source nvm in all shells so Claude can use `nvm use <version>`
# /etc/profile.d/ covers login shells; /etc/bash.bashrc covers interactive shells
RUN printf '#!/bin/sh\nexport NVM_DIR=/usr/local/nvm\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\n' \
        > /etc/profile.d/nvm.sh \
    && chmod +x /etc/profile.d/nvm.sh \
    && printf '\n# nvm\nexport NVM_DIR=/usr/local/nvm\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\n' \
        >> /etc/bash.bashrc

# Create a home directory that will be used at runtime
# The actual UID will be set via --user at runtime, but we need the directory to exist
RUN mkdir -p /home/sandbox && chmod 777 /home/sandbox

# Bake in Claude Code settings with bypass permissions and read-only deny list
# This ensures sandbox always has correct permissions regardless of project settings
# Note: The volume mount at runtime hides these, so claude-sandbox script also ensures
# settings.json exists in the mounted auth directory
# Deny list last audited: 2026-02-19. Re-audit write tools after plugin updates.
RUN mkdir -p /home/sandbox/.claude && chmod 777 /home/sandbox/.claude
COPY <<'SETTINGS' /home/sandbox/.claude/settings.json
{
  "permissions": {
    "allow": [],
    "deny": [
      "mcp__claude_ai_Slack__slack_send_message",
      "mcp__claude_ai_Slack__slack_send_message_draft",
      "mcp__claude_ai_Slack__slack_schedule_message",
      "mcp__claude_ai_Slack__slack_create_canvas",
      "mcp__claude_ai_Linear__create_attachment",
      "mcp__claude_ai_Linear__create_comment",
      "mcp__claude_ai_Linear__create_document",
      "mcp__claude_ai_Linear__create_initiative",
      "mcp__claude_ai_Linear__create_issue",
      "mcp__claude_ai_Linear__create_issue_label",
      "mcp__claude_ai_Linear__create_milestone",
      "mcp__claude_ai_Linear__create_project",
      "mcp__claude_ai_Linear__delete_attachment",
      "mcp__claude_ai_Linear__delete_status_update",
      "mcp__claude_ai_Linear__save_status_update",
      "mcp__claude_ai_Linear__update_document",
      "mcp__claude_ai_Linear__update_initiative",
      "mcp__claude_ai_Linear__update_issue",
      "mcp__claude_ai_Linear__update_milestone",
      "mcp__claude_ai_Linear__update_project",
      "mcp__claude_ai_Notion__notion-create-comment",
      "mcp__claude_ai_Notion__notion-create-database",
      "mcp__claude_ai_Notion__notion-create-pages",
      "mcp__claude_ai_Notion__notion-duplicate-page",
      "mcp__claude_ai_Notion__notion-move-pages",
      "mcp__claude_ai_Notion__notion-update-data-source",
      "mcp__claude_ai_Notion__notion-update-page",
      "mcp__pylon__pylon_create_account",
      "mcp__pylon__pylon_update_account",
      "mcp__pylon__pylon_delete_account",
      "mcp__pylon__pylon_create_contact",
      "mcp__pylon__pylon_update_contact",
      "mcp__pylon__pylon_delete_contact",
      "mcp__pylon__pylon_create_issue",
      "mcp__pylon__pylon_update_issue",
      "mcp__pylon__pylon_delete_issue",
      "mcp__pylon__pylon_snooze_issue",
      "mcp__pylon__pylon_update_issue_followers",
      "mcp__pylon__pylon_redact_message",
      "mcp__pylon__pylon_create_tag",
      "mcp__pylon__pylon_update_tag",
      "mcp__pylon__pylon_delete_tag",
      "mcp__pylon__pylon_create_team",
      "mcp__pylon__pylon_update_team"
    ],
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

# Network audit script - verifies egress filtering is working correctly
COPY network-audit.sh /usr/local/bin/network-audit
RUN chmod +x /usr/local/bin/network-audit

# Draft commit helper - for use when commits are disabled
RUN printf '#!/bin/bash\necho "$*" > /workspace/.commit-msg\necho "Commit message saved to .commit-msg"\necho "On host run: git commit -F .commit-msg"\n' > /usr/local/bin/git-draft-commit \
    && chmod +x /usr/local/bin/git-draft-commit

# Plugin entrypoint: installs official plugins on first run
# Plugins persist in ~/.claude/plugins/ (mounted from auth dir)
# Bump PLUGIN_SETUP_VERSION to trigger re-install after adding new plugins
COPY <<'ENTRYPOINT' /usr/local/bin/claude-entrypoint
#!/bin/bash
PLUGIN_SETUP_VERSION="v3"

if [ ! -f "$HOME/.claude/.plugins-setup-$PLUGIN_SETUP_VERSION" ]; then
    echo "Installing Claude Code plugins (first run only)..."

    # External service integrations (OAuth-based, auth via: claude-sandbox --auth)
    claude plugin install slack@claude-plugins-official --scope user 2>&1 || true
    claude plugin install linear@claude-plugins-official --scope user 2>&1 || true

    # Language server integration (real-time type errors on every edit)
    claude plugin install typescript-lsp@claude-plugins-official --scope user 2>&1 || true
    claude plugin install pyright-lsp@claude-plugins-official --scope user 2>&1 || true
    claude plugin install rust-analyzer-lsp@claude-plugins-official --scope user 2>&1 || true

    # Code quality and review
    claude plugin install code-review@claude-plugins-official --scope user 2>&1 || true
    claude plugin install security-guidance@claude-plugins-official --scope user 2>&1 || true

    # Development workflows
    claude plugin install commit-commands@claude-plugins-official --scope user 2>&1 || true
    claude plugin install context7@claude-plugins-official --scope user 2>&1 || true

    touch "$HOME/.claude/.plugins-setup-$PLUGIN_SETUP_VERSION"
    echo "Plugin setup complete."
fi

exec "$@"
ENTRYPOINT
RUN chmod +x /usr/local/bin/claude-entrypoint

# --- Claude Code install (LAST so cachebust only affects this layer) ---
# Install Claude Code and copy to /usr/local/bin for non-root access
# (avoids conflict with /workspace/claude/ directory when cwd is /workspace)
ARG CLAUDE_CACHEBUST=1
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && cp "$HOME/.local/bin/claude" /usr/local/bin/claude \
    && chmod +x /usr/local/bin/claude

# Proxy support: NODE_PATH lets --require find globally installed global-agent.
# Set after all build-time npm installs to avoid breaking them during the build.
# Path must match `npm root -g` output (Ubuntu 24.04 / Node 20 = /usr/lib/node_modules).
ENV NODE_PATH=/usr/lib/node_modules
ENV NODE_OPTIONS="--require global-agent/bootstrap"

ENTRYPOINT ["claude-entrypoint"]
CMD ["claude"]
